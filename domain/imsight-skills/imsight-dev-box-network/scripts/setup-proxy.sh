#!/usr/bin/env bash
# Usage:
#   source ~/setup-proxy.sh
#
# Sets HTTP(S) proxy env vars to the first reachable proxy from ordered proxy
# candidate groups.
# Also sets no_proxy/NO_PROXY so local and private-network traffic bypasses
# the proxy.
#
# Proxy groups:
# - local: proxies running on this host, including host-side proxies reachable
#   from Docker containers.
# - remote: proxies running on remote/LAN servers, reached directly over
#   http/https/socks5 transport.
# - tunnel: remote proxies mapped to this host through SSH tunnels.
#
# Default group scan order:
#   local,remote,tunnel
#
# PROXY_MANUAL_CANDIDATE_LIST is tried before the group scan, regardless of
# the candidate type.
#
# Override group order with:
#   source ~/setup-proxy.sh --proxy-types local,tunnel,remote
#
# Explicit candidate override:
#   source ~/setup-proxy.sh --proxy-candidate-list "proxy1,proxy2"
#
# HTTPS behavior:
# - An https:// proxy candidate is preferred for HTTPS_PROXY/https_proxy.
# - If none is reachable, the selected HTTP/SOCKS proxy is also used for HTTPS
#   unless SETUP_PROXY_FORBID_HTTP_FOR_HTTPS is 1/true/yes/on.
#
# Candidate list env vars:
# - PROXY_MANUAL_CANDIDATE_LIST is tried first, before any proxy group.
# - PROXY_LOCAL_CANDIDATE_LIST
# - PROXY_REMOTE_CANDIDATE_LIST
# - PROXY_TUNNEL_CANDIDATE_LIST
#
# Candidate list format:
# - Comma-separated list of URLs or host[:port] entries.
# - Supported schemes: http://, https://, socks5:// (or no scheme -> http://).
# - Missing port -> assumed 7890.
#
# If no candidate lists are set, local probes default to 127.0.0.1:7890.
#
# no_proxy behavior:
# - SETUP_PROXY_NO_PROXY, when set, is merged with the built-in bypass list.
# - Existing no_proxy/NO_PROXY values are also preserved and merged.
# - Built-in bypasses cover localhost, loopback, Docker host aliases, and
#   common private address ranges.
#
# Docker behavior:
# - If no local candidate list is set and we detect we're running inside a
#   container, the local default probe list expands to:
#     - 127.0.0.1:7890
#     - host.docker.internal:7890
#     - <container default gateway IP>:7890 (parsed from /proc/net/route)
#
# Note: On many Linux Docker setups, host.docker.internal is NOT available by
# default. You can enable it per-container with:
#   docker run --add-host host.docker.internal:host-gateway ...
# If no candidate is reachable, leaves the current environment unchanged.

# If this script is executed (not sourced), instruct the user and exit.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cat >&2 <<'EOF'
Usage:
  source ~/setup-proxy.sh [--proxy-types local,remote,tunnel]
  source ~/setup-proxy.sh [--proxy-candidate-list "a:7890,b:7890"]

Behavior:
  - Picks the first reachable proxy from ordered proxy groups.
  - Default group order: local,remote,tunnel.
  - --proxy-types controls group scan order.
  - --proxy-candidate-list overrides grouped scanning.
  - Candidate env vars:
      PROXY_MANUAL_CANDIDATE_LIST
      PROXY_LOCAL_CANDIDATE_LIST
      PROXY_REMOTE_CANDIDATE_LIST
      PROXY_TUNNEL_CANDIDATE_LIST
  - PROXY_MANUAL_CANDIDATE_LIST is tried first, before any proxy group.
  - HTTPS_PROXY prefers an https:// proxy. If none is reachable, the selected
    HTTP/SOCKS proxy is also used for HTTPS unless
    SETUP_PROXY_FORBID_HTTP_FOR_HTTPS=1.
  - Sets no_proxy/NO_PROXY for localhost, loopback, Docker host aliases, and
    common private address ranges. Add extra entries with SETUP_PROXY_NO_PROXY.

Docker behavior:
  - If no candidate list is provided and the script detects it's running inside
    a container, the default probe list expands to include:
      - 127.0.0.1:7890
      - host.docker.internal:7890
      - <container default gateway IP>:7890
  - On many Linux Docker setups, host.docker.internal is NOT available by
    default; you can enable it per-container with:
      docker run --add-host host.docker.internal:host-gateway ...

Candidate format:
  - Comma-separated entries: URL or host[:port]
  - Supported schemes: http://, https://, socks5://
  - Missing scheme defaults to http://
  - Missing port defaults to 7890
EOF
  exit 2
fi

_default_proxy_port="7890"
_default_no_proxy="localhost,127.0.0.1,127.0.0.0/8,::1,0.0.0.0,host.docker.internal,.local,*.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"

_log() {
  echo "[setup-proxy] $*" >&2
}

_in_docker() {
  # Common indicators for Docker/containers.
  [[ -f "/.dockerenv" ]] && return 0
  [[ -r "/proc/1/cgroup" ]] && grep -qaE '(docker|containerd|kubepods)' /proc/1/cgroup && return 0
  return 1
}

_hex_le_to_ipv4() {
  # Convert an 8-hex-digit little-endian IPv4 (as in /proc/net/route) to dotted quad.
  local h="${1}"
  [[ "${#h}" -ne 8 ]] && return 1
  local b1="${h:6:2}" b2="${h:4:2}" b3="${h:2:2}" b4="${h:0:2}"
  printf '%d.%d.%d.%d' "$((16#${b1}))" "$((16#${b2}))" "$((16#${b3}))" "$((16#${b4}))"
}

_docker_default_gateway_ipv4() {
  # Best-effort: parse /proc/net/route for the default route gateway.
  [[ -r /proc/net/route ]] || return 1
  local line iface dest gw flags rest
  # Skip header
  while IFS=$'\t ' read -r iface dest gw flags rest; do
    [[ -z "${iface}" || "${iface}" == "Iface" ]] && continue
    [[ "${dest}" != "00000000" ]] && continue
    local ip
    ip="$(_hex_le_to_ipv4 "${gw}")" || continue
    [[ -n "${ip}" ]] || continue
    printf '%s' "${ip}"
    return 0
  done < /proc/net/route
  return 1
}

_proxy_candidate_list_arg=""
_proxy_types_arg=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --proxy-candidate-list)
      shift
      if [[ $# -lt 1 || -z "${1}" ]]; then
        echo "Missing value for --proxy-candidate-list" >&2
        return 2
      fi
      _proxy_candidate_list_arg="$1"
      shift
      ;;
    --proxy-candidate-list=*)
      _proxy_candidate_list_arg="${1#*=}"
      shift
      ;;
    --proxy-types)
      shift
      if [[ $# -lt 1 || -z "${1}" ]]; then
        echo "Missing value for --proxy-types" >&2
        return 2
      fi
      _proxy_types_arg="$1"
      shift
      ;;
    --proxy-types=*)
      _proxy_types_arg="${1#*=}"
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: source ~/setup-proxy.sh [--proxy-types local,remote,tunnel] [--proxy-candidate-list \"a:7890,b:7890\"]" >&2
      return 2
      ;;
  esac
done

_is_empty_or_unset() {
  [[ -z "${1-}" ]]
}

_normalize_candidate_list() {
  # Emits one normalized proxy URL per line.
  # Normalized form: http://host:port, https://host:port, or socks5://host:port
  local raw_source="${1}"
  local raw_list="${2}"
  [[ -z "${raw_list}" ]] && return 0
  _log "[INFO] Candidate source: ${raw_source}"
  _log "[INFO] Raw candidates: ${raw_list}"
  # Pure-bash normalization.
  local IFS=','
  local item
  local -A _seen
  for item in ${raw_list}; do
    item="${item#${item%%[![:space:]]*}}" # ltrim
    item="${item%${item##*[![:space:]]}}" # rtrim
    [[ -z "${item}" ]] && continue

    local scheme="http"
    local rest="${item}"
    if [[ "${item}" == *"://"* ]]; then
      scheme="${item%%://*}"
      rest="${item#*://}"
      scheme="${scheme,,}"
    fi
    [[ "${scheme}" != "http" && "${scheme}" != "https" && "${scheme}" != "socks5" ]] && continue

    # Strip path/query/fragment.
    rest="${rest%%/*}"
    rest="${rest%%\?*}"
    rest="${rest%%#*}"

    # Strip userinfo.
    rest="${rest#*@}"

    rest="${rest#${rest%%[![:space:]]*}}" # ltrim
    rest="${rest%${rest##*[![:space:]]}}" # rtrim
    [[ -z "${rest}" ]] && continue

    local host=""
    local port="${_default_proxy_port}"
    # Support bracketed IPv6: [::1]:7890 (optional port)
    if [[ "${rest}" == \[*\]* ]]; then
      # rest like: [host] or [host]:port
      host="${rest#\[}"
      host="${host%%\]*}"
      if [[ "${rest}" == \[*\]:* ]]; then
        local maybe_port="${rest##*:}"
        [[ "${maybe_port}" =~ ^[0-9]+$ ]] && port="${maybe_port}"
      fi
      [[ -z "${host}" ]] && continue
      local normalized="${scheme}://[${host}]:${port}"
      if [[ -z "${_seen[${normalized}]+x}" ]]; then
        _seen["${normalized}"]=1
        printf '%s\n' "${normalized}"
      fi
      continue
    fi

    host="${rest}"
    if [[ "${rest}" == *":"* ]]; then
      local maybe_port="${rest##*:}"
      local maybe_host="${rest%:*}"
      if [[ -n "${maybe_host}" && "${maybe_port}" =~ ^[0-9]+$ ]]; then
        host="${maybe_host}"
        port="${maybe_port}"
      fi
    fi
    [[ -z "${host}" ]] && continue
    local normalized="${scheme}://${host}:${port}"
    if [[ -z "${_seen[${normalized}]+x}" ]]; then
      _seen["${normalized}"]=1
      printf '%s\n' "${normalized}"
    fi
  done
}

_default_local_proxy_candidates() {
  local raw_list="127.0.0.1:${_default_proxy_port}"
  if _in_docker; then
    raw_list+=",host.docker.internal:${_default_proxy_port}"
    local gw
    gw="$(_docker_default_gateway_ipv4 2>/dev/null || true)"
    if [[ -n "${gw}" ]]; then
      raw_list+="${raw_list:+,}${gw}:${_default_proxy_port}"
    fi
  fi
  printf '%s' "${raw_list}"
}

_group_specific_candidate_lists_are_set() {
  [[ -n "${PROXY_LOCAL_CANDIDATE_LIST-}" || \
     -n "${PROXY_REMOTE_CANDIDATE_LIST-}" || \
     -n "${PROXY_TUNNEL_CANDIDATE_LIST-}" ]]
}

_proxy_group_order() {
  local raw="${_proxy_types_arg:-local,remote,tunnel}"
  local IFS=','
  local item
  local -A seen
  for item in ${raw}; do
    item="${item#${item%%[![:space:]]*}}"
    item="${item%${item##*[![:space:]]}}"
    item="${item,,}"
    case "${item}" in
      local|local-proxy|local-proxies) item="local" ;;
      remote|remote-proxy|remote-proxies) item="remote" ;;
      tunnel|tunnel-proxy|tunnel-proxies|remote-tunnel|remote-tunnel-proxy|remote-tunnel-proxies) item="tunnel" ;;
      "") continue ;;
      *)
        echo "Unknown proxy type: ${item}" >&2
        echo "Allowed proxy types: local,remote,tunnel" >&2
        return 2
        ;;
    esac
    if [[ -z "${seen[${item}]+x}" ]]; then
      seen["${item}"]=1
      printf '%s\n' "${item}"
    fi
  done
}

_emit_group_candidates() {
  local group="${1}"
  local raw_list=""
  local raw_source=""
  case "${group}" in
    local)
      if [[ -n "${PROXY_LOCAL_CANDIDATE_LIST-}" ]]; then
        raw_list="${PROXY_LOCAL_CANDIDATE_LIST}"
        raw_source="PROXY_LOCAL_CANDIDATE_LIST"
      else
        raw_list="$(_default_local_proxy_candidates)"
        raw_source="default local"
      fi
      ;;
    remote)
      if [[ -n "${PROXY_REMOTE_CANDIDATE_LIST-}" ]]; then
        raw_list="${PROXY_REMOTE_CANDIDATE_LIST}"
        raw_source="PROXY_REMOTE_CANDIDATE_LIST"
      fi
      ;;
    tunnel)
      if [[ -n "${PROXY_TUNNEL_CANDIDATE_LIST-}" ]]; then
        raw_list="${PROXY_TUNNEL_CANDIDATE_LIST}"
        raw_source="PROXY_TUNNEL_CANDIDATE_LIST"
      fi
      ;;
  esac
  if [[ -z "${raw_list}" ]]; then
    _log "[INFO] Candidate source: ${group} (empty)"
    return 0
  fi
  _normalize_candidate_list "${raw_source}" "${raw_list}"
}

_normalize_candidates() {
  if ! _is_empty_or_unset "${_proxy_candidate_list_arg-}"; then
    _normalize_candidate_list "--proxy-candidate-list" "${_proxy_candidate_list_arg}"
    return 0
  fi

  if ! _is_empty_or_unset "${PROXY_MANUAL_CANDIDATE_LIST-}"; then
    _normalize_candidate_list "PROXY_MANUAL_CANDIDATE_LIST" "${PROXY_MANUAL_CANDIDATE_LIST}"
  fi

  _log "[INFO] Proxy type order: ${_proxy_types_arg:-local,remote,tunnel}"
  local group
  while IFS= read -r group; do
    [[ -z "${group}" ]] && continue
    _emit_group_candidates "${group}"
  done < <(_proxy_group_order)
}

_extract_host_port() {
  # Input: normalized URL (http://host:port or socks5://host:port)
  # Output: host<space>port
  local url="${1}"
  local rest="${url#*://}"
  local hostport="${rest%%/*}"
  if [[ "${hostport}" == \[*\]::* ]]; then
    # [::1]:7890
    local host="${hostport%%]*}"
    host="${host#[}"
    local port="${hostport##*:}"
    printf '%s %s\n' "${host}" "${port}"
    return 0
  fi
  local host="${hostport%:*}"
  local port="${hostport##*:}"
  printf '%s %s\n' "${host}" "${port}"
}

_candidate_scheme() {
  local url="${1}"
  printf '%s\n' "${url%%://*}"
}

# Return success (0) if we can open a TCP connection to host:port quickly.
_proxy_reachable_host_port() {
  local host="${1}"
  local port="${2}"

  # Fallback (requires bash with /dev/tcp support).
  if command -v timeout >/dev/null 2>&1; then
    timeout 2 bash -lc "cat < /dev/null > /dev/tcp/${host}/${port}" >/dev/null 2>&1
    return $?
  fi

  # Last-resort attempt without timeout.
  bash -lc "cat < /dev/null > /dev/tcp/${host}/${port}" >/dev/null 2>&1
}

_append_unique_csv() {
  local current="${1}"
  local additions="${2}"
  local IFS=','
  local item
  for item in ${additions}; do
    item="${item#${item%%[![:space:]]*}}" # ltrim
    item="${item%${item##*[![:space:]]}}" # rtrim
    [[ -z "${item}" ]] && continue
    if [[ ",${current}," != *",${item},"* ]]; then
      current+="${current:+,}${item}"
    fi
  done
  printf '%s' "${current}"
}

_resolved_no_proxy() {
  local value=""
  value="$(_append_unique_csv "${value}" "${no_proxy-}")"
  value="$(_append_unique_csv "${value}" "${NO_PROXY-}")"
  value="$(_append_unique_csv "${value}" "${SETUP_PROXY_NO_PROXY-}")"
  value="$(_append_unique_csv "${value}" "${_default_no_proxy}")"
  printf '%s' "${value}"
}

_http_for_https_forbidden() {
  case "${SETUP_PROXY_FORBID_HTTP_FOR_HTTPS-}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

_selected_proxy_url=""
_selected_https_proxy_url=""

if ! _proxy_group_order >/dev/null; then
  unset _proxy_candidate_list_arg _proxy_types_arg
  return 2
fi

_candidate_urls=()
while IFS= read -r candidate_url; do
  [[ -z "${candidate_url}" ]] && continue
  _candidate_urls+=("${candidate_url}")
done < <(_normalize_candidates)

for candidate_url in "${_candidate_urls[@]}"; do
  _log "[TRY] ${candidate_url}"
  read -r _host _port < <(_extract_host_port "${candidate_url}")
  if _proxy_reachable_host_port "${_host}" "${_port}"; then
    _log "[OK] ${candidate_url}"
    if [[ -z "${_selected_proxy_url}" ]]; then
      _selected_proxy_url="${candidate_url}"
    fi
    if [[ -z "${_selected_https_proxy_url}" && "$(_candidate_scheme "${candidate_url}")" == "https" ]]; then
      _selected_https_proxy_url="${candidate_url}"
    fi
    if [[ -n "${_selected_proxy_url}" && -n "${_selected_https_proxy_url}" ]]; then
      break
    fi
    continue
  fi
  _log "[FAILED] ${candidate_url}"
done

if [[ -z "${_selected_proxy_url}" ]]; then
  echo "No reachable proxy found; leaving environment unchanged." >&2
  unset _proxy_candidate_list_arg _proxy_types_arg _candidate_urls _selected_https_proxy_url
  return 0
fi

if [[ -z "${_selected_https_proxy_url}" ]]; then
  if _http_for_https_forbidden; then
    _log "[INFO] No https:// proxy found; HTTPS proxy fallback is disabled."
  else
    _selected_https_proxy_url="${_selected_proxy_url}"
    _log "[INFO] No https:// proxy found; using selected proxy for HTTPS."
  fi
fi

_log "[SELECTED] ${_selected_proxy_url}"
[[ -n "${_selected_https_proxy_url}" ]] && _log "[SELECTED HTTPS] ${_selected_https_proxy_url}"

# Set both lowercase and uppercase variants used by many tools.
export http_proxy="${_selected_proxy_url}"
export HTTP_PROXY="${_selected_proxy_url}"
if [[ -n "${_selected_https_proxy_url}" ]]; then
  export https_proxy="${_selected_https_proxy_url}"
  export HTTPS_PROXY="${_selected_https_proxy_url}"
else
  unset https_proxy HTTPS_PROXY
fi

# (Optional) some tools honor this as well.
export all_proxy="${_selected_proxy_url}"
export ALL_PROXY="${_selected_proxy_url}"

_selected_no_proxy="$(_resolved_no_proxy)"
export no_proxy="${_selected_no_proxy}"
export NO_PROXY="${_selected_no_proxy}"

echo "Proxy enabled: ${_selected_proxy_url}" >&2
if [[ -n "${_selected_https_proxy_url}" ]]; then
  echo "HTTPS proxy enabled: ${_selected_https_proxy_url}" >&2
else
  echo "HTTPS proxy disabled: no https:// proxy found and HTTP/SOCKS fallback is forbidden." >&2
fi
echo "Proxy bypass: ${_selected_no_proxy}" >&2

unset _proxy_candidate_list_arg _proxy_types_arg _candidate_urls _selected_no_proxy _selected_https_proxy_url
