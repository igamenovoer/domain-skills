#!/usr/bin/env bash

set -euo pipefail

print_usage() {
    cat <<'EOF'
Usage: detect_project_kind.sh [--repo PATH] [--json]

Inspect repository layout and Git identity to distinguish a metaproj workspace,
an attached realwork submodule, a standalone realwork repository, or an
ambiguous hybrid layout.

Options:
  --repo PATH   Target repository path. Default: current working directory.
  --json        Emit JSON instead of KEY=VALUE lines.
  -h, --help    Show this help.
EOF
}

json_escape() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\t'/\\t}"
    value="${value//$'\r'/\\r}"
    value="${value//$'\n'/\\n}"
    printf '%s' "$value"
}

has_realworks_submodules() {
    local root="$1"
    local gitmodules="$root/.gitmodules"

    [[ -f "$gitmodules" ]] || return 1
    git config --file "$gitmodules" --get-regexp '^submodule\..*\.path$' 2>/dev/null \
        | awk '
            {
                $1 = ""
                sub(/^ /, "")
                if ($0 ~ /^realworks\//) {
                    found = 1
                }
            }
            END { exit(found ? 0 : 1) }
        '
}

collect_root_meta_signals() {
    local root="$1"
    local -n out_signals_ref="$2"
    local -n out_strong_ref="$3"
    local -n out_realworks_dir_ref="$4"
    local branch=""

    out_signals_ref=()
    out_strong_ref=0
    out_realworks_dir_ref=0

    if has_realworks_submodules "$root"; then
        out_signals_ref+=("realworks_submodules")
        out_strong_ref=1
    fi

    if [[ -f "$root/meta_configs/workspace.toml" ]]; then
        out_signals_ref+=("meta_configs_workspace_toml")
        out_strong_ref=1
    fi

    if [[ -d "$root/meta_src" ]]; then
        out_signals_ref+=("meta_src_dir")
        out_strong_ref=1
    fi

    if [[ -d "$root/meta_scripts" ]]; then
        out_signals_ref+=("meta_scripts_dir")
        out_strong_ref=1
    fi

    if [[ -d "$root/meta_configs" ]]; then
        out_signals_ref+=("meta_configs_dir")
        out_strong_ref=1
    fi

    branch="$(git -C "$root" branch --show-current 2>/dev/null || true)"
    if [[ "$branch" == "metaproj" ]]; then
        out_signals_ref+=("metaproj_branch")
        out_strong_ref=1
    fi

    if [[ -d "$root/realworks" ]]; then
        out_signals_ref+=("realworks_dir")
        out_realworks_dir_ref=1
    fi
}

find_enclosing_meta_superproject() {
    local start_root="$1"
    local cur="$start_root"
    local sp=""
    local sp_real=""
    local hop=0
    local -a sp_signals=()
    local sp_strong=0
    local sp_realworks_dir=0

    while ((hop < 8)); do
        sp="$(git -C "$cur" rev-parse --show-superproject-working-tree 2>/dev/null || true)"
        if [[ -z "$sp" ]]; then
            break
        fi
        sp_real="$(realpath "$sp")"
        if [[ "$cur" == "$sp_real/realworks/"* ]]; then
            printf '%s\n' "$sp_real"
            return 0
        fi
        collect_root_meta_signals "$sp_real" sp_signals sp_strong sp_realworks_dir
        if ((sp_strong == 1 || sp_realworks_dir == 1)); then
            printf '%s\n' "$sp_real"
            return 0
        fi
        cur="$sp_real"
        hop=$((hop + 1))
    done

    return 1
}

repo_arg=""
emit_json=0

while (($# > 0)); do
    case "$1" in
        --repo)
            [[ $# -ge 2 ]] || { echo "error: --repo requires a value" >&2; exit 2; }
            repo_arg="$2"
            shift 2
            ;;
        --json)
            emit_json=1
            shift
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

target_dir="${repo_arg:-.}"
if [[ ! -d "$target_dir" ]]; then
    echo "error: repository path does not exist: $target_dir" >&2
    exit 1
fi

inside_work_tree="$(git -C "$target_dir" rev-parse --is-inside-work-tree 2>/dev/null || true)"
if [[ "$inside_work_tree" != "true" ]]; then
    echo "error: not inside a Git working tree: $target_dir" >&2
    exit 1
fi

repo_root="$(realpath "$(git -C "$target_dir" rev-parse --show-toplevel)")"
git_dir="$(realpath "$(git -C "$repo_root" rev-parse --absolute-git-dir)")"
raw_common_dir="$(git -C "$repo_root" rev-parse --git-common-dir)"
if [[ "$raw_common_dir" == /* ]]; then
    common_dir="$(realpath "$raw_common_dir")"
else
    common_dir="$(realpath "$repo_root/$raw_common_dir")"
fi

is_linked_worktree="false"
primary_repo_root="$repo_root"
if [[ "$git_dir" != "$common_dir" ]]; then
    is_linked_worktree="true"
    first_worktree="$(
        git -C "$repo_root" worktree list --porcelain \
            | awk '/^worktree / { sub(/^worktree /, ""); print; exit }'
    )"
    if [[ -n "$first_worktree" ]]; then
        primary_repo_root="$(realpath "$first_worktree")"
    fi
fi

current_branch="$(git -C "$repo_root" branch --show-current 2>/dev/null || true)"

declare -a root_signals=()
strong_meta=0
has_realworks_dir=0
collect_root_meta_signals "$primary_repo_root" root_signals strong_meta has_realworks_dir

superproject_root=""
if ((strong_meta == 0 && has_realworks_dir == 0)); then
    superproject_root="$(find_enclosing_meta_superproject "$primary_repo_root" || true)"
fi

project_kind="standalone-realwork"
temp_worktree_allowed="true"
recommended_route="realwork-project-mgr"

if ((strong_meta == 1)); then
    if [[ -d "$primary_repo_root/src" ]]; then
        root_signals+=("root_src_present")
        project_kind="ambiguous"
        temp_worktree_allowed="false"
        recommended_route="clarify-workspace"
    else
        project_kind="meta-project"
        temp_worktree_allowed="false"
        recommended_route="meta-project-mgr"
    fi
elif ((has_realworks_dir == 1)); then
    project_kind="ambiguous"
    temp_worktree_allowed="false"
    recommended_route="clarify-workspace"
elif [[ -n "$superproject_root" ]]; then
    root_signals+=("enclosing_meta_superproject")
    project_kind="attached-realwork"
    temp_worktree_allowed="false"
    recommended_route="meta-project-mgr"
fi

if ((${#root_signals[@]} == 0)); then
    meta_signatures="none"
else
    meta_signatures="$(IFS=,; printf '%s' "${root_signals[*]}")"
fi

if ((emit_json == 1)); then
    sig_json="[]"
    if ((${#root_signals[@]} > 0)); then
        sig_items=""
        for sig in "${root_signals[@]}"; do
            if [[ -n "$sig_items" ]]; then
                sig_items="$sig_items, "
            fi
            sig_items="$sig_items\"$(json_escape "$sig")\""
        done
        sig_json="[$sig_items]"
    fi
    cat <<EOF
{
  "project_kind": "$(json_escape "$project_kind")",
  "temp_worktree_allowed": $temp_worktree_allowed,
  "repo_root": "$(json_escape "$repo_root")",
  "primary_repo_root": "$(json_escape "$primary_repo_root")",
  "branch": "$(json_escape "$current_branch")",
  "is_linked_worktree": $is_linked_worktree,
  "superproject_root": "$(json_escape "$superproject_root")",
  "meta_signatures": $sig_json,
  "recommended_route": "$(json_escape "$recommended_route")"
}
EOF
else
    echo "PROJECT_KIND=$project_kind"
    echo "TEMP_WORKTREE_ALLOWED=$temp_worktree_allowed"
    echo "REPO_ROOT=$repo_root"
    echo "PRIMARY_REPO_ROOT=$primary_repo_root"
    echo "BRANCH=$current_branch"
    echo "IS_LINKED_WORKTREE=$is_linked_worktree"
    echo "SUPERPROJECT_ROOT=$superproject_root"
    echo "META_SIGNATURES=$meta_signatures"
    echo "RECOMMENDED_ROUTE=$recommended_route"
fi
