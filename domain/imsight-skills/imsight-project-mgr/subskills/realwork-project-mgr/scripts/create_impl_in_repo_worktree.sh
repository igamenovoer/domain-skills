#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_worktree_common.sh
source "$script_dir/_worktree_common.sh"

automation_root_rel=".imsight-arts/impl-branches"

print_usage() {
    cat <<'EOF'
Usage: create_impl_in_repo_worktree.sh [--repo PATH] [--topic TOPIC_SLUG] [--kind feature|fix] [--branch NAME] [--impl-home PATH] [--path WORKTREE_PATH] [--link-dir RELATIVE_DIR]

Create a new local implementation branch from the current repository state of a
standalone realwork repository, including uncommitted tracked and untracked
changes, then create a separate worktree for that branch and link reusable
local-state directories into it. Refuses metaproj workspaces and attached
realwork submodules.

Options:
  --repo PATH        Repository path. Default: current working tree.
  --topic SLUG       Topic slug used for branch and worktree naming.
  --kind KIND        Branch kind: feature or fix. Default: feature.
  --branch NAME      Full branch name. Default: <kind>/<topic-slug>.
  --impl-home PATH   Impl home path. Default: <repo-root>/.imsight-arts/impl-branches/<kind>/<topic-slug>
  --path PATH        Worktree path. Default: <impl-home>/repo
  --link-dir PATH    Extra directory to symlink if it exists and is not tracked in the new worktree.
  -h, --help         Show this help.
EOF
}

gitignore_has_impl_entry() {
    local gitignore_path="$1"

    [[ -f "$gitignore_path" ]] || return 1
    grep -Eq '^[[:space:]]*/?\.imsight-arts/impl-branches/?[[:space:]]*$' "$gitignore_path"
}

gitignore_has_impl_comment() {
    local gitignore_path="$1"

    [[ -f "$gitignore_path" ]] || return 1
    grep -Eq '^[[:space:]]*#.*\.imsight-arts/impl-branches/?' "$gitignore_path"
}

ensure_impl_gitignored() {
    local repo_root="$1"
    local gitignore_path="$repo_root/.gitignore"
    local last_char=""

    if git -C "$repo_root" check-ignore --quiet --no-index -- "$automation_root_rel/.ignore-probe"; then
        return 0
    fi

    if gitignore_has_impl_entry "$gitignore_path"; then
        return 0
    fi

    if gitignore_has_impl_comment "$gitignore_path"; then
        return 0
    fi

    if [[ -f "$gitignore_path" && -s "$gitignore_path" ]]; then
        last_char="$(tail -c 1 "$gitignore_path" 2>/dev/null || true)"
        if [[ "$last_char" != $'\n' ]]; then
            printf '\n' >> "$gitignore_path"
        fi
    fi

    printf '.imsight-arts/impl-branches/\n' >> "$gitignore_path"
}

normalize_topic_slug() {
    printf '%s' "$1" \
        | tr '[:upper:]' '[:lower:]' \
        | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-{2,}/-/g'
}

validate_topic_slug() {
    [[ "$1" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

validate_branch_kind() {
    [[ "$1" == "feature" || "$1" == "fix" ]]
}

validate_branch_name() {
    [[ "$1" =~ ^(feature|fix)/[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

resolve_impl_home() {
    local repo_root="$1"
    local branch_kind="$2"
    local topic_slug="$3"
    local requested_impl_home="$4"

    if [[ -z "$requested_impl_home" ]]; then
        printf '%s/%s/%s/%s\n' "$repo_root" "$automation_root_rel" "$branch_kind" "$topic_slug"
        return
    fi

    case "$requested_impl_home" in
        /*)
            printf '%s\n' "$requested_impl_home"
            ;;
        *)
            printf '%s/%s\n' "$repo_root" "$requested_impl_home"
            ;;
    esac
}

resolve_worktree_path() {
    local repo_root="$1"
    local impl_home="$2"
    local requested_path="$3"

    if [[ -z "$requested_path" ]]; then
        printf '%s/repo\n' "$impl_home"
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

repo_arg=""
topic_slug=""
branch_kind="feature"
impl_branch=""
requested_impl_home=""
requested_path=""
declare -a extra_link_dirs=()

while (($# > 0)); do
    case "$1" in
        --repo)
            [[ $# -ge 2 ]] || { echo "error: --repo requires a value" >&2; exit 2; }
            repo_arg="$2"
            shift 2
            ;;
        --topic)
            [[ $# -ge 2 ]] || { echo "error: --topic requires a value" >&2; exit 2; }
            topic_slug="$2"
            shift 2
            ;;
        --kind)
            [[ $# -ge 2 ]] || { echo "error: --kind requires a value" >&2; exit 2; }
            branch_kind="$2"
            shift 2
            ;;
        --branch)
            [[ $# -ge 2 ]] || { echo "error: --branch requires a value" >&2; exit 2; }
            impl_branch="$2"
            shift 2
            ;;
        --impl-home)
            [[ $# -ge 2 ]] || { echo "error: --impl-home requires a value" >&2; exit 2; }
            requested_impl_home="$2"
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

if ! validate_branch_kind "$branch_kind"; then
    echo "error: --kind must be 'feature' or 'fix'" >&2
    exit 2
fi

repo_root="$(resolve_repo_root "$repo_arg")"
enforce_standalone_realwork "$script_dir" "$repo_root"

automation_root_path="$repo_root/$automation_root_rel"
automation_root_was_present=0

if [[ -e "$automation_root_path" ]]; then
    automation_root_was_present=1
fi

if [[ -n "$topic_slug" ]]; then
    topic_slug="$(normalize_topic_slug "$topic_slug")"
    if ! validate_topic_slug "$topic_slug"; then
        echo "error: topic slug must normalize to hyphen-case like foo-bar" >&2
        exit 2
    fi
fi

if [[ -n "$impl_branch" ]]; then
    if ! validate_branch_name "$impl_branch"; then
        echo "error: branch must look like feature/<topic-slug> or fix/<topic-slug>" >&2
        exit 2
    fi
    branch_kind="${impl_branch%%/*}"
    branch_topic="${impl_branch#*/}"
    if [[ -n "$topic_slug" && "$topic_slug" != "$branch_topic" ]]; then
        echo "error: --topic does not match the topic portion of --branch" >&2
        exit 2
    fi
    topic_slug="$branch_topic"
fi

if [[ -z "$topic_slug" ]]; then
    echo "error: pass --topic or --branch" >&2
    exit 2
fi

if [[ -z "$impl_branch" ]]; then
    impl_branch="$branch_kind/$topic_slug"
fi

if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$impl_branch"; then
    echo "error: branch already exists: $impl_branch" >&2
    exit 1
fi

impl_home="$(realpath -m "$(resolve_impl_home "$repo_root" "$branch_kind" "$topic_slug" "$requested_impl_home")")"
worktree_path="$(realpath -m "$(resolve_worktree_path "$repo_root" "$impl_home" "$requested_path")")"
validate_in_repo_path "$repo_root" "$impl_home" "implementation home"
validate_in_repo_path "$repo_root" "$worktree_path" "implementation worktree"

if [[ -e "$worktree_path" ]]; then
    echo "error: worktree path already exists: $worktree_path" >&2
    exit 1
fi

if ! parent_commit="$(git -C "$repo_root" rev-parse --verify HEAD 2>/dev/null)"; then
    echo "error: repository has no commits yet (HEAD missing)" >&2
    exit 1
fi

timestamp="$(date -u +%Y%m%d-%H%M%S)"
tmp_index_dir="$(mktemp -d "${TMPDIR:-/tmp}/impl-worktree-index.XXXXXX")"
tmp_index="$tmp_index_dir/index"

cleanup() {
    rm -rf "$tmp_index_dir"
}

trap cleanup EXIT

GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" add -A
tree_id="$(GIT_INDEX_FILE="$tmp_index" git -C "$repo_root" write-tree)"
snapshot_commit="$(
    git -C "$repo_root" commit-tree \
        "$tree_id" \
        -p "$parent_commit" \
        -m "impl snapshot $impl_branch $timestamp"
)"

git -C "$repo_root" branch "$impl_branch" "$snapshot_commit"
mkdir -p "$(dirname "$worktree_path")"
git -C "$repo_root" worktree add "$worktree_path" "$impl_branch" >/dev/null

if [[ "$automation_root_was_present" -eq 0 && -d "$automation_root_path" ]]; then
    ensure_impl_gitignored "$repo_root"
fi

link_standard_local_state "$repo_root" "$worktree_path" "${extra_link_dirs[@]}"

echo "PROJECT_KIND=$DETECTED_PROJECT_KIND"
echo "WORKTREE_KIND=in-repo-temporary-implementation"
echo "REPO_ROOT=$repo_root"
echo "SOURCE_HEAD=$parent_commit"
echo "BRANCH_KIND=$branch_kind"
echo "TOPIC_SLUG=$topic_slug"
echo "IMPL_BRANCH=$impl_branch"
echo "SNAPSHOT_COMMIT=$snapshot_commit"
echo "IMPL_HOME=$impl_home"
echo "WORKTREE=$worktree_path"
echo "COMMIT=$(git -C "$worktree_path" rev-parse HEAD)"
print_link_results
