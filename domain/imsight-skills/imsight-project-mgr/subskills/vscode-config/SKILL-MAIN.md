---
name: vscode-config
description: Use when a project's VS Code workspace should stop watching or analyzing read-only-intended trees — dependency and environment directories, build outputs, caches, data and model homes, vendored third-party checkouts, generated artifacts, and machine runtime state — that exhaust the inotify watch budget and language-server CPU while contributing nothing to first-party development.
skill_invocation_notation: >
  Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
  SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
  accepted only as legacy input when SKILL-MAIN.md is absent.
  Skill and subskill entrypoints use bare object paths: `X` invokes skill X and
  `X->Y->Z` invokes subskill Z. Subcommands use parenthesized components:
  `X->cmd()` invokes a direct subcommand, `X->Y->cmd()` invokes a subcommand of
  subskill Y, and `X->parent()->child()` invokes child subcommand child exposed
  by parent subcommand parent. Intermediate subcommands act as object generators.
  Forms such as `X()` and `X->Y()` are invalid for skill or subskill entrypoints.
---

# VS Code Workspace Configuration

## Overview

Scope a project's VS Code workspace so file watching and language-server analysis cover only the trees whose changes the editor must actually react to. Projects of any structure accumulate read-only-intended trees — installed dependencies, tool environments, build outputs, caches, datasets, model weights, vendored reference code, runtime state — and every file in them costs an inotify watch and possibly language-server work. When the kernel's per-user watch budget (often 65536) is exhausted, the failure surfaces far from the cause: dev servers report misleading "module not found" storms or crash with `ENOSPC`. This subskill teaches a generic classification method — decide watch-worthiness from a tree's intent, not from any particular repository layout — and reconciles the project `.vscode/settings.json` (a JSONC file that belongs in Git) accordingly.

## When to Use

- Use when a dev server, bundler, or test watcher fails with watch-exhaustion signatures: `ENOSPC: System limit for number of file watchers reached` (chokidar/webpack/vite/watchman), or a Turbopack/Next.js module-resolution storm whose debug info says `OS file watch limit reached`.
- Use when VS Code or its language servers are sluggish, hot, or memory-heavy on a repository that carries installed, vendored, generated, data, or runtime-state trees.
- Use to onboard or re-audit a project's watcher and analysis scoping after it gains any large read-only tree.
- Do not use for host-level kernel or system-limit tuning or for editor/extension installation (route those to `imsight-dev-box-init`), or for editors other than VS Code.

## Workflow

When this subskill is invoked, execute the following steps in order.

1. **Confirm routing**. Continue only when the user explicitly invoked `imsight-project-mgr->vscode-config` or the parent skill routed the operation here.
2. **Resolve the project root**. Use the user-provided project directory, or the current repository root when the task clearly targets it.
3. **Inventory and classify the workspace trees**. Walk the project root (sizes via `du -sh -- */`, hidden entries included) and assign every substantial directory to watch or unwatch by applying **Classification Principles**. Do not copy another project's glob list; derive the classification from this project's actual trees.
4. **Select the subcommand** from **Subcommands**. File watching and language-server analysis are independent mechanisms with separate settings keys; run both when the task covers both.
5. **Load and execute the selected command page**. Follow its workflow step by step, merging into the existing `.vscode/settings.json` rather than replacing it.
6. **Verify and report**. Apply the command page's activation and verification steps, then report the changed keys, the measured budget relief, and any host-level follow-up left to the user.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the subcommands, classification principles, and constraints in this subskill, then execute the plan.

## Invocation Contract

- Preferred explicit form: invoke skill `imsight-project-mgr->vscode-config` with the target project and request body.
- Direct subcommand form: invoke skill subcommand `imsight-project-mgr->vscode-config->config-file-watch()` or `imsight-project-mgr->vscode-config->python-watch()`.
- No subcommand and no actionable task means `help`.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `config-file-watch` | Reconcile `files.watcherExclude` so the OS inotify budget is spent on trees the editor must react to, not read-only-intended ones | `commands/config-file-watch.md` |
| `python-watch` | Scope Python language-server analysis (`python.analysis.*`) so Pylance does not parse, index, and check unnecessary Python code | `commands/python-watch.md` |
| `help` | Explain this subskill and list its subcommands | This entrypoint |

Each subcommand is independently invocable; the table order does not impose a lifecycle.

## Classification Principles

The durable product of this subskill is the classification itself; glob patterns only encode it. Apply these principles in order to every candidate tree.

### 1. Watch what the editor must react to

A file deserves a watch when a human edits it as part of development or a tool must react to its change (rebuild, hot-reload, re-analyze, refresh diagnostics). Everything else is budget waste. The question is never "is this directory important?" — dependencies are important and still do not need watching — but "does the editor gain anything from noticing a change here?"

### 2. Classify by intent, not by size

Ask of each tree which single intent governs it:

| Intent | Question | Treatment |
| --- | --- | --- |
| Authored | Do humans edit these files as first-party work (source, tests, docs, specs, configuration)? | Watch and analyze |
| Derived | Is it rebuilt from authored inputs (build outputs, generated code, compiled assets)? | Exclude — rebuilds regenerate it; watching only feeds loops |
| Obtained | Is it installed, vendored, or downloaded from elsewhere (dependencies, environments, datasets, models, reference checkouts)? | Exclude — it changes only through explicit tool runs, not editing |
| Machine state | Is it runtime, agent, or scratch state (logs, databases, session data, temp files)? | Exclude — it churns without any editing meaning |

Size and file count set priority and urgency — a huge authored tree still stays watched, a tiny obtained tree still gets excluded — but intent decides.

### 3. Trust well-known conventions

Recognized directory conventions carry their meaning with them; classify them at sight without deep inspection:

- Dependencies and environments: `node_modules/`, `.pixi/`, `.venv/`, `venv/`, `.direnv/`, `vendor/`, `third_party/`
- Build outputs and bundler caches: `dist/`, `build/`, `out/`, `.next/`, `.nuxt/`, `site/`, `coverage/`
- Tool caches: `__pycache__/`, `.mypy_cache/`, `.pytest_cache/`, `.ruff_cache/`, `.cache/`, `.turbo/`, `.parcel-cache/`
- Data and artifact homes: `datasets/`, `models/`, `downloads/`, `tmp/`
- Vendored or reference third-party: `extern/`, `external/`, `deps/`

These names mean the same thing in any project that adopts them. A project that keeps authored sources under such a name has mislabeled its layout — surface that instead of watching the tree.

### 4. Resolve unfamiliar trees from repository evidence

When a tree matches no convention and its intent is not obvious, gather evidence instead of guessing:

- Git tracked vs ignored (`git check-ignore`, ignored status): a large ignored tree is almost always derived, obtained, or state — exclude. A tracked tree is usually authored — but tracked reference data (for example via Git LFS) is still obtained; confirm who edits it.
- Documentation: the project's README, `AGENTS.md`, or the tree's own README usually states its purpose.
- Writer identity: files written by tools (lockstep regeneration, machine timestamps, generated-file banners) indicate derived or state; files with human commit history indicate authored.
- When evidence stays ambiguous, ask the user — one question beats a wrong durable exclusion.

### 5. Protect editor integrations and first-party trees

Never exclude `.git/` from watching (the SCM integration depends on it), and never exclude an authored tree merely because it is large — large first-party trees are a reason to raise the host budget or shrink the excluded set further, not to stop watching the work itself.

## Guardrails

- DO NOT exclude authored first-party source, test, documentation, or specification trees from watching or analysis, whatever their size.
- DO NOT copy another project's exclude list wholesale; derive the classification from the target project's actual trees using the principles above.
- DO NOT overwrite or reformat an existing `.vscode/settings.json`; merge new keys and preserve existing entries and JSONC comments.
- DO NOT report the configuration as effective before the window reload or language-server restart and the measured verification on the command page.
- DO NOT raise kernel inotify limits or otherwise mutate host settings; recommend the host-level fix and route it to `imsight-dev-box-init` when requested.
- DO NOT edit user-level (global) VS Code settings when a workspace `.vscode/settings.json` exists, unless the user explicitly asks for a user-level rule.

## Maintenance

Keep this entrypoint as a compact router with the shared classification principles. Put executable procedures in `commands/`; add a `references/` page only when a procedure needs material shared by several subcommands.
