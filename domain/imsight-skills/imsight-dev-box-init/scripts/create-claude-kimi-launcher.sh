#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: create-claude-kimi-launcher.sh [options]

Creates a Unix claude-kimi launcher that runs Claude Code against Kimi Code.
The generated launcher reads a shared kimi-api-key file from the launcher dir.
If the key file is missing, the launcher prompts once and writes it there.

Options:
  --api-key KEY       Optional Kimi API key to seed the shared key file.
                     Defaults to KIMI_API_KEY, then ANTHROPIC_API_KEY.
  --output PATH      Launcher path. Default: $HOME/.local/bin/claude-kimi.
  --key-file PATH    Shared key file. Default: <launcher-dir>/kimi-api-key.
  --base-url URL     Anthropic-compatible Kimi endpoint. Default: https://api.moonshot.ai/anthropic.
  --model MODEL      Startup model passed to Claude Code --model. Default: opus.
                     Use a Claude tier alias (opus, sonnet, haiku, fable) or a raw
                     Kimi model name.
  --model-opus MODEL     Kimi model the opus alias resolves to.
  --model-sonnet MODEL   Kimi model the sonnet alias resolves to.
  --model-haiku MODEL    Kimi model the haiku alias resolves to.
  --model-fable MODEL    Kimi model the fable alias resolves to.
  --model-subagent MODEL Kimi model used for subagents.
                     Tier defaults depend on the lane:
                       Platform API: opus=kimi-k3 sonnet=kimi-k2.7-code haiku=kimi-k2.6
                                     fable=kimi-k3 subagent=kimi-k2.7-code
                       Coding Plan:  opus=k3-256k sonnet=kimi-for-coding haiku=kimi-for-coding
                                     fable=k3 subagent=kimi-for-coding
                     Never map an alias to a highspeed variant by default.
  --compact-window N Auto-compaction window. Default: derived from the resolved
                     startup model (262144 for K2-series, kimi-for-coding, and
                     coding-plan k3; 1048576 otherwise).
  --claude-bin PATH  Optional fixed Claude Code executable path.
  -h, --help         Show this help.
EOF
}

api_key="${KIMI_API_KEY:-${ANTHROPIC_API_KEY:-}}"
output="$HOME/.local/bin/claude-kimi"
key_file=""
base_url="https://api.moonshot.ai/anthropic"
model="opus"
model_opus=""
model_sonnet=""
model_haiku=""
model_fable=""
model_subagent=""
compact_window=""
claude_bin=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --api-key)
      api_key="${2:?missing value for --api-key}"
      shift 2
      ;;
    --api-key=*)
      api_key="${1#*=}"
      shift
      ;;
    --output)
      output="${2:?missing value for --output}"
      shift 2
      ;;
    --output=*)
      output="${1#*=}"
      shift
      ;;
    --key-file)
      key_file="${2:?missing value for --key-file}"
      shift 2
      ;;
    --key-file=*)
      key_file="${1#*=}"
      shift
      ;;
    --base-url)
      base_url="${2:?missing value for --base-url}"
      shift 2
      ;;
    --base-url=*)
      base_url="${1#*=}"
      shift
      ;;
    --model)
      model="${2:?missing value for --model}"
      shift 2
      ;;
    --model=*)
      model="${1#*=}"
      shift
      ;;
    --model-opus)
      model_opus="${2:?missing value for --model-opus}"
      shift 2
      ;;
    --model-opus=*)
      model_opus="${1#*=}"
      shift
      ;;
    --model-sonnet)
      model_sonnet="${2:?missing value for --model-sonnet}"
      shift 2
      ;;
    --model-sonnet=*)
      model_sonnet="${1#*=}"
      shift
      ;;
    --model-haiku)
      model_haiku="${2:?missing value for --model-haiku}"
      shift 2
      ;;
    --model-haiku=*)
      model_haiku="${1#*=}"
      shift
      ;;
    --model-fable)
      model_fable="${2:?missing value for --model-fable}"
      shift 2
      ;;
    --model-fable=*)
      model_fable="${1#*=}"
      shift
      ;;
    --model-subagent)
      model_subagent="${2:?missing value for --model-subagent}"
      shift 2
      ;;
    --model-subagent=*)
      model_subagent="${1#*=}"
      shift
      ;;
    --compact-window)
      compact_window="${2:?missing value for --compact-window}"
      shift 2
      ;;
    --compact-window=*)
      compact_window="${1#*=}"
      shift
      ;;
    --claude-bin)
      claude_bin="${2:?missing value for --claude-bin}"
      shift 2
      ;;
    --claude-bin=*)
      claude_bin="${1#*=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

output_dir="$(dirname "$output")"
if [[ -z "$key_file" ]]; then
  key_file="$output_dir/kimi-api-key"
fi

# The Kimi Coding Plan endpoint (api.kimi.com) authenticates with
# ANTHROPIC_API_KEY; the Kimi Platform API endpoint authenticates with
# ANTHROPIC_AUTH_TOKEN. Tier defaults also differ per lane.
if [[ "$base_url" == *api.kimi.com* ]]; then
  coding_lane=1
  model_opus="${model_opus:-k3-256k}"
  model_sonnet="${model_sonnet:-kimi-for-coding}"
  model_haiku="${model_haiku:-kimi-for-coding}"
  model_fable="${model_fable:-k3}"
  model_subagent="${model_subagent:-kimi-for-coding}"
else
  coding_lane=0
  model_opus="${model_opus:-kimi-k3}"
  model_sonnet="${model_sonnet:-kimi-k2.7-code}"
  model_haiku="${model_haiku:-kimi-k2.6}"
  model_fable="${model_fable:-kimi-k3}"
  model_subagent="${model_subagent:-kimi-k2.7-code}"
fi

# Resolve a Claude tier alias to its Kimi model; raw model names pass through.
resolve_tier_model() {
  case "$1" in
    opus) printf '%s' "$model_opus" ;;
    sonnet) printf '%s' "$model_sonnet" ;;
    haiku) printf '%s' "$model_haiku" ;;
    fable) printf '%s' "$model_fable" ;;
    *) printf '%s' "$1" ;;
  esac
}
startup_model_resolved="$(resolve_tier_model "$model")"

if [[ -z "$compact_window" ]]; then
  case "$startup_model_resolved" in
    *k2.*|kimi-for-coding*|k3|k3-256k)
      # K2-series models, the K2.7 Code family, coding-plan k3
      # (Moderato tier), and k3-256k use a 256K context window.
      compact_window=262144
      ;;
    *)
      # kimi-k3 and 1M-variant models use a 1M context window.
      compact_window=1048576
      ;;
  esac
fi
if [[ ! "$compact_window" =~ ^[0-9]+$ ]]; then
  echo "invalid --compact-window: $compact_window (expected a number)" >&2
  exit 2
fi

# Each lane carries its own guide-mandated variable set, emitted after the
# KIMI_MODEL_* tier variables are resolved in the launcher.
if [[ "$coding_lane" -eq 1 ]]; then
  auth_export='export ANTHROPIC_API_KEY="$kimi_key"'
  auth_unset='unset ANTHROPIC_AUTH_TOKEN CLAUDE_CODE_OAUTH_TOKEN'
  lane_exports="export ANTHROPIC_DEFAULT_FABLE_MODEL=\"\$KIMI_MODEL_FABLE\"
export CLAUDE_CODE_MAX_CONTEXT_TOKENS=\"\${CLAUDE_CODE_MAX_CONTEXT_TOKENS:-$compact_window}\"
_kimi_startup_resolved=\"\$KIMI_MODEL\"
case \"\$KIMI_MODEL\" in
  opus) _kimi_startup_resolved=\"\$KIMI_MODEL_OPUS\" ;;
  sonnet) _kimi_startup_resolved=\"\$KIMI_MODEL_SONNET\" ;;
  haiku) _kimi_startup_resolved=\"\$KIMI_MODEL_HAIKU\" ;;
  fable) _kimi_startup_resolved=\"\$KIMI_MODEL_FABLE\" ;;
esac
case \"\$_kimi_startup_resolved\" in
  k3|k3-*|'k3[1m]')
    # Only K3 supports CLAUDE_CODE_EFFORT_LEVEL, and only max.
    export CLAUDE_CODE_EFFORT_LEVEL=\"\${CLAUDE_CODE_EFFORT_LEVEL:-max}\"
    ;;
esac"
else
  auth_export='export ANTHROPIC_AUTH_TOKEN="$kimi_key"'
  auth_unset='unset ANTHROPIC_API_KEY CLAUDE_CODE_OAUTH_TOKEN'
  lane_exports='export ENABLE_TOOL_SEARCH="${ENABLE_TOOL_SEARCH:-false}"'
fi

shell_quote() {
  printf '%q' "$1"
}

base_url_q="$(shell_quote "$base_url")"
model_q="$(shell_quote "$model")"
model_opus_q="$(shell_quote "$model_opus")"
model_sonnet_q="$(shell_quote "$model_sonnet")"
model_haiku_q="$(shell_quote "$model_haiku")"
model_fable_q="$(shell_quote "$model_fable")"
model_subagent_q="$(shell_quote "$model_subagent")"
claude_bin_q="$(shell_quote "$claude_bin")"
key_file_q="$(shell_quote "$key_file")"

mkdir -p "$output_dir"
umask 077

if [[ -n "$api_key" ]]; then
  mkdir -p "$(dirname "$key_file")"
  printf '%s\n' "$api_key" > "$key_file"
  chmod 600 "$key_file"
fi

cat > "$output" <<SH
#!/usr/bin/env bash
set -euo pipefail

key_file=$key_file_q
if [[ ! -r "\$key_file" ]]; then
  if [[ ! -t 0 ]]; then
    echo "claude-kimi: missing \$key_file and cannot prompt for a key without a terminal" >&2
    exit 2
  fi
  read -r -s -p "Kimi API key: " kimi_key
  echo >&2
  if [[ -z "\$kimi_key" ]]; then
    echo "claude-kimi: empty Kimi API key" >&2
    exit 2
  fi
  mkdir -p "\$(dirname "\$key_file")"
  umask 077
  printf '%s\n' "\$kimi_key" > "\$key_file"
  chmod 600 "\$key_file" 2>/dev/null || true
else
  IFS= read -r kimi_key < "\$key_file" || true
  if [[ -z "\$kimi_key" ]]; then
    echo "claude-kimi: empty Kimi API key in \$key_file" >&2
    exit 2
  fi
fi

$auth_export
$auth_unset
export ANTHROPIC_BASE_URL=$base_url_q
export CLAUDE_CODE_AUTO_COMPACT_WINDOW="\${CLAUDE_CODE_AUTO_COMPACT_WINDOW:-$compact_window}"
# CLAUDE_KIMI_MODEL is the single override knob: it resets the startup model and
# every tier at once. Per-tier overrides use CLAUDE_KIMI_MODEL_<TIER>.
KIMI_MODEL=\${CLAUDE_KIMI_MODEL:-$model_q}
KIMI_MODEL_OPUS=\${CLAUDE_KIMI_MODEL:-\${CLAUDE_KIMI_MODEL_OPUS:-$model_opus_q}}
KIMI_MODEL_SONNET=\${CLAUDE_KIMI_MODEL:-\${CLAUDE_KIMI_MODEL_SONNET:-$model_sonnet_q}}
KIMI_MODEL_HAIKU=\${CLAUDE_KIMI_MODEL:-\${CLAUDE_KIMI_MODEL_HAIKU:-$model_haiku_q}}
KIMI_MODEL_FABLE=\${CLAUDE_KIMI_MODEL:-\${CLAUDE_KIMI_MODEL_FABLE:-$model_fable_q}}
KIMI_MODEL_SUBAGENT=\${CLAUDE_KIMI_MODEL:-\${CLAUDE_KIMI_MODEL_SUBAGENT:-$model_subagent_q}}
export ANTHROPIC_DEFAULT_OPUS_MODEL="\$KIMI_MODEL_OPUS"
export ANTHROPIC_DEFAULT_SONNET_MODEL="\$KIMI_MODEL_SONNET"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="\$KIMI_MODEL_HAIKU"
export CLAUDE_CODE_SUBAGENT_MODEL="\$KIMI_MODEL_SUBAGENT"
$lane_exports

if command -v node >/dev/null 2>&1; then
  node --eval "
    const fs = require('fs');
    const os = require('os');
    const path = require('path');
    const filePath = path.join(os.homedir(), '.claude.json');
    const content = fs.existsSync(filePath)
      ? JSON.parse(fs.readFileSync(filePath, 'utf-8'))
      : {};
    fs.writeFileSync(
      filePath,
      JSON.stringify({ ...content, hasCompletedOnboarding: true }, null, 2),
      'utf-8'
    );
  "
fi

claude_bin=$claude_bin_q
if [[ -z "\$claude_bin" ]]; then
  for candidate in "\$HOME"/.nvm/versions/node/*/bin/claude "\$HOME"/.bun/bin/claude "\$HOME"/.local/bin/claude; do
    if [[ -x "\$candidate" ]]; then
      claude_bin="\$candidate"
      break
    fi
  done
fi
if [[ -z "\$claude_bin" ]]; then
  claude_bin="\$(command -v claude || true)"
fi
if [[ -z "\$claude_bin" ]]; then
  echo "claude-kimi: claude binary not found" >&2
  exit 127
fi

add_model=1
for arg in "\$@"; do
  # Runtime args belong to Claude Code. The launcher only observes them to avoid
  # injecting duplicate defaults; it must not consume or reinterpret Claude flags.
  case "\$arg" in
    --model|--model=*|--help|-h|--version|-v)
      add_model=0
      ;;
  esac
done

if [[ "\$add_model" -eq 1 ]]; then
  exec "\$claude_bin" --dangerously-skip-permissions --model "\$KIMI_MODEL" "\$@"
fi
exec "\$claude_bin" --dangerously-skip-permissions "\$@"
SH

chmod 700 "$output"
echo "created $output"
echo "key file: $key_file"
