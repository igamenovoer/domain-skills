# Create Sibling Worktree

Create or reconcile a persistent Git worktree as a direct sibling of the source repository. Use this command for a named parallel worker that remains available across several features, repeatedly synchronizes with the primary checkout, and appears through `extern/trees/<worker-name>` for browsing.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Resolve worker identity and purpose**. Require a stable hyphen-case worker name and a concrete goal. Resolve the source repository, base ref, worker branch, sibling path, and Pixi mode.
2. **Reconcile the local control plane**. Read `../references/external-project-layout.md` and `../references/worktree-local-state-policy.md`. Ensure `extern/README.md`, `extern/trees/README.md`, the narrow external-link ignore policy, and local handling for `.proj-local/` and `.pixi/` exist before creating the worker. Preserve established documentation.
3. **Inspect conflicts and existing state**. Confirm the sibling path is a direct child of the repository parent, the branch is not checked out elsewhere, and any existing target is the registered worktree expected for this worker. Stop on a conflicting path, branch, or link.
4. **Create or reuse the persistent worker**. Run the bundled helper from **Helper Invocation**. Create an attached worker branch; never use detached HEAD for this lifecycle kind.
5. **Initialize the worker environment**. Apply the resolved local-state policy. Use an independent Pixi environment by default. Initialize registered submodules when required by the repository, obtaining authorization before network access when it is not already in scope. Apply the isolation decision from **Submodule Isolation**.
6. **Create the project-local goal**. Ensure `<worktree>/.proj-local/goal.md` records the worker purpose, anchor branch, base ref, lifetime, Pixi mode, synchronization policy, and current feature focus when known. Keep `.proj-local/` local unless repository policy intentionally tracks it.
7. **Expose and document the worker**. Verify that `extern/trees/<worker-name>` is a relative symlink to the exact sibling worktree. Reconcile `extern/README.md` and `extern/trees/README.md` with its logical name, purpose, branch convention, recreation command, and removal command. Do not write the machine-specific absolute target into committed documentation.
8. **Verify and report**. Report whether the worktree was created or reused, its branch and commit, goal path, Pixi mode and installation result, linked local state, external-tree link, and the submodule mode with initialized submodules, their dedicated branches, or skipped setup.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the placement, branch, environment, external-layout, synchronization, and lifecycle constraints in this command, then execute the plan.

## Defaults

- Lifecycle kind: persistent sibling worker.
- Worker name: required stable hyphen-case name.
- Goal: required concrete purpose.
- Base ref: current branch in the source repository.
- Worker branch: `worker/<worker-name>`.
- Target path: `<repo-parent>/<repo-name>-<worker-name>`.
- Pixi mode: `isolated` for a Pixi-managed repository.
- Pixi installation: run `pixi install` after creation unless the user requests deferred installation.
- Submodule isolation: `leave-alone`; submodules stay on the gitlink commits recorded by the base ref unless a trigger from **Submodule Isolation** applies.
- External tree exposure: required at `extern/trees/<worker-name>`.
- Retirement: explicit only; completion of one feature does not retire the worker.

The worker branch is an anchor for the persistent physical worktree. Prefer short-lived feature or fix branches for deliverable changes, then return the physical worktree to `worker/<worker-name>` after integration. Do not accumulate unrelated unfinished features on the anchor branch.

## Helper Invocation

```bash
bash <skill-dir>/scripts/create_sibling_worktree.sh \
  --repo PATH \
  --name WORKER_NAME \
  --goal "CONCRETE PURPOSE"
```

Optional arguments are:

```bash
bash <skill-dir>/scripts/create_sibling_worktree.sh \
  --base BASE_REF \
  --branch worker/WORKER_NAME \
  --path SIBLING_PATH \
  --pixi-mode isolated \
  --no-pixi-install \
  --link-dir RELATIVE_DIR
```

Use `--pixi-mode shared` only when the user explicitly chooses to reuse the source `.pixi`; use `--pixi-mode none` when the worker does not need a Pixi environment. `--no-pixi-install` preserves isolated mode but defers materialization until a later `pixi install` or `pixi run`.

The helper may reuse an existing target only when Git already registers it as the same repository worktree with the requested worker branch. Reconciliation must not discard, overwrite, or switch existing work.

## Worker Branch Contract

- A persistent sibling worktree must use an attached branch unique to that worker.
- The default `worker/<worker-name>` branch begins at the resolved base ref.
- Reusing an existing worker branch is valid only when it is not checked out at another path and its identity matches the requested worker.
- Topic branches may be created and checked out inside the persistent physical worktree for individual features.
- Keep `.proj-local/goal.md` stable across topic-branch switches.
- Use `sync-sibling-worktree` for deliberate movement of commits between the primary checkout and the worker.

## Submodule Isolation

Submodules default to `leave-alone`: initialize them only when the repository requires them, keep them on the exact gitlink commits recorded by the base ref, and create no branches inside them.

Switch to `isolated` when the user asks for it, with wording such as "isolate submodule", "create branch for submodule", or "we will modify submodules as part of work", or when the worker goal shows that tracked submodule content is very likely part of the work, such as kernel or framework changes inside `extern/tracked/`. State the evidence when making this decision without explicit user wording.

When the mode is `isolated`:

- Initialize each in-scope tracked submodule after worktree creation, obtaining authorization before network access when it is not already in scope.
- Create or reuse a dedicated attached branch `worker/<worker-name>` inside each isolated submodule, matching the worker anchor branch. Never leave an isolated submodule on a detached HEAD.
- Reuse an existing `worker/<worker-name>` submodule branch only when its identity matches this worker, and stop when that branch is checked out at another path.
- Record the submodule mode and each isolated submodule's branch in `<worktree>/.proj-local/goal.md`.

Isolation changes only the submodule's checked-out branch. Worktree creation never commits or pushes inside a submodule and never updates superproject gitlinks.

## Guardrails

- DO NOT create this worktree inside the repository, under `extern/`, or outside the repository parent without a separate explicit design.
- DO NOT use detached HEAD or silently attach a branch checked out elsewhere.
- DO NOT create branches inside submodules unless the user requested submodule isolation or the worker goal clearly requires modifying tracked submodule content.
- DO NOT leave an isolated submodule on a detached HEAD, and do not silently reuse a submodule branch checked out at another path.
- DO NOT commit or push submodule changes or update superproject gitlinks merely because worktree creation was requested.
- DO NOT snapshot uncommitted source-checkout changes into the sibling worker; report that only committed base state transfers.
- DO NOT share `.pixi` unless the effective Pixi mode is explicitly `shared`.
- DO NOT replace an existing `extern/trees/<worker-name>` entry unless it already resolves to this exact worktree.
- DO NOT make project runtime code, builds, tests, or CI depend on `extern/trees/`.
- DO NOT push, integrate feature commits, or retire another worktree merely because creation was requested.

## Example Prompts

- `Use $imsight-project-mgr create-sibling-worktree named shadowkv-kernels for long-running model-specific kernel experiments.`
- `Use $imsight-project-mgr create-sibling-worktree named serving-lab with its own Pixi environment and expose it through extern/trees.`
- `Use $imsight-project-mgr create-sibling-worktree named profiling-worker and explicitly share the primary .pixi environment.`
