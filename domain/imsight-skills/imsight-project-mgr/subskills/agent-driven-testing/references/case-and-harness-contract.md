---
metadata:
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

# Instructional Test Case and Harness Contract

This reference defines the three-part artifact architecture (test definitions, test outputs, and test reports), bundle lifecycle status, harness contract, soft-goal scenario schema, agent-behavior blinding rules, and operator prompting patterns shared by all `imsight-project-mgr->agent-driven-testing` subcommands.

## Three-Part Artifact Split

Instructional testing separates its artifacts into three distinct locations so tracked test definitions stay clean, raw test outputs can store anything produced during execution without polluting Git, and curated test reports can be tracked or archived independently:

1. **Test Definitions (`<cases-dir>/<case-slug>/`)** — **kept in the repo, Git-tracked**: durable harness contracts, user-POV scenarios, and optional helpers owned by the realwork project.
2. **Test Output (`<output-dir>/<test-slug>/`)** — **Git-ignored, can contain anything**: per-run execution workspace holding scripts, disposable runtime state, logs, screenshots, ARIA snapshots, transcripts, JSON cross-checks, `run-meta.json`, and any ad-hoc diagnostic artifacts.
3. **Test Reports (`<report-path>`)** — **durable Markdown reports (e.g., `.imsight-arts/...`), optionally Git-tracked**: curated, secret-redacted verdict and triage reports pointing to artifacts in `<output-dir>/<test-slug>/`. See [report-template.md](report-template.md).

## Part 1: Test Definitions (`<cases-dir>/<case-slug>/`)

Test definitions are functional verification assets owned by the **realwork project** and tracked in Git. Always resolve `<cases-dir>` and `<case-slug>` before proposing, authoring, running, or auditing cases:

1. **User-specified `<cases-dir>`**: honor an explicit test-definitions directory provided by the user.
2. **Project context**: use an existing instructional test root declared in the realwork or enclosing metaproj `AGENTS.md` or `tests/README.md`.
3. **Default `<cases-dir>`**: `<realwork>/tests/instructional/`.

Resolve `<case-slug>` as a concise kebab-case bundle identifier (explicitly named by the user, or derived from the target feature, workflow, or debug campaign topic, such as `skill-update` or `two-agent-mailbox`). If the user passes a full bundle path that already ends in `<case-slug>` (or a specific file inside `<cases-dir>/<case-slug>/cases/`), do not double-nest `<case-slug>/<case-slug>`; extract `<cases-dir>` and `<case-slug>` from that path and confirm both in the output.

Every test definition bundle lives under `<cases-dir>/<case-slug>/`, never directly under `<cases-dir>`, so independent suites and their harnesses never collide:

```text
<cases-dir>/                         # Default: <realwork>/tests/instructional/ (Git-tracked in realwork)
├── README.md                        # Optional. Lightweight index listing <case-slug>/ bundles only (never a single bundle's harness).
└── <case-slug>/                     # Required per-topic/case bundle directory (e.g., skill-update/, two-agent-mailbox/).
    ├── README.md                    # Required. Bundle status (`draft` | `proven`), harness contract, preconditions, driving rules, and scenario index.
    ├── cases/                       # Required. One or more user-POV Markdown scenario files for <case-slug>.
    │   ├── <scenario-slug>.md
    │   └── ...
    └── helpers/                     # Optional. Durable, executable helper scripts and fixtures scoped to <case-slug>.
```

- Keep implementation internals out of `cases/`. Describe user-visible surfaces, stable handles, required preconditions, exact commands, observable signals, and soft goals.
- Every file in `<cases-dir>/<case-slug>/helpers/` must be executable and have its exact invocation documented in `<cases-dir>/<case-slug>/README.md` or the calling scenario file.
- When `<cases-dir>` already contains an optional top-level `<cases-dir>/README.md` index, update only its bundle index link when adding or removing a `<case-slug>/` directory during `author-case()` or `audit-case()`.
- Never place disposable run logs, temporary scripts, secrets, auth tokens, screenshots, raw outputs, or test reports inside `<cases-dir>`.
- `run-case()` treats `<cases-dir>` as strictly read-only; modifications to `<cases-dir>/<case-slug>/` happen only under explicit instruction via `author-case()` or `audit-case()`.

### Bundle Verification Status (`draft` vs. `proven`)

To preserve `pstack`'s principle that an unexecuted verification bundle is a draft rather than a proven deliverable while keeping authoring and execution cleanly separated:

- **`status: draft`**: assigned by `author-case()` whenever a bundle is newly created or its harness/steps/helpers are materially changed without a subsequent live run. Signals that the harness has been statically checked against the repo but not yet proven end to end.
- **`status: proven`**: assigned only via an explicit `author-case()` update (citing a verified `run-case()` report and commit SHA) or after a live-verified `audit-case()` pass. `run-case()` never edits `<cases-dir>/<case-slug>/README.md` to change this field on its own; instead, it notes in its report whether a `draft` bundle is ready for promotion.

Record this metadata near the top of `<cases-dir>/<case-slug>/README.md` (for example, `Status: draft` or `Status: proven (commit <sha>, report <path>)`).

## Part 2: Test Output (`<output-dir>/<test-slug>/`)

All temporary scripting, disposable runtime state, raw evidence, logs, and ad-hoc diagnostic files produced during execution belong inside **`<output-dir>/<test-slug>/`**, never inside `<cases-dir>`, tracked repo paths, or system `/tmp`.

### Output Directory Resolution (`<output-dir>`)

Resolve `<output-dir>` in this exact order before writing any test execution output:

1. **User-specified `<output-dir>`**: honor an explicit output directory provided by the user.
2. **Project-local temporary root (`<project-tmp-root>`)**: inspect the realwork and enclosing metaproj `AGENTS.md`, `.gitignore`, `env.example` / `.env` (`<PREFIX>_DEV_TMP_ROOT`), and existing ignored temporary trees (for example `<meta-root>/tmp/<complete-checkout-key>/` in a metaproj, or `<realwork>/tmp/`, `<realwork>/.tmp/`, `<realwork>/.scratch/` in a standalone realwork), then set `<output-dir> = <project-tmp-root>/instructional-tests/`.
3. **Project-local fallback**: when no temp convention is documented, choose `<meta-root>/tmp/<complete-checkout-key>/instructional-tests/` (when attached to a metaproj) or `<realwork>/tmp/instructional-tests/` (when standalone), confirm the parent temp tree is ignored by Git using `git check-ignore -q <path>`, and create it. If the path is not ignored, add or request an ignore rule before writing output files.

### Per-Run Test Output Layout (`<output-dir>/<test-slug>/`)

Allocate a unique `<test-slug>` per execution (for example `YYYYMMDD-HHMMSS-<case-slug>` or a user-provided slug) so concurrent or repeated runs never collide. `<output-dir>/<test-slug>/` **can contain anything** needed to run, observe, and diagnose the test; use this conventional layout as the default starting point:

```text
<output-dir>/<test-slug>/
├── scripts/        # Disposable per-run driver scripts, Playwright snippets, tmux/env shims
├── runtime/        # Disposable app data dirs, configs, caches, PIDs, stdout/stderr logs, profiles
├── evidence/       # Proof artifacts that MUST survive cleanup (screenshots, ARIA snapshots, transcripts, JSON cross-checks)
├── run-meta.json   # Run identity: realwork path, commit SHA, dirty status, harness version, timestamps, PIDs/sockets started
└── ...             # Any additional raw dumps, traces, recordings, or scratch diagnostics produced by the run
```

- **Temporary scripts (`scripts/`)**: write one-off exploration wrappers, browser-driving scripts, or launch shims here. When agents keep rewriting the same temporary script across runs, recommend promoting a clean version into `<cases-dir>/<case-slug>/helpers/` via an explicit `author-case()` update.
- **Disposable runtime state (`runtime/`)**: keep isolated data dirs, test databases, homes, logs, and browser profiles here. Delete or stop only what this run created during cleanup.
- **Surviving artifacts (`evidence/`)**: store every screenshot, terminal capture, ARIA snapshot, HTTP/CLI transcript, and read-only cross-check file here under `<case-slug>/<scenario-slug>/`. Cleanup must never delete `evidence/` or any artifact cited by the test report.
- **OS socket-length exception**: if an IPC or tmux Unix socket path under `<output-dir>/<test-slug>/` exceeds the OS `AF_UNIX` length limit, place only the short run-unique socket file under an isolated OS socket dir (such as `/tmp/tmux-<uid>/<project>-<test-slug>/`), record its exact path in `run-meta.json`, clean up only that socket on teardown, and keep all scripts, runtime data, and evidence inside `<output-dir>/<test-slug>/`.

## Part 3: Test Reports

Durable Markdown test reports are written separately from both `<cases-dir>/<case-slug>/` and raw `<output-dir>/<test-slug>/` outputs (defaulting to `.imsight-arts/project-mgr/agent-driven-testing/reports/<timestamp>-<run-slug>.md`, or a user/env destination) and **may be chosen to be Git-tracked** by the project or user. See [report-template.md](report-template.md) for destination priority, verdict/triage rules, and the full template.

## Harness Contract (`<cases-dir>/<case-slug>/README.md`)

Write `<cases-dir>/<case-slug>/README.md` for a cold agent reading the repo mid-task, with concrete repo commands and zero placeholders. Include a top status line (`Status: draft` or `Status: proven (...)`) followed by these sections:

1. **Baseline Preconditions & Isolation**: how to resolve `<output-dir>/<test-slug>/`, required env vars, seeded fixtures, isolated ports/data dirs/tmux sockets, and whether two instances can run side by side (if not, state explicitly to refuse double-driving a shared instance).
2. **Launch**: exact command to start the target from an empty disposable data directory (including build, migrations, or seeding), plus the concrete signal that proves the target is *usable* (not merely listening). For short-lived CLIs or TUIs, state the one-time build step and how each drive launches an isolated PTY or tmux server (`env -u TMUX -u TMUX_PANE -u TMUX_TMPDIR tmux -S <socket>`).
3. **Doctor**: one read-only command or check answering "is this instance worth driving?" — process alive, expected revision/version, port or socket owned by this run, auth/endpoints healthy, and stable app marker confirmed.
4. **Drive**: the exact driving surface and conventions (existing test harness first, otherwise Playwright/CDP for Web, PTY/isolated tmux for CLI/TUI, HTTP/CLI for services). Prefer stable handles (ARIA roles/names, data attributes, explicit flags, `--print-json` / `--format json`, exact route paths) over coordinates, generated CSS hashes, or fragile DOM positions.
5. **Evidence**: proof standards and artifact paths inside `<output-dir>/<test-slug>/evidence/<case-slug>/<scenario-slug>/`. Require exercising the real user path, capturing both the triggering action and resulting state, and performing a read-only second-view cross-check of side effects (files written, DB rows, mailbox state, logs, exit codes). For dry-run or safe modes, require observing what the mode actually skipped rather than trusting its flag name.
6. **Cleanup**: exact teardown steps that stop only PIDs, containers, gateways, or isolated tmux servers started by this run (recorded in `run-meta.json`), remove disposable `runtime/` scratch state, and leave `evidence/` intact.
7. **Helpers** (when `helpers/` is present): list every executable script in `<cases-dir>/<case-slug>/helpers/` with its exact command-line invocation and purpose.
8. **Case Index**: link every file under `<cases-dir>/<case-slug>/cases/` with a one-line user-visible summary and any required capability tags (such as `cli`, `web`, `multi-agent`, `external-model`).

## Instructional Test Case Template (`<cases-dir>/<case-slug>/cases/<scenario-slug>.md`)

Every case file starts with an H1 title and one concise paragraph describing the intent and user-visible scope under test, followed by **five fixed H2 sections** in this exact order:

```markdown
# <User-Facing Feature or Scenario Name>

<Intent & scope: one-paragraph summary of what the user or operator wants to accomplish, what is in scope, and why it matters.>

## Sub-cases

- `<case-id-1>`: <one-line observable behavior>
- `<case-id-2>`: <one-line observable behavior>

## How to get to it (user POV)

- <User entry point 1 (UI control, keyboard shortcut, CLI command, API route, or operator workflow)>
- <User entry point 2>

## Driving it with <harness-name>

Preconditions:

- <Isolated runtime healthy via Doctor check>
- <Exact seed fixture, config, or service prerequisite>

- **<Step label>.** <User intent.> Run `<exact literal command or harness action>`. <Observable progression proving this step executed.>
- **<Next step label>.** ...
- **Cross-check.** <Read-only second view confirming durable side effects or transcripts.>
- **Proof.** Save `<artifacts>` under `<output-dir>/<test-slug>/evidence/<case-slug>/<scenario-slug>/`.

## Expected Outcome (Soft Goals)

- **Soft goals (runner makes final PASS/FAIL decision):**
  - <Qualitative goal 1 describing what a successful outcome looks like from the user's POV>
  - <Qualitative goal 2>
- **Observable signals to inspect:** <Exact captured artifacts, UI/CLI outputs, or read-only cross-checks the runner must inspect and cite in its rationale.>
- **Hard disqualifiers (automatic FAIL):** <Non-negotiable failure conditions such as crashes, forbidden mutations, leaked secrets, wrong exit codes on required steps, or missing cross-check evidence.>

## Gotchas

- <Known timing/debounce rule: wait for an observable state, never a fixed sleep when avoidable>
- <Known wrong surface, flag trap, or unmet precondition behavior>
- <Reset or cleanup note preserving proof artifacts>
```

### Rules for Good Cases and Soft Goals

- **Test behavior, not implementation**: a case should fail if user-observable behavior breaks and keep passing if only internals change.
- **Soft goals are qualitative, not vague**: state what matters to a human user or operator without over-constraining incidental wording, layout pixels, or formatting, and pair every soft goal with the concrete evidence the runner must inspect to judge it.
- **No silent entry-point substitution**: proving one entry point does not verify another entry point listed under `How to get to it (user POV)`.
- **Fail honestly on missing preconditions**: if seed data, credentials, or a required service is missing, report `VERIFIED-UNREACHABLE` or `BLOCKED` and note the cause in the report. Never weaken steps or goals to force a pass.
- **Include negative and reset steps where meaningful**: pair "must succeed" flows with refusal/guardrail checks and explicit reset instructions when a case can be repeated twice (such as bug reproduction or before-and-after fix verification).

## Optional Addendum: Agent-Behavior and Multi-Agent Cases

When the system under test includes AI agents, system skills, prompts, or multi-agent coordination (for example, evaluating whether two managed agents coordinate over a mailbox or obey guardrails), add an optional `## Blinding and Transcript Checks` section at the bottom of the case file with these rules:

- **Prevent observer effect**: keep meta-words (`eval`, `test`, `judge`, `rubric`, `benchmark`, `candidate`, `arena`) out of directories, filenames, and prompts seen by the tested agent. Give an organic user/operator prompt.
- **Grade from transcripts and side effects, not self-report**: inspect the tested agent's actual execution transcript, tool calls, opened files, and durable outputs (mailbox state, written files, audit logs) rather than trusting the agent's final summary.
- **Isolate fixture roles from general behavior**: do not leave narrow smoke-test roles (such as acknowledgement-only instructions) active when testing general task execution.

## How to Instruct an Agent Across the Three Phases

Users and operators can invoke each phase independently by specifying the target realwork, an optional `<cases-dir>` (defaulting to `<realwork>/tests/instructional/`), a `<case-slug>` bundle name, and (for runs) an optional `<output-dir>` and report destination.

> **Example Warning:** The user/AI prompt examples below are for example purposes only. Learn their style, intent, and semantics rather than hardcoding the example text, filenames, or model names.

### Example 1: Phase 1 — Propose a Test Case (Discussion Only)

- **User prompt**: "Invoke `imsight-project-mgr->agent-driven-testing->propose-case()` on `<realwork>` for a `cli-and-web-smoke` bundle. Interview the repo and propose the scope, preconditions, driving plan, and soft goals — do not write files or run anything yet."
- **Expected AI response shape**: Summarizes what the repo interview found across `Surface`, `Run`, `Drive`, `Observe`, and `Isolate`, proposes `<cases-dir>/cli-and-web-smoke/`, sub-cases, preconditions, `Doctor`/harness plan, qualitative soft goals, observable signals, hard disqualifiers, and open questions for user feedback, with zero files modified and zero processes started.

### Example 2: Phase 2 — Author or Update Test Definitions (`author-case()`)

- **User prompt**: "Invoke `imsight-project-mgr->agent-driven-testing->author-case()` on `<realwork>` to write the approved `two-agent-mailbox` test definitions under `tests/instructional/two-agent-mailbox/`."
- **Expected AI response shape**: Confirms tracked definition files written under `<cases-dir>/two-agent-mailbox/` (`README.md` marked `Status: draft`, `cases/*.md` with `## Expected Outcome (Soft Goals)`, optional executable `helpers/`), reports static repo grounding checks performed, confirms no live run was executed, and suggests running `imsight-project-mgr->agent-driven-testing->run-case()` next.

### Example 3: Phase 3 — Run Live (`run-case()`)

- **User prompt**: "Invoke `imsight-project-mgr->agent-driven-testing->run-case()` on `<realwork>` for `tests/instructional/skill-update/`, writing test outputs under `tmp/instructional-tests/`."
- **Expected AI response shape**: Executes `Launch`, `Doctor`, each scenario, read-only cross-checks, and `Cleanup` inside `<output-dir>/<test-slug>/` without modifying anything under `tests/instructional/skill-update/`, renders a definitive verdict (`PASS`, `FAIL`, `BLOCKED`, or `VERIFIED-UNREACHABLE`) for every scenario with evidence-cited soft-goal rationale, reports any `usability-issue` encountered along with uncertainty/open questions in the durable report (`.imsight-arts/...`), confirms evidence survived cleanup, and notes whether any test-definition updates (such as promoting `draft` -> `proven` or fixing a `harness-gap`) are recommended under explicit `author-case()` instruction.
