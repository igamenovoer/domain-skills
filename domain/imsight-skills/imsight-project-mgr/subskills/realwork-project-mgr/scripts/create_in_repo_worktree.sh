#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_worktree_common.sh
source "$script_dir/_worktree_common.sh"

print_usage() {
    cat <<'EOF'
Usage: create_in_repo_worktree.sh [--repo PATH] [--branch REF] [--path TARGET_PATH] [--link-dir NAME]

Create a temporary clean git worktree inside a standalone realwork repository
and symlink selected untracked local-state directories into it. Refuses
metaproj workspaces and attached realwork submodules.

Options:
  --repo PATH        Repository path. Default: current working tree.
  --branch REF       Branch or ref to base the worktree on. Default: current branch.
  --path TARGET_PATH Target path. Default: <repo-root>/.imsight-arts/worktrees/worktree-<ts>
  --link-dir NAME    Extra directory to symlink if it exists and is untracked.
  -h, --help         Show this help.
EOF
}

resolve_target_path() {
    local repo_root="$1"
    local requested_path="$2"
    local ts=""

    if [[ -z "$requested_path" ]]; then
        ts="$(date -u +%Y%m%d-%H%M%S)"
        printf '%s/.imsight-arts/worktrees/worktree-%s\n' "$repo_root" "$ts"
        return
    fi

    case "$requested_path" in
        /*)
            printf '%s\n' "$requested_path"
            ;;
        *)
            printf '%s/%s\n' "$repo_root" "$requested_path"
            ;;
    esac
}

validate_in_repo_target() {
    local repo_root="$1"
    local worktree_path="$2"
    local rel_path=""

    validate_in_repo_path "$repo_root" "$worktree_path" "in-repo worktree target"

    if [[ -e "$worktree_path" ]]; then
        echo "error: worktree path already exists: $worktree_path" >&2
        exit 1
    fi

    rel_path="${worktree_path#"$repo_root"/}"
    if ! git -C "$repo_root" check-ignore --quiet --no-index -- "$rel_path"; then
        echo "error: in-repo worktree target is not ignored: $rel_path" >&2
        exit 1
    fi
}

is_local_branch() {
    local repo_root="$1"
    local ref_name="$2"

    git -C "$repo_root" show-ref --verify --quiet "refs/heads/$ref_name"
}

branch_checked_out() {
    local repo_root="$1"
    local branch_name="$2"

    git -C "$repo_root" worktree list --porcelain | awk -v want="refs/heads/$branch_name" '
        $1 == "branch" && $2 == want { found = 1 }
        END { exit found ? 0 : 1 }
    '
}

repo_arg=""
source_ref=""
requested_path=""
declare -a extra_link_dirs=()

while (($# > 0)); do
    case "$1" in
        --repo)
            [[ $# -ge 2 ]] || { echo "error: --repo requires a value" >&2; exit 2; }
            repo_arg="$2"
            shift 2
            ;;
        --branch|--ref)
            [[ $# -ge 2 ]] || { echo "error: --branch requires a value" >&2; exit 2; }
            source_ref="$2"
            shift 2
            ;;
        --path)
            [[ $# -ge 2 ]] || { echo "error: --path requires a value" >&2; exit 2; }
            requested_path="$2"
            shift 2
            ;;
        --link-dir)
            [[ $# -ge 2 ]] || { echo "error: --link-dir requires a value" >&2; exit 2; }
            extra_link_dirs+=("$2")
            shift 2
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "error: unknown argument: $1" >&2
            print_usage >&2
            exit 2
            ;;
    esac
done

for dir_name in "${extra_link_dirs[@]}"; do
    validate_link_dir "$dir_name"
done

repo_root="$(resolve_repo_root "$repo_arg")"
enforce_standalone_realwork "$script_dir" "$repo_root"

if [[ -z "$source_ref" ]]; then
    source_ref="$(git -C "$repo_root" branch --show-current)"
fi

if [[ -z "$source_ref" ]]; then
    echo "error: no current branch detected; pass --branch <ref> explicitly" >&2
    exit 1
fi

source_commit="$(git -C "$repo_root" rev-parse --verify "$source_ref^{commit}")"
worktree_path="$(realpath -m "$(resolve_target_path "$repo_root" "$requested_path")")"
validate_in_repo_target "$repo_root" "$worktree_path"

mkdir -p "$(dirname "$worktree_path")"

checkout_mode="detached"
if is_local_branch "$repo_root" "$source_ref" && ! branch_checked_out "$repo_root" "$source_ref"; then
    git -C "$repo_root" worktree add "$worktree_path" "$source_ref"
    checkout_mode="branch"
else
    git -C "$repo_root" worktree add --detach "$worktree_path" "$source_commit"
fi

link_standard_local_state "$repo_root" "$worktree_path" "${extra_link_dirs[@]}"

echo "PROJECT_KIND=$DETECTED_PROJECT_KIND"
echo "WORKTREE_KIND=in-repo-temporary"
echo "WORKTREE=$worktree_path"
echo "SOURCE_REF=$source_ref"
echo "CHECKOUT_MODE=$checkout_mode"
echo "COMMIT=$(git -C "$worktree_path" rev-parse HEAD)"
echo "BRANCH=$(git -C "$worktree_path" branch --show-current)"
print_link_results
