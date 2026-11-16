# Migrate an Existing Project to Metaproj and Realworks

## Workflow

1. **Inventory before mutation.** Read the existing project, guidance, build/test/CI, Git history/remotes, linked worktrees, submodules, symlinks, environments, payloads and active tasks. Establish baseline checks and known failures. Include untracked/ignored state without printing secrets.
2. **Write a concrete move plan.** Under a chosen durable planning location, record source/destination, owner, consumers and preservation checks for each affected group. Split mixed documents, scripts and tests using **Content Decisions**. Record unresolved ownership before moving it.
3. **Preserve source identity and recovery.** Record base commits and source digests. Create a backup ref/tag or verified bundle when authorized; otherwise retain existing refs and record recovery locations. Resolve dirty files deliberately. Do not switch a dirty occupied source checkout or stop unrelated tasks.
4. **Prepare independent Git trees.** Establish functional `main` and a `metaproj` branch sharing existing ancestry. Stage in a separate clone when the original cannot safely change roles. Apply branch-specific removals only after their content remains reachable. Register main under `realworks/main` as an independent submodule; retain nested pins. Follow [git-lifecycle.md](../references/git-lifecycle.md).
5. **Move development ownership.** Lift tools, policy, plans, design docs, skills, editor/CI config, and all OpenSpec records into meta. Keep functional code, experiments, tests, public contracts, package resources and acquisition controls in realwork. Preserve immutable evidence and record intentional edits separately from byte-identical moves.
6. **Repair consumers and setup.** Update imports, path resolution, commands, build metadata, link destinations, discovery, skill references, both agent guides, and optional standalone instructions. Follow [configure-workspace.md](configure-workspace.md). Replace implicit parent searching and old worktree symlinks with declared bindings; adapt provenance paths without changing historical bytes.
7. **Verify before replacing old locations.** Follow [verify-workspace.md](verify-workspace.md). Confirm standalone functionality with provisioned prerequisites and two-checkout source/dependency isolation. Preserve failures proven on the baseline; do not delete tests or dilute contracts to pass.
8. **Finalize the move record.** Reconcile every moved or retained group, run revision/link checks, and report new roots, refs/pins, test outcomes and manual setup. Remove old aliases/worktrees only within explicit cleanup scope. Publish functional/dependency commits before meta pins when publication is requested.

If interrupted, resume by comparing the ledger and actual source/destination states. Do not restart destructive moves or treat an existing partial destination as safe to overwrite.

## Content Decisions

- Package metadata, runtime/optional dependencies, distributed assets and required source dependency declarations remain functional. Shared development manifests, lockfiles and test/lint/build orchestration move to meta; functional verification dependencies and suite configuration stay with tests.
- Experimental code can be usable even when integrated by monkeypatch. Keep it and its tests in realwork; lift campaign plans/internal reports, bind shared inputs, and isolate new output.
- Separate API/format/usage material from implementation plans inside mixed documents. Feature verifiers and demonstrations stay with their feature; repository placement/lifecycle-policy engines and their tests move to meta.
- Keep model/dataset acquisition and functional configuration portable. Moving payload storage does not authorize deleting it or silently making a meta reference clone a runtime dependency.
- `context/`, project skills, editor support and OpenSpec become meta-owned. Preserve OpenSpec IDs, archives, task state and links to implementation revisions. Shared plans identify the relevant realwork and branch.
- Existing `.env`, credentials, caches, payloads and retained evidence are local state to preserve, not content to stage with `git add -A`. Record ownership and hashes where useful without logging secret values.

## Transaction and Recovery Record

Track completed moves with their original digest, target path, intended edits, ref containing the old content, and validation. For a conflict where both copies exist, compare content before deciding which is authoritative. Verify recovery before discarding the final source copy. Working-tree reorganization is reversible; history rewriting, replacing a remote branch, purging objects, deleting data and stopping services are separate operations.

The existing repo path may become metaproj only after the functional source is preserved and its independent checkout works. A temporary staging clone is an implementation detail, not a permanent sibling-worktree topology.
