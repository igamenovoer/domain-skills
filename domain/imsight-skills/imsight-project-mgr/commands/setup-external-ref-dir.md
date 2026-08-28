# Set Up External Reference Directory

Create or reconcile a project directory that keeps third-party or machine-local resources outside Git while committing the documentation, metadata, and bootstrap logic needed to reconstruct them. Run this operation on demand; do not make it an automatic part of project initialization.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Resolve the project and managed directory**. Use the project root and external-reference-heavy directory named by the user. If the request names resources but no directory, infer a conventional project-relative home only when repository evidence makes the choice clear; otherwise ask for the smallest missing decision.
2. **Inspect existing state**. Read repository instructions, Git status and ignore rules, existing documentation, directory contents, symlinks, bootstrap files, and resource-specific conventions before changing anything.
3. **Resolve each external reference**. Record its project use, upstream source, license or attribution needs, expected local material, target-resolution method, version or checksum requirements, and derived artifacts. See **Reference Contract**.
4. **Create or reconcile the control plane**. Apply **Directory Layout**, **Documentation Contract**, and **Gitignore Policy** while preserving compatible files and unrelated local changes.
5. **Create or reconcile bootstrap behavior**. Apply **Bootstrap Contract** to each reference and add a top-level fan-out script only when the managed directory contains several references or the user requests one.
6. **Populate or link resources when requested**. Create a symlink, clone, download, or derived output only when the user requested that side effect and the required source information is available. Follow **Resource Materialization** and preserve external source data.
7. **Validate the result**. Apply **Verification**, including shell syntax, ignore behavior, symlink targets, idempotency when bootstrap execution is in scope, and confirmation that Git does not capture machine-local or large content.
8. **Report the setup**. List managed references, created or changed control files, tracked and ignored paths, environment variables, bootstrap commands, materialization performed, and unresolved inputs.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the layout, documentation, bootstrap, materialization, Git, and safety constraints in this command, then execute the plan.

## Scope and Directory Choice

Use this command for directories such as `models/`, `datasets/`, `external-resources/`, or `extern/resources/` whose large or host-specific contents stay local while their reconstruction contract remains in Git.

Keep the operation separate from `init-pixi-project` and `structure-pixi-project`. Those commands may create general external-dependency homes, but they do not automatically create resource-specific bootstrap packages.

Respect the existing `extern/` taxonomy:

- Use `extern/tracked/<repo>/` for a pinned third-party checkout that belongs in Git as a submodule.
- Use `extern/orphan/<repo>/` for a disposable or local-only checkout whose contents and setup metadata need not be committed.
- Use `extern/trees/<name>` only for an ignored symlink to a persistent sibling Git worktree created or reconciled through `create-sibling-worktree`. It is not a temporary worktree, managed resource home, or runtime dependency.
- Prefer `extern/resources/<name>/` or another dedicated managed directory when the project must commit resource documentation and bootstrap logic while ignoring the resource itself.

If the selected managed directory is already ignored in full, do not silently place committed control files there. Report the conflict and either use a trackable managed directory or adjust the ignore policy when the user explicitly chooses that design.

## Directory Layout

Use one self-contained folder per external reference:

```text
<managed-dir>/
|-- README.md
|-- bootstrap.sh                 # Optional fan-out entrypoint
|-- .gitignore
`-- <reference-name>/
    |-- README.md
    |-- bootstrap.sh
    |-- bootstrap.yaml           # Optional declarative configuration
    |-- source-data -> <target>   # Usually an ignored machine-local symlink
    |-- metadata/                 # Small stable files suitable for Git
    `-- derived/                  # Optional generated outputs, usually ignored
```

Treat `<managed-dir>/<reference-name>/` as the unit of organization. Keep its documentation, bootstrap logic, small metadata, and derived-artifact description together.

`source-data` may be an ignored checkout or downloaded directory when a symlink does not fit the resource. Preserve the same interface name unless project conventions require another name, and document the deviation.

Use `bootstrap.yaml` when separating declarative values from shell logic improves maintenance. Useful fields include the environment-variable name, optional non-machine-specific default root, source subdirectory, repository link name, pinned version or checksum, required files, and preparation settings. Do not add configuration machinery when a short script and README are clearer.

## Reference Contract

Resolve these facts for each reference from the user's request and repository evidence:

- Stable local reference name and project-relative path.
- Upstream URL or authoritative source description.
- How the project uses the resource.
- Expected contents, approximate size when relevant, and required files for sanity checks.
- License, attribution, access, or redistribution constraints that affect setup.
- Reproducible revision, tag, commit, artifact version, or checksum when the source supports pinning.
- Machine-local root environment variable and source subdirectory for symlink targets.
- Derived artifacts, their deterministic creation command, and whether Git tracks or ignores them.

Ask for a missing value only when choosing it could point at the wrong source, overwrite local state, weaken reproducibility, or trigger an unauthorized external action. Otherwise create a documented placeholder that fails clearly at bootstrap time.

## Documentation Contract

The top-level `README.md` must identify the directory as a home for external, third-party, or machine-local resources. It must index every managed reference with its local path, source, project use, expected `source-data`, derived artifacts, and bootstrap entrypoint.

When the managed directory is an immediate child of `extern/`, create or reconcile `extern/README.md` and the managed directory's `README.md` according to `../references/external-project-layout.md`. Preserve other indexed subdirectories and entries.

Each per-reference `README.md` must document:

- the resource and why the project needs it;
- the upstream source and pinned identity when available;
- licensing, attribution, access, or redistribution notes;
- required tools and environment variables;
- expected target contents and required-file checks;
- bootstrap, non-interactive, cleanup, and verification commands;
- generated artifacts and their tracked or ignored status.

Use repository-relative paths in committed documentation. Avoid embedding host-specific absolute paths, credentials, private URLs, or tokens.

## Bootstrap Contract

Each per-reference `bootstrap.sh` must be a small idempotent Bash program that uses `set -euo pipefail` and resolves its own directory from `BASH_SOURCE[0]`. Adapt the mechanics to the resource while preserving this operation shape:

1. Parse supported options and reject unknown arguments.
2. Validate required commands and configuration.
3. Resolve the source target from an environment variable and stable resource-relative values.
4. Print the resolved source target and repository-local destination before mutation.
5. Reconcile the symlink, checkout, or download without deleting external source data.
6. Validate required files, revision, or checksum when configured.
7. Create deterministic derived artifacts only when requested by the resource contract.
8. Report what changed and what remains unresolved.

Support these common modes when they apply:

- Default: interactive reconciliation that asks before replacing an existing managed symlink or local artifact.
- `--yes`: non-interactive acceptance of established defaults. It may replace a conflicting managed symlink, but it must not authorize deletion of a real directory or external source data.
- `--clean`: remove only repository-local symlinks and other explicitly documented disposable links created by the bootstrap process. Succeed when they are already absent and do not touch source data.

A top-level `bootstrap.sh`, when present, must invoke per-reference scripts from a deterministic list, forward supported modes, stop on failure, and remain idempotent.

Prefer environment variables for machine-local roots. Do not hard-code a host-specific absolute target in committed scripts or configuration unless the user explicitly requires that non-portable contract. An explicit fixed target must be documented as host-specific.

## Resource Materialization

For a symlink-backed resource:

- Confirm that the resolved target is sensible and that its required files exist when the resource contract defines them.
- Treat `-L` as authoritative when detecting an existing or broken link.
- Leave a link unchanged when it already resolves to the requested target.
- Ask before replacing a different link unless `--yes` applies, and remove only the link itself.
- Stop when the destination is a real file or directory. Replace, move, or delete it only after the user explicitly authorizes that exact action.
- Use `readlink` or `realpath` during verification and report the resolved target.

For a clone or download, use a pinned revision, version, or checksum whenever the source supports one. Make reruns detect an already valid local copy. Do not perform network access, authentication, license acceptance, or large downloads merely because the setup files describe those operations; execute them only when the user's request includes materialization or later bootstrap execution supplies the required authority.

Keep derived generation deterministic. Track small stable manifests, checksums, splits, or smoke-test samples under `metadata/`. Put large or machine-dependent products under `derived/` and ignore them.

## Gitignore Policy

Place `.gitignore` inside the managed directory and ignore machine-local or generated content narrowly. A common baseline is:

```gitignore
*/source-data
*/source-data/**
*/derived/
*/derived/**
```

Adapt names to the selected layout. Preserve existing ignore rules and add only required entries. Keep `README.md`, `bootstrap.sh`, optional `bootstrap.yaml`, and small `metadata/` files trackable.

Do not ignore the entire managed directory at the project root. Verify behavior with `git check-ignore -v` or equivalent checks against both ignored resource paths and committed control files.

## Verification

Perform checks proportional to the created or reconciled setup:

1. Run `bash -n` on every changed shell script.
2. Confirm every README, bootstrap entrypoint, optional configuration file, and metadata path referenced by another file exists.
3. Use `git check-ignore -v` to confirm resource and derived paths are ignored while control files remain trackable.
4. Inspect each created symlink with `readlink` and verify the target and required files when materialization was requested.
5. When bootstrap execution is authorized and practical, run it twice to confirm idempotency and run `--clean` only when cleanup validation will not disrupt required local setup.
6. Inspect `git status` and the final diff for large files, machine-specific paths, credentials, unrelated edits, and accidental capture of external content.

If an external source is unavailable, validate the control plane and report materialization as pending. Do not claim the resource itself is ready.

## Guardrails

- DO NOT run this command automatically as part of project initialization.
- DO NOT ignore the complete managed directory when its documentation and bootstrap logic must remain tracked.
- DO NOT commit machine-local source data, large derived artifacts, credentials, private source URLs, or host-specific secrets.
- DO NOT replace or delete a real file or directory while repairing a managed symlink without explicit authorization for that exact path.
- DO NOT let `--yes` or `--clean` delete external source data.
- DO NOT perform network access, authentication, license acceptance, or large downloads unless the user requested materialization or bootstrap execution.
- DO NOT claim reproducibility without a pinned revision, version, checksum, or an explicit note that the upstream source is unpinned.
- DO NOT place temporary worktrees, managed resource data, or runtime dependencies under `extern/trees/`; that directory is reserved for ignored links to persistent sibling workers.

## Example Prompts

- `Use $imsight-project-mgr use setup-external-ref-dir to create datasets/ with one managed reference for OmniDocBench; generate bootstrap files but do not download the dataset.`
- `Use $imsight-project-mgr use setup-external-ref-dir to add models/deepseek-ocr backed by MODEL_ROOT and validate the required Hugging Face files.`
- `Use $imsight-project-mgr use setup-external-ref-dir to reconcile extern/resources/ against its existing README, bootstrap scripts, and ignore rules.`
