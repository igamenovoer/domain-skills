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

# Retire Worktree

Safely remove a registered temporary in-repo Git worktree after proving that its useful work remains reachable. Retirement is an explicit destructive lifecycle operation; feature completion alone does not authorize it.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Detect project topology and resolve the exact worktree**. Run `bash <realwork-skill-dir>/scripts/detect_project_kind.sh --repo <target>` and apply [project-topology-detection.md](../references/project-topology-detection.md). If `PROJECT_KIND` is `meta-project` or `attached-realwork`, route submodule removal to `imsight-project-mgr->meta-project-mgr->manage-realworks()` (or legacy linked-worktree migration to `meta-project-mgr`'s Git lifecycle guide). Resolve the target worktree's registered canonical path, lifecycle kind, current branch or detached commit, and explicit user authorization.
2. **Inspect retention evidence**. Follow [inspect-worktrees.md](inspect-worktrees.md). Report tracked, untracked, ignored, and submodule state, commits not reachable from retained branches, active Git operations, locks, and worktree-specific files such as an independent `.pixi`.
3. **Resolve what must survive**. Require the user to preserve, commit, integrate, copy out, or deliberately discard any material state whose disposition is unclear. A branch that remains reachable may be kept after the directory is removed.
4. **Unlink owned local-state symlinks**. Identify skill-owned local-state symlinks inside the retiring worktree (such as `.claude`, `.codex`, `.gemini`, or shared `.pixi`). After authorization, unlink only those verified symlink paths inside the retiring worktree and leave their source targets untouched.
5. **Remove through Git**. Use `git worktree remove <exact-path>` without `--force`. Stop if Git still refuses and inspect the remaining state. Never replace this step with recursive filesystem deletion.
6. **Optionally delete the branch**. Delete a temporary worktree branch only when the user explicitly requested branch deletion and Git proves its commits remain reachable as intended. Never force-delete by default.
7. **Verify and report**. Confirm that Git no longer registers the path, source `.pixi` and local-state targets remain untouched, and retained refs still resolve. State whether the branch and commits remain recoverable.

If the task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the topology, retention, symlink-cleanup, and destructive-action constraints in this command, then execute the plan.

## Lifecycle Rules

- Temporary in-repo worktrees become retirement candidates after their bounded task is integrated or deliberately abandoned.
- A shared `.pixi` symlink inside a retiring worktree must be unlinked only inside the worktree; its source `.pixi` in the primary checkout must remain untouched.
- Removing an independent `.pixi` or ignored temporary files inside the worktree can be hard to recover; report them before removal.

## Guardrails

- DO NOT infer retirement authorization from a clean worktree, merged branch, completed feature, or old timestamp.
- DO NOT use `rm -rf`, `git worktree remove --force`, hard reset, force checkout, or force branch deletion.
- DO NOT remove or modify the source targets of symlinked `.pixi` or agent directories in the primary checkout.
- DO NOT delete a branch as an implicit consequence of removing its worktree.
- DO NOT prune locked, missing, or unfamiliar worktrees without determining their ownership.
- DO NOT claim recovery is possible unless a retained ref or verified commit identifier remains.

## Example Prompts

- `Use $imsight-project-mgr->realwork-project-mgr retire-worktree to remove the completed temporary feature worktree while keeping its branch.`
- `Use $imsight-project-mgr->realwork-project-mgr retire-worktree to clean up .imsight-arts/worktrees/worktree-20261120-080000 after confirming no unmerged changes remain.`
