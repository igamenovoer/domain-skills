#!/bin/bash
set -uo pipefail

config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
config_file=$config_home/remote-desktop-mode.conf
if [ -r "$config_file" ]; then
  # This is a user-owned shell environment file.
  # shellcheck disable=SC1090
  . "$config_file"
fi

desktop_port=${X11VNC_DESKTOP_PORT:-5903}
password_file=${X11VNC_DESKTOP_PASSWORD_FILE:-"$HOME/.config/x11vnc/passwd"}
localhost_only=${X11VNC_DESKTOP_LOCALHOST:-yes}
state_dir=${XDG_STATE_HOME:-"$HOME/.local/state"}/x11vnc
log_file=$state_dir/desktop.log
expected_uid=$(id -u)

child_pid=
child_key=
candidate_key=
candidate_polls=0
missing_polls=0
required_stability_polls=8
required_missing_polls=5
listener_args=()

log()
{
  printf '%s\n' "x11vnc-hybrid-desktop-loop: $*"
}

stop_child()
{
  local attempt

  [ -n "$child_pid" ] || return 0
  if kill -0 "$child_pid" 2>/dev/null; then
    kill "$child_pid" 2>/dev/null || true
    for attempt in {1..20}; do
      kill -0 "$child_pid" 2>/dev/null || break
      sleep 0.1
    done
    if kill -0 "$child_pid" 2>/dev/null; then
      log "x11vnc pid=$child_pid did not stop after SIGTERM; sending SIGKILL"
      kill -KILL "$child_pid" 2>/dev/null || true
    fi
  fi
  wait "$child_pid" 2>/dev/null || true
  child_pid=
  child_key=
}

process_has_argument()
{
  local pid=$1 expected=$2 argument

  while IFS= read -r -d '' argument; do
    [ "$argument" = "$expected" ] && return 0
  done <"/proc/$pid/cmdline"
  return 1
}

auth_for_pid()
{
  local pid=$1 previous= argument

  while IFS= read -r -d '' argument; do
    if [ "$previous" = "-auth" ]; then
      printf '%s\n' "$argument"
      return 0
    fi
    previous=$argument
  done <"/proc/$pid/cmdline"
  return 1
}

display_for_pid()
{
  local pid=$1 fd target inode path
  local -A socket_inodes=()

  for fd in /proc/"$pid"/fd/*; do
    target=$(readlink "$fd" 2>/dev/null) || continue
    case "$target" in
      socket:\[*\])
        inode=${target#socket:[}
        socket_inodes["${inode%]}"]=1
        ;;
    esac
  done

  while read -r inode path; do
    [ -n "${socket_inodes[$inode]+present}" ] || continue
    case "$path" in
      /tmp/.X11-unix/X[0-9]*)
        printf ':%s\n' "${path##*/X}"
        return 0
        ;;
    esac
  done < <(awk 'NR > 1 && NF >= 8 { print $7, $8 }' /proc/net/unix)
  return 1
}

gnome_shell_is_ready()
{
  systemctl --user is-active --quiet org.gnome.Shell@x11.service
}

resolve_active_user_target()
{
  local session session_class session_type session_active tty vt uid
  local pid proc_uid auth display

  session=$(loginctl show-seat seat0 --property=ActiveSession --value 2>/dev/null)
  [ -n "$session" ] || return 1
  session_class=$(loginctl show-session "$session" --property=Class --value 2>/dev/null)
  [ "$session_class" = "user" ] || return 1
  session_type=$(loginctl show-session "$session" --property=Type --value 2>/dev/null)
  [ "$session_type" = "x11" ] || return 1
  session_active=$(loginctl show-session "$session" --property=Active --value 2>/dev/null)
  [ "$session_active" = "yes" ] || return 1
  uid=$(loginctl show-session "$session" --property=User --value 2>/dev/null)
  [ "$uid" = "$expected_uid" ] || return 1
  tty=$(loginctl show-session "$session" --property=TTY --value 2>/dev/null)
  case "$tty" in
    tty[0-9]*) vt=${tty#tty} ;;
    *) return 1 ;;
  esac
  gnome_shell_is_ready || return 1

  while IFS= read -r pid; do
    proc_uid=$(stat -c %u "/proc/$pid" 2>/dev/null) || continue
    [ "$proc_uid" = "$uid" ] || continue
    process_has_argument "$pid" "vt$vt" || continue
    auth=$(auth_for_pid "$pid") || continue
    [ -r "$auth" ] || continue
    display=$(display_for_pid "$pid") || continue
    env DISPLAY="$display" XAUTHORITY="$auth" xdpyinfo >/dev/null 2>&1 || continue

    target_session=$session
    target_pid=$pid
    target_display=$display
    target_auth=$auth
    return 0
  done < <(pgrep -x Xorg || true)
  return 1
}

target_is_still_active_user()
{
  local active_session active_class active_type active_uid

  active_session=$(loginctl show-seat seat0 --property=ActiveSession --value 2>/dev/null)
  [ "$active_session" = "$target_session" ] || return 1
  active_class=$(loginctl show-session "$active_session" --property=Class --value 2>/dev/null)
  [ "$active_class" = "user" ] || return 1
  active_type=$(loginctl show-session "$active_session" --property=Type --value 2>/dev/null)
  [ "$active_type" = "x11" ] || return 1
  active_uid=$(loginctl show-session "$active_session" --property=User --value 2>/dev/null)
  [ "$active_uid" = "$expected_uid" ] || return 1
  gnome_shell_is_ready
}

shutdown()
{
  trap - TERM INT
  stop_child
  exit 0
}

trap shutdown TERM INT

install -d -m 0700 "$state_dir"
if ! [[ "$desktop_port" =~ ^[0-9]+$ ]] ||
   [ "$desktop_port" -lt 1 ] ||
   [ "$desktop_port" -gt 65535 ]; then
  log "invalid X11VNC_DESKTOP_PORT: $desktop_port"
  exit 1
fi
if [ ! -r "$password_file" ]; then
  log "password file is not readable: $password_file"
  exit 1
fi
case "$localhost_only" in
  yes) listener_args=(-localhost) ;;
  no) listener_args=() ;;
  *)
    log "X11VNC_DESKTOP_LOCALHOST must be yes or no"
    exit 1
    ;;
esac

while true; do
  if [ -n "$child_pid" ] && ! kill -0 "$child_pid" 2>/dev/null; then
    wait "$child_pid" 2>/dev/null || true
    child_pid=
    child_key=
  fi

  if resolve_active_user_target; then
    missing_polls=0
    target_key="$target_session:$target_pid:$target_display:$target_auth"
    if [ "$target_key" = "$child_key" ]; then
      candidate_key=
      candidate_polls=0
    elif [ "$target_key" != "$candidate_key" ]; then
      candidate_key=$target_key
      candidate_polls=1
    elif [ "$candidate_polls" -lt "$required_stability_polls" ]; then
      candidate_polls=$((candidate_polls + 1))
    elif target_is_still_active_user; then
      stop_child
      log "attaching active GNOME user session=$target_session pid=$target_pid display=$target_display port=$desktop_port"
      /usr/bin/x11vnc -display "$target_display" -auth "$target_auth" \
        -rfbauth "$password_file" -rfbport "$desktop_port" \
        -noshm -noxdamage -noxfixes -noxrecord -nowf -noscr \
        -forever -shared -repeat -xkb -nolookup \
        "${listener_args[@]}" -o "$log_file" &
      child_pid=$!
      child_key=$target_key
      candidate_key=
      candidate_polls=0
    else
      candidate_key=
      candidate_polls=0
    fi
  else
    candidate_key=
    candidate_polls=0
    if [ -n "$child_pid" ]; then
      missing_polls=$((missing_polls + 1))
      if [ "$missing_polls" -ge "$required_missing_polls" ]; then
        log "the GNOME user session is no longer a stable active target; stopping desktop VNC"
        stop_child
        missing_polls=0
      fi
    else
      missing_polls=0
    fi
  fi

  sleep 1
done
