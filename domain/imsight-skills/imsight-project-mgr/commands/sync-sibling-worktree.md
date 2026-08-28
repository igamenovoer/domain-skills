# Sync Sibling Worktree

Synchronize committed work between a persistent sibling worker and the primary checkout in one explicit direction. This command coordinates Git history; it does not copy working files or imply remote publication.

## Workflow

1. **Resolve both endpoints**. Identify the primary checkout and branch, sibling worktree and anchor branch, requested direction, and exact source and target refs. Read the worker's `.proj-local/goal.md` when present.
2. **Inspect before changing refs**. Follow the read-only checks in `inspect-worktrees`. Require clean tracked state and an explicit disposition for unexpected untracked state in every worktree that must switch branches or receive commits. Verified skill-owned local-state symlinks may remain when they cannot be overwritten by the operation. Inspect relevant submodules separately.
3. **Resolve the committed synchronization boundary**. Report source and target commits, merge base, ahead and behind counts, and commits that would move. Uncommitted files remain isolated and are never synchronized by this command.
4. **Choose one integration operation**. Follow **Direction Contract** and repository-specific branch policy. Prefer fast-forward, rebase only unpublished topic branches, and preserve shared history with merges.
5. **Execute and verify**. Run the selected Git operation from the receiving worktree, stop on conflicts, and verify resulting refs, worktree status, submodules, and relevant lightweight tests when required.
6. **Update worker context and report**. Record the last successful synchronization and current topic in `.proj-local/goal.md` when that file is local worker state. Report before and after commits, direction, operation, created commits, unresolved conflicts, and remote state left untouched.

If the request does not name a direction or the source commits, perform the inspection and ask for the missing decision. Do not interpret “sync” as authorization for both directions.

If the task otherwise does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the endpoint, direction, history, conflict, and repository-policy constraints in this command, then execute the plan.

## Direction Contract

### From Primary

Use `from-primary` to bring the selected primary branch into the sibling worker.

- Resolve whether the worker currently has its anchor branch or a topic branch checked out.
- Update the worker anchor from the selected primary branch first when the anchor is the intended long-lived baseline.
- Fast-forward the anchor when possible. Merge when the persistent shared anchor has diverged. Rebase only when the branch is unpublished and the user or repository policy selects it.
- If a topic branch must receive the updated anchor, integrate it as a second explicit step and report the operation separately.
- A request for the latest remote state requires an explicit fetch or pull decision; local synchronization alone uses existing refs.

### To Primary

Use `to-primary` to integrate a completed topic branch or explicit commit range into the selected primary branch.

- Require the topic branch or commit range. Do not integrate every commit reachable from a persistent worker anchor by assumption.
- Respect repository requirements for local merge, cherry-pick, pull request, review, and verification.
- Keep remote pushes, pull-request creation, and external messages outside the default local synchronization boundary unless the user explicitly requests them.
- Return the persistent physical worktree to its anchor branch after successful feature integration when safe and requested; do not retire it.

## Conflict Contract

- Stop when merge or rebase conflicts occur and report the receiving worktree and exact in-progress Git operation.
- Preserve the conflict state for deliberate resolution unless the user asks to abort.
- Never use hard reset, force checkout, force push, or automatic conflict preference as a generic synchronization strategy.
- Do not hide submodule conflicts behind a clean superproject report.

## Guardrails

- DO NOT change either endpoint when it contains uncommitted work or unexpected untracked files that the operation could disturb.
- DO NOT sync untracked or ignored files by copying them between worktrees.
- DO NOT create synthetic snapshot commits for sibling synchronization.
- DO NOT fetch, pull, push, or open a pull request unless the request includes the corresponding remote action.
- DO NOT delete integrated topic branches unless the user explicitly asks.
- DO NOT retire the persistent worker after synchronization.

## Example Prompts

- `Use $imsight-project-mgr sync-sibling-worktree from primary main into shadowkv-kernels.`
- `Use $imsight-project-mgr sync-sibling-worktree to primary by integrating feature/fused-rope from shadowkv-kernels.`
