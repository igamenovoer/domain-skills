# Configure VS Code Python Analysis Scope

Reconcile a workspace's `python.analysis.*` settings so the Python language server (Pylance) parses, indexes, and checks only the Python code whose diagnostics and navigation the developer actually uses — the authored first-party trees — instead of every installed environment, vendored checkout, and generated artifact reachable from the workspace. Run this on demand: when Pylance is slow, hot, or memory-heavy, when the problems panel fills with third-party diagnostics, or as an audit after a project gains a large Python-bearing read-only tree.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Inventory the Python-bearing trees**. Find where Python code lives in and around the workspace (environments, vendored checkouts, generated bindings, data tooling) and classify each tree with the parent subskill's **Classification Principles**: authored trees keep full analysis; obtained, derived, and machine-state trees are analysis waste.
2. **Choose the mechanism per tree and symptom**. The `python.analysis.*` family has several distinct levers with different semantics; pick deliberately. See **Mechanism Selection**.
3. **Reconcile `.vscode/settings.json`**. Merge the selected keys into the project settings file, preserving every existing entry and JSONC comment. See **Configuration Patterns**.
4. **Activate and verify**. Analysis rescoping takes effect only after the language server restarts. See **Activation and Verification**.
5. **Report the result**. List the changed keys, the trees excluded from analysis with their classification intent, and the observed effect (indexing time, CPU, diagnostic noise).

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the classification, mechanism-selection, reconciliation, and verification constraints in this command, then execute the plan.

## Mechanism Selection

Each lever answers a different question. Match it to the actual intent instead of stacking all of them:

| Key | Semantics | Use When |
| --- | --- | --- |
| `python.analysis.exclude` (globs) | Matching files are not analyzed as workspace members: no diagnostics, no workspace indexing. They remain import-resolvable, so authored code that imports them still resolves. | The default tool for environment trees, vendored checkouts, and generated code that first-party code imports or navigates into. |
| `python.analysis.ignore` (globs) | Suppresses all diagnostics for matching paths while keeping them otherwise analyzable. | Trees that stay analyzable for navigation but must never raise problems — typically vendored code a developer occasionally opens. |
| `python.analysis.diagnosticMode` | `workspace` analyzes every workspace file; `openFilesOnly` analyzes only open editors. | `openFilesOnly` is the big CPU/RAM lever for huge workspaces; the tradeoff is that project-wide error lists and some cross-file checks degrade until files are opened. |
| `python.analysis.indexing` | Indexes installed libraries and workspace files for completions and references. | Disable only when background indexing itself is the cost; expect poorer auto-import and reference results. |
| `python.analysis.userFileIndexingLimit` | Caps how many workspace user files get indexed (default 2000); larger workspaces skip user-file indexing entirely. | A workspace blowing past the cap silently loses project-wide completions/references — raise with reason or shrink the analyzed set with `exclude`. |
| `python.analysis.autoImportCompletions` | Scans installed packages to offer auto-import completions. | Disable when environment scanning itself is the hotspot and the user accepts weaker auto-imports. |
| `python.analysis.extraPaths` | Adds import-resolution roots — and enlarges the analysis surface with them. | Treat as a cost, not a fix: prefer resolving imports through the environment and excluding the trees instead of adding paths. |

The file-watcher scoping from `config-file-watch` is complementary, not overlapping: `files.watcherExclude` releases the core editor's inotify watches, while the keys above cut the language server's own parsing, indexing, and watching work. Heavy Python workspaces usually need both.

## Configuration Patterns

Exclude globs follow the same `**/<name>/**` convention as the watcher keys, derived from the classification step rather than copied from another project:

```jsonc
{
  "python.analysis.exclude": [
    "**/.pixi/**",        // tool environment (obtained)
    "**/.venv/**",        // virtual environment (obtained)
    "**/node_modules/**", // vendored JS that may carry Python tooling (obtained)
    "**/extern/**",       // vendored/reference checkouts (obtained)
    "**/build/**"         // generated bindings and build output (derived)
  ]
}
```

Keep the authored trees — the project's own `src/`, `tests/`, `scripts/`, however they are named in the target project — fully analyzed. Add `python.analysis.diagnosticMode: "openFilesOnly"` only when the workspace remains heavy after scoping, and say its tradeoff in the report.

## Activation and Verification

1. Restart the analysis engine: run `Python: Restart Language Server`, or reload the window (`Developer: Reload Window`). State this plainly in the report when the user must do it.
2. Verify the effect: Pylance's output channel completes indexing quickly, background CPU settles, and the problems panel no longer carries diagnostics from excluded trees.
3. Open a file inside an excluded or ignored tree and confirm the intended semantics: excluded files still support import resolution from authored code, and ignored files open without raising diagnostics.

## Guardrails

- DO NOT exclude or ignore the project's authored first-party Python trees from analysis, whatever their size.
- DO NOT lower `python.analysis.typeCheckingMode` to silence diagnostics from read-only trees; scope the analysis surface instead of weakening the checks on authored code.
- DO NOT enable `diagnosticMode: "workspace"` on a workspace carrying large vendored or environment trees without first scoping `exclude`.
- DO NOT merge blindly into `.vscode/settings.json`; preserve existing entries and JSONC comments.
- DO NOT report the configuration as effective before the language-server restart and the observed verification.
- DO NOT edit user-level (global) VS Code settings when a workspace `.vscode/settings.json` exists, unless the user explicitly asks for a user-level rule.
