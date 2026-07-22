#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

target="generic"
mode="copy"
scope="project"
yes=0

usage() {
  cat <<'EOF'
Usage: install-to-agents.sh [options]

Install the local imsight-* skills into a supported agent skills directory.

Options:
  --target TARGET   Agent target: claude-code, generic, kimi-code, codex.
                    Default: generic.
  --mode MODE       Install mode: copy or symlink. Default: copy.
  --scope SCOPE     Install scope: global (under $HOME) or project (under cwd).
                    Default: project.
  --yes             Skip the confirmation prompt.
  -h, --help        Show this help.

Target paths:
  claude-code  global: ~/.claude/skills         project: .claude/skills
  kimi-code    global: ~/.kimi-code/skills      project: .kimi-code/skills
  codex        global: $CODEX_HOME/skills       project: .codex/skills
               (CODEX_HOME defaults to ~/.codex)
  generic      global: ~/.agents/skills         project: .agents/skills

In either mode, any pre-existing imsight-* entries in the destination are
removed first. Symlinks are unlinked without following them, so the source
tree is never deleted.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      target="${2:?missing value for --target}"
      shift 2
      ;;
    --target=*)
      target="${1#*=}"
      shift
      ;;
    --mode)
      mode="${2:?missing value for --mode}"
      shift 2
      ;;
    --mode=*)
      mode="${1#*=}"
      shift
      ;;
    --scope)
      scope="${2:?missing value for --scope}"
      shift 2
      ;;
    --scope=*)
      scope="${1#*=}"
      shift
      ;;
    --yes)
      yes=1
      shift
      ;;
    -h|--help)
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

case "$target" in
  claude-code|generic|kimi-code|codex) ;;
  *)
    echo "Unsupported --target: $target" >&2
    usage >&2
    exit 2
    ;;
esac

case "$mode" in
  copy|symlink) ;;
  *)
    echo "Unsupported --mode: $mode" >&2
    usage >&2
    exit 2
    ;;
esac

case "$scope" in
  global|project) ;;
  *)
    echo "Unsupported --scope: $scope" >&2
    usage >&2
    exit 2
    ;;
esac

if [ "$scope" = "global" ]; then
  case "$target" in
    claude-code) dest_root="$HOME/.claude/skills" ;;
    kimi-code)   dest_root="$HOME/.kimi-code/skills" ;;
    codex)       dest_root="${CODEX_HOME:-$HOME/.codex}/skills" ;;
    generic)     dest_root="$HOME/.agents/skills" ;;
  esac
else
  case "$target" in
    claude-code) dest_root=".claude/skills" ;;
    kimi-code)   dest_root=".kimi-code/skills" ;;
    codex)       dest_root=".codex/skills" ;;
    generic)     dest_root=".agents/skills" ;;
  esac
fi

mkdir -p "$dest_root"
dest_root="$(cd "$dest_root" && pwd)"

# Discover source skills before prompting.
skills=()
for skill_dir in "$SCRIPT_DIR"/imsight-*/; do
  [ -d "$skill_dir" ] || continue
  skills+=("$(basename "$skill_dir")")
done

if [ "${#skills[@]}" -eq 0 ]; then
  echo "No imsight-* skill directories found in $SCRIPT_DIR" >&2
  exit 1
fi

# Confirmation prompt.
if [ "$yes" -ne 1 ]; then
  echo "This will install ${#skills[@]} imsight skill(s) into:"
  echo "  $dest_root"
  echo "Any existing imsight-* entries there will be removed first."
  printf 'Continue? [Y/n] '
  if ! read -r reply; then
    echo "" >&2
    echo "No confirmation received; aborting. Use --yes to skip this prompt." >&2
    exit 1
  fi
  case "$reply" in
    ''|[Yy]|[Yy][Ee][Ss]) ;;
    *)
      echo "Aborted."
      exit 1
      ;;
  esac
fi

echo "Installing imsight skills for target=$target mode=$mode scope=$scope into $dest_root"

# Remove any existing imsight-* entries. find without -L does not follow
# symlinks, so only the link itself is removed, never its target.
cd "$dest_root"
find . -maxdepth 1 -name 'imsight-*' -exec rm -rf {} +

cd "$SCRIPT_DIR"

for name in "${skills[@]}"; do
  skill_dir="$SCRIPT_DIR/$name"

  if [ "$mode" = "symlink" ]; then
    ln -s "$skill_dir" "$dest_root/$name"
  else
    cp -a "$skill_dir" "$dest_root/$name"
  fi

  echo "  $name"
done

echo "Installed ${#skills[@]} skill(s)."
