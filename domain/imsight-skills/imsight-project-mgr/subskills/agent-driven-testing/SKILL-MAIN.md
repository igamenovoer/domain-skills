---
name: agent-driven-testing
description: Use when proposing, authoring, running, auditing, or reporting agent-driven instructional test suites with separated test definitions (<cases-dir>/<case-slug>/, tracked in repo), test outputs (<output-dir>/<test-slug>/, isolated run artifacts), and test reports (.imsight-arts/..., optionally tracked), using separated propose/author/run phases, qualitative soft-goal outcomes, and usability-issue triage.
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

# Agent-Driven Testing

## Overview

Design, author, execute, audit, and report self-contained agent-driven instructional test suites across three strictly separated artifact layers: **test definitions** (`<cases-dir>/<case-slug>/`, kept in the realwork repo and Git-tracked), **test outputs** (`<output-dir>/<test-slug>/`, isolated per-run workspace that can contain any scripts, runtime state, logs, and raw evidence), and **test reports** (`.imsight-arts/...` or user-chosen destination, optionally Git-tracked). The workflow separates discussion (`propose-case()`), authoring (`author-case()`), and live execution (`run-case()`) so no phase surprises the user with unintended edits or launches, expected outcomes use qualitative **soft goals** judged definitively from surviving runtime evidence, and triage captures `usability-issue` alongside `doc-drift`, `harness-gap`, and `product-regression`.

## When to Use

- Use when a realwork project needs repeatable, agent-executable verification suites under `<cases-dir>/<case-slug>/` (default `<cases-dir>`: `<realwork>/tests/instructional/`) for CLI, TUI, Web UI, service, API, or multi-agent behaviors that unit tests alone cannot prove.
- Use when turning manual walkthroughs, debug campaigns, OpenSpec requirements, or bug reproductions into durable instructional test definitions through an explicit propose -> author -> run lifecycle.
- Use when running instructional test suites live against the realwork without modifying test definitions, capturing usability friction that confuses the executing agent, auditing definitions for drift against current source, or synthesizing evidence-backed test reports.
- Do not use for ordinary fast unit tests (`tests/unit/`), static lint/type checks, or repository-policy checks owned by a metaproj (place those in standard automated suites or metaproj tools instead).
- Do not use to silently patch product code during test execution or audit; report confirmed product regressions and usability issues separately.

## Workflow

When this subskill is invoked, execute the following steps in order.

1. **Confirm routing, target realwork, `<cases-dir>`, and `<case-slug>`.** Continue on explicit invocation of `imsight-project-mgr->agent-driven-testing` or a route from `imsight-project-mgr`. Resolve the exact realwork checkout and branch (and enclosing metaproj root when attached) following the [responsibility contract](../../references/project-responsibilities.md), resolve `<cases-dir>` (user-specified path first, then project context, then default `<realwork>/tests/instructional/`), and resolve the target test definition directory `<cases-dir>/<case-slug>/` (or all `<case-slug>/` bundles under `<cases-dir>` for whole-directory runs/audits). See **Three-Part Artifact Architecture**.
2. **Select the phase subcommand without auto-chaining.** Choose the exact subcommand from **Subcommands** that matches the user's request (`propose-case`, `author-case`, `run-case`, `audit-case`, `report-results`, or `help`). Stop at the end of the selected phase; never jump from `propose-case()` into writing files, never jump from `author-case()` into launching the app, and never mutate `<cases-dir>/<case-slug>/` during `run-case()`.
3. **Resolve the test output directory (`<output-dir>/<test-slug>/`) and report destination when running or auditing.** For `run-case()`, `audit-case()`, or `report-results()`, resolve `<output-dir>` (explicit user path or `<project-tmp-root>/instructional-tests/`) and allocate `<output-dir>/<test-slug>/` for all raw execution artifacts, plus resolve the durable test report path per [report-template.md](references/report-template.md). See **Three-Part Artifact Architecture** and [case-and-harness-contract.md](references/case-and-harness-contract.md).
4. **Load and execute the selected command page.** Follow its numbered workflow, phase boundaries, soft-goal judgment rules, usability-issue capture rules, and live-verification invariants without weakening preconditions or skipping runtime proof.
5. **Deliver phase output.** Return the design proposal (for `propose-case()`), the authored test-definition summary with `status: draft` noted (for `author-case()`), or the durable Markdown test report plus concise in-chat summary distinguishing definitive verdicts, usability issues, uncertainty/open questions, and cleanup status (for `run-case()`, `audit-case()`, and `report-results()`).

If the user explicitly requests chaining multiple phases in one turn (for example, authoring a bundle and immediately running it), use your native planning tool to sequence the matching subcommands in order while honoring every phase boundary, read-only rule, and live-proof invariant.

## Invocation Contract

- Preferred explicit form: invoke skill `imsight-project-mgr->agent-driven-testing` with the selected realwork, optional `<cases-dir>`, `<case-slug>`, `<output-dir>`, and phase task.
- Direct subcommand forms:
  - `imsight-project-mgr->agent-driven-testing->propose-case()`
  - `imsight-project-mgr->agent-driven-testing->author-case()`
  - `imsight-project-mgr->agent-driven-testing->run-case()`
  - `imsight-project-mgr->agent-driven-testing->audit-case()`
  - `imsight-project-mgr->agent-driven-testing->report-results()`
  - `imsight-project-mgr->agent-driven-testing->help()`
- No subcommand and no actionable task means `help()`.

## Subcommands

### Procedural Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `propose-case` | **Phase 1 (Discuss only):** interview the realwork repo read-only and propose a test case design (intent, scope, preconditions, driving plan, soft goals, and pass/fail criteria) with zero file writes and zero app execution | [propose-case.md](commands/propose-case.md) |
| `author-case` | **Phase 2 (Create or update test definitions):** write or update tracked definitions under `<cases-dir>/<case-slug>/` (`README.md`, `cases/*.md`, optional `helpers/`) with static repo grounding only (no live execution); stamps newly authored/changed unexecuted bundles `status: draft` | [author-case.md](commands/author-case.md) |
| `run-case` | **Phase 3 (Execute live, read-only on definitions):** execute one `<cases-dir>/<case-slug>/` bundle (or all bundles under `<cases-dir>`) live, write all raw execution artifacts to `<output-dir>/<test-slug>/`, judge soft goals definitively, log any `usability-issue`, and emit the test report without modifying test definitions | [run-case.md](commands/run-case.md) |
| `audit-case` | **Maintenance:** on explicit invocation, keep `<cases-dir>/<case-slug>/` definitions aligned with evolving source through index hygiene, a parallel read-only source wave, a mandatory live pass writing raw output to `<output-dir>/<test-slug>/`, and strict triage (`doc-drift`, `harness-gap`, `product-regression`, `usability-issue`) | [audit-case.md](commands/audit-case.md) |
| `report-results` | **Report synthesis:** synthesize or aggregate verified artifacts from `<output-dir>/<test-slug>/` into a durable Markdown test report and concise in-chat summary | [report-results.md](commands/report-results.md) |

### Helper Subcommands

No helper subcommands are currently exposed.

### Misc Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `help` | Explain the three-phase lifecycle (`propose-case` -> `author-case` -> `run-case`), three-part artifact split (definitions / outputs / reports), soft-goal contract, usability-issue triage, and available subcommands without mutating files | This entrypoint |

## Three-Part Artifact Architecture

Keep test artifacts strictly separated across three locations with distinct lifecycles and Git policies:

| Artifact Part | Location | Git Tracking | Contents | Written By |
| --- | --- | --- | --- | --- |
| **1. Test Definitions** | `<cases-dir>/<case-slug>/` (default `<cases-dir>`: `<realwork>/tests/instructional/`) | **Tracked in repo** | `README.md` (`Status: draft \| proven` + harness contract + index), `cases/<scenario-slug>.md` (user-POV scenarios + soft goals), optional executable `helpers/` | `author-case()` (and `audit-case()` for proven `doc-drift`/`harness-gap` fixes only). **Strictly read-only during `run-case()`.** |
| **2. Test Output** | `<output-dir>/<test-slug>/` (default `<output-dir>`: `<project-tmp-root>/instructional-tests/`; `<test-slug>`: run-unique slug such as `YYYYMMDD-HHMMSS-<case-slug>`) | **Git-ignored** (disposable/raw) | **Anything produced by execution**: temporary `scripts/`, disposable `runtime/` state/logs/profiles, surviving `evidence/` (screenshots, ARIA snapshots, transcripts, JSON cross-checks), `run-meta.json`, and any ad-hoc diagnostic artifacts | `run-case()` and `audit-case()`. Cleanup removes run-owned processes/sockets and disposable `runtime/` while preserving `evidence/` and cited artifacts. |
| **3. Test Reports** | User-specified path, `IMSIGHT_SKILL_OUTPUT_DIR`, or `<meta/realwork-root>/.imsight-arts/project-mgr/agent-driven-testing/reports/<timestamp>-<run-slug>.md` | **Optionally Git-tracked** (project/user choice) | Curated, secret-redacted Markdown report with forced verdicts, soft-goal rationale, usability issues, triage, uncertainty/open questions, and pointers to `<output-dir>/<test-slug>/` | `run-case()`, `audit-case()`, and `report-results()`. |

Always nest each test definition bundle inside its own kebab-case subdirectory `<cases-dir>/<case-slug>/` (never directly under `<cases-dir>`), and always nest each execution's raw output inside its own `<output-dir>/<test-slug>/` directory. Full resolution rules, schemas, and templates live in [case-and-harness-contract.md](references/case-and-harness-contract.md) and [report-template.md](references/report-template.md).

## Foundational Principles

- **Phase boundaries are real contracts:** `propose-case()` only discusses, `author-case()` only writes/updates tracked test definitions (stamped `status: draft` until explicitly proven), and `run-case()` only writes to `<output-dir>/<test-slug>/` and the report destination without modifying test definitions.
- **Violating the letter of live-verification rules is violating the spirit of verification:** "It compiles," passing unit tests, code inspection, or an agent's self-report never substitute for driving the real surface and inspecting captured evidence.
- **Soft goals require grounded, forced verdicts:** Qualitative expected outcomes let the executing agent exercise judgment on realistic behavior, but the agent must still render a definitive verdict (`PASS`, `FAIL`, `BLOCKED`, or `VERIFIED-UNREACHABLE` — never `INCONCLUSIVE`), cite surviving disk artifacts in `<output-dir>/<test-slug>/`, and log any residual uncertainty or open questions explicitly in the test report.
- **Agent confusion is a usability signal:** If a CLI, UI, error message, state transition, or workflow is counter-intuitive, misleads the executing agent into the wrong mental model, or lacks actionable feedback on failure, it will likely confuse human users too. Always capture and report such friction under `usability-issue` — even when the scenario ultimately passes.

## Rationalization Table

| Excuse | Reality |
| --- | --- |
| "While proposing the case, I will also write the files to save a turn." | `propose-case()` is strictly discussion-only. Present the design and stop so the user can review intent, preconditions, and soft goals first. |
| "I just authored the bundle, so I will run it immediately to prove it." | `author-case()` only writes/updates `<cases-dir>/<case-slug>/` and stamps `status: draft`. Run only when `run-case()` is invoked (or explicitly chained by the user). |
| "The bundle had a selector typo or stayed `draft` after passing, so I will edit `README.md` during `run-case()`." | `run-case()` is strictly read-only on `<cases-dir>/<case-slug>/`. Write only to `<output-dir>/<test-slug>/` and the report destination; modify test definitions only under explicit instruction (`author-case()` or `audit-case()`). |
| "I eventually figured out the confusing error message and the test passed, so no need to mention it." | If something misled or confused the agent or lacked actionable error feedback, it will likely confuse users too. Report it as a `usability-issue` in the test report. |
| "The soft goal is qualitative and borderline, so I will mark it `INCONCLUSIVE`." | No `INCONCLUSIVE` verdict exists. Make a definitive `PASS` or `FAIL` decision from captured evidence and document every caveat, ambiguity, and open question in the report. |
| "The unit tests pass and the diff looks right, so I can skip the live run." | Unit tests verify isolated branches, not the real launch, wiring, UI, CLI, or multi-agent path. Run the instructional case live or report `BLOCKED`. |
| "I will put my scratch script in `/tmp` because it is faster." | `/tmp` hides test scripts and evidence outside the project context and collides across checkouts. Resolve and use `<output-dir>/<test-slug>/` inside the project-local temp directory. |
| "Cleanup should delete `<output-dir>/<test-slug>/` so nothing is left behind." | Deleting `evidence/` destroys the proof. Remove processes, sessions, and disposable `runtime/` state while preserving `evidence/` and report-cited artifacts. |

## Red Flags

Stop and correct course immediately if you notice any of the following:

- Writing files or running the app during `propose-case()`.
- Launching the app or executing test scenarios during `author-case()` when the user did not explicitly request chaining `run-case()`.
- Modifying test definitions under `<cases-dir>/<case-slug>/` during `run-case()`.
- Mixing test outputs or durable reports into `<cases-dir>/<case-slug>/`.
- Glossing over confusing system behavior, misleading mental models, or unhelpful error messages instead of logging a `usability-issue`.
- Claiming an unexecuted `status: draft` bundle is already proven.
- Reporting `INCONCLUSIVE` instead of making a definitive verdict and documenting uncertainty/open questions in the report.
- Reporting `PASS` without citing surviving proof artifacts on disk after cleanup.
- Driving an instance after a surprising failure without re-running `Doctor` (or resetting/relaunching a wedged state).
- Killing processes by bare process name (`pkill`, `killall`, or stopping the user's default tmux server) instead of only the PIDs, sessions, or sockets this run created.
- Grading an agent-behavior case from the tested agent's summary instead of inspecting its transcript and side effects.

## Guardrails

- DO NOT write files, create directories, or launch the app during `propose-case()`.
- DO NOT automatically execute test scenarios or launch the target app during `author-case()` unless the user explicitly asks to chain `run-case()`.
- DO NOT modify test definitions under `<cases-dir>/<case-slug>/` or `<cases-dir>/README.md` during `run-case()`.
- DO NOT place a single bundle's `README.md`, `cases/`, or `helpers/` directly under `<cases-dir>`; always nest each bundle under `<cases-dir>/<case-slug>/`.
- DO NOT store disposable scripts, runtime logs, raw screenshots, secrets, session tokens, or test reports inside `<cases-dir>`.
- DO NOT write raw test outputs to system `/tmp` when a project-local ignored `<output-dir>` can be resolved or created.
- DO NOT emit an `INCONCLUSIVE` verdict; always choose one of `PASS`, `FAIL`, `BLOCKED`, or `VERIFIED-UNREACHABLE` and record uncertainty or open questions in the test report.
- DO NOT omit counter-intuitive UX, misleading behavior, or opaque error feedback encountered during execution; always report them as `usability-issue`.
- DO NOT drive an instance without running `Doctor` before the first drive, on each fresh session, and after any failed drive.
- DO NOT inject internal state, call hidden setters, or weaken test steps or soft goals to force a pass.
- DO NOT delete captured proof artifacts in `<output-dir>/<test-slug>/evidence/` during cleanup.
- DO NOT edit product source code during `run-case()` or `audit-case()` unless the user separately authorizes a fix.
- DO NOT kill processes by name or touch user-owned sessions (such as the default tmux server or non-test browser profiles).

## Troubleshooting Guide

- The project has no documented temporary directory in `AGENTS.md` or `.gitignore`.
  - If no project-local temp convention exists, then inspect existing ignored directories first, create `<realwork>/tmp/` (or `<meta-root>/tmp/<checkout-key>/` in a metaproj) with a matching `.gitignore` entry or explicit user approval, and verify with `git check-ignore` before allocating `<output-dir>/<test-slug>/`.
- A Unix socket path (such as tmux `-S` or an IPC socket) exceeds the OS `AF_UNIX` path-length limit inside `<output-dir>/<test-slug>/`.
  - If the socket path overflows the OS limit, then place only the short socket file in an isolated OS runtime directory with a run-unique name, record that exact socket path in `<output-dir>/<test-slug>/run-meta.json`, clean up only that socket on teardown, and keep all scripts, logs, and evidence inside `<output-dir>/<test-slug>/`.
- `Doctor` passes on the process, but the UI, TUI, or agent session is wedged in an unexpected state.
  - If a healthy process is stuck in an invalid state, then capture diagnostic evidence first, execute the harness reset or clean relaunch procedure, re-run `Doctor`, and retry from clean preconditions rather than continuing on wedged state.
- A run hits a `harness-gap` or `doc-drift` inside a `status: draft` bundle during `run-case()`.
  - If `run-case()` discovers an authoring defect in `<cases-dir>/<case-slug>/`, then do not patch the test definition during `run-case()`; record the exact defect, evidence, and recommended fix in the test report so the user can explicitly authorize `author-case()` or `audit-case()`.
- A case cannot reach a required feature because of missing credentials, external services, or OS constraints.
  - If a real external precondition is unavailable, then stop attempting workarounds that weaken the test, record the attempted command and exact unmet precondition, classify the case as `VERIFIED-UNREACHABLE` (or `BLOCKED` if the harness itself cannot start), and note the prerequisite gap in the report.
