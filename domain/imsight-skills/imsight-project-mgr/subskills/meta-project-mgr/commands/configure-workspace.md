# Configure Shared Development Resources

## Workflow

1. **Inspect the current workspace.** Resolve registered realworks, intended tools, dependency manifests, runtime entrypoints, tests, resource consumers and existing local environment values.
2. **Reconcile shared environments.** Use the existing manager or the requested Pixi setup. Keep development dependencies/locks in meta, functional dependencies in each product, and incompatible toolchains in separate named meta environments. Do not repoint shared editable installs.
3. **Provide explicit target execution.** Preserve a correct project launcher or adapt the bundled [workspace.py](../assets/workspace.py) using [launcher-contract.md](../references/launcher-contract.md). Product commands require a checkout key. Restore cwd and source roots after environment activation and propagate exit codes/signals.
4. **Declare resources.** Use a project-specific prefix, tracked realwork `env.example`, ignored `.env`, relative defaults anchored at the selected realwork, and full-key temporary roots. Replace hardcoded moved paths at their owning resolver; preserve explicit overrides and system-wide coordination contracts.
5. **Reconcile development guidance.** Meta instructions own routing, policy, shared-edit coordination and all OpenSpec/skills. Realwork instructions explain use, tests and manual development attachment. Scope editor watching to authored meta and selected realworks without scanning all payloads or dependency trees.
6. **Verify setup.** Check environment/lock compatibility, configured source roots, dependency initialization, no-write dry runs, resource precedence and concurrent selected-source imports. Use the [verification procedure](verify-workspace.md).

For non-Python or non-Pixi projects, retain the same ownership and explicit-target guarantees using the native manager rather than imposing Python infrastructure.

## Launcher Template

The template is a small stdlib implementation that can be copied into a project's `meta_src/` and configured through `meta_configs/workspace.toml`. It implements registration checks, execution, dotenv precedence, path bindings and Pixi reactivation. It is not a mandatory new dependency or a universal build system. Reuse a correct existing launcher when one exists.

Define only required source roots, dependency roots and purpose variables. Keep task dispatch in meta; a generic `-- <command> ...` form avoids recreating every product CLI in this skill. Each project decides its concise aliases, test/lint/type commands, package/build gate and intended environment names.

## Resource Rules

Before moving a consumer, identify whether each path is an input, output, immutable provenance identity, or system coordination location. Resolve shared development inputs and output defaults from declared variables. Do not rewrite source IDs in frozen evidence just because paths move. Treat `/tmp` sockets/locks used for cross-process ownership separately from disposable per-checkout output.

No automatic standalone setup is required. Explain how a direct product checkout obtains compatible tools, dependency installations and input resources using explicit paths, copies or intentionally ignored links. A template is a reference; never claim a nonstandard filename is directly accepted by an environment manager without checking.

## Shared Editing

Concurrent product tasks receive separate checkout keys. One owner coordinates `.gitmodules`, gitlinks, shared environment locks, common specification files, and launcher changes. Inspect the final tree before committing any meta change; another worker's uncommitted edits are not automatically part of the task. Different change directories help separate plans but do not isolate modifications to the same common spec.
