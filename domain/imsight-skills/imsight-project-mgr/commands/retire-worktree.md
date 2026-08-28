# Retire Worktree

Safely remove a registered temporary or persistent Git worktree after proving that its useful work remains reachable. Retirement is an explicit destructive lifecycle operation; feature completion alone does not authorize it.

## Workflow

1. **Resolve the exact worktree**. Identify its registered canonical path, lifecycle kind, current branch or detached commit, corresponding `extern/trees/` link, and whether the user explicitly requested retirement of that target.
2. **Inspect retention evidence**. Follow `inspect-worktrees`. Report tracked, untracked, ignored, and submodule state; commits not reachable from retained branches; active Git operations; locks; and worktree-specific files such as an independent `.pixi` and `.proj-local/`.
3. **Resolve what must survive**. Require the user to preserve, commit, integrate, copy out, or deliberately discard any material state whose disposition is unclear. A branch that remains reachable may be kept after the directory is removed.
4. **Resolve owned cleanup**. For a persistent sibling worker, verify the exact `extern/trees/<name>` symlink and determine whether its durable README entry should be removed or marked retired. Identify skill-owned local-state symlinks inside the worktree. After the user authorizes discarding those links, unlink only the verified link paths and leave their targets untouched. Branch deletion is a separate optional action.
5. **Remove through Git**. Use `git worktree remove <exact-path>` without `--force`. Stop if Git still refuses and inspect the remaining state. Never replace this step with recursive filesystem deletion.
6. **Clean verified references**. After successful removal, unlink only the verified `extern/trees/<name>` symlink, reconcile external-layout documentation, and run `git worktree prune` only when stale administrative records are understood.
7. **Optionally delete the branch**. Delete a worktree branch only when the user explicitly requested branch deletion and Git proves its commits remain reachable as intended. Never force-delete by default.
8. **Verify and report**. Confirm that Git no longer registers the path, the external link is absent, retained refs still resolve, and any independent environment was removed with the worktree. State whether the branch and commits remain recoverable.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the retention, lifecycle, external-link, and destructive-action constraints in this command, then execute the plan.

## Lifecycle Rules

- Temporary in-repo worktrees normally become retirement candidates after their bounded task is integrated or abandoned deliberately.
- Persistent sibling worktrees survive completion of individual features. Retire one only when the user retires the worker itself.
- Removing an independent `.pixi` may reclaim substantial disk space, but installed environments and ignored worker-local files may be difficult to recover. Include them in the pre-removal report.
- A shared `.pixi` symlink must be unlinked with the worktree; its source environment must remain untouched.

## Guardrails

- DO NOT infer retirement authorization from a clean worktree, merged branch, completed feature, or old timestamp.
- DO NOT use `rm -rf`, `git worktree remove --force`, hard reset, force checkout, or force branch deletion.
- DO NOT remove an `extern/trees/` entry until its exact target matches the retiring worktree.
- DO NOT delete a branch as an implicit consequence of removing its worktree.
- DO NOT prune locked, missing, or unfamiliar worktrees without determining their ownership.
- DO NOT claim recovery is possible unless a retained ref or verified commit identifier remains.

## Example Prompts

- `Use $imsight-project-mgr retire-worktree to remove the completed temporary feature worktree but keep its branch.`
- `Use $imsight-project-mgr retire-worktree to retire the shadowkv-kernels sibling worker after confirming all feature commits are retained.`
