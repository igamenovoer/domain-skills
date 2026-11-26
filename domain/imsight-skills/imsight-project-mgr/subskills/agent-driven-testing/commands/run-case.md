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

# Run Instructional Test Cases

**Phase 3 (Live Execution, Definitions Strictly Read-Only).** Execute `<cases-dir>/<case-slug>/` (or all bundles under `<cases-dir>`) live against the realwork checkout, store all execution outputs in `<output-dir>/<test-slug>/`, evaluate quantified and qualitative criteria definitively, surface any `usability-issue`, and emit the test report without modifying tracked test definitions.

## Predecessors

- Requires an existing bundle under `<cases-dir>/<case-slug>/` (`README.md` and `cases/*.md`). If none exists, stop without creating one and point to `propose-case()` and `author-case()`.

## Workflow

When `imsight-project-mgr->agent-driven-testing->run-case()` is invoked, execute the following steps in order while holding [principles.md](../references/principles.md) (`v1`–`v7`).

1. **Read target definitions and allocate `<output-dir>/<test-slug>/`.** Record the realwork path, branch, commit SHA, dirty state, and bundle status (`draft` or `proven`) in `<output-dir>/<test-slug>/run-meta.json` with `scripts/`, `runtime/`, and `evidence/` initialized per [case-and-harness-contract.md](../references/case-and-harness-contract.md). Confirm `<output-dir>` is Git-ignored before writing run files.
2. **Select the execution mode** from **Execution Modes** matching the task.
3. **Launch/preflight and run `Doctor` (`v4`).** Follow the bundle's `Launch` model (long-lived isolated instance for services/daemons, or per-invocation isolation for short-lived CLIs/jobs). Run `Doctor` before the first drive, on each fresh session, and after any unexpected failure; reset or relaunch if a healthy process is wedged.
4. **Drive the real surface and capture independent proof (`v1`, `v3`, `v6`).** Execute the literal entry points in each scenario, write any per-run scripts or diagnostics inside `<output-dir>/<test-slug>/`, save outputs plus independent read-only cross-checks under `<output-dir>/<test-slug>/evidence/<case-slug>/<scenario-slug>/`, and record any counter-intuitive behavior or opaque error feedback as `usability-issue`.
5. **Clean up runtime residue while preserving proof (`v7`).** Stop every PID, daemon, container, or isolated session recorded in `run-meta.json` (including after failed iterations), clean disposable `runtime/` state as appropriate, verify on disk that all cited files in `<output-dir>/<test-slug>/evidence/` survived, and confirm `<cases-dir>/<case-slug>/` remained untouched.
6. **Render forced verdicts and write the report (`v2`, `v5`, `v6`).** Evaluate every **Quantified check** and **Qualitative check** from surviving artifacts, assign `PASS`, `FAIL`, `BLOCKED`, or `VERIFIED-UNREACHABLE` (never `INCONCLUSIVE`), log all `usability-issue` findings (including on passing cases) and any residual uncertainty/open questions, and produce the report and in-chat summary per [report-template.md](../references/report-template.md).

If the user asks for interactive checkpoints or custom staging, use your native planning tool while keeping `Doctor`, surviving proof, cleanup, and read-only test definitions intact.

## Execution Modes

| Mode | When to Use | Extra Discipline |
| --- | --- | --- |
| **Standard live pass** | Normal verification of one or more bundles | Drive every listed entry point and second-view check; verify quantified predicates and judge qualitative criteria from disk artifacts. |
| **Before-and-after fix** | Proving a bug fix resolves a real symptom | Same inputs on baseline and patched commits: observe the broken state **twice** on baseline (with clean reset between runs) and the fixed state **twice** on the patched build. |
| **Parallel slice fan-out** | Disjoint cases where `README.md` allows concurrent isolation | One subagent per slice with its own `<output-dir>/<test-slug>/` and resources; require SHA, verdict, rationale, usability notes, and surviving evidence paths from every worker. |
| **Blinded agent eval** | Cases with `## Blinding and Transcript Checks` | Strip meta-words (`eval`, `test`, `judge`, `rubric`, `benchmark`, `candidate`, `arena`) from candidate-visible paths/prompts; grade from execution transcripts and durable side effects rather than self-report. |

## Guardrails

- DO NOT create, edit, or delete any file under `<cases-dir>` during `run-case()` (even to promote `Status: draft` -> `proven` or fix a broken driver; report recommended updates instead).
- DO NOT emit an `INCONCLUSIVE` verdict; decide `PASS`, `FAIL`, `BLOCKED`, or `VERIFIED-UNREACHABLE` and record uncertainty or open questions in the report.
- DO NOT omit counter-intuitive behavior, misleading cues, or unhelpful error messages encountered during the run; always report them under `usability-issue`.
- DO NOT drive an unchecked instance (`v4`), inject internal state (`v1`), trust self-reports or `--dry-run` names without an independent check (`v3`), or weaken preconditions/criteria to pass (`v5`).
- DO NOT edit product source code during `run-case()`, delete `<output-dir>/<test-slug>/evidence/` on cleanup, write raw outputs to system `/tmp` when a project-local `<output-dir>` exists, or kill processes by bare name.
