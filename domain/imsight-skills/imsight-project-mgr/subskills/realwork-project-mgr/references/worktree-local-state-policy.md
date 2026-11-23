# Worktree Local-State Policy

This reference defines the local-resource and Pixi environment contract for temporary in-repo Git worktrees created in standalone realwork repositories.

## Default Link Candidates

- `.claude`
- `.codex`
- `.gemini`
- `.github`
- `.aider`
- `.cursor`
- `.continue`
- `.windsurf`
- `.kiro`

Callers may add repository-relative candidates with repeated `--link-dir` arguments. `.pixi` follows the separate mode policy below and must not be passed through `--link-dir` when Pixi mode is `none`.

## Eligibility Rules

For each candidate:

1. Link it only when the source path exists in the original project root.
2. Skip it when Git tracks files under that path in the target worktree.
3. Never replace tracked worktree content or a conflicting existing path with a symlink.
4. Treat the link as local setup rather than a product change; do not commit it unless the repository intentionally tracks that path.
5. Prefer the narrowest resource link that satisfies the worktree rather than linking broad resource roots.
6. Report linked, tracked-skipped, missing, and conflicting candidates separately.

## Pixi Modes

Resolve one effective mode for a Pixi-managed repository, detected through `pixi.toml`, `pixi.lock`, or `[tool.pixi]` in `pyproject.toml`.

| Mode | Default For | Behavior |
| --- | --- | --- |
| `shared` | Temporary in-repo worktrees | Link the source `.pixi` when it exists and is untracked in the target worktree. Report `none` when no reusable source environment exists. |
| `none` | Explicit environment-free or non-Pixi work | Do not link `.pixi`. |

Sharing `.pixi` couples editable installs, build artifacts, and package state with the source checkout; keep temporary worktrees scoped to short-lived tasks and retire them explicitly when finished.

## Missing Resources and Boundary Rules

Before treating a missing ignored or untracked resource as a product defect, determine whether the narrowest useful local symlink can bridge it safely. Managed datasets and models should follow repository acquisition controls rather than copying large payloads between worktrees.

Do not expose temporary in-repo worktrees through `extern/trees/`, and do not create persistent sibling worktrees or `.proj-local/goal.md` metadata. Multi-branch parallel workspaces belong in a `metaproj` managed by the meta manager.
