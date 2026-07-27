#!/bin/bash
set -euo pipefail

expected_uid=$(id -u)
runtime_dir=${XDG_RUNTIME_DIR:-"/run/user/$expected_uid"}
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
config_file=$config_home/remote-desktop-mode.conf

if [ -r "$config_file" ]; then
  # This is a user-owned shell environment file used by both switch and unit.
  # shellcheck disable=SC1090
  . "$config_file"
fi

vnc_unit=x11vnc-desktop.service
rdp_unit=gnome-remote-desktop.service
bootstrap_port=${GDM_VNC_PORT:-5902}
vnc_port=${X11VNC_DESKTOP_PORT:-5903}
rdp_port=${GNOME_RDP_PORT:-3389}

export XDG_RUNTIME_DIR=$runtime_dir
export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-"unix:path=$runtime_dir/bus"}

if [ ! -S "$runtime_dir/bus" ]; then
  printf 'remote-desktop-mode: the systemd user manager is unavailable at %s\n' "$runtime_dir/bus" >&2
  exit 1
fi

exec 9>"$runtime_dir/remote-desktop-mode.lock"
flock -x 9

port_is_listening()
{
  local port=$1
  ss -H -ltn "sport = :$port" | rg -q .
}

wait_for_port()
{
  local port=$1 expected=$2 attempts=$3 attempt observed

  for ((attempt = 1; attempt <= attempts; attempt++)); do
    if port_is_listening "$port"; then
      observed=on
    else
      observed=off
    fi
    [ "$observed" = "$expected" ] && return 0
    sleep 0.1
  done
  return 1
}

active_desktop_is_ours()
{
  local session session_class session_type session_uid

  session=$(loginctl show-seat seat0 --property=ActiveSession --value 2>/dev/null)
  [ -n "$session" ] || return 1
  session_class=$(loginctl show-session "$session" --property=Class --value 2>/dev/null)
  [ "$session_class" = "user" ] || return 1
  session_type=$(loginctl show-session "$session" --property=Type --value 2>/dev/null)
  [ "$session_type" = "x11" ] || return 1
  session_uid=$(loginctl show-session "$session" --property=User --value 2>/dev/null)
  [ "$session_uid" = "$expected_uid" ]
}

unit_enabled()
{
  systemctl --user is-enabled --quiet "$1" 2>/dev/null
}

unit_state()
{
  systemctl --user is-active "$1" 2>/dev/null || true
}

port_state()
{
  if port_is_listening "$1"; then
    printf 'listening'
  else
    printf 'closed'
  fi
}

show_status()
{
  local vnc_enabled=no rdp_enabled=no mode active_session active_name active_class

  unit_enabled "$vnc_unit" && vnc_enabled=yes
  unit_enabled "$rdp_unit" && rdp_enabled=yes
  if [ "$vnc_enabled:$rdp_enabled" = "yes:no" ]; then
    mode=vnc
  elif [ "$vnc_enabled:$rdp_enabled" = "no:yes" ]; then
    mode=rdp
  elif [ "$vnc_enabled:$rdp_enabled" = "yes:yes" ]; then
    mode=conflict
  else
    mode=disabled
  fi

  active_session=$(loginctl show-seat seat0 --property=ActiveSession --value 2>/dev/null || true)
  active_name=$(loginctl show-session "$active_session" --property=Name --value 2>/dev/null || true)
  active_class=$(loginctl show-session "$active_session" --property=Class --value 2>/dev/null || true)

  printf 'configured mode: %s\n' "$mode"
  printf 'active seat: session=%s name=%s class=%s\n' \
    "${active_session:-none}" "${active_name:-none}" "${active_class:-none}"
  printf 'desktop VNC: enabled=%s service=%s port-%s=%s\n' \
    "$vnc_enabled" "$(unit_state "$vnc_unit")" "$vnc_port" "$(port_state "$vnc_port")"
  printf 'GNOME RDP: enabled=%s service=%s port-%s=%s\n' \
    "$rdp_enabled" "$(unit_state "$rdp_unit")" "$rdp_port" "$(port_state "$rdp_port")"
  printf 'GDM bootstrap VNC: port-%s=%s\n' \
    "$bootstrap_port" "$(port_state "$bootstrap_port")"
}

switch_to_vnc()
{
  systemctl --user disable --now "$rdp_unit"
  if ! wait_for_port "$rdp_port" off 50; then
    printf 'remote-desktop-mode: RDP port %s did not close\n' "$rdp_port" >&2
    exit 1
  fi

  systemctl --user enable --now "$vnc_unit"
  if active_desktop_is_ours; then
    if ! wait_for_port "$vnc_port" on 200; then
      printf 'remote-desktop-mode: desktop VNC did not become ready on port %s\n' "$vnc_port" >&2
      systemctl --user --no-pager --full status "$vnc_unit" >&2 || true
      exit 1
    fi
  else
    printf 'Desktop VNC is armed and will start when this user owns the active X11 GNOME seat.\n'
  fi
  show_status
}

switch_to_rdp()
{
  systemctl --user disable --now "$vnc_unit"
  if ! wait_for_port "$vnc_port" off 50; then
    printf 'remote-desktop-mode: desktop VNC port %s did not close\n' "$vnc_port" >&2
    exit 1
  fi

  systemctl --user enable --now "$rdp_unit"
  if active_desktop_is_ours; then
    if ! wait_for_port "$rdp_port" on 100; then
      printf 'remote-desktop-mode: GNOME RDP did not become ready on port %s\n' "$rdp_port" >&2
      systemctl --user --no-pager --full status "$rdp_unit" >&2 || true
      exit 1
    fi
  else
    printf 'GNOME RDP is armed and will become usable after this user logs in graphically.\n'
  fi
  show_status
}

case ${1:-status} in
  vnc)
    switch_to_vnc
    ;;
  rdp)
    switch_to_rdp
    ;;
  status)
    show_status
    ;;
  help|-h|--help)
    printf 'Usage: remote-desktop-mode {vnc|rdp|status}\n'
    ;;
  *)
    printf 'Usage: remote-desktop-mode {vnc|rdp|status}\n' >&2
    exit 2
    ;;
esac
