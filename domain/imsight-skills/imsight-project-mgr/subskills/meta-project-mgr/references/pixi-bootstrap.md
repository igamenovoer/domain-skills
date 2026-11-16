# Pixi Bootstrap for Metaproj

This procedure supplies the environment half of `init-meta-project`. It assumes the selected functional branches and their `realworks/<key>` submodules have been prepared as described by that command. The default selection is `main`; an explicit set may omit it. Keep environment and launcher definitions in metaproj; each realwork retains user-facing package/build metadata and declared feature dependencies.

## Manifest and Requirements

Inspect existing manifests before writing anything. For a new meta workspace, run `pixi init --format pixi --channel conda-forge .` from the meta root and reconcile its output. Use the target's actual supported platforms and a Python constraint compatible with its functionality and the Python 3.11+ launcher. Preserve a deliberately selected `pyproject.toml` form, but do not add product metadata or a build backend just to make metaproj look publishable.

Derive requirements from each selected branch's functional package, tests and requested engineering tools. Group compatible requirements into shared environments and assign separate named meta environments when they conflict; record the branch-to-environment selection without silently upgrading dependencies across branches. Use `pixi add` for required Conda packages and `pixi add --pypi` for required PyPI packages against the explicit meta manifest. Do not blindly install a standard scientific or documentation bundle. Do not add the selected product itself with `--editable`; its source is selected per process. Required runtime dependencies must be available in the assigned environment, even though their end-user declarations remain in the realwork manifest.

The following illustrates a small Python/pytest project, not a dependency list to impose on every project. Replace its workspace name, platform, and Python constraint with the resolved values; include pytest only when that is the selected test runner.

```toml
[workspace]
name = "example-development"
channels = ["conda-forge"]
platforms = ["linux-64"]

[dependencies]
python = ">=3.11,<4"
pytest = "*"

[tasks]
worktree = "python meta_src/workspace.py --meta-root ."
```

Keep `pixi.lock` tracked and `.pixi/` ignored. Initialize each branch's required functional dependency submodules at its own pinned revisions before commands or environment resolution need their paths. Reuse compatible environments; add named meta environments for actual dependency conflicts. Do not symlink `.pixi/` into realworks or switch a shared editable installation between branches.

## Launcher and Resources

Reuse a correct existing launcher, or copy the bundled [workspace.py](../assets/workspace.py) to `meta_src/workspace.py`. The sample Pixi task above forwards its arguments to that script. Create `meta_configs/workspace.toml`, adapted to the functional language and actual source roots:

```toml
[workspace]
prefix = "EXAMPLE"
manifest = "pixi.toml"
source_paths = ["src", "."]
dependency_paths = []

[resources]
CONTEXT_ROOT = "context"
OPENSPEC_ROOT = "openspec"
```

Use the selected project prefix instead of `EXAMPLE`, add only relevant resources, and initialize OpenSpec in meta only when the project adopts it. Source/dependency paths must exist inside each selected realwork. If layouts differ, adapt the project launcher to select explicit per-checkout paths rather than importing a missing dependency from another branch. Required source dependencies have their own pinned submodules and independent working files. Non-Python product commands can use the same explicit cwd/resource launcher with language-specific setup described separately.

Each realwork's tracked `env.example` documents the resource variables and checkout-relative defaults. Examples are `<PREFIX>_DEV_TMP_ROOT=../../tmp/main` for key `main`, and `../../../tmp/feature/rendering` for key `feature/rendering`. Meta resource prefixes likewise depend on the key's depth. Preserve an existing `.env`; otherwise prepare local settings without credentials and ignore the file. Do not copy main's settings verbatim into a deeper checkout. The launcher reads literal values and supplies defaults, so users do not need a shell-sourced file for ordinary meta commands. See [launcher-contract.md](launcher-contract.md) for precedence and isolation.

## Install and Verify

Run from the meta root using its actual manifest filename. The commands below illustrate a selection containing `main`; substitute a registered checkout key and its assigned environment when the selection differs:

```bash
pixi install --manifest-path pixi.toml
pixi lock --check --manifest-path pixi.toml
pixi task list --manifest-path pixi.toml
pixi run --manifest-path pixi.toml worktree --list
pixi run --manifest-path pixi.toml worktree --worktree main --dry-run -- python -c "import sys; print(sys.executable)"
```

Then execute a safe product import and the selected functional tests. For the illustrative Python/pytest layout:

```bash
pixi run --manifest-path pixi.toml worktree --worktree main -- python -m pytest tests/unit tests/integration
```

Repeat the applicable smoke and functional tests for every selected branch in its assigned environment. Use actual existing suite paths and package imports; do not claim a template or nonexistent test suite was exercised. Verify that commands without `--worktree` are rejected, each selected cwd and source resolve to `realworks/<key>`, and temporary output stays under meta `tmp/<key>/`. Neither realwork `.pixi/` nor root product `src/` should be created. Check a standalone functional smoke with provisioned dependencies, and use two distinct checkout fixtures to verify the reusable launcher as required by workspace verification.

## Completion States

- **Initialized:** every selected branch/submodule, the meta manifest and lock, assigned installed environments, launcher, guidance and bindings are present, and the applicable smoke/tests pass for the complete selection.
- **Prepared, installation deferred:** the user requested setup files only; report the exact install/check commands still needed.
- **Incomplete:** installation, required dependency resolution, Git identity or verification failed; retain the useful scaffold and report the concrete failure.

Do not call a directory tree alone a ready Pixi workspace. Do not initialize another realwork environment as a fallback for a failed shared installation. Creating the workspace does not publish branches, models, secrets, or releases.
