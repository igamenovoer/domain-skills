#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: create-claude-gac-launcher.sh [options]

Creates a Linux claude-gac launcher that runs Claude Code through GAC.
The launcher reads a shared gac-api-key file and prompts on first use when the
file is missing.

Options:
  --output PATH      Launcher path. Default: $HOME/.local/bin/claude-gac.
  --key-file PATH    Key file. Default: <launcher-dir>/gac-api-key.
  --base-url URL     GAC endpoint. Default: https://gaccode.com/claudecode.
  --claude-bin PATH  Optional fixed Claude Code executable path.
  -h, --help         Show this help.

Set GAC_API_KEY only when explicitly seeding the key file for unattended setup.
EOF
}

api_key="${GAC_API_KEY:-}"
output="$HOME/.local/bin/claude-gac"
key_file=""
base_url="https://gaccode.com/claudecode"
claude_bin=""

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
      echo "create-claude-gac-launcher: unknown option $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

output_dir="$(dirname "$output")"
if [[ -z "$key_file" ]]; then
  key_file="$output_dir/gac-api-key"
fi

shell_quote() {
  printf '%q' "$1"
}

key_file_q="$(shell_quote "$key_file")"
base_url_q="$(shell_quote "$base_url")"
claude_bin_q="$(shell_quote "$claude_bin")"

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
    echo "claude-gac: missing \$key_file and cannot prompt for a key without a terminal" >&2
    exit 2
  fi
  read -r -s -p "GAC API key: " api_key
  echo >&2
  if [[ -z "\$api_key" ]]; then
    echo "claude-gac: empty GAC API key" >&2
    exit 2
  fi
  mkdir -p "\$(dirname "\$key_file")"
  umask 077
  printf '%s\n' "\$api_key" > "\$key_file"
  chmod 600 "\$key_file"
else
  api_key="\$(tr -d '[:space:]' < "\$key_file")"
  if [[ -z "\$api_key" ]]; then
    echo "claude-gac: empty GAC API key in \$key_file" >&2
    exit 2
  fi
fi

export ANTHROPIC_BASE_URL=$base_url_q
export ANTHROPIC_API_KEY="\$api_key"
export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="\${CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY:-1}"

claude_bin=$claude_bin_q
if [[ -z "\$claude_bin" ]]; then
  claude_bin="\$(command -v claude || true)"
fi
if [[ -z "\$claude_bin" ]]; then
  echo "claude-gac: claude binary not found" >&2
  exit 127
fi

exec "\$claude_bin" "\$@"
SH

chmod 700 "$output"
echo "created launcher: $output"
echo "GAC key file: $key_file"
if [[ ":$PATH:" != *":$output_dir:"* ]]; then
  echo "next step: add $output_dir to PATH in the active shell's startup file"
fi
if [[ ! -f "$key_file" ]]; then
  echo "next step: run $output and enter the GAC API key securely"
fi
