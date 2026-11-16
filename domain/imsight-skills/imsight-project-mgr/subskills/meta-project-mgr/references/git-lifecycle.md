# Git Identity and Lifecycle

## Identity Checks

A registered realwork has a path under `realworks/`, a `.gitmodules` URL and branch mapping, and a gitlink in the meta index/commit. Its independent Git administration normally lives in meta `.git/modules/`. Check `git rev-parse --show-toplevel`, `--absolute-git-dir` and `--git-common-dir` from the selected checkout; do not treat an arbitrary directory, symlink outside the workspace, or linked `git worktree` as an equivalent registration.

Do not infer the branch from the path. `main` and `feature/...` are conventional mappings, not proof. New development checkouts attach to their declared branch; detached recorded commits are valid reproduction targets. If an attached branch differs from the mapping, stop targeted execution until the identity is reconciled. Independent clones avoid the shared administration and branch-checkout constraints of linked worktrees.

## State Before Mutation

Read both meta and realwork status. Inspect nested repositories separately. Preserve staged, unstaged, untracked and relevant ignored files, active tasks, in-progress merges/rebases, local branch-only commits and alternate remotes. A clean status does not establish synchronization or remote recoverability. Compare actual commits and refs. Never silently transfer dirty working files through a synthetic snapshot commit.

Creation requires a resolved committed base; source dirtiness can remain untouched if the request starts from that commit. Starting from dirty edits requires a deliberate task-scoped transfer or commit, not staging everything. Local submodule setup may need a seed commit and index registration; these are structural operations to report, not authority for unrelated feature commits or remote publication.

## History and Removal

Keep one explicit source and receiving branch for integration. Do not merge functional changes into `metaproj` as source code or merge its workspace tree into `main`. A metaproj commit records which functional revisions it accompanies through gitlinks.

A submodule gitlink protects a commit only while its repository objects remain obtainable. Before deleting the final clone or purging absorbed storage, verify a retained remote, bundle, or other repository has every needed object. Removing the working checkout and deleting branches/objects are separate decisions.

## Migrating Legacy Linked Worktrees

Inventory them with `git worktree list --porcelain`, branch reachability, status and local resource links. Keep old worktrees usable while preparing independent clones from committed refs. Transfer dirty task work only after explicit disposition; initialize nested dependency sources independently. Change consumers and resource bindings, validate the replacement, then remove an old linked worktree through native `git worktree remove` only when requested. Do not move `.git` control files by hand, prune unknown registrations, or require old `extern/trees/` links in the new model.
