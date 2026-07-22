# Implement in Worktree

Implement a change in an isolated worktree without disturbing the active checkout. Carry the current repository state into a new local branch, bridge required local-only state, and perform implementation, verification, and local commits from inside that worktree.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Resolve the target and branch naming**. Follow **Target and Branch Contract**, including the OpenSpec special case.
2. **Create the isolated branch and worktree**. Use the bundled helper from **Helper Invocation**; never reuse or overwrite a conflicting branch or path silently.
3. **Bridge local resources**. Follow `../references/worktree-local-state-policy.md` and add only the narrowest safe links needed for execution.
4. **Move into the worktree and stay there**. Perform all subsequent reads, edits, builds, tests, and OpenSpec commands inside the returned `WORKTREE`.
5. **Implement and verify the requested change**. Use repository-native workflows; for an OpenSpec target, follow **OpenSpec Target Contract**.
6. **Commit locally**. After relevant verification passes, create one or more local commits on the implementation branch without pushing.
7. **Report the result**. Report the worktree, branch, final commit, verification commands, linked resources, assumptions, and local-only status.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the isolation, implementation, verification, commit, and safety constraints in this command, then execute the plan.

## Defaults

- Topic slug: derive from the target, normalize to hyphen-case, and keep it stable.
- Branch kind: `fix` for broken behavior, regressions, failing tests, or repairs; otherwise `feature`.
- Implementation branch: `<branch-kind>/<topic-slug>`.
- Implementation home: `<repo-root>/.imsight-arts/impl-branches/<branch-kind>/<topic-slug>`.
- Worktree: `<impl-home>/repo`.
- Extra link directories: none.
- Final delivery: one or more verified local commits; do not push.

If this command creates `.imsight-arts/impl-branches/`, add it to `.gitignore`. If `.gitignore` already has a commented entry for that path, do not add an active rule automatically.

## Target and Branch Contract

- Identify the exact change and expected verification commands.
- Choose `fix` for repairs and `feature` for new behavior or refactors.
- Derive a stable hyphen-case topic slug.
- Identify any required local directories beyond the shared defaults.
- When the target is an OpenSpec path under `openspec/changes/<change-name>/`, derive the change name from the path when clear; otherwise confirm it with `openspec list --json`.
- Prefer the resolved OpenSpec change name as the topic slug unless the user requests another.

## Helper Invocation

```bash
bash <skill-dir>/scripts/create_impl_worktree.sh --topic TOPIC_SLUG --kind feature
```

Use `--kind fix` for repair work. Optional arguments are:

```bash
bash <skill-dir>/scripts/create_impl_worktree.sh \
  --repo PATH \
  --topic TOPIC_SLUG \
  --kind feature \
  --branch feature/TOPIC_SLUG \
  --impl-home IMPL_HOME \
  --path WORKTREE_PATH \
  --link-dir RELATIVE_DIR
```

If the helper reports an existing branch or path, stop and choose whether to continue that isolated session or use a new topic. Do not overwrite it.

The helper snapshots tracked and untracked source state through a temporary Git index and commit, creates the requested branch and worktree, and does not commit or switch the original checkout.

## OpenSpec Target Contract

- Run OpenSpec commands only inside the isolated worktree after creation.
- Do not assume `proposal.md`, `design.md`, `tasks.md`, or spec paths exist from a path shape alone.
- Gather authoritative context with `openspec status --change "<change-name>" --json`.
- Use `$openspec-apply-change` inside the worktree to own artifact discovery, context reading, task progression, and checkbox updates.
- Keep ownership of the isolated branch, worktree, local resource bridges, verification boundary, and local delivery in this command.

## Guardrails

- DO NOT switch branches or continue implementation in the original checkout after the isolated worktree exists.
- DO NOT push, open a pull request, or delete the branch or worktree unless the user explicitly asks.
- DO NOT copy the repository manually.
- DO NOT treat a missing local resource as a product defect before checking whether a safe link can bridge it.
- DO NOT bypass OpenSpec CLI discovery by hard-coding artifact layouts for OpenSpec targets.
- DO NOT clean unrelated problems unless they directly block delivery.

## Example Prompts

- `Use $imsight-project-mgr impl-in-worktree to implement this feature on a fresh local branch without disturbing my checkout.`
- `Use $imsight-project-mgr impl-in-worktree to fix the failing runtime bug, run relevant tests, and leave the branch local for review.`
- `Use $imsight-project-mgr impl-in-worktree on openspec/changes/<change-name> and use $openspec-apply-change inside the worktree.`
