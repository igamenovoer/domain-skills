# Initialize a Pixi Meta Project with Selected Realworks

## Workflow

1. **Resolve the intended workspace and branch set.** Identify its path, functional project/source repository, requested branches and checkout keys, package name where applicable, resource-variable prefix, Python/platform requirements, and remote policy. Follow **Branch Selection**; default to `main` only when no set is supplied. This command uses Pixi and creates the meta branch `metaproj`. The bundled Python launcher needs Python 3.11 or newer. If populated product code occupies the target, use [migrate-project.md](migrate-project.md) rather than overwriting it.
2. **Establish Git identities.** Follow [the Git lifecycle](../references/git-lifecycle.md). Default to one remote with `metaproj` and the selected functional branches; do not create a second remote or bare `runtime.git` unnecessarily. New local branches and a local seed commit may be necessary structural steps, but remote creation/push requires publication authorization.
3. **Resolve committed functional revisions.** For existing source branches, preserve their histories and record the exact commits to register. For a new project, create an end-user functional seed through the realwork manager, commit it on the selected seed branch, and create other requested new branches from their declared base. Create `metaproj` from the resolved history; remove product paths only on `metaproj` after their content remains reachable. Do not create per-realwork development Pixi environments. Use the configured Git author; missing identity needs resolution rather than a global configuration change.
4. **Register every selected branch independently.** For each selection, clone independent working files, attach its declared branch at the resolved commit, register `realworks/<key>`, record the exact gitlink and absorb its Git directory. See **Local Bootstrap**. Initialize each checkout's required nested dependencies at its own pins. Use a portable intended remote URL in tracked metadata when available; do not publish local filesystem URLs.
5. **Initialize meta Pixi and explicit execution.** Follow [pixi-bootstrap.md](../references/pixi-bootstrap.md): reconcile the root manifest against all selected branches, install and lock compatible shared environments, and configure explicit target execution. Prefer root `pixi.toml` for a new non-publishable meta project. Keep an existing valid manifest form. Incompatible branch requirements use separate named meta environments. Do not add root product source or a shared editable product install.
6. **Create development guidance and bindings.** Follow [configure-workspace.md](configure-workspace.md). Meta owns engineering guidance, useful planning/skill homes, and OpenSpec when adopted. Each realwork documents feature use and checkout-relative resource defaults calculated from its complete key; local `.env` remains ignored. Explain manual standalone development setup and coordinated meta edits. Preserve existing source contracts; missing development attachment support is reported or added only within the requested setup scope.
7. **Verify and report every selection.** Run the bootstrap acceptance checks and relevant [workspace verification](verify-workspace.md). Confirm each branch/pin, its mapped path, required dependency pins, environment compatibility, imports/tests through the launcher, and absence of root product source. Report a branch/key/commit/environment table and any branch-specific failure. If installation was explicitly deferred or failed, describe the scaffold as prepared but not fully initialized.

If a remote or package identity is unavailable, prepare the local structure and record the missing publication value; do not invent an endpoint.

## Invocation and Result

Use this command for a new Pixi-managed meta workspace with an initial set of realworks. For example: “Initialize a meta workspace from this repository with `main`, `feature/rendering`, and `release/1.x` as realworks.” The unchanged simple request defaults to only `main`. Existing combined projects use migration; adding branches after initialization uses realwork management.

The result includes a top-level `metaproj` checkout, its Pixi manifest and lock, shared `.pixi/` environments, meta guidance/tool configuration, and one independent submodule for each selected branch. Every submodule has a branch mapping and an exact gitlink; `main` is not mandatory in an explicit selection. Functional source, end-user manifests, tests, usage guidance and resource declarations belong in the realworks. Creating required initial Git seeds is part of new-project setup; remote creation, pushes and later feature commits are not implied.

## Branch Selection

Resolve a nonempty selection before creating checkouts. Each record identifies the source branch, checkout key, exact source commit, and intended meta environment. By default the key equals the branch name, preserving slashes: `feature/rendering` becomes `realworks/feature/rendering`. Honor explicit key mappings without renaming the source branch.

| Input | Result |
| --- | --- |
| No branch set | Register `main` at `realworks/main`. |
| `main`, `feature/rendering`, `release/1.x` | Register exactly those three branches at their matching paths. |
| `feature/rendering`, `feature/export` | Register those two; do not add `main` implicitly. |
| Branch `release/1.x` with key `stable` | Register `realworks/stable`, mapped to `release/1.x`. |

Validate actual branch names with Git and reject duplicate branches, duplicate keys, traversal, absolute keys, conflicting existing paths, and ancestor/descendant key collisions such as `feature` and `feature/rendering`. The meta branch itself is not a functional realwork. Existing remote/local branches must resolve to recorded commits; do not quietly substitute another branch when one is missing.

For an existing source repository, an absent branch is a missing input unless the user also requests its creation and identifies a base, or that base is unambiguous from the task. For a brand-new project, the requested set authorizes creating its initial branches: use the explicitly selected seed branch, or the first branch in the requested order, for the initial functional commit; start the others from the declared base, defaulting to that new seed. Do not manufacture `main` when the explicit set omits it. The initialization default does not establish a default for subsequent runtime commands: each command still names its realwork.

## Local Bootstrap

A clean local source can seed branch-specific submodules before publishing. Prefer native Git operations over copying `.git` internals. Repeat this representative sequence for each resolved branch/key pair; `main` below illustrates the default selection:

```bash
git clone --no-hardlinks --branch main --no-checkout /absolute/local/source realworks/main
git -C realworks/main switch main
git -c protocol.file.allow=always submodule add -b main /absolute/local/source realworks/main
git submodule absorbgitdirs -- realworks/main
```

Use the one-command file protocol allowance only for the explicitly chosen local bootstrap; do not change global Git configuration. After registration, replace the submodule URL with the intended portable remote using `git submodule set-url`, and preserve a usable local origin until publishing is possible. Mark the workspace local-only until every recorded commit is obtainable from that URL. Initialize required nested functional dependencies independently.

The meta branch's history may share the functional ancestor. Removing product files from its tree does not delete their history. Never use a broad filesystem deletion for this step; remove only the classified product paths on the meta branch, preserving `.git`, local resources, and files already assigned to meta. Do not switch an occupied/dirty original checkout to perform this sequence; migration has a preservation-first staging procedure.
