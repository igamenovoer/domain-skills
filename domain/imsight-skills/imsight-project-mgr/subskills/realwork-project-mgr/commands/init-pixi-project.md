# Provision a Standalone Pixi Checkout

## Workflow

1. **Resolve ownership first.** For an attached realwork, use its metaproj environment and route changes to meta configuration. Run this standalone procedure only when the user asks to provision a functional checkout without that environment.
2. **Inspect existing manifests.** Preserve package/build metadata, Python constraints, locks, and any `pixi.toml` or `[tool.pixi]` configuration. Do not rerun initialization over compatible existing state.
3. **Choose the smallest environment.** Use actual functional and selected verification requirements. Follow explicit Python/platform constraints; query the installed tool's help when syntax or support is uncertain. Do not install a fixed scientific/documentation bundle.
4. **Prepare the requested local manifest.** Prefer a separate local `pixi.toml` where it avoids replacing functional `pyproject.toml`. A metaproj template is a manual reference, not an automatically merged manifest. Decide whether standalone files are intentionally tracked or local according to the task.
5. **Install when requested and verify.** Run Pixi against the explicit supported manifest, then test imports and a representative safe entrypoint. Respect existing dependency pins and report installation failures without claiming readiness.
6. **Reconcile functionality** through [structure-project.md](structure-project.md) only as needed; do not add parallel-development or engineering scaffolding here.

If project setup is incomplete, plan the minimal manual attachment of compatible resources and explain the remaining prerequisites.

## Contract

Pixi manifest filenames and supported options come from the installed CLI, not a renamed template. A file called `pyproject.standalone.toml` may be useful as a reference, but is not automatically an accepted Pixi manifest. Invocation selects one explicit manifest; it never searches for a random ancestor or silently reuses another checkout's editable source.

This command preserves direct functional use. Full engineering setup remains meta-owned; no automatic standalone manifest merger, symlink farm, or environment copier is introduced.
