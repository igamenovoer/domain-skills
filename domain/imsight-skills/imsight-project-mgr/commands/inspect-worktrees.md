# Inspect Worktrees

Inspect all Git worktrees registered for a repository without changing files, branches, refs, links, or environments. Use this command before synchronization or retirement and when coordinating several persistent sibling workers.

## Workflow

1. **Resolve the repository and primary checkout**. Use `git worktree list --porcelain` and Git's common directory; do not infer registration from directory names alone.
2. **Classify each worktree**. Identify the primary checkout, temporary in-repo worktrees, persistent sibling worktrees, and unclassified external worktrees. Treat lifecycle metadata and verified `extern/trees/` links as stronger evidence than a name heuristic.
3. **Inspect Git state**. For every accessible worktree, report path, HEAD, branch or detached state, lock or prune state, tracked and untracked cleanliness, and submodule state when relevant. Classify verified skill-owned local-state symlinks separately from unexpected untracked files.
4. **Compare branches**. Resolve the requested primary branch, calculate merge bases and left/right commit counts, and report ahead or behind without fetching unless network access was requested.
5. **Inspect local environment and links**. Report whether `.pixi` is absent, an independent directory, or a symlink; inspect `.proj-local/goal.md`; verify each corresponding `extern/trees/<name>` link with `readlink` and `realpath`.
6. **Report health and suggested operations**. Identify stale registrations, broken or conflicting links, missing goals, dirty workers, detached persistent workers, and workers requiring synchronization. Suggest the narrowest command without mutating state.

If the user's task does not map cleanly to these steps, use your native planning tool to build a read-only inspection plan from the Git, lifecycle, environment, and external-link evidence in this command, then execute the plan.

## Output

Use a compact table with at least `Name`, `Kind`, `Path`, `Branch`, `Clean`, `Versus Primary`, `Pixi`, and `External Link`. Follow it with details for states that require attention. Distinguish local branch divergence from remote-tracking divergence.

## Classification Contract

- `primary`: the main worktree recorded by Git.
- `in-repo temporary`: a registered worktree inside the primary repository, normally under `.imsight-arts/`.
- `sibling persistent`: a registered direct sibling with persistent-worker metadata or a verified `extern/trees/<name>` link.
- `external unclassified`: any other registered worktree. Do not relabel or manage it without evidence.

## Guardrails

- DO NOT run fetch, checkout, switch, reset, merge, rebase, prune, unlink, install, or cleanup commands.
- DO NOT follow linked worktrees in broad recursive searches; inspect each exact registered root separately.
- DO NOT claim a worker is synchronized from working-tree cleanliness alone; compare commits.
- DO NOT treat a missing directory as safe to prune until Git's registration, lock state, and intended lifecycle are understood.

## Example Prompts

- `Use $imsight-project-mgr inspect-worktrees and show which persistent workers are behind main.`
- `Use $imsight-project-mgr inspect-worktrees before we retire the temporary feature worktree.`
