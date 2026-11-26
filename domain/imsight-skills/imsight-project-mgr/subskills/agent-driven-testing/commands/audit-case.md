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

**Maintenance Pass (Explicit Invocation Only).** Keep `<cases-dir>/<case-slug>/` definitions honest as the codebase evolves: parallel source readers per scenario, one live pass exercising every scenario with outputs in `<output-dir>/<test-slug>/`, and strict triage separating `doc-drift` and `harness-gap` (fixed in definitions) from `product-regression` and `usability-issue` (reported, never papered over).

## Predecessors

- Requires existing definitions under `<cases-dir>/<case-slug>/`; if none exist, stop and point to `propose-case()` and `author-case()`.
- Explicit `audit-case()` invocation authorizes edits **strictly inside `<cases-dir>/<case-slug>/`** (and optional `<cases-dir>/README.md` index) for proven `doc-drift` and `harness-gap` fixes only.

## Workflow

When `imsight-project-mgr->agent-driven-testing->audit-case()` is invoked, execute the following steps in order while applying [principles.md](../references/principles.md) (`v1`–`v7`).

1. **Locate `<cases-dir>/<case-slug>/`, allocate `<output-dir>/<test-slug>/`, and run index hygiene.** Repair missing, extra, duplicate, or dead links in `<cases-dir>/<case-slug>/README.md` (and any `<cases-dir>/README.md` index).
2. **Source wave.** Spawn one read-only subagent per scenario concurrently. Each reads current product source and returns: (1) one-sentence user/caller-facing summary, (2) `file:line` entry points, (3) likely drift with citation or `none`, and (4) one concise live-verification recipe. Children never run the program or edit files.
3. **Reconcile and check recent churn.** Merge overlapping recipes into minimal program states, spot-check cited drift, and scan recent commits for new public surfaces missing from `<cases-dir>` (citing concrete source paths).
4. **Live pass (mandatory even if source looks clean).** Follow [run-case.md](run-case.md) invariants (`Doctor`, real boundary, independent second view, forced verdicts, surviving proof in `<output-dir>/<test-slug>/evidence/`, clean residue teardown). If `Doctor` fails due to bundle drift, fix it within `<cases-dir>/<case-slug>/`, restart only what the fix invalidated, and retry once before calling `blocked`.
5. **Triage and re-prove.** Apply **Triage Rules** below. Re-drive every `harness-gap` or `doc-drift` edit live before final teardown, re-read all modified definition files, and update `Status: proven (commit <sha>, report <path>)` when a bundle achieves full verified live coverage.
6. **Report via [report-template.md](../references/report-template.md)** with one explicit audit outcome: **`clean`** (full source + live coverage, no definition edits), **`changed`** (proven `doc-drift`/`harness-gap` fixes applied inside `<cases-dir>/<case-slug>/` and re-driven live), or **`blocked`** (coverage or verification could not finish safely; exact blocker named).

If auditing an explicitly scoped subset of scenarios, use your native planning tool to run the same source-wave, live-pass, and triage loop on that subset and list untouched scenarios under unverified scope.

## Triage Rules

| Finding | Label | Action During Audit |
| --- | --- | --- |
| Intentional change in commands, flags, interfaces, or prerequisites (backed by source/spec/commit), leaving definitions stale | `doc-drift` | Update `<cases-dir>/<case-slug>/` (keeping structural checks quantified per `v2`), then verify live. |
| Program works cleanly at its boundary, but the bundle's driver or helper cannot drive or observe it reliably | `harness-gap` | Fix the driver/helper in `<cases-dir>/<case-slug>/` (executable, documented in `README.md`), then **re-drive live**. |
| Program violates its intended contract, quantified invariant, or qualitative expectation | `product-regression` | **Touch neither product code nor the scenario expectation.** Report repro steps, commit SHA, and surviving proof. |
| Interface, state transitions, or error messages mislead or confuse the agent (`v6`) | `usability-issue` | **Do not edit product code and do not bury UX friction as `doc-drift`.** Report prominently under `## Usability Issues` (even on `PASS` cases) before adding any factual note in `Gotchas`. |

## Guardrails

- DO NOT edit product source code, production configs, or non-instructional test suites during `audit-case()`.
- DO NOT skip the live pass because the source wave looked clean, or let source-wave subagents run the program or edit files.
- DO NOT mask a `product-regression` or `usability-issue` by weakening quantified checks or qualitative criteria (`v5`, `v6`).
- DO NOT ship a `harness-gap` fix without re-driving the fixed path live before teardown.
- DO NOT emit an `INCONCLUSIVE` verdict or commit raw files from `<output-dir>/<test-slug>/`.
