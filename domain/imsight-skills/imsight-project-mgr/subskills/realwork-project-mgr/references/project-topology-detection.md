---
metadata:
  skill_invocation_notation: >
    Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
    SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
    accepted only as legacy input when SKILL-MAIN.md is absent.
    Skill and subskill entrypoints use bare object paths: `X` invokes skill X and
    `X->Y->Z` invokes subskill Z. Subcommands use parenthesized components:
    `X->cmd()` invokes a direct subcommand, `X->Y->cmd()` invokes a subcommand of
    subskill Y, and `X->parent()->child()` invokes child subcommand child exposed
    by parent subcommand parent. Intermediate subcommands act as object generators.
    Forms such as `X()` and `X->Y()` are invalid for skill or subskill entrypoints.
---

# Project Topology Detection

Detect whether a target repository is a `metaproj` development workspace, an attached realwork inside a `metaproj`, a standalone realwork repository, or an ambiguous partial migration before creating or inspecting temporary in-repo Git worktrees.

## Meta Project vs Realwork Signatures

Do not rely on generic directories such as `context/`, `openspec/`, `docs/`, `skillset/`, `extern/`, `pixi.toml`, or `pixi.lock` to decide workspace type, because standalone or unmigrated realwork repositories may also contain them. Use the structural signatures below instead:

| Signature | Where Checked | Meaning |
| --- | --- | --- |
| `.gitmodules` entries with `path = realworks/<key>` | Primary repo root | Registered branch submodules under `realworks/` (`meta-project` indicator) |
| `meta_configs/workspace.toml` | Primary repo root | Metaproj explicit-checkout launcher configuration (`meta-project` indicator) |
| `meta_src/`, `meta_scripts/`, or `meta_configs/` | Primary repo root | Metaproj-owned tooling and configuration directories (`meta-project` indicator) |
| Current Git branch named `metaproj` | Primary repo root | Standard metaproj workspace branch (`meta-project` indicator) |
| `realworks/` directory without `.gitmodules` `realworks/*` mapping | Primary repo root | Partial or unconfigured metaproj layout (`ambiguous` indicator) |
| Meta indicator coexisting with root `src/` | Primary repo root | Incomplete migration or mixed root (`ambiguous` indicator; metaproj owns no root `src/`) |
| Non-empty `git rev-parse --show-superproject-working-tree` whose ancestor has meta indicators (or path lies under `<superproject>/realworks/`) | Enclosing superproject chain | Attached realwork checkout owned by an enclosing `metaproj` (`attached-realwork`) |
| None of the above in a valid Git working tree | Primary repo root | Standalone functional/combined repository (`standalone-realwork`) |

## Deterministic Check

Run the bundled detector before creating a temporary worktree:

```bash
bash <realwork-skill-dir>/scripts/detect_project_kind.sh [--repo PATH] [--json]
```

The detector inspects the repository root (resolving the primary checkout if invoked inside an existing linked worktree) and walks enclosing superprojects via `git rev-parse --show-superproject-working-tree`. It outputs `PROJECT_KIND`, `TEMP_WORKTREE_ALLOWED`, `REPO_ROOT`, `PRIMARY_REPO_ROOT`, `BRANCH`, `IS_LINKED_WORKTREE`, `SUPERPROJECT_ROOT`, `META_SIGNATURES`, and `RECOMMENDED_ROUTE`.

## Routing Decisions

| `PROJECT_KIND` | `TEMP_WORKTREE_ALLOWED` | Required Action |
| --- | --- | --- |
| `standalone-realwork` | `true` | Temporary in-repo worktrees are allowed through `imsight-project-mgr->realwork-project-mgr->create-in-repo-worktree()` or `imsight-project-mgr->realwork-project-mgr->impl-in-repo-worktree()`. Reject nesting if `IS_LINKED_WORKTREE=true`. |
| `meta-project` | `false` | Refuse temporary Git worktree creation. Route parallel development to `imsight-project-mgr->meta-project-mgr->manage-realworks()` (or `init-meta-project()` for initial workspace setup). |
| `attached-realwork` | `false` | Refuse temporary in-repo worktrees inside the submodule. Route parallel branch checkout creation to the enclosing workspace via `imsight-project-mgr->meta-project-mgr->manage-realworks()`. |
| `ambiguous` | `false` | Stop and report `META_SIGNATURES`. Clarify repository ownership or complete migration via `imsight-project-mgr->meta-project-mgr->migrate-project()` before creating parallel checkouts. |
