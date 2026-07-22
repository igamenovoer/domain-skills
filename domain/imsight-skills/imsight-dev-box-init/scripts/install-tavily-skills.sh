#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install-tavily-skills.sh [options]

Install Tavily agent skills for one supported coding agent.

Options:
  --agent NAME      Agent id: claude-code, codex, gemini-cli, kimi-cli.
                   Default: codex.
  --scope SCOPE     project or global. Default: project.
  --skill NAME      Skill name to install. Repeatable. Default: all Tavily skills.
  --manual          Force manual git fallback instead of npx skills add.
  --help            Show this help.

Notes:
  Project scope paths:
    claude-code -> .claude/skills/
    codex, gemini-cli, kimi-cli -> .agents/skills/

  Global scope paths:
    claude-code -> ~/.claude/skills/
    codex       -> ${CODEX_HOME:-~/.codex}/skills/
    gemini-cli  -> ~/.gemini/skills/
    kimi-cli    -> ~/.config/agents/skills/
EOF
}

agent="codex"
scope="project"
manual=0
skills=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --agent)
      agent="${2:?missing --agent value}"
      shift 2
      ;;
    --agent=*)
      agent="${1#*=}"
      shift
      ;;
    --scope)
      scope="${2:?missing --scope value}"
      shift 2
      ;;
    --scope=*)
      scope="${1#*=}"
      shift
      ;;
    --skill)
      skills+=("${2:?missing --skill value}")
      shift 2
      ;;
    --skill=*)
      skills+=("${1#*=}")
      shift
      ;;
    --manual)
      manual=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$agent" in
  claude-code|codex|gemini-cli|kimi-cli) ;;
  *)
    echo "Unsupported --agent: $agent" >&2
    exit 2
    ;;
esac

case "$scope" in
  project|global) ;;
  *)
    echo "Unsupported --scope: $scope" >&2
    exit 2
    ;;
esac

if [ "${#skills[@]}" -eq 0 ]; then
  skills=("*")
fi

if [ "$manual" -eq 0 ] && command -v npx >/dev/null 2>&1; then
  args=(npx skills add https://github.com/tavily-ai/skills --agent "$agent" --yes)
  if [ "$scope" = "global" ]; then
    args+=(--global)
  fi
  for skill in "${skills[@]}"; do
    args+=(--skill "$skill")
  done
  exec "${args[@]}"
fi

target_root=""
if [ "$scope" = "project" ]; then
  case "$agent" in
    claude-code) target_root=".claude/skills" ;;
    codex|gemini-cli|kimi-cli) target_root=".agents/skills" ;;
  esac
else
  case "$agent" in
    claude-code) target_root="$HOME/.claude/skills" ;;
    codex) target_root="${CODEX_HOME:-$HOME/.codex}/skills" ;;
    gemini-cli) target_root="$HOME/.gemini/skills" ;;
    kimi-cli) target_root="$HOME/.config/agents/skills" ;;
  esac
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

git clone https://github.com/tavily-ai/skills.git "$tmp_dir/tavily-skills"
mkdir -p "$target_root"

if [ "${#skills[@]}" -eq 1 ] && [ "${skills[0]}" = "*" ]; then
  cp -a "$tmp_dir/tavily-skills/skills/." "$target_root/"
else
  for skill in "${skills[@]}"; do
    src="$tmp_dir/tavily-skills/skills/$skill"
    if [ ! -d "$src" ]; then
      echo "Skill not found in Tavily repository: $skill" >&2
      exit 1
    fi
    rm -rf "$target_root/$skill"
    cp -a "$src" "$target_root/$skill"
  done
fi

printf 'Installed Tavily skills for %s (%s) into %s\n' "$agent" "$scope" "$target_root"
