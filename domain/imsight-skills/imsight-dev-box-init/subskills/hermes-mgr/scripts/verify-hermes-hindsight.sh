#!/usr/bin/env bash
set -uo pipefail

usage() {
  cat <<'EOF'
Usage: verify-hermes-hindsight.sh [options]

Options:
  --api-url URL       Hindsight API URL (default: http://127.0.0.1:18888)
  --ui-url URL        Hindsight UI URL (default: http://127.0.0.1:19999)
  --container NAME    Hindsight container (default: hermes-hindsight)
  --volume NAME       Persistent volume (default: hermes-hindsight-data)
  -h, --help          Show this help.
EOF
}

api_url='http://127.0.0.1:18888'
ui_url='http://127.0.0.1:19999'
container='hermes-hindsight'
volume='hermes-hindsight-data'

while [ "$#" -gt 0 ]; do
  case "$1" in
    --api-url)
      api_url="${2:?missing value for --api-url}"
      shift 2
      ;;
    --api-url=*)
      api_url="${1#*=}"
      shift
      ;;
    --ui-url)
      ui_url="${2:?missing value for --ui-url}"
      shift 2
      ;;
    --ui-url=*)
      ui_url="${1#*=}"
      shift
      ;;
    --container)
      container="${2:?missing value for --container}"
      shift 2
      ;;
    --container=*)
      container="${1#*=}"
      shift
      ;;
    --volume)
      volume="${2:?missing value for --volume}"
      shift 2
      ;;
    --volume=*)
      volume="${1#*=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

failures=0

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

for required in curl docker hermes python3 rg; do
  if command -v "$required" >/dev/null 2>&1; then
    pass "$required is available"
  else
    fail "$required is not available"
  fi
done

health_json="$(curl -fsS --max-time 20 "$api_url/health" 2>/dev/null || true)"
if [ -n "$health_json" ] && printf '%s' "$health_json" | python3 -c '
import json, sys
data = json.load(sys.stdin)
raise SystemExit(0 if data.get("status") == "healthy" and data.get("database") == "connected" else 1)
'; then
  pass "Hindsight health and database status"
else
  fail "Hindsight API is unhealthy at $api_url"
fi

if curl -fsS --max-time 20 -o /dev/null "$ui_url" 2>/dev/null; then
  pass "Hindsight UI responds at $ui_url"
else
  fail "Hindsight UI does not respond at $ui_url"
fi

container_json="$(docker inspect "$container" 2>/dev/null || true)"
if [ -n "$container_json" ]; then
  if printf '%s' "$container_json" | python3 -c '
import json, sys
item = json.load(sys.stdin)[0]
running = item["State"]["Running"] is True
restart = item["HostConfig"]["RestartPolicy"]["Name"] == "unless-stopped"
ports = item["NetworkSettings"]["Ports"]
loopback = all(
    bool(ports.get(key))
    and all(binding.get("HostIp") == "127.0.0.1" for binding in ports[key])
    for key in ("8888/tcp", "9999/tcp")
)
raise SystemExit(0 if running and restart and loopback else 1)
'; then
    pass "container is running with unless-stopped and loopback-only bindings"
  else
    fail "container state, restart policy, or port bindings differ from the maintained contract"
  fi
else
  fail "container $container does not exist"
fi

if docker volume inspect "$volume" >/dev/null 2>&1; then
  pass "persistent volume $volume exists"
else
  fail "persistent volume $volume does not exist"
fi

provider="$(hermes config get model.provider 2>/dev/null || true)"
model="$(hermes config get model.default 2>/dev/null || true)"
if [ "$provider" = "kimi-coding" ] && [ "$model" = "k3-256k" ]; then
  pass "Hermes uses kimi-coding/k3-256k"
else
  fail "Hermes model route is provider=$provider model=$model"
fi

memory_status="$(hermes memory status 2>/dev/null || true)"
if printf '%s' "$memory_status" | rg -q 'Provider:\s+hindsight' &&
   printf '%s' "$memory_status" | rg -q 'Status:\s+available'; then
  pass "Hermes Hindsight provider is active and available"
else
  fail "Hermes Hindsight provider is not active and available"
fi

if hermes gateway status >/dev/null 2>&1; then
  pass "Hermes gateway reports healthy status"
else
  fail "Hermes gateway does not report healthy status"
fi

if [ "$failures" -ne 0 ]; then
  echo "$failures verification check(s) failed." >&2
  exit 1
fi

echo "Hermes + Kimi + Hindsight stack verification passed."
