# Create In-Repo Worktree

Create a temporary clean worktree inside the source repository while leaving the active checkout untouched. Use this command for one bounded task, inspection, feature, or fix that normally ends with explicit retirement. Use `create-sibling-worktree` for a persistent worker outside the repository.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Resolve the source repository and ref**. Use the user-selected ref, or the current branch; require an explicit ref for a detached checkout.
2. **Resolve an ignored in-repo target**. Use the user-provided path or `<repo-root>/.imsight-arts/worktrees/worktree-<UTC timestamp>`. The resolved path must remain inside the repository and must not be `extern/trees/`.
3. **Create the worktree with the bundled helper**. Run the command in **Helper Invocation** and never copy the repository manually.
4. **Apply temporary local-state policy**. Follow `../references/worktree-local-state-policy.md`. Share an existing eligible `.pixi` by default for a Pixi-managed repository.
5. **Verify and report**. Report the worktree kind, path, source ref, commit, checkout mode, Pixi mode, linked resources, and tracked or missing skips. State that retirement remains explicit.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the Git, path, local-state, lifecycle, and safety constraints in this command, then execute the plan.

## Defaults

- Lifecycle kind: temporary in-repo worktree.
- Source ref: current branch from `git branch --show-current`.
- Target path: `<repo-root>/.imsight-arts/worktrees/worktree-<timestamp>`.
- Timestamp: `YYYYMMDD-HHMMSS` in UTC.
- Pixi mode: `shared` when the repository is Pixi-managed and the source `.pixi` exists; otherwise `none`.
- Extra link directories: none.
- External tree exposure: prohibited.

The target or its containing automation directory must be ignored. Prefer an existing repository rule. If a narrow local exclusion is needed, preserve repository policy and report it; do not expose the nested worktree as ordinary source content.

## Helper Invocation

```bash
bash <skill-dir>/scripts/create_in_repo_worktree.sh [--branch BRANCH] [--path TARGET_PATH] [--link-dir NAME]
```

If the source ref is a local branch not checked out in another worktree, the helper creates a branch-attached worktree. If that branch is already checked out, it creates a detached worktree at the branch tip. This preserves the requested snapshot without disturbing an existing checkout.

## Safety and Reporting

- Do not accept a target outside the repository; route a persistent sibling request to `create-sibling-worktree`.
- Do not switch branches or modify tracked content in the active checkout.
- Do not replace tracked paths with local-state symlinks.
- Do not create an `extern/trees/` link for this lifecycle kind.
- A new worktree may report linked local-state directories as untracked; this is expected.
- Report `WORKTREE_KIND`, `WORKTREE`, `SOURCE_REF`, `CHECKOUT_MODE`, `COMMIT`, `BRANCH`, `PIXI_MODE`, and each `LINKED`, `SKIPPED_TRACKED`, `SKIPPED_MISSING`, or `SKIPPED_CONFLICT` result returned by the helper.
- Use `retire-worktree` after the bounded task is integrated or no longer needed. Do not remove the worktree automatically.

## Example Prompts

- `Use $imsight-project-mgr create-in-repo-worktree to create a temporary clean worktree for this repository.`
- `Use $imsight-project-mgr create-in-repo-worktree from branch release/1.4 and reuse the local agent directories and Pixi environment.`
- `Use $imsight-project-mgr create-in-repo-worktree for a bounded inspection; keep my current uncommitted changes untouched.`
