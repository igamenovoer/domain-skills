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

# Audit Instructional Test Cases

Keep `<realwork>/tests/instructional/` honest as the realwork evolves by checking index hygiene, auditing every case against current source in parallel, driving every case live, triaging drift versus regressions strictly, and shipping proven test-suite corrections without touching product code.

## Workflow

When `imsight-project-mgr->agent-driven-testing->audit-cases()` is invoked, execute the following steps in order.

1. **Locate the suite and resolve the project-local temp directory.** Confirm `<realwork>/tests/instructional/README.md` and `cases/` exist; if absent, stop and point the user to `imsight-project-mgr->agent-driven-testing->generate-cases()`. Resolve `<project-tmp-root>` per [case-and-harness-contract.md](../references/case-and-harness-contract.md) and allocate `<run-tmp>`.
2. **Run index hygiene.** Compare the case index in `tests/instructional/README.md` against the actual files in `tests/instructional/cases/` and `helpers/`. Record or repair missing, extra, duplicate, or dead links.
3. **Run a parallel read-only source wave.** Launch one read-only subagent per case file concurrently to inspect current product source against the case, cite likely doc drift with `file:line`, and propose one concise live-verification recipe. Children never drive the app and never edit files. See **Source Wave and Reconciliation**.
4. **Reconcile source findings and sweep recent churn.** Merge overlapping recipes into as few clean app states as practical, spot-check cited drift, and inspect recent commits for new user-facing surfaces missing from `tests/instructional/` (requiring a concrete source path before flagging a missing surface).
5. **Execute a mandatory live pass.** Even when source looks clean, run all mapped cases live following `imsight-project-mgr->agent-driven-testing->run-cases()` invariants (coordinator owns driving, `Doctor` before first drive / per fresh session / after failures, evidence survives cleanup, failed-iteration residue cleaned). If a `Doctor` failure is caused by skill/harness drift inside `tests/instructional/`, fix it within edit scope, restart only what the fix invalidated, and retry once before calling the audit `blocked`.
6. **Triage every finding strictly.** Classify each mismatch into `doc-drift`, `harness-gap`, or `product-regression`, applying edits only inside `<realwork>/tests/instructional/` and re-driving every harness fix live before final teardown. See **Edit Scope and Triage**.
7. **Report the audit outcome.** Call `imsight-project-mgr->agent-driven-testing->report-results()` with one explicit audit outcome (`clean`, `changed`, or `blocked`), coverage summary, confirmed regressions kept out of edits, and surviving proof links.

If the user scopes the audit to a subset of cases or a single changed subsystem, use your native planning tool to run the same source-wave, live-pass, and triage discipline on that explicit subset and record the untouched cases under unverified scope.

## Source Wave and Reconciliation

- **Per-case read-only subagent return shape**:
  1. One-sentence user-facing feature summary from current source.
  2. Authoritative source entry points (`file:line`).
  3. Likely drift (with exact citation) or `none`.
  4. One concise live-verification recipe matching the harness in `README.md`.
- **Reconciliation rules**:
  - Wait until every targeted case file has a returned summary before driving live.
  - Spot-check cited drift directly; do not waste turns re-proving clean claims from source because the live pass will exercise them directly.
  - Do not report a missing feature solely from speculation; cite the real CLI command, route, UI control, or spec file added in recent churn.

## Edit Scope and Triage

Edit scope during `audit-cases()` is **strictly limited to `<realwork>/tests/instructional/`** (`README.md`, `cases/*.md`, and `helpers/*`). Never modify product code under `src/` or package code during an audit.

| Observation | Triage Class | Allowed Action in Audit |
| --- | --- | --- |
| User-visible command, label, route, or prerequisite changed on purpose (backed by code/spec/commit evidence), and the case doc is stale | `doc-drift` | Update the case or `README.md` under `tests/instructional/`, then verify live. |
| Product behavior works for a user, but the harness script or selector cannot drive or observe it reliably | `harness-gap` | Fix the helper or selector under `tests/instructional/` (keep scripts executable and documented in `README.md`), then **re-drive live** to prove the fix works. |
| App behavior genuinely breaks its documented or intended contract | `product-regression` | **Do not edit product code and do not edit the case to accept the broken behavior.** Record exact repro steps, expected vs. observed state, commit SHA, and surviving proof artifacts in the report. |

## Audit Outcomes

Pick exactly one outcome and state it prominently in the report:

- **`clean`**: every targeted case got source and live coverage with nothing worth changing in `tests/instructional/`. No files modified.
- **`changed`**: proven `doc-drift` or `harness-gap` corrections were applied strictly inside `tests/instructional/`, every changed file was re-read, and every harness fix was re-driven live before final teardown.
- **`blocked`**: coverage could not complete or a proven fix could not be verified safely; name the exact blocker and partial coverage honestly.

## Guardrails

- DO NOT edit product source code, production configs, or non-instructional test suites during `audit-cases()`.
- DO NOT skip the live pass because the source wave looked clean.
- DO NOT let read-only source-wave subagents drive the live app or modify files.
- DO NOT hide a `product-regression` by rewriting a case file to match broken behavior.
- DO NOT ship a `harness-gap` fix without re-driving the fixed path live before final teardown.
- DO NOT commit scratch audit notes or temporary files from `<project-tmp-root>` into the repository.
