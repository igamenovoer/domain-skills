#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: verify-tavily-skills.sh [options]

Verify Tavily agent skills for one supported coding agent.

Options:
  --agent NAME       Agent id: claude-code, codex, gemini-cli, kimi-cli.
                    Default: codex.
  --scope SCOPE      project or global. Default: project.
  --manual           Verify manual filesystem install instead of npx skills metadata.
  --help             Show this help.
EOF
}

agent="codex"
scope="project"
manual=0

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

if [ "$manual" -eq 0 ] && command -v npx >/dev/null 2>&1; then
  args=(npx skills list --agent "$agent" --json)
  if [ "$scope" = "global" ]; then
    args+=(--global)
  fi
  exec "${args[@]}"
fi

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

find "$target_root" -maxdepth 2 -path '*/tavily-*/SKILL.md' | sort
