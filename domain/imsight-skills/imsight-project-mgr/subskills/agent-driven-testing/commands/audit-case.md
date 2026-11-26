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

**Maintenance Pass (Explicit Invocation Only).** Keep tracked instructional test definitions under `<cases-dir>/<case-slug>/` (defaulting `<cases-dir>` to `<realwork>/tests/instructional/`) honest as the realwork evolves by checking index hygiene, auditing every scenario against current source in parallel, driving every scenario live with outputs stored under `<output-dir>/<test-slug>/`, triaging drift versus harness gaps versus product regressions versus usability issues strictly, and shipping proven test-definition corrections without touching product code.

## Predecessors

- Requires at least one existing test definition bundle under `<cases-dir>/<case-slug>/` (`README.md` and `cases/*.md`). If none exist, refuse to run and point the user to `imsight-project-mgr->agent-driven-testing->propose-case()` and `imsight-project-mgr->agent-driven-testing->author-case()`.
- Invoking `audit-case()` explicitly authorizes edits strictly inside the audited `<cases-dir>/<case-slug>/` definition bundle(s) (and optional `<cases-dir>/README.md` index) for proven `doc-drift` or `harness-gap` fixes only.

## Workflow

When `imsight-project-mgr->agent-driven-testing->audit-case()` is invoked, execute the following steps in order.

1. **Locate target test definitions (`<cases-dir>/<case-slug>/`) and allocate test output (`<output-dir>/<test-slug>/`).** Resolve `<cases-dir>` and the target `<cases-dir>/<case-slug>/` bundle(s) (one named bundle, or every `<case-slug>/` directory containing `README.md` and `cases/` under `<cases-dir>`) per **Part 1: Test Definitions** in [case-and-harness-contract.md](../references/case-and-harness-contract.md). If none exist, stop and point the user to `propose-case()` and `author-case()`. Resolve `<output-dir>` per **Part 2: Test Output** and allocate `<output-dir>/<test-slug>/`.
2. **Run index hygiene.** Compare each bundle's `<cases-dir>/<case-slug>/README.md` case index against `<cases-dir>/<case-slug>/cases/` and `helpers/`, and check any optional top-level `<cases-dir>/README.md` index against existing `<case-slug>/` subdirectories. Record or repair missing, extra, duplicate, or dead links.
3. **Run a parallel read-only source wave.** Launch one read-only subagent per scenario file concurrently to inspect current product source against the scenario, cite likely doc drift with `file:line`, and propose one concise live-verification recipe. Children never drive the app and never edit files. See **Source Wave and Reconciliation**.
4. **Reconcile source findings and sweep recent churn.** Merge overlapping recipes into as few clean app states as practical, spot-check cited drift, and inspect recent commits for new user-facing surfaces missing from `<cases-dir>` (requiring a concrete source path before flagging a missing surface).
5. **Execute a mandatory live pass.** Even when source looks clean, run all mapped scenarios live writing raw outputs into `<output-dir>/<test-slug>/` and holding `imsight-project-mgr->agent-driven-testing->run-case()` live invariants (coordinator owns driving, `Doctor` before first drive / per fresh session / after failures, forced verdicts on soft goals with evidence-cited rationale, usability-issue observation, evidence survives cleanup, failed-iteration residue cleaned). If a `Doctor` failure is caused by harness drift inside `<cases-dir>/<case-slug>/`, fix it within edit scope, restart only what the fix invalidated, and retry once before calling the audit `blocked`.
6. **Triage every finding strictly.** Classify each mismatch or friction point into `doc-drift`, `harness-gap`, `product-regression`, or `usability-issue`, applying edits only inside the audited `<cases-dir>/<case-slug>/` bundle(s) (and optional `<cases-dir>/README.md` index), re-driving every harness fix live before final teardown, and updating `Status: proven (commit <sha>, report <path>)` when the audited bundle achieves full verified live coverage. See **Edit Scope and Triage**.
7. **Report the audit outcome.** Call `imsight-project-mgr->agent-driven-testing->report-results()` with one explicit audit outcome (`clean`, `changed`, or `blocked`), coverage summary, forced per-case verdicts, usability issues, uncertainty/open questions, confirmed regressions kept out of edits, and surviving proof links under `<output-dir>/<test-slug>/`.

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

Edit scope during `audit-case()` is **strictly limited to `<cases-dir>/<case-slug>/`** (`README.md`, `cases/*.md`, and `helpers/*`) plus any optional top-level `<cases-dir>/README.md` bundle index. Never modify product code under `src/` or package code during an audit.

| Observation | Triage Class | Allowed Action in Audit |
| --- | --- | --- |
| User-visible command, label, route, or prerequisite changed on purpose (backed by code/spec/commit evidence), and the test definition is stale | `doc-drift` | Update the scenario or `README.md` under `<cases-dir>/<case-slug>/`, then verify live. |
| Product behavior works cleanly for a human user, but the harness script or selector cannot drive or observe it reliably | `harness-gap` | Fix the helper or selector under `<cases-dir>/<case-slug>/` (keep scripts executable and documented in `<cases-dir>/<case-slug>/README.md`), then **re-drive live** to prove the fix works. |
| App behavior genuinely breaks its documented or intended contract (or fails soft goals / triggers a hard disqualifier) | `product-regression` | **Do not edit product code and do not edit the scenario to accept the broken behavior.** Record exact repro steps, expected vs. observed state, commit SHA, and surviving proof artifacts in the report. |
| System behavior is counter-intuitive, misleads the agent into a wrong mental model or operation, confuses state, or lacks actionable feedback when an error occurs (**if it confuses the agent, it will likely confuse users too**) | `usability-issue` | **Do not edit product code and do not bury the UX flaw as mere doc drift.** Report the exact confusing interaction, what misled the agent, what error feedback was missing, and the surviving evidence under `## Usability Issues` in the report (including on passing cases). You may also add a factual note in `Gotchas` only after recording the `usability-issue` prominently in the report. |

## Audit Outcomes

Pick exactly one outcome and state it prominently in the report:

- **`clean`**: every targeted bundle and scenario got source and live coverage with nothing worth changing under `<cases-dir>`. No definition files modified.
- **`changed`**: proven `doc-drift` or `harness-gap` corrections were applied strictly inside the audited `<cases-dir>/<case-slug>/` bundle(s) (and optional `<cases-dir>/README.md` index), every changed file was re-read, and every harness fix was re-driven live before final teardown.
- **`blocked`**: coverage could not complete or a proven fix could not be verified safely; name the exact blocker and partial coverage honestly.

## Guardrails

- DO NOT edit product source code, production configs, or non-instructional test suites during `audit-case()`.
- DO NOT skip the live pass because the source wave looked clean.
- DO NOT let read-only source-wave subagents drive the live app or modify files.
- DO NOT hide a `product-regression` or `usability-issue` by rewriting a case file or softening its soft goals to paper over broken or confusing behavior.
- DO NOT ship a `harness-gap` fix without re-driving the fixed path live before final teardown.
- DO NOT emit an `INCONCLUSIVE` case verdict; make a definitive verdict and record uncertainty or open questions in the report.
- DO NOT commit scratch audit notes or raw test outputs from `<output-dir>/<test-slug>/` into the repository.
