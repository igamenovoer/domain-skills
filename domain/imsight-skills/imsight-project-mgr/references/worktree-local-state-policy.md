# Worktree Local-State Policy

This reference defines the local-resource and Pixi environment contract shared by temporary in-repo worktrees and persistent sibling worktrees.

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

Callers may add repository-relative candidates with repeated `--link-dir` arguments. `.pixi` follows the separate mode policy below and must not be smuggled through a generic `--link-dir` when the effective mode is isolated or none.

## Eligibility Rules

For each candidate:

1. Link it only when the source path exists in the original project root.
2. Skip it when Git tracks files under that path.
3. Never replace tracked worktree content or a conflicting existing path with a symlink.
4. Treat the link as local setup rather than a product change; do not commit it unless the repository intentionally tracks that path.
5. Prefer the narrowest resource link that satisfies the worker rather than linking broad resource roots.
6. Report linked, tracked-skipped, missing, and conflicting candidates separately.

## Pixi Modes

Resolve one effective mode for a Pixi-managed repository, detected through `pixi.toml`, `pixi.lock`, or `[tool.pixi]` in `pyproject.toml`.

| Mode | Default For | Behavior |
| --- | --- | --- |
| `shared` | Temporary in-repo worktrees | Link the source `.pixi` when it exists and is untracked. Report `none` when no reusable source environment exists. |
| `isolated` | Persistent sibling worktrees | Do not link `.pixi`. Materialize an independent environment with `pixi install` unless installation was explicitly deferred. |
| `none` | Explicit environment-free work | Do not link or install `.pixi`. |

An explicitly selected `shared` sibling mode is valid when the user accepts coupled editable installs, build artifacts, package state, and concurrent environment mutation. Report this coupling. An isolated environment may still use Pixi's global package cache; isolation concerns the project environment directory and its mutable state.

Check available storage before materializing a large independent environment. Network access, credential use, or license acceptance requires the authorization that applies to those external actions. If isolated installation is deferred, report the exact `pixi install` command and do not describe the environment as materialized.

## Persistent Worker State

Keep `.proj-local/goal.md` inside each persistent sibling worktree. Record the worker purpose, anchor branch, base ref, Pixi mode, synchronization expectations, and current feature focus. Treat it as worktree-local coordination state unless repository policy intentionally tracks `.proj-local/`.

Do not link `.proj-local/` between worktrees. Its purpose is to distinguish each persistent worker.

## Missing Resources

Before treating a missing ignored, untracked, or external resource as a product defect, determine whether the narrowest useful local symlink can bridge it safely. Managed datasets and models should use their repository bootstrap contracts rather than broad links copied from another worktree.
