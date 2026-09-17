#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: create-claude-gac-launcher.sh [options]

Creates a Linux claude-gac launcher with the fixed GAC endpoint and the GAC API
key embedded directly in the generated file.

Options:
  --output PATH                  Launcher path. Default: $HOME/.local/bin/claude-gac.
  --claude-bin PATH              Optional fixed Claude Code executable path.
  --require-permission-prompts   Do not inject --dangerously-skip-permissions.
  -h, --help                     Show this help.

The generator reads GAC_API_KEY or prompts securely. It never creates key or
endpoint side files.
EOF
}

api_key="${GAC_API_KEY:-}"
output="$HOME/.local/bin/claude-gac"
claude_bin=""
base_url='https://gaccode.com/claudecode'
permissive=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      output="${2:?missing value for --output}"
      shift 2
      ;;
    --output=*)
      output="${1#*=}"
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
    --require-permission-prompts)
      permissive=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "create-claude-gac-launcher: unknown option $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$api_key" ]]; then
  if [[ ! -t 0 ]]; then
    echo 'create-claude-gac-launcher: GAC_API_KEY is required without an interactive terminal' >&2
    exit 2
  fi
  read -r -s -p 'GAC API key: ' api_key
  echo >&2
fi
if [[ -z "$api_key" ]]; then
  echo 'create-claude-gac-launcher: empty GAC API key' >&2
  exit 2
fi

shell_quote() {
  printf '%q' "$1"
}

api_key_q="$(shell_quote "$api_key")"
base_url_q="$(shell_quote "$base_url")"
claude_bin_q="$(shell_quote "$claude_bin")"
output_dir="$(dirname "$output")"
permission_args_line='permission_args=(--dangerously-skip-permissions)'
if [[ "$permissive" -eq 0 ]]; then
  permission_args_line='permission_args=()'
fi

mkdir -p "$output_dir"
umask 077

cat > "$output" <<SH
#!/usr/bin/env bash
set -euo pipefail

# GAC-specific Claude Code launcher. The endpoint and API key are intentionally
# embedded; do not replace them with token or endpoint side files.
export ANTHROPIC_BASE_URL=$base_url_q
export ANTHROPIC_API_KEY=$api_key_q
export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY='1'
unset ANTHROPIC_AUTH_TOKEN CLAUDE_CODE_OAUTH_TOKEN

claude_bin=$claude_bin_q
if [[ -z "\$claude_bin" ]]; then
  claude_bin="\$(command -v claude || true)"
fi
if [[ -z "\$claude_bin" ]]; then
  echo 'claude-gac: claude binary not found' >&2
  exit 127
fi

$permission_args_line
exec "\$claude_bin" "\${permission_args[@]}" "\$@"
SH

chmod 700 "$output"
echo "created launcher: $output"
if [[ "$permissive" -eq 1 ]]; then
  echo 'permission mode: --dangerously-skip-permissions (default)'
else
  echo 'permission mode: prompts enabled (explicit opt-out)'
fi
if [[ ":$PATH:" != *":$output_dir:"* ]]; then
  echo "next step: add $output_dir to PATH in the active shell's startup file"
fi
