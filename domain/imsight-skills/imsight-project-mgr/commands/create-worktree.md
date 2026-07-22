# Create Worktree

Create a clean worktree from the current repository while leaving the active checkout untouched. Use the bundled script so branch handling, default paths, and safe local-state links remain consistent.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Resolve the source repository and ref**. Use the user-selected ref, or the current branch; require an explicit ref for a detached checkout.
2. **Resolve the target path**. Use the user-provided path or `<repo-root>/.imsight-arts/worktrees/worktree-<UTC timestamp>`.
3. **Create the worktree with the bundled helper**. Run the command in **Helper Invocation** and never copy the repository manually.
4. **Apply local-state policy**. Pass requested extra link directories and follow `../references/worktree-local-state-policy.md`.
5. **Verify and report**. Report the worktree path, source ref, commit, checkout mode, linked resources, and tracked or missing skips.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the Git, path, local-state, and safety constraints in this command, then execute the plan.

## Defaults

- Source ref: current branch from `git branch --show-current`.
- Target path: `<repo-root>/.imsight-arts/worktrees/worktree-<timestamp>`.
- Timestamp: `YYYYMMDD-HHMMSS` in UTC.
- Extra link directories: none.

## Helper Invocation

```bash
bash <skill-dir>/scripts/create_worktree.sh [--branch BRANCH] [--path TARGET_PATH] [--link-dir NAME]
```

If the source ref is a local branch not checked out in another worktree, the helper creates a branch-attached worktree. If that branch is already checked out, it creates a detached worktree at the branch tip. This preserves the requested snapshot without disturbing an existing checkout.

## Safety and Reporting

- Do not switch branches or modify tracked content in the active checkout.
- Do not replace tracked paths with local-state symlinks.
- A new worktree may report linked local-state directories as untracked; this is expected.
- Report `WORKTREE`, `SOURCE_REF`, `CHECKOUT_MODE`, `COMMIT`, `BRANCH`, and each `LINKED`, `SKIPPED_TRACKED`, or `SKIPPED_MISSING` result returned by the helper.

## Example Prompts

- `Use $imsight-project-mgr create-worktree to create a clean worktree for this repository and link the agent home directories.`
- `Use $imsight-project-mgr create-worktree to make a clean worktree of branch release/1.4 and reuse .claude and .pixi.`
- `Use $imsight-project-mgr create-worktree at /tmp/gig-agents-clean; keep my current uncommitted changes untouched.`
