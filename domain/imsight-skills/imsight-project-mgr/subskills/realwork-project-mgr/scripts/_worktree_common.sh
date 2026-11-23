#!/usr/bin/env bash

# Shared helpers sourced by temporary in-repo worktree scripts.

resolve_repo_root() {
    local repo_arg="$1"
    local target_dir="${repo_arg:-.}"
    local inside_work_tree=""

    if [[ ! -d "$target_dir" ]]; then
        echo "error: repository path does not exist: $target_dir" >&2
        exit 1
    fi

    inside_work_tree="$(git -C "$target_dir" rev-parse --is-inside-work-tree 2>/dev/null || true)"
    if [[ "$inside_work_tree" != "true" ]]; then
        echo "error: not inside a Git working tree: $target_dir" >&2
        exit 1
    fi

    realpath "$(git -C "$target_dir" rev-parse --show-toplevel)"
}

enforce_standalone_realwork() {
    local script_dir="$1"
    local repo_root="$2"
    local detector="$script_dir/detect_project_kind.sh"
    local detection_output=""
    local key=""
    local val=""

    DETECTED_PROJECT_KIND=""
    DETECTED_IS_LINKED_WORKTREE=""
    DETECTED_PRIMARY_REPO_ROOT=""
    DETECTED_SUPERPROJECT_ROOT=""
    DETECTED_META_SIGNATURES=""

    detection_output="$("$detector" --repo "$repo_root")"
    while IFS='=' read -r key val; do
        case "$key" in
            PROJECT_KIND) DETECTED_PROJECT_KIND="$val" ;;
            IS_LINKED_WORKTREE) DETECTED_IS_LINKED_WORKTREE="$val" ;;
            PRIMARY_REPO_ROOT) DETECTED_PRIMARY_REPO_ROOT="$val" ;;
            SUPERPROJECT_ROOT) DETECTED_SUPERPROJECT_ROOT="$val" ;;
            META_SIGNATURES) DETECTED_META_SIGNATURES="$val" ;;
        esac
    done <<< "$detection_output"

    case "$DETECTED_PROJECT_KIND" in
        meta-project)
            echo "error: detected metaproj workspace ($DETECTED_META_SIGNATURES) at $repo_root; use imsight-project-mgr->meta-project-mgr->manage-realworks() instead of temporary Git worktrees" >&2
            exit 1
            ;;
        attached-realwork)
            echo "error: repository at $repo_root is an attached realwork under enclosing metaproj ($DETECTED_SUPERPROJECT_ROOT); use imsight-project-mgr->meta-project-mgr->manage-realworks() instead of temporary in-repo worktrees" >&2
            exit 1
            ;;
        ambiguous)
            echo "error: repository at $repo_root has ambiguous workspace signatures ($DETECTED_META_SIGNATURES); reconcile project ownership or run imsight-project-mgr->meta-project-mgr->migrate-project() before creating temporary worktrees" >&2
            exit 1
            ;;
        standalone-realwork)
            ;;
        *)
            echo "error: unrecognized project classification '$DETECTED_PROJECT_KIND' at $repo_root" >&2
            exit 1
            ;;
    esac

    if [[ "$DETECTED_IS_LINKED_WORKTREE" == "true" ]]; then
        echo "error: target $repo_root is already a linked Git worktree; invoke from the primary checkout ($DETECTED_PRIMARY_REPO_ROOT) instead of nesting worktrees" >&2
        exit 1
    fi
}

validate_in_repo_path() {
    local repo_root="$1"
    local candidate_path="$2"
    local label="$3"
    local rel_path=""

    case "$candidate_path" in
        "$repo_root"/*)
            ;;
        *)
            echo "error: $label must be inside repository: $candidate_path" >&2
            exit 1
            ;;
    esac

    rel_path="${candidate_path#"$repo_root"/}"
    case "$rel_path" in
        extern/trees|extern/trees/*)
            echo "error: extern/trees is not permitted for temporary in-repo worktrees" >&2
            exit 1
            ;;
    esac
}

has_tracked_files_in_worktree() {
    local worktree_path="$1"
    local rel_path="$2"

    git -C "$worktree_path" ls-files -- "$rel_path" | grep -q .
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

validate_link_dir() {
    local dir_name="$1"

    if [[ -z "$dir_name" ]]; then
        echo "error: link directory cannot be empty" >&2
        exit 2
    fi

    case "$dir_name" in
        /*|..|../*|*/../*|*/..)
            echo "error: link directory must remain repository-relative: $dir_name" >&2
            exit 2
            ;;
    esac
}

add_unique_dir() {
    local dir_name="$1"

    validate_link_dir "$dir_name"

    if [[ -z "${seen_link_dirs[$dir_name]+x}" ]]; then
        seen_link_dirs["$dir_name"]=1
        link_dirs+=("$dir_name")
    fi
}

symlink_dir_if_safe() {
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

    if [[ -e "$target_path" || -L "$target_path" ]]; then
        skipped_conflicting_dirs+=("$rel_path")
        return
    fi

    mkdir -p "$(dirname "$target_path")"
    ln -s "$source_path" "$target_path"
    linked_dirs+=("$rel_path")
    if [[ "$rel_path" == ".pixi" ]]; then
        PIXI_MODE="shared"
    fi
}

link_standard_local_state() {
    local repo_root="$1"
    local worktree_path="$2"
    shift 2

    declare -gA seen_link_dirs=()
    declare -ga link_dirs=()
    declare -ga linked_dirs=()
    declare -ga skipped_tracked_dirs=()
    declare -ga skipped_missing_dirs=()
    declare -ga skipped_conflicting_dirs=()

    local dir_name=""
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

    for dir_name in "$@"; do
        add_unique_dir "$dir_name"
    done

    PIXI_MODE="none"
    if is_pixi_project "$repo_root" && [[ -e "$repo_root/.pixi" || -L "$repo_root/.pixi" ]]; then
        add_unique_dir ".pixi"
    fi

    for dir_name in "${link_dirs[@]}"; do
        symlink_dir_if_safe "$repo_root" "$worktree_path" "$dir_name"
    done
}

print_link_results() {
    local dir_name=""

    echo "PIXI_MODE=$PIXI_MODE"

    for dir_name in "${linked_dirs[@]}"; do
        echo "LINKED=$dir_name"
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
}
