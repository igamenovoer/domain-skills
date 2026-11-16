# Manage Realwork Checkouts

## Workflow

1. **Resolve one action** from **Actions**, the meta root, and exact checkout key(s). With no action, show help; do not turn an ambiguous request into mutation.
2. **Inspect registration and local state.** Use [git-lifecycle.md](../references/git-lifecycle.md). Report branch, actual commit, index/HEAD pin, dirty and untracked files, nested submodules and relevant ahead/behind counts. Pure inspection does not fetch or change files.
3. **Resolve the action boundary.** Name source and destination refs, target path, environment and retained work. For integration or removal, account for unpublished commits and ignored state before acting.
4. **Execute the selected action.** Use native Git with explicit paths. Preserve other realworks and coordinate `.gitmodules`/gitlink edits in meta.
5. **Verify and report.** Confirm mapping, resulting commits, pin state, local resources, and relevant feature tests. State whether commits, publication or branch deletion were performed.

If scope is unclear, perform the safe inspection first and ask only for the specific missing destructive or semantic decision.

## Actions

| Action | Required inputs | Behavior |
| --- | --- | --- |
| `list` / `inspect` | Meta root; optional checkout keys | Read declared registrations and inspect each selected repository; uninitialized pins remain visible. |
| `create` | New branch, committed base, checkout key | Create an independent local clone, create the named functional branch from the exact base, and register it as a submodule. No automatic push. |
| `register` | Existing repository/ref and target key | Verify identity, branch and nested dependencies, then register and absorb the independent clone. Stop on conflicting paths or linked-worktree administration. |
| `restore` | Key and recorded pin source | Restore the explicitly selected index/HEAD gitlink in a clean checkout; normally detached. This does not follow a branch tip. |
| `record` | Key and intended functional commit | Record that exact commit as meta's gitlink after verification. Branch mapping alone is not a pin. Do not commit or push implicitly. |
| `integrate` | Source ref/range and receiving functional branch | Transfer selected committed work, fast-forward/merge/cherry-pick per policy; rebase only suitable unpublished topics. Meta branch is never the code receiver. |
| `remove` | Exact key and retained-work disposition | Deregister the submodule and remove its checkout safely. Branch deletion and Git-store purge remain separately requested actions. |

## Local Creation

A feature can start from a clean committed realwork without pushing first. Clone it with independent working files, use `--no-hardlinks` for a local clone, create the requested branch at the selected commit, then `git submodule add -b <branch> <source> realworks/<key>` and absorb its Git directory. Set the tracked URL to the portable canonical remote. Until publication, record that its new commit is only local; do not claim another machine can initialize it.

Use the full checkout key, such as `feature/example`, for metadata and temporary output. New development checkouts attach to their mapped branch. Detached recorded pins remain valid for reproduction. Missing nested functional dependencies are initialized at their own pins, not replaced by shared mutable symlinks. Do not copy another checkout's `.env`; derive relative local defaults from the complete new path while preserving any existing explicit values. Shared `env.example` instructions must explain branch-depth differences rather than claim main's literal paths fit every branch.

## Integration, Recording, and Publication

Inspection distinguishes local source/receiver divergence from remote-tracking divergence. Fetch only when the requested operation needs current remote state. Resolve conflicts using the repository's normal review process and preserve unrelated changes; never apply a blanket conflict preference or reset.

After integration, verify the receiving feature behavior and explicitly decide which gitlink(s) to record. A `record` action does not integrate code; a branch merge does not update meta automatically. When publishing is requested, push nested dependency commits and realwork commits first, verify remote reachability, then commit/push matching meta pins and plans. With a shared remote, never merge the `metaproj` tree into functional branches as a way to synchronize code.

## Removal

Inspect tracked/untracked/ignored files, active tasks, in-progress Git operations, and nested repositories. Preserve local settings and unpushed commits through retained branches, bundles or verified copies as needed. Reachability from a branch inside an about-to-be-deleted Git store is insufficient for purging that store. Migrate evidence/resources before removing their last location.

Use `git submodule deinit -- <path>` and `git rm -- <path>` only after the exact removal is authorized and state is safe; preserve absorbed Git storage by default. Reconcile `.gitmodules`, registration, and current indexes. Do not force removal, recursively wipe `.git/modules`, stop services, delete branches, or delete the checkout's shared temp/data merely because a feature is complete.
