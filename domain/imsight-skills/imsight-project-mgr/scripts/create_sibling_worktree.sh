#!/usr/bin/env bash

set -euo pipefail

print_usage() {
    cat <<'EOF'
Usage: create_sibling_worktree.sh --name NAME --goal TEXT [--repo PATH] [--base REF] [--branch NAME] [--path PATH] [--pixi-mode isolated|shared|none] [--no-pixi-install] [--link-dir RELATIVE_DIR]

Create or reconcile a persistent direct-sibling Git worktree, its worker-local
goal, local-state links, Pixi environment policy, and extern/trees view.

Options:
  --repo PATH             Repository path. Default: current working tree.
  --name NAME             Stable hyphen-case worker name. Required.
  --goal TEXT             Concrete worker purpose. Required.
  --base REF              Base ref for a new worker branch. Default: current branch.
  --branch NAME           Worker branch. Default: worker/<name>.
  --path PATH             Direct-sibling path. Default: <repo-parent>/<repo-name>-<name>.
  --pixi-mode MODE        Pixi mode: isolated, shared, or none. Default: isolated.
  --no-pixi-install       Keep isolated mode but defer pixi install.
  --link-dir PATH         Extra repository-relative local-state directory to link.
  -h, --help              Show this help.
EOF
}

resolve_repo_root() {
    local repo_arg="$1"

    if [[ -n "$repo_arg" ]]; then
        git -C "$repo_arg" rev-parse --show-toplevel
    else
        git rev-parse --show-toplevel
    fi
}

is_pixi_project() {
    local repo_root="$1"
    local pyproject_path="$repo_root/pyproject.toml"

    if [[ -f "$repo_root/pixi.toml" || -f "$repo_root/pixi.lock" ]]; then
        return 0
    fi

    if [[ -f "$pyproject_path" ]] && grep -Eq '^\[tool\.pixi([.]|])?' "$pyproject_path"; then
        return 0
    fi

    return 1
}

has_tracked_files() {
    local repo_root="$1"
    local rel_path="$2"

    git -C "$repo_root" ls-files -- "$rel_path" | grep -q .
}

has_tracked_files_in_worktree() {
    local worktree_path="$1"
    local rel_path="$2"

    git -C "$worktree_path" ls-files -- "$rel_path" | grep -q .
}

is_registered_worktree() {
    local repo_root="$1"
    local wanted_path="$2"
    local line=""

    while IFS= read -r line; do
        if [[ "$line" == worktree\ * && "${line#worktree }" == "$wanted_path" ]]; then
            return 0
        fi
    done < <(git -C "$repo_root" worktree list --porcelain)

    return 1
}

registered_branch_at_path() {
    local repo_root="$1"
    local wanted_path="$2"
    local current_path=""
    local line=""

    while IFS= read -r line; do
        case "$line" in
            worktree\ *)
                current_path="${line#worktree }"
                ;;
            branch\ *)
                if [[ "$current_path" == "$wanted_path" ]]; then
                    printf '%s\n' "${line#branch refs/heads/}"
                    return 0
                fi
                ;;
            detached)
                if [[ "$current_path" == "$wanted_path" ]]; then
                    return 1
                fi
                ;;
        esac
    done < <(git -C "$repo_root" worktree list --porcelain)

    return 1
}

branch_checkout_path() {
    local repo_root="$1"
    local wanted_branch="$2"
    local current_path=""
    local line=""

    while IFS= read -r line; do
        case "$line" in
            worktree\ *)
                current_path="${line#worktree }"
                ;;
            branch\ refs/heads/*)
                if [[ "${line#branch refs/heads/}" == "$wanted_branch" ]]; then
                    printf '%s\n' "$current_path"
                    return 0
                fi
                ;;
        esac
    done < <(git -C "$repo_root" worktree list --porcelain)

    return 1
}

validate_worker_name() {
    [[ "$1" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

validate_link_dir() {
    local rel_path="$1"

    if [[ -z "$rel_path" ]]; then
        echo "error: link directory cannot be empty" >&2
        exit 2
    fi

    case "$rel_path" in
        /*|..|../*|*/../*|*/..)
            echo "error: link directory must remain repository-relative: $rel_path" >&2
            exit 2
            ;;
        .pixi)
            echo "error: select .pixi through --pixi-mode, not --link-dir" >&2
            exit 2
            ;;
    esac
}

add_unique_dir() {
    local rel_path="$1"

    validate_link_dir "$rel_path"
    if [[ -z "${seen_link_dirs[$rel_path]+x}" ]]; then
        seen_link_dirs["$rel_path"]=1
        link_dirs+=("$rel_path")
    fi
}

link_local_state_if_safe() {
    local repo_root="$1"
    local worktree_path="$2"
    local rel_path="$3"
    local source_path="$repo_root/$rel_path"
    local target_path="$worktree_path/$rel_path"

    if [[ ! -d "$source_path" && ! -L "$source_path" ]]; then
        skipped_missing_dirs+=("$rel_path")
        return
    fi

    if has_tracked_files_in_worktree "$worktree_path" "$rel_path"; then
        skipped_tracked_dirs+=("$rel_path")
        return
    fi

    if [[ -L "$target_path" ]] && [[ "$(realpath "$target_path")" == "$(realpath "$source_path")" ]]; then
        reused_link_dirs+=("$rel_path")
        return
    fi

    if [[ -e "$target_path" || -L "$target_path" ]]; then
        skipped_conflicting_dirs+=("$rel_path")
        return
    fi

    mkdir -p "$(dirname "$target_path")"
    ln -s "$source_path" "$target_path"
    linked_dirs+=("$rel_path")
}

repo_arg=""
worker_name=""
worker_goal=""
base_ref=""
worker_branch=""
requested_path=""
pixi_mode="isolated"
install_pixi=1
declare -a extra_link_dirs=()

while (($# > 0)); do
    case "$1" in
        --repo)
            [[ $# -ge 2 ]] || { echo "error: --repo requires a value" >&2; exit 2; }
            repo_arg="$2"
            shift 2
            ;;
        --name)
            [[ $# -ge 2 ]] || { echo "error: --name requires a value" >&2; exit 2; }
            worker_name="$2"
            shift 2
            ;;
        --goal)
            [[ $# -ge 2 ]] || { echo "error: --goal requires a value" >&2; exit 2; }
            worker_goal="$2"
            shift 2
            ;;
        --base|--ref)
            [[ $# -ge 2 ]] || { echo "error: --base requires a value" >&2; exit 2; }
            base_ref="$2"
            shift 2
            ;;
        --branch)
            [[ $# -ge 2 ]] || { echo "error: --branch requires a value" >&2; exit 2; }
            worker_branch="$2"
            shift 2
            ;;
        --path)
            [[ $# -ge 2 ]] || { echo "error: --path requires a value" >&2; exit 2; }
            requested_path="$2"
            shift 2
            ;;
        --pixi-mode)
            [[ $# -ge 2 ]] || { echo "error: --pixi-mode requires a value" >&2; exit 2; }
            pixi_mode="$2"
            shift 2
            ;;
        --no-pixi-install)
            install_pixi=0
            shift
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

if ! validate_worker_name "$worker_name"; then
    echo "error: --name must use hyphen-case like kernel-worker" >&2
    exit 2
fi

if [[ -z "$worker_goal" ]]; then
    echo "error: --goal is required" >&2
    exit 2
fi

case "$pixi_mode" in
    isolated|shared|none)
        ;;
    *)
        echo "error: --pixi-mode must be isolated, shared, or none" >&2
        exit 2
        ;;
esac

repo_root="$(realpath "$(resolve_repo_root "$repo_arg")")"
repo_parent="$(dirname "$repo_root")"
repo_name="$(basename "$repo_root")"

if [[ -z "$base_ref" ]]; then
    base_ref="$(git -C "$repo_root" branch --show-current)"
fi

if [[ -z "$base_ref" ]]; then
    echo "error: no current branch detected; pass --base <ref> explicitly" >&2
    exit 1
fi

base_commit="$(git -C "$repo_root" rev-parse --verify "$base_ref^{commit}")"

if [[ -z "$worker_branch" ]]; then
    worker_branch="worker/$worker_name"
fi

if ! git check-ref-format --branch "$worker_branch" >/dev/null; then
    echo "error: invalid worker branch: $worker_branch" >&2
    exit 2
fi

if [[ -z "$requested_path" ]]; then
    worktree_path="$repo_parent/$repo_name-$worker_name"
else
    case "$requested_path" in
        /*)
            worktree_path="$requested_path"
            ;;
        *)
            worktree_path="$repo_parent/$requested_path"
            ;;
    esac
fi

worktree_path="$(realpath -m "$worktree_path")"
if [[ "$(dirname "$worktree_path")" != "$repo_parent" || "$worktree_path" == "$repo_root" ]]; then
    echo "error: sibling worktree must be a direct child of repository parent: $repo_parent" >&2
    exit 1
fi

trees_dir="$repo_root/extern/trees"
external_link="$trees_dir/$worker_name"
if [[ ! -f "$repo_root/extern/README.md" ]]; then
    echo "error: reconcile extern/README.md before creating a sibling worker" >&2
    exit 1
fi

if [[ ! -f "$trees_dir/README.md" ]]; then
    echo "error: reconcile extern/trees/README.md before creating a sibling worker" >&2
    exit 1
fi

if ! git -C "$repo_root" check-ignore --quiet --no-index -- ".proj-local/goal.md" \
    && ! git -C "$repo_root" ls-files --error-unmatch -- ".proj-local/goal.md" >/dev/null 2>&1; then
    echo "error: .proj-local/goal.md must be ignored or intentionally tracked before worker creation" >&2
    exit 1
fi

if ! git -C "$repo_root" check-ignore --quiet --no-index -- "extern/trees/$worker_name"; then
    echo "error: extern/trees/$worker_name is not ignored by repository policy" >&2
    exit 1
fi

if [[ -e "$external_link" && ! -L "$external_link" ]]; then
    echo "error: external tree entry exists and is not a symlink: $external_link" >&2
    exit 1
fi

if [[ -L "$external_link" ]] && [[ "$(realpath -m "$external_link")" != "$worktree_path" ]]; then
    echo "error: existing external tree link points elsewhere: $external_link" >&2
    exit 1
fi

if is_pixi_project "$repo_root"; then
    if [[ "$pixi_mode" != "none" ]] && ! git -C "$repo_root" check-ignore --quiet --no-index -- ".pixi/environment-probe"; then
        echo "error: .pixi must be ignored before creating or sharing a worker environment" >&2
        exit 1
    fi

    case "$pixi_mode" in
        isolated)
            if [[ -L "$worktree_path/.pixi" ]]; then
                echo "error: isolated Pixi mode conflicts with existing .pixi symlink" >&2
                exit 1
            fi
            if [[ "$install_pixi" -eq 1 && ! -d "$worktree_path/.pixi" ]] && ! command -v pixi >/dev/null 2>&1; then
                echo "error: pixi is required for isolated installation; pass --no-pixi-install to defer" >&2
                exit 1
            fi
            ;;
        shared)
            if [[ ! -d "$repo_root/.pixi" && ! -L "$repo_root/.pixi" ]]; then
                echo "error: shared Pixi mode requires a source .pixi environment" >&2
                exit 1
            fi
            if has_tracked_files "$repo_root" ".pixi"; then
                echo "error: shared Pixi mode cannot replace tracked .pixi content" >&2
                exit 1
            fi
            if [[ -e "$worktree_path/.pixi" || -L "$worktree_path/.pixi" ]]; then
                if [[ ! -L "$worktree_path/.pixi" ]] || [[ "$(realpath "$worktree_path/.pixi")" != "$(realpath "$repo_root/.pixi")" ]]; then
                    echo "error: shared Pixi mode conflicts with existing worker .pixi" >&2
                    exit 1
                fi
            fi
            ;;
        none)
            if [[ -e "$worktree_path/.pixi" || -L "$worktree_path/.pixi" ]]; then
                echo "error: Pixi mode none conflicts with existing worker .pixi" >&2
                exit 1
            fi
            ;;
    esac
fi

creation_status=""
if [[ -e "$worktree_path" || -L "$worktree_path" ]]; then
    if [[ ! -d "$worktree_path" ]] || ! is_registered_worktree "$repo_root" "$worktree_path"; then
        echo "error: sibling path exists but is not the expected registered worktree: $worktree_path" >&2
        exit 1
    fi

    existing_branch="$(registered_branch_at_path "$repo_root" "$worktree_path" || true)"
    if [[ "$existing_branch" != "$worker_branch" ]]; then
        echo "error: existing worktree is not on requested worker branch: ${existing_branch:-detached}" >&2
        exit 1
    fi
    creation_status="reused-worktree"
else
    checked_out_path="$(branch_checkout_path "$repo_root" "$worker_branch" || true)"
    if [[ -n "$checked_out_path" ]]; then
        echo "error: worker branch is already checked out at: $checked_out_path" >&2
        exit 1
    fi

    if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$worker_branch"; then
        git -C "$repo_root" worktree add "$worktree_path" "$worker_branch"
        creation_status="created-from-existing-branch"
    else
        git -C "$repo_root" worktree add -b "$worker_branch" "$worktree_path" "$base_commit"
        creation_status="created-branch-and-worktree"
    fi
fi

declare -A seen_link_dirs=()
declare -a link_dirs=()
declare -a linked_dirs=()
declare -a reused_link_dirs=()
declare -a skipped_tracked_dirs=()
declare -a skipped_missing_dirs=()
declare -a skipped_conflicting_dirs=()

for dir_name in \
    .claude \
    .codex \
    .gemini \
    .github \
    .aider \
    .cursor \
    .continue \
    .windsurf \
    .kiro
do
    add_unique_dir "$dir_name"
done

for dir_name in "${extra_link_dirs[@]}"; do
    add_unique_dir "$dir_name"
done

for dir_name in "${link_dirs[@]}"; do
    link_local_state_if_safe "$repo_root" "$worktree_path" "$dir_name"
done

effective_pixi_mode="none"
pixi_status="not-applicable"
if is_pixi_project "$repo_root"; then
    effective_pixi_mode="$pixi_mode"
    case "$pixi_mode" in
        isolated)
            if [[ -d "$worktree_path/.pixi" ]]; then
                pixi_status="existing-independent-environment"
            elif [[ "$install_pixi" -eq 0 ]]; then
                pixi_status="installation-deferred"
            else
                (cd "$worktree_path" && pixi install)
                pixi_status="installed-independent-environment"
            fi
            ;;
        shared)
            if [[ -L "$worktree_path/.pixi" ]] && [[ "$(realpath "$worktree_path/.pixi")" == "$(realpath "$repo_root/.pixi")" ]]; then
                pixi_status="reused-shared-link"
            else
                ln -s "$repo_root/.pixi" "$worktree_path/.pixi"
                pixi_status="created-shared-link"
            fi
            ;;
        none)
            pixi_status="disabled"
            ;;
    esac
fi

goal_dir="$worktree_path/.proj-local"
goal_path="$goal_dir/goal.md"
goal_status=""
mkdir -p "$goal_dir"
if [[ -e "$goal_path" || -L "$goal_path" ]]; then
    goal_status="preserved-existing"
else
    goal_base_label="Initial base"
    if [[ "$creation_status" != "created-branch-and-worktree" ]]; then
        goal_base_label="Reconciliation base"
    fi
    {
        printf '# Worker Goal\n\n'
        printf 'Purpose: %s\n\n' "$worker_goal"
        printf -- '- Lifecycle: persistent sibling worker\n'
        printf -- '- Anchor branch: `%s`\n' "$worker_branch"
        printf -- '- %s: `%s` at `%s`\n' "$goal_base_label" "$base_ref" "$base_commit"
        printf -- '- Worker commit at initialization: `%s`\n' "$(git -C "$worktree_path" rev-parse HEAD)"
        printf -- '- Pixi mode: `%s`\n' "$effective_pixi_mode"
        printf -- '- Synchronization: use explicit `from-primary` or `to-primary` operations\n'
        printf -- '- Retirement: explicit worker retirement only; feature completion does not remove this tree\n'
    } > "$goal_path"
    goal_status="created"
fi

if git -C "$worktree_path" check-ignore --quiet --no-index -- ".proj-local/goal.md"; then
    goal_tracking="ignored"
elif git -C "$worktree_path" ls-files --error-unmatch -- ".proj-local/goal.md" >/dev/null 2>&1; then
    goal_tracking="tracked"
else
    goal_tracking="untracked"
fi

if [[ -L "$external_link" ]]; then
    if [[ "$(realpath "$external_link")" != "$worktree_path" ]]; then
        echo "error: existing external tree link points elsewhere: $external_link" >&2
        exit 1
    fi
    external_link_status="reused"
else
    relative_target="$(realpath --relative-to="$trees_dir" "$worktree_path")"
    ln -s "$relative_target" "$external_link"
    external_link_status="created"
fi

source_dirty="false"
if [[ -n "$(git -C "$repo_root" status --short --untracked-files=all)" ]]; then
    source_dirty="true"
fi

echo "WORKTREE_KIND=sibling-persistent"
echo "CREATION_STATUS=$creation_status"
echo "REPO_ROOT=$repo_root"
echo "SOURCE_DIRTY=$source_dirty"
echo "WORKER_NAME=$worker_name"
echo "WORKTREE=$worktree_path"
echo "BASE_REF=$base_ref"
echo "BASE_COMMIT=$base_commit"
echo "BRANCH=$worker_branch"
echo "COMMIT=$(git -C "$worktree_path" rev-parse HEAD)"
echo "PIXI_MODE=$effective_pixi_mode"
echo "PIXI_STATUS=$pixi_status"
echo "GOAL=$goal_path"
echo "GOAL_STATUS=$goal_status"
echo "GOAL_TRACKING=$goal_tracking"
echo "EXTERNAL_TREE=$external_link"
echo "EXTERNAL_TREE_STATUS=$external_link_status"
echo "EXTERNAL_TREE_TARGET=$(realpath "$external_link")"

for dir_name in "${linked_dirs[@]}"; do
    echo "LINKED=$dir_name"
done

for dir_name in "${reused_link_dirs[@]}"; do
    echo "REUSED_LINK=$dir_name"
done

for dir_name in "${skipped_tracked_dirs[@]}"; do
    echo "SKIPPED_TRACKED=$dir_name"
done

for dir_name in "${skipped_missing_dirs[@]}"; do
    echo "SKIPPED_MISSING=$dir_name"
done

for dir_name in "${skipped_conflicting_dirs[@]}"; do
    echo "SKIPPED_CONFLICT=$dir_name"
done
