---
name: agent-driven-testing
description: Use when proposing, authoring, running, auditing, or reporting agent-driven instructional test suites for any kind of program, with separated propose/author/run phases, tracked test definitions (<cases-dir>/<case-slug>/), isolated test outputs (<output-dir>/<test-slug>/), durable test reports (.imsight-arts/...), decomposed quantified-and-qualitative criteria, and usability-issue triage.
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

Design, author, execute, audit, and report self-contained agent-driven verification suites for any kind of program — CLIs, services/daemons, batch or compute pipelines, libraries, compilers, interactive apps, or multi-agent systems. Following `pstack`'s live-verification model with explicit phase separation, the subskill splits discussion (`propose-case()`), authoring (`author-case()`), and live execution (`run-case()`), decomposes test criteria into **quantified structural checks** plus **irreducible qualitative checks** judged definitively from real artifacts, surfaces agent-confusing UX or opaque errors as `usability-issue`, and keeps tracked **test definitions**, ignored **test outputs**, and durable **test reports** strictly separated.

## When to Use

- Use when a realwork project needs repeatable, agent-executable verification suites under `<cases-dir>/<case-slug>/` (default `<cases-dir>`: `<realwork>/tests/instructional/`) for end-to-end program, service, workflow, or multi-agent behaviors that unit tests alone cannot prove.
- Use when distilling debug campaigns, OpenSpec requirements, manual walkthroughs, or bug reproductions into durable test definitions through an explicit propose -> author -> run lifecycle.
- Use when executing suites live without modifying test definitions, auditing definitions against evolving source, or synthesizing evidence-backed reports.
- Do not use for fast hermetic unit tests (`tests/unit/`), static lint/type checks, or metaproj repository-policy checks.

## Workflow

When this subskill is invoked, execute the following steps in order.

1. **Confirm routing, target realwork, `<cases-dir>`, and `<case-slug>`.** Continue on explicit invocation of `imsight-project-mgr->agent-driven-testing` or a route from `imsight-project-mgr`. Resolve the realwork checkout and branch (and enclosing metaproj root when attached) per the [responsibility contract](../../references/project-responsibilities.md), and resolve `<cases-dir>/<case-slug>/` (default `<cases-dir>`: `<realwork>/tests/instructional/`). See **Three-Part Artifact Split**.
2. **Load the core thinking principles.** Read [principles.md](references/principles.md) (`v1`–`v7`) and apply its judgment rules across proposing, authoring, running, and triaging rather than relying on mechanical surface-specific checklists.
3. **Select the phase subcommand without auto-chaining.** Pick the subcommand from **Subcommands** matching the user's request (`propose-case`, `author-case`, `run-case`, `audit-case`, `report-results`, or `help`). Stop at that phase's boundary unless the user explicitly asked to chain phases.
4. **Resolve `<output-dir>/<test-slug>/` and report destination when running, auditing, or reporting.** Allocate raw run outputs inside a Git-ignored project-local `<output-dir>/<test-slug>/` and write curated reports to the resolved report destination per [case-and-harness-contract.md](references/case-and-harness-contract.md) and [report-template.md](references/report-template.md).
5. **Execute the selected command page and deliver its output.** Return the design proposal (`propose-case()`), the authored definition summary stamped `Status: draft` (`author-case()`), or the durable Markdown report plus concise in-chat summary (`run-case()`, `audit-case()`, `report-results()`).

If the user explicitly requests chaining phases or custom sequencing, use your native planning tool to order the subcommands while preserving every phase boundary, read-only rule, and verification principle in [principles.md](references/principles.md).

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
| `propose-case` | **Phase 1 (Discuss only):** interview the repo read-only and propose intent, scope, preconditions, driving plan, and decomposed quantified + qualitative criteria — zero file writes, zero program execution | [propose-case.md](commands/propose-case.md) |
| `author-case` | **Phase 2 (Create/update definitions):** write or update tracked definitions under `<cases-dir>/<case-slug>/` (`README.md`, `cases/*.md`, optional `helpers/`) grounded statically in the repo; marks unexecuted bundles `Status: draft` | [author-case.md](commands/author-case.md) |
| `run-case` | **Phase 3 (Execute live, definitions read-only):** run `<cases-dir>/<case-slug>/` live, write all raw outputs to `<output-dir>/<test-slug>/`, render forced verdicts (`PASS` / `FAIL` / `BLOCKED` / `VERIFIED-UNREACHABLE`), log `usability-issue` friction, and emit the test report without touching `<cases-dir>` | [run-case.md](commands/run-case.md) |
| `audit-case` | **Maintenance:** on explicit invocation, audit `<cases-dir>/<case-slug>/` via index hygiene, parallel read-only source readers, a mandatory live pass, and strict triage (`doc-drift`, `harness-gap`, `product-regression`, `usability-issue`) | [audit-case.md](commands/audit-case.md) |
| `report-results` | **Report synthesis:** synthesize or aggregate verified artifacts from `<output-dir>/<test-slug>/` into a durable Markdown report and concise in-chat summary | [report-results.md](commands/report-results.md) |

### Helper Subcommands

No helper subcommands are currently exposed.

### Misc Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `help` | Explain the three-phase lifecycle, three-part artifact split, verification principles (`v1`–`v7`), and available subcommands without mutating files | This entrypoint |

## Three-Part Artifact Split

| Artifact Part | Location | Git Policy | Contents & Ownership |
| --- | --- | --- | --- |
| **1. Test Definitions** | `<cases-dir>/<case-slug>/` (default `<cases-dir>`: `<realwork>/tests/instructional/`) | **Tracked in repo** | `README.md` (`Status: draft \| proven`, harness contract, index), `cases/*.md` (scenarios + quantified & qualitative criteria), optional executable `helpers/`. Written only by `author-case()` / `audit-case()`; **read-only during `run-case()`.** |
| **2. Test Output** | `<output-dir>/<test-slug>/` (default `<output-dir>`: `<project-tmp-root>/instructional-tests/`) | **Git-ignored** | **Anything produced by the run**: `scripts/`, `runtime/` state/logs, surviving `evidence/`, `run-meta.json`, traces, or ad-hoc diagnostic dumps. Cleanup preserves `evidence/` and report-cited files. |
| **3. Test Reports** | User path, `IMSIGHT_SKILL_OUTPUT_DIR`, or `<meta/realwork-root>/.imsight-arts/project-mgr/agent-driven-testing/reports/<timestamp>-<run-slug>.md` | **Optionally Git-tracked** | Curated, secret-redacted Markdown report with forced verdicts, evidence-cited judgment rationale, `usability-issue` findings, uncertainty/open questions, and pointers to `<output-dir>/<test-slug>/`. |

Full layout, harness, criteria, and report schemas live in [case-and-harness-contract.md](references/case-and-harness-contract.md) and [report-template.md](references/report-template.md).

## Guardrails

- DO NOT write files or launch the target program during `propose-case()`.
- DO NOT launch the target program or execute test scenarios during `author-case()` unless the user explicitly requested chaining `run-case()`.
- DO NOT modify test definitions under `<cases-dir>/<case-slug>/` or `<cases-dir>/README.md` during `run-case()`.
- DO NOT place a single bundle's `README.md`, `cases/`, or `helpers/` directly under `<cases-dir>`; always nest under `<cases-dir>/<case-slug>/`.
- DO NOT store raw test outputs, scratch scripts, secrets, or test reports inside `<cases-dir>`, or write raw outputs to system `/tmp` when a project-local ignored `<output-dir>` is available.
- DO NOT leave structural or countable expectations unquantified, and DO NOT force irreducible natural-language semantics into brittle exact-string checks.
- DO NOT emit an `INCONCLUSIVE` verdict; always choose `PASS`, `FAIL`, `BLOCKED`, or `VERIFIED-UNREACHABLE` and record residual uncertainty or open questions in the report.
- DO NOT omit counter-intuitive behavior, misleading cues, or opaque error feedback encountered during execution; always report them under `usability-issue`.
- DO NOT weaken preconditions or expectations to force a pass, edit product code during `run-case()` or `audit-case()`, delete `<output-dir>/<test-slug>/evidence/` on cleanup, or kill processes by bare name.
