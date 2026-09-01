# Configure VS Code File Watching

Reconcile a workspace's `files.watcherExclude` so the kernel's per-user inotify watch budget is spent on trees the editor must react to, not on read-only-intended ones. Run this on demand — when watch exhaustion symptoms appear, when the editor is sluggish on a heavy repository, or as an audit after a project gains a large installed, vendored, generated, or data tree.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Confirm the budget state and the symptom**. Measure the current watch pressure and identify the dominant watch consumers. See **Diagnosis**.
2. **Inventory and classify the workspace trees**. Apply the parent subskill's **Classification Principles** to every substantial directory of the project. Record the watch/unwatch decision per tree before writing any glob.
3. **Reconcile `files.watcherExclude`**. Merge the excluded trees into the project `.vscode/settings.json` (creating the file when absent), one `**/<name>/**` glob per excluded tree, preserving every existing entry and JSONC comment. See **Exclude Pattern Library** for the glob conventions.
4. **Align the related knobs when the task covers them**. `search.exclude` and `files.exclude` are separate mechanisms with separate purposes. See **Related Knobs** and change them only for their own reasons.
5. **Activate and verify**. Existing watches are released only when the editor's window reloads. See **Activation and Verification**; do not report success before the measured check.
6. **Report the result**. List the changed keys, the excluded trees with their classification intent, the measured watch counts before and after, and any host-level follow-up left to the user (see **Host-Level Relief**).

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the diagnosis, classification, reconciliation, and verification constraints in this command, then execute the plan.

## Diagnosis

The inotify watch budget is a per-user kernel limit shared by every process on the machine — the editor, dev servers, language servers, and any other tool all draw from the same pool. Measure before and after; never tune blind.

- Current limit: `cat /proc/sys/fs/inotify/max_user_watches` (a frequent default is 65536).
- Per-process watch consumption (count inotify watch descriptors per process, largest first):

```bash
for p in /proc/[0-9]*/fdinfo; do
  pid=${p%/fdinfo}; pid=${pid#/proc/}
  n=$(cat "$p"/* 2>/dev/null | grep -c '^inotify')
  [ "$n" -gt 100 ] && echo "$n $pid $(tr '\0' ' ' < /proc/$pid/cmdline 2>/dev/null | cut -c1-90)"
done | sort -rn | head -15
```

- Symptom signatures that point at watch exhaustion rather than broken dependencies:
  - chokidar / webpack / vite / watchman: `ENOSPC: System limit for number of file watchers reached`.
  - Next.js (Turbopack): a cascade of `Module not found: Can't resolve '<package>'` errors whose debug info carries `OS file watch limit reached` — the bundler cannot watch its dependency tree and module resolution collapses, so the errors misleadingly implicate installed packages that are perfectly intact on disk.

The dominant consumer is usually the editor itself watching the whole workspace. Exhaustion that appears "suddenly" typically means a new heavy tree appeared or another watcher-heavy process joined the pool; treat the workspace scoping below as the durable project-side fix regardless of which process tipped the pool over.

## Exclude Pattern Library

`files.watcherExclude` maps glob patterns to booleans in `.vscode/settings.json` (JSONC — comments allowed). Write one `**/<name>/**` entry per excluded tree so the rule matches the directory wherever it nests:

```jsonc
{
  "files.watcherExclude": {
    "**/node_modules/**": true,   // installed dependencies (obtained)
    "**/.pixi/**": true,          // tool environment (obtained)
    "**/.next/**": true,          // bundler build cache (derived)
    "**/dist/**": true            // build output (derived)
  }
}
```

Derive the actual entries from the classification step, using the parent subskill's well-known-conventions table for recognized names. Guidance:

- Prefer the recursive `**/<name>/**` form over a root-anchored `<name>/**` unless the project deliberately uses the same directory name for authored content elsewhere.
- Exclude whole trees, not individual file types; per-extension exclusions belong to search or lint tooling, not watching.
- A tree that must stay watched but is huge is not a watcherExclude problem — see **Host-Level Relief**.
- When a tree is excluded but the user occasionally edits inside it (rare configuration fixes inside a vendored checkout, for example), note that the editor will no longer auto-refresh the explorer there; files still open, edit, and save normally.

## Related Knobs

Three independent `*.exclude` families are easy to confuse; change each only for its own purpose:

| Key | Mechanism | Effect |
| --- | --- | --- |
| `files.watcherExclude` | OS file watching | Releases inotify watches; the explorer no longer auto-refreshes those trees. This command's subject. |
| `search.exclude` | Search scope | Keeps trees out of search results. VS Code already excludes `node_modules` and `bower_components` by default. |
| `files.exclude` | Explorer visibility | Hides trees from the explorer view entirely; affects presentation, not watch budget. |

`files.watcherInclude` exists for explicitly adding watch targets outside the workspace root; it is rarely needed and never a substitute for excluding the read-only trees.

## Activation and Verification

`files.watcherExclude` changes do not release watches the editor already holds; activation is an explicit step:

1. Reload the window: `Developer: Reload Window` (or restart the editor). State this plainly in the report when the user must do it.
2. Re-run the **Diagnosis** per-process count and confirm the editor's watch total collapsed to roughly the watched-set size; confirm the pool now has headroom for dev servers and language servers.
3. Re-run the failing consumer (dev server, bundler, test watcher) and confirm the watch-exhaustion signature is gone and module resolution/compiles succeed.

## Host-Level Relief

When the legitimately watched set itself approaches the limit, workspace scoping is not enough: the durable fix is raising the per-user ceiling (for example `fs.inotify.max_user_watches=524288` via a `sysctl.d` drop-in plus `sysctl --system`). That is host-level mutation outside this command's scope — recommend the exact commands to the user and route the operation to `imsight-dev-box-init` when requested.

## Guardrails

- DO NOT exclude `.git/` or any authored first-party tree from watching.
- DO NOT remove or rewrite existing `files.watcherExclude` entries or JSONC comments while merging new ones.
- DO NOT report the configuration as effective before the window reload and the measured watch-count check.
- DO NOT treat `search.exclude` or `files.exclude` edits as substitutes for watcher scoping, or vice versa.
- DO NOT modify kernel limits or other host settings from this command.
- DO NOT edit user-level (global) VS Code settings when a workspace `.vscode/settings.json` exists, unless the user explicitly asks for a user-level rule.
