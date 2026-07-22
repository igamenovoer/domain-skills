# Worktree Local-State Policy

This reference defines the shared local-resource linking contract for `create-worktree` and `impl-in-worktree`.

## Default Candidates

- `.claude`
- `.codex`
- `.gemini`
- `.github`
- `.aider`
- `.cursor`
- `.continue`
- `.windsurf`
- `.kiro`

Callers may add repository-relative candidates with repeated `--link-dir` arguments.

## Eligibility Rules

For each candidate:

1. Link it only when the source path exists in the original project root.
2. Skip it when Git tracks files under that path.
3. Never replace tracked worktree content with a symlink.
4. Treat the link as local setup rather than a product change; do not commit it unless the repository intentionally tracks that path.
5. Report linked, tracked-skipped, and missing candidates separately.

## Pixi Environment Reuse

Add `.pixi` only when the repository is Pixi-managed, detected through `pixi.toml`, `pixi.lock`, or `[tool.pixi]` in `pyproject.toml`, and the source `.pixi` path exists locally.

## Missing Resources

Before treating a missing ignored, untracked, or external resource as a product defect, determine whether the narrowest useful local symlink can bridge it into the worktree safely.
