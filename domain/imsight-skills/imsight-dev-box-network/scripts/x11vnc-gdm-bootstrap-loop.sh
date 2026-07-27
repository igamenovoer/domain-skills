#!/bin/bash
set -uo pipefail

config_file=${X11VNC_GDM_CONFIG:-/etc/default/x11vnc-gdm-bootstrap}
if [ -r "$config_file" ]; then
  # The installer must keep this shell environment file root-owned.
  # shellcheck disable=SC1090
  . "$config_file"
fi

bootstrap_port=${GDM_VNC_PORT:-5902}
password_file=${GDM_VNC_PASSWORD_FILE:-/etc/x11vnc-gdm.pass}
log_file=${GDM_VNC_LOG_FILE:-/var/log/x11vnc-gdm.log}
localhost_only=${GDM_VNC_LOCALHOST:-yes}

child_pid=
child_key=
candidate_key=
candidate_polls=0
required_stability_polls=2
listener_args=()

log()
{
  printf '%s\n' "x11vnc-gdm-bootstrap-loop: $*"
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

resolve_active_greeter_target()
{
  local session session_class session_type tty vt uid
  local pid proc_uid auth display

  session=$(loginctl show-seat seat0 --property=ActiveSession --value 2>/dev/null)
  [ -n "$session" ] || return 1
  session_class=$(loginctl show-session "$session" --property=Class --value 2>/dev/null)
  [ "$session_class" = "greeter" ] || return 1
  session_type=$(loginctl show-session "$session" --property=Type --value 2>/dev/null)
  [ "$session_type" = "x11" ] || return 1
  tty=$(loginctl show-session "$session" --property=TTY --value 2>/dev/null)
  uid=$(loginctl show-session "$session" --property=User --value 2>/dev/null)
  case "$tty" in
    tty[0-9]*) vt=${tty#tty} ;;
    *) return 1 ;;
  esac
  [ -n "$uid" ] || return 1

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

target_is_still_active_greeter()
{
  local active_session active_class active_type

  active_session=$(loginctl show-seat seat0 --property=ActiveSession --value 2>/dev/null)
  [ "$active_session" = "$target_session" ] || return 1
  active_class=$(loginctl show-session "$active_session" --property=Class --value 2>/dev/null)
  [ "$active_class" = "greeter" ] || return 1
  active_type=$(loginctl show-session "$active_session" --property=Type --value 2>/dev/null)
  [ "$active_type" = "x11" ]
}

shutdown()
{
  trap - TERM INT
  stop_child
  exit 0
}

trap shutdown TERM INT

if ! [[ "$bootstrap_port" =~ ^[0-9]+$ ]] ||
   [ "$bootstrap_port" -lt 1 ] ||
   [ "$bootstrap_port" -gt 65535 ]; then
  log "invalid GDM_VNC_PORT: $bootstrap_port"
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
    log "GDM_VNC_LOCALHOST must be yes or no"
    exit 1
    ;;
esac

while true; do
  if [ -n "$child_pid" ] && ! kill -0 "$child_pid" 2>/dev/null; then
    wait "$child_pid" 2>/dev/null || true
    child_pid=
    child_key=
  fi

  if resolve_active_greeter_target; then
    target_key="$target_session:$target_pid:$target_display:$target_auth"
    if [ "$target_key" = "$child_key" ]; then
      candidate_key=
      candidate_polls=0
    elif [ "$target_key" != "$candidate_key" ]; then
      candidate_key=$target_key
      candidate_polls=1
    elif [ "$candidate_polls" -lt "$required_stability_polls" ]; then
      candidate_polls=$((candidate_polls + 1))
    elif target_is_still_active_greeter; then
      stop_child
      log "attaching active GDM greeter session=$target_session pid=$target_pid display=$target_display port=$bootstrap_port"
      /usr/bin/x11vnc -display "$target_display" -auth "$target_auth" \
        -rfbauth "$password_file" -rfbport "$bootstrap_port" \
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
      log "active seat is not GDM; stopping bootstrap VNC for the logged-in transport handoff"
    fi
    stop_child
  fi

  sleep 1
done
