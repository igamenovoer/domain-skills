---
name: agent-driven-testing
description: Use when authoring, running, auditing, or reporting agent-driven instructional test cases stored under tests/instructional in a realwork project, or when distilling debug campaigns, specs, or PR behavior into live agent-executable verification suites.
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

Design, maintain, execute, and report agent-driven instructional test suites under `<realwork>/tests/instructional/` so any cold agent can launch a realwork project, drive user-facing features or multi-agent workflows through real interfaces, capture surviving runtime evidence inside a project-local temporary directory, and report verifiable outcomes without conflating test drift with product regressions.

## When to Use

- Use when a realwork project needs repeatable, agent-executable verification cases in `tests/instructional/` for CLI, TUI, Web UI, service, API, or multi-agent behaviors that unit tests alone cannot prove.
- Use when turning manual walkthroughs, debug campaigns, OpenSpec requirements, or bug reproductions into durable instructional test cases.
- Use when running instructional test cases live, verifying before-and-after bug fixes on the real surface, auditing `tests/instructional/` for drift against current source, or generating evidence-backed test reports.
- Do not use for ordinary fast unit tests (`tests/unit/`), static lint/type checks, or repository-policy checks owned by a metaproj (place those in standard automated suites or metaproj tools instead).
- Do not use to silently patch product code during test execution or audit; report confirmed product regressions separately.

## Workflow

When this subskill is invoked, execute the following steps in order.

1. **Confirm routing and target realwork.** Continue on explicit invocation of `imsight-project-mgr->agent-driven-testing` or a route from `imsight-project-mgr`. Resolve the exact realwork checkout and branch (and enclosing metaproj root when attached) following the [responsibility contract](../../references/project-responsibilities.md).
2. **Resolve the project-local temporary directory.** Locate `<project-tmp-root>` from explicit user input, project context, or an ignored project-local directory so all temporary scripts, disposable runtime state, and raw proof artifacts stay inside the project's ignored temp tree. See **Project-Local Temporary Directory** and [case-and-harness-contract.md](references/case-and-harness-contract.md).
3. **Select the subcommand** from **Subcommands** based on the user's request (`generate-cases`, `run-cases`, `audit-cases`, `report-results`, or `help`).
4. **Load and execute the selected command page.** Follow its numbered workflow, live-verification invariants, and evidence rules without weakening preconditions or skipping runtime proof.
5. **Report verified results.** Deliver the durable Markdown report (when running or auditing) and a concise in-chat summary distinguishing proven passes, confirmed failures, blocks, unreachable paths, and cleanup status.

If the user's request spans multiple stages (for example, distilling a debug campaign into new cases, running them, and publishing a report), use your native planning tool to chain the matching subcommands while preserving every live-proof and isolation constraint.

## Invocation Contract

- Preferred explicit form: invoke skill `imsight-project-mgr->agent-driven-testing` with the selected realwork and task.
- Direct subcommand forms:
  - `imsight-project-mgr->agent-driven-testing->generate-cases()`
  - `imsight-project-mgr->agent-driven-testing->run-cases()`
  - `imsight-project-mgr->agent-driven-testing->audit-cases()`
  - `imsight-project-mgr->agent-driven-testing->report-results()`
  - `imsight-project-mgr->agent-driven-testing->help()`
- No subcommand and no actionable task means `help()`.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `generate-cases` | Interview the realwork repo (or distill a debug campaign, spec, or PR) to create or update `tests/instructional/README.md`, user-POV cases in `tests/instructional/cases/`, and optional helpers, then self-prove at least one case live | [generate-cases.md](commands/generate-cases.md) |
| `run-cases` | Execute selected or all cases in `tests/instructional/` live against the realwork using a project-local temp workspace for temporary scripts, runtime state, and surviving proof artifacts | [run-cases.md](commands/run-cases.md) |
| `audit-cases` | Keep `tests/instructional/` aligned with evolving source through index hygiene, a parallel read-only source wave, a mandatory live pass, and strict drift-versus-regression triage | [audit-cases.md](commands/audit-cases.md) |
| `report-results` | Synthesize verified run artifacts into a durable Markdown test report and a concise in-chat summary | [report-results.md](commands/report-results.md) |
| `help` | Explain the `tests/instructional/` layout, project-local temp directory rules, and available subcommands without mutating files | This entrypoint |

Each subcommand is independently invocable; the table lists common entry points without forcing a fixed pipeline.

## Ownership and Layout Summary

Committed instructional test assets belong to the **realwork project** under `<realwork>/tests/instructional/`:

- `tests/instructional/README.md`: harness contract (`Launch`, `Doctor`, `Drive`, `Evidence`, `Cleanup`, `Helpers`), isolation rules, and case index.
- `tests/instructional/cases/<case-slug>.md`: user-POV instructional test cases using four fixed H2 sections (`Sub-cases`, `How to get to it (user POV)`, `Driving it with <harness>`, `Gotchas`).
- `tests/instructional/helpers/`: optional durable, executable helper scripts invoked directly by `README.md` or case files.

Disposable run state, temporary per-run scripts, and raw proof artifacts never go into `tests/instructional/` or Git; they go into `<project-tmp-root>/instructional-tests/<run-id>/`. Full schemas and templates live in [case-and-harness-contract.md](references/case-and-harness-contract.md) and [report-template.md](references/report-template.md).

## Project-Local Temporary Directory

Always resolve `<project-tmp-root>` before writing temporary test scripts or capturing run artifacts:

1. **User-specified path**: honor an explicit directory provided by the user.
2. **Project context**: inspect the realwork and enclosing metaproj `AGENTS.md`, `.gitignore`, environment files (`<PREFIX>_DEV_TMP_ROOT`), and existing ignored scratch folders (such as `<meta-root>/tmp/<checkout-key>/`, `<realwork>/tmp/`, or `<realwork>/.tmp/`).
3. **Project-local fallback**: if no convention is declared, create an ignored directory inside the project (`<meta-root>/tmp/<checkout-key>/` when attached, `<realwork>/tmp/` when standalone) and verify it is Git-ignored via `git check-ignore` before creating run files.

Inside `<project-tmp-root>/instructional-tests/<run-id>/`, separate `scripts/` (temporary test scripts and wrappers), `runtime/` (disposable app data, configs, logs, PID files), and `evidence/` (proof artifacts that must survive teardown). See [case-and-harness-contract.md](references/case-and-harness-contract.md) for OS socket-path exceptions and retention rules.

## Foundational Principle

**Violating the letter of live-verification rules is violating the spirit of verification.** "It compiles," passing unit tests, code inspection, or an agent's self-report never substitute for driving the real surface and inspecting captured evidence.

## Rationalization Table

| Excuse | Reality |
| --- | --- |
| "The unit tests pass and the diff looks right, so I can skip the live run." | Unit tests verify isolated branches, not the real launch, wiring, UI, CLI, or multi-agent path. Run the instructional case live or report `BLOCKED`. |
| "I will put my scratch script in `/tmp` because it is faster." | `/tmp` hides test scripts and evidence outside the project context and collides across checkouts. Resolve and use the project-local temp directory. |
| "The precondition is missing, so I will simplify the case steps so it passes." | Weakening a case hides broken setup or product gaps. Fail or mark `VERIFIED-UNREACHABLE` with the exact unmet precondition and log it under `Gotchas`. |
| "I can set the internal state or database directly to trigger the bug faster." | Fixtures may arrange preconditions, never inject the symptom itself. Drive the real user interface or CLI path. |
| "Cleanup should delete the whole run directory so nothing is left behind." | A cleanup that deletes `evidence/` destroys the proof. Remove processes, sessions, and `runtime/` scratch state while preserving `evidence/`. |
| "The app changed behavior, so I will update the case to match the new output." | Confirm from source, specs, or commit intent whether behavior changed on purpose. Never mask a product regression as doc drift. |

## Red Flags

Stop and correct course immediately if you notice any of the following:

- Writing an instructional test case you have not executed at least once end to end.
- Reporting `PASS` without checking that proof artifacts exist on disk after cleanup.
- Driving an instance after a surprising failure without re-running `Doctor` (or resetting/relaunching a wedged state).
- Writing temporary scripts or evidence into tracked directories, the repository root, or system `/tmp` when a project-local ignored temp directory is available.
- Killing processes by bare process name (`pkill`, `killall`, or stopping the user's default tmux server) instead of only the PIDs, sessions, or sockets this run created.
- Grading an agent-behavior case from the tested agent's summary instead of inspecting its transcript and side effects.

## Guardrails

- DO NOT store disposable scripts, runtime logs, raw screenshots, secrets, or session tokens under `tests/instructional/` or any Git-tracked path.
- DO NOT write temporary test scripts or run artifacts to system `/tmp` when a project-local ignored temporary directory can be resolved or created.
- DO NOT declare a newly generated instructional test suite ready before executing at least one mapped case end to end and confirming evidence survives cleanup.
- DO NOT drive an instance without running `Doctor` before the first drive, on each fresh session, and after any failed drive.
- DO NOT inject internal state, call hidden setters, or weaken test assertions to force a pass.
- DO NOT delete captured proof artifacts in `evidence/` during cleanup.
- DO NOT edit product source code during `run-cases()` or `audit-cases()` unless the user separately authorizes a fix.
- DO NOT kill processes by name or touch user-owned sessions (such as the default tmux server or non-test browser profiles).

## Troubleshooting Guide

- The project has no documented temporary directory in `AGENTS.md` or `.gitignore`.
  - If no project-local temp convention exists, then inspect existing ignored directories first, create `<realwork>/tmp/` (or `<meta-root>/tmp/<checkout-key>/` in a metaproj) with a matching `.gitignore` entry or explicit user approval, and verify with `git check-ignore` before running tests.
- A Unix socket path (such as tmux `-S` or an IPC socket) exceeds the OS `AF_UNIX` path-length limit inside `<project-tmp-root>`.
  - If the socket path overflows the OS limit, then place only the short socket file in an isolated OS runtime directory with a run-unique name, record that exact socket path in `<run-tmp>/runtime/` metadata, clean up only that socket on teardown, and keep all scripts, logs, and evidence inside `<project-tmp-root>`.
- `Doctor` passes on the process, but the UI, TUI, or agent session is wedged in an unexpected state.
  - If a healthy process is stuck in an invalid state, then capture diagnostic evidence first, execute the harness reset or clean relaunch procedure, re-run `Doctor`, and retry from clean preconditions rather than continuing on wedged state.
- A generated or audited case cannot reach a required feature because of missing credentials, external services, or OS constraints.
  - If a real external precondition is unavailable, then stop attempting workarounds that weaken the test, record the attempted command and exact unmet precondition, classify the case as `VERIFIED-UNREACHABLE` (or `BLOCKED` if the harness itself cannot start), and document the prerequisite in the case's `Gotchas` section.
