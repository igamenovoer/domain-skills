# Explicit Launcher Contract

## Configuration

Copy [workspace.py](../assets/workspace.py) into an appropriate maintained meta location only if the project needs a launcher. It uses Python 3.11+ standard-library TOML parsing. Configure it in `meta_configs/workspace.toml`:

```toml
[workspace]
prefix = "EXAMPLE"
manifest = "pixi.toml"
source_paths = ["src", "."]
dependency_paths = ["extern/tracked/required-lib/src"]

[resources]
CONTEXT_ROOT = "context"
OPENSPEC_ROOT = "openspec"
TEST_DATA_ROOT = "data/test-data"
```

Remove the example dependency entry when the product has none. Source and dependency paths are relative to the selected realwork and must exist inside it; resource defaults are relative to meta. Do not add unsupported language paths. The prefix defines `EXAMPLE_META_ROOT`, `EXAMPLE_WORKTREE_ROOT`, `EXAMPLE_WORKTREE_KEY` and `EXAMPLE_DEV_<PURPOSE>`. It must be adapted to the project and documented in realwork `env.example`.

Invoke from a provisioned meta environment, naming its root and a realwork explicitly:

```bash
python meta_src/workspace.py --meta-root . --list
python meta_src/workspace.py --meta-root . --worktree main --dry-run -- python -m pytest tests/unit
python meta_src/workspace.py --meta-root . --worktree feature/example --environment default -- python -m pytest tests/unit
```

Use `--direct` only when the current environment is deliberately provisioned. Default execution reactivates the configured Pixi environment with its existing locked dependencies, then restores the selected realwork cwd and source roots. The launcher starts the actual command with exec, preserving signals and exit status. It neither reinstalls the product nor changes Git branches.

## Scope and Resources

The template supports listing from `.gitmodules` and the meta index without initializing checkouts. Execution requires a registered independent absorbed submodule, matching attached branch or detached pin, and existing declared source roots. Missing paths or branch mismatch produce a diagnostic; the launcher never repairs them implicitly.

Dotenv values are literal assignments with optional `export` and surrounding quotes. Shell substitutions and variable interpolation are not evaluated; inline comments are not parsed. Precedence is inherited process, then realwork `.env`, then meta `.env`, then generated defaults. Relative `EXAMPLE_DEV_*` values are consumed relative to the selected realwork; the launcher normalizes its own temp paths. It tracks its generated defaults in a private environment marker so nested selection can recompute those defaults without discarding explicit overrides.

`EXAMPLE_DEV_TMP_ROOT` defaults to meta `tmp/<full-key>/`, with `temporary/` for native temp files and `pytest/` for independently numbered pytest runs. Actual execution creates those directories; dry-run does not. Workflows add unique purpose/run folders for explicit artifacts. A resource helper in product code should normalize relative paths using the explicit realwork root, validate required inputs at use time, and preserve standalone behavior. Do not import this meta launcher from product code.

`--meta-code` is for an explicitly requested engineering command and additionally exposes the meta root on Python's import path. Functional commands omit it. Default Python execution replaces inherited `PYTHONPATH` and disables user-site imports; verify separately that the environment does not contain editable install hooks pointing at a different realwork. Do not put the product into the shared environment as an editable install that is switched between branches.

## Limits and Adaptation

This is a template, not a universal environment manager. Add native-language source selection, per-tool build directories, dynamic editable-dependency roots or persistent-state bindings only when the actual project requires them. Its path checks do not prove optional services, GPUs or input payloads are ready. Test those prerequisites through the selected functional workflow.

The template validates only the configured source paths; verify required dependency gitlink revisions and independent working files during registration and workspace verification. No global active checkout, automatic source symlink, branch switch, download, deployment or Git mutation occurs in the launcher.
