# Verify a Separated Workspace

## Workflow

1. **Inspect actual owners and refs.** Confirm meta has no product `src/`, each intended realwork is registered with branch and exact pin, and required nested dependencies are independently initialized. Distinguish deliberate local pin drift from a reproducible published state.
2. **Check functional completeness.** Inspect build/package resources, operational helpers, experiments, tests and public documentation. Run relevant existing tests and an installed/standalone smoke check with provisioned dependencies outside the meta source path.
3. **Check development completeness.** Exercise meta tools, their tests, spec discovery, agent routing, editor/source boundaries, and moved-document links. Preserve immutable move digests and validate intentionally changed current records separately.
4. **Prove source and environment isolation.** Run two distinct checkout fixtures concurrently. Each must import its own product and required dependency source, use its own cwd, restore its selection after activation, and place temp output under its complete key. Check nested keys and explicit overrides. No shared editable reinstall is allowed.
5. **Check preservation and scope.** Confirm local values, payloads, historical evidence and unrelated tasks were retained. Audit tracked/untracked state so output, credentials, models or machine paths are not staged accidentally.
6. **Report results and limits.** Record commands, actual revisions, baseline comparisons, skipped external prerequisites and remaining manual steps. Do not present an incomplete broad suite or uninitialized dependency as passing.

Use proportionate checks for an incremental edit; full creation or migration requires the ownership and two-checkout proofs. Plan representative tests when the project is not Python/Pixi.

## Essential Failure Cases

Reject missing/unknown/traversing checkout keys, external symlink destinations, branch-map mismatches, linked-worktree administration masquerading as independent submodules, missing required source dependencies, implicit shared source selection and absent required resources. A read-only dry run must not create directories or write config. Detached recorded pins are valid; pure inspection must not fetch, install, repair, or clean.

Check recovery: a migration move ledger can identify each old source/ref and new owner; a removed checkout's needed commits remain in a remote, bundle or preserved Git store. Publication verification reads back remote refs and checks the meta gitlink, rather than trusting a push message alone.
