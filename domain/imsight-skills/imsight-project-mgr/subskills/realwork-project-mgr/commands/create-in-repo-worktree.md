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

# Create In-Repo Worktree

Create a temporary clean Git worktree inside a standalone realwork repository while leaving the active checkout untouched. Use this command for one bounded task, inspection, feature, or fix that ends with explicit retirement.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Detect project topology first**. Run `bash <realwork-skill-dir>/scripts/detect_project_kind.sh --repo <target>` and apply [project-topology-detection.md](../references/project-topology-detection.md). Proceed only when `PROJECT_KIND=standalone-realwork` and `IS_LINKED_WORKTREE=false`; route `meta-project` and `attached-realwork` requests to `imsight-project-mgr->meta-project-mgr->manage-realworks()`.
2. **Resolve the source repository and ref**. Use the user-selected ref, or the current branch; require an explicit ref for a detached checkout.
3. **Resolve an ignored in-repo target**. Use the user-provided path or `<repo-root>/.imsight-arts/worktrees/worktree-<UTC timestamp>`. Ensure the resolved path stays inside the repository, avoids `extern/trees/`, and is ignored by Git (see **Ignore Rules**).
4. **Create the worktree with the bundled helper**. Run the command in **Helper Invocation** and never copy the repository manually.
5. **Apply temporary local-state policy**. Follow [worktree-local-state-policy.md](../references/worktree-local-state-policy.md). Share an existing untracked `.pixi` by default for a Pixi-managed repository.
6. **Verify and report**. Report `PROJECT_KIND`, `WORKTREE_KIND`, `WORKTREE`, `SOURCE_REF`, `CHECKOUT_MODE`, `COMMIT`, `BRANCH`, `PIXI_MODE`, and each `LINKED`, `SKIPPED_TRACKED`, `SKIPPED_MISSING`, or `SKIPPED_CONFLICT` result. State that retirement remains explicit via `retire-worktree()`.

If the task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the topology-detection, Git, path, ignore, local-state, and safety constraints in this command, then execute the plan.

## Defaults

- Eligible topology: `standalone-realwork` (primary checkout only).
- Lifecycle kind: temporary in-repo worktree (`in-repo-temporary`).
- Source ref: current branch from `git branch --show-current`.
- Target path: `<repo-root>/.imsight-arts/worktrees/worktree-<timestamp>`.
- Timestamp: `YYYYMMDD-HHMMSS` in UTC.
- Pixi mode: `shared` when the repository is Pixi-managed and source `.pixi` exists and links cleanly; otherwise `none`.
- Extra link directories: none.
- External tree exposure: prohibited.

## Ignore Rules

The target path or its containing directory must be ignored before the helper runs (`git check-ignore --quiet --no-index -- <rel-path>`). Prefer an existing repository ignore rule (for example passing `--path` under an already-ignored scratch path when requested, or adding `.imsight-arts/worktrees/` to `.git/info/exclude` to avoid modifying tracked `.gitignore`). Report any added local exclusion rule and never expose the nested worktree as untracked source content.

## Helper Invocation

```bash
bash <realwork-skill-dir>/scripts/create_in_repo_worktree.sh [--repo PATH] [--branch REF] [--path TARGET_PATH] [--link-dir NAME]
```

If the source ref is a local branch not checked out in another worktree, the helper creates a branch-attached worktree. If that branch is already checked out, it creates a detached worktree at the branch tip so the requested snapshot is preserved without disturbing the active checkout. The helper automatically runs `detect_project_kind.sh` and aborts on `meta-project`, `attached-realwork`, `ambiguous`, or nested linked-worktree targets.

## Guardrails

- DO NOT create a temporary worktree when `detect_project_kind.sh` classifies the repository as `meta-project`, `attached-realwork`, or `ambiguous`.
- DO NOT nest a temporary worktree inside another linked Git worktree or place targets outside the repository.
- DO NOT switch branches or modify tracked files in the active checkout.
- DO NOT replace tracked paths with local-state symlinks or expose temporary worktrees under `extern/trees/`.
- DO NOT remove the worktree automatically upon task completion; use `retire-worktree()` explicitly.

## Example Prompts

- `Use $imsight-project-mgr->realwork-project-mgr create-in-repo-worktree to create a temporary clean worktree for this standalone repository.`
- `Use $imsight-project-mgr->realwork-project-mgr create-in-repo-worktree from branch release/1.4 and reuse the local agent directories and Pixi environment.`
- `Use $imsight-project-mgr->realwork-project-mgr create-in-repo-worktree for a bounded inspection while keeping current uncommitted changes untouched.`
