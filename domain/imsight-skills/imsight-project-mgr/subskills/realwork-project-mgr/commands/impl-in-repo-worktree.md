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

# Implement in In-Repo Worktree

Implement one change in a temporary in-repo worktree of a standalone realwork repository without disturbing the active checkout. Carry the current repository state into a new local branch, bridge required local-only state, and perform implementation, verification, and local commits from inside that worktree.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Detect project topology first**. Run `bash <realwork-skill-dir>/scripts/detect_project_kind.sh --repo <target>` and apply [project-topology-detection.md](../references/project-topology-detection.md). Proceed only when `PROJECT_KIND=standalone-realwork` and `IS_LINKED_WORKTREE=false`; route `meta-project` and `attached-realwork` requests to `imsight-project-mgr->meta-project-mgr->manage-realworks()`.
2. **Resolve the target and branch naming**. Follow **Target and Branch Contract**, including the OpenSpec special case.
3. **Create the isolated branch and in-repo worktree**. Use the bundled helper from **Helper Invocation**; never reuse or overwrite a conflicting branch or path silently.
4. **Bridge temporary local resources**. Follow [worktree-local-state-policy.md](../references/worktree-local-state-policy.md) and add only the narrowest safe links needed for execution. Share an eligible `.pixi` by default.
5. **Move into the worktree and stay there**. Perform all subsequent reads, edits, builds, tests, and OpenSpec commands inside the returned `WORKTREE`.
6. **Implement and verify the requested change**. Use repository-native workflows; for an OpenSpec target, follow **OpenSpec Target Contract**.
7. **Commit locally**. After relevant verification passes, create one or more local commits on the implementation branch without pushing.
8. **Report the result**. Report `PROJECT_KIND`, `WORKTREE`, `IMPL_BRANCH`, `SNAPSHOT_COMMIT`, final commit, verification commands, linked resources, assumptions, local-only status, and the explicit retirement requirement via `retire-worktree()`.

If the task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the topology-detection, isolation, implementation, verification, commit, and safety constraints in this command, then execute the plan.

## Defaults

- Eligible topology: `standalone-realwork` (primary checkout only).
- Lifecycle kind: temporary in-repo implementation worktree (`in-repo-temporary-implementation`).
- Topic slug: derive from the target, normalize to hyphen-case, and keep it stable.
- Branch kind: `fix` for broken behavior, regressions, failing tests, or repairs; otherwise `feature`.
- Implementation branch: `<branch-kind>/<topic-slug>`.
- Implementation home: `<repo-root>/.imsight-arts/impl-branches/<branch-kind>/<topic-slug>`.
- Worktree: `<impl-home>/repo`.
- Pixi mode: `shared` when the repository is Pixi-managed and source `.pixi` exists and links cleanly; otherwise `none`.
- Extra link directories: none.
- External tree exposure: prohibited.
- Final delivery: one or more verified local commits; do not push.

If the helper creates `.imsight-arts/impl-branches/` and the path is not yet ignored, it appends `.imsight-arts/impl-branches/` to `.gitignore` unless `.gitignore` already has a commented entry for that path.

## Target and Branch Contract

- Identify the exact change and expected verification commands.
- Choose `fix` for repairs and `feature` for new behavior or refactors.
- Derive a stable hyphen-case topic slug.
- Identify any required local directories beyond the shared defaults.
- When the target is an OpenSpec path under `openspec/changes/<change-name>/`, derive the change name from the path when clear; otherwise confirm it with `openspec list --json`.
- Prefer the resolved OpenSpec change name as the topic slug unless the user requests another.

## Helper Invocation

```bash
bash <realwork-skill-dir>/scripts/create_impl_in_repo_worktree.sh --topic TOPIC_SLUG --kind feature
```

Use `--kind fix` for repair work. Optional arguments are:

```bash
bash <realwork-skill-dir>/scripts/create_impl_in_repo_worktree.sh \
  --repo PATH \
  --topic TOPIC_SLUG \
  --kind feature \
  --branch feature/TOPIC_SLUG \
  --impl-home IMPL_HOME \
  --path WORKTREE_PATH \
  --link-dir RELATIVE_DIR
```

If the helper reports an existing branch or path, stop and choose whether to continue that isolated session or use a new topic rather than overwriting it. The helper runs `detect_project_kind.sh` first, snapshots tracked and untracked source state through a temporary Git index and commit, creates the requested branch and worktree, and leaves the original checkout untouched and on its existing branch.

## OpenSpec Target Contract

- Run OpenSpec commands only inside the isolated worktree after creation.
- Do not assume `proposal.md`, `design.md`, `tasks.md`, or spec paths exist from a path shape alone.
- Gather authoritative context with `openspec status --change "<change-name>" --json`.
- Use `$openspec-apply-change` inside the worktree to own artifact discovery, context reading, task progression, and checkbox updates.
- Keep ownership of the isolated branch, worktree, local resource bridges, verification boundary, and local delivery in this command.

## Guardrails

- DO NOT create an implementation worktree when `detect_project_kind.sh` classifies the repository as `meta-project`, `attached-realwork`, or `ambiguous`.
- DO NOT switch branches or continue implementation in the original checkout after the isolated worktree exists.
- DO NOT expose this temporary worktree through `extern/trees/`.
- DO NOT push, open a pull request, delete the branch, or retire the worktree unless the user explicitly asks.
- DO NOT copy the repository manually or overwrite an existing implementation branch or worktree path.
- DO NOT treat a missing local resource as a product defect before checking whether a safe link can bridge it.
- DO NOT bypass OpenSpec CLI discovery by hard-coding artifact layouts for OpenSpec targets.

## Example Prompts

- `Use $imsight-project-mgr->realwork-project-mgr impl-in-repo-worktree to implement this feature on a fresh local branch without disturbing my checkout.`
- `Use $imsight-project-mgr->realwork-project-mgr impl-in-repo-worktree to fix the failing runtime bug, run relevant tests, and leave the branch local for review.`
- `Use $imsight-project-mgr->realwork-project-mgr impl-in-repo-worktree on openspec/changes/<change-name> and use $openspec-apply-change inside the worktree.`
