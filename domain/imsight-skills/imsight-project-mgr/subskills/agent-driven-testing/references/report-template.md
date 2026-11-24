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

# Instructional Test Reporting Contract

This reference defines report destinations, verdict and triage taxonomies, the durable Markdown report template, and the concise in-chat summary contract used by `imsight-project-mgr->agent-driven-testing->report-results()` and the reporting step of `run-cases()` and `audit-cases()`.

## Report Destination Priority

Resolve where the durable Markdown report is written in this priority order:

1. **User-specified destination**: an explicit file or directory requested by the user (for example, a debug campaign folder or PR handoff note).
2. **Environment override**: `IMSIGHT_SKILL_OUTPUT_DIR` resolved from the owning project.
3. **Default durable report root**:
   - Attached metaproj: `<meta-root>/.imsight-arts/project-mgr/agent-driven-testing/reports/<timestamp>-<run-slug>.md`
   - Standalone realwork: `<realwork-root>/.imsight-arts/project-mgr/agent-driven-testing/reports/<timestamp>-<run-slug>.md`

Keep raw proof artifacts (screenshots, ARIA snapshots, terminal transcripts, JSON dumps, temporary scripts) inside `<project-tmp-root>/instructional-tests/<run-id>/evidence/` (and optionally copy or link the report at `<project-tmp-root>/instructional-tests/<run-id>/report.md`). Never commit disposable temp artifacts into the realwork repository.

## Verdict Taxonomy

Assign exactly one verdict to each executed case (and sub-case when granular reporting is helpful):

| Verdict | Meaning | Required Evidence |
| --- | --- | --- |
| `PASS` | Every required step, observable assertion, and read-only cross-check succeeded on the real surface | Exact commands, exit codes/outputs, read-only cross-check result, and surviving artifact paths in `<run-tmp>/evidence/` |
| `FAIL` | The target launched and reached the feature, and real execution broke an expected behavior or invariant | Exact failing step, expected vs. observed state, surviving artifact paths, and triage classification |
| `BLOCKED` | The harness or target could not reach a valid drivable state (build/launch failure, `Doctor` failure not resolved by a harness fix, or missing required capability) | Exact blocking command/error, `Doctor` output, and what stopped execution |
| `VERIFIED-UNREACHABLE` | The harness ran cleanly, but a concrete external prerequisite (missing credential, entitlement, OS feature, or offline external service) prevented reaching the case | Attempted route/command, concrete unmet prerequisite, and confirmation that the prerequisite is documented in `Gotchas` |

### Run-Level Outcome (for `audit-cases()`)

- `clean`: every mapped case received source and live coverage with no drift, harness gap, or regression to fix.
- `changed`: proven fixes were applied strictly inside `<suite-root>` (doc drift or harness gap) and re-verified live.
- `blocked`: coverage could not complete or a proven harness fix could not be verified safely; exact blocker named.

## Triage Categories (for `FAIL` or Drift Findings)

Classify every non-passing finding honestly so product bugs are never buried as test-doc updates:

- `doc-drift`: the product behaves as intended (confirmed from source, specs, or commit history), while `<suite-root>` describes stale flags, routes, labels, or omitted prerequisites.
- `harness-gap`: the product works for a human user, but the harness script or selector in `<suite-root>` cannot drive or observe it reliably.
- `product-regression`: the product violates its documented or intended contract on the real surface. Record the repro steps, observed vs. expected behavior, and commit SHA; do not mask it by weakening the case.

## Durable Markdown Report Template

Write the Markdown report without hard-wrapping normal paragraphs, filling every section from observed run evidence:

```markdown
# Instructional Test Report: <run-slug>

Date: YYYY-MM-DD HH:MM UTC | Overall Status: <PASS | FAIL | MIXED | BLOCKED> | Mode: <run-cases | audit-cases | before-after-fix | blinded-eval>

## Run Identity and Environment

- **Realwork checkout**: `<path>` (branch `<branch>`, commit `<sha>`, working tree `<clean | dirty: summary>`)
- **Enclosing metaproj**: `<path or none (standalone)>`
- **Instructional suite root**: `<suite-root>` (default `<realwork>/tests/instructional/` or user-specified path)
- **Project-local temp workspace**: `<project-tmp-root>/instructional-tests/<run-id>/`
- **Evidence root (verified post-cleanup)**: `<project-tmp-root>/instructional-tests/<run-id>/evidence/`
- **Temporary scripts used**: `<list under scripts/ or none>`
- **Harness & tool versions**: `<app/CLI/browser/model versions actually observed by Doctor>`
- **Stand-in or environment deltas**: `<none, or exact setup steps performed by a local stand-in that the production target will not perform>`

## Summary Table

| Case | Entry Point(s) Tested | Verdict | Triage | Doctor | Surviving Evidence | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `<case-slug>` | `<cli / web / ...>` | `PASS` | `none` | `pass` | `<evidence/<case-slug>/...>` | `<1-line summary>` |

## Per-Case Details

### `<case-slug>` — `<VERDICT>`

- **Preconditions & Doctor**: `<exact doctor check and observed app identity/version>`
- **Executed path**: `<ordered steps or commands run>`
- **Expected vs. observed**: `<concrete outputs, exit codes, UI/state observations>`
- **Read-only cross-check**: `<independent verification of files, DB, mailbox, or transcript>`
- **Artifacts**: `<exact paths under <run-tmp>/evidence/<case-slug>/ verified present after cleanup>`
- **Triage & follow-up**: `<none, or doc-drift / harness-gap / product-regression with exact file/line or issue target>`

## Cleanup Verification

- **Stopped/removed**: `<exact PIDs, gateways, isolated tmux sockets, and runtime/ directories cleaned>`
- **Preserved**: `<confirmation that evidence/ files still exist and user-owned sessions were untouched>`
- **Residual items**: `<none, or any leaked resource and why>`

## Unverified Scope and Next Steps

- `<List skipped cases, unverified entry points, deferred lanes, or recommended product/harness follow-ups>`
```

## In-Chat Summary Contract

Always pair the durable report with a concise in-chat summary containing:

1. **Target & Run Identity**: realwork checkout, commit SHA, `<project-tmp-root>/instructional-tests/<run-id>/`, and link to the durable Markdown report.
2. **Result Table**: case name, verdict (`PASS` / `FAIL` / `BLOCKED` / `VERIFIED-UNREACHABLE`), triage label, and primary evidence path.
3. **Key Findings**: concrete root-cause or symptom bullets for every `FAIL`, `BLOCKED`, `doc-drift`, `harness-gap`, or `product-regression` item (never hand-wave passes or omit dropped/inconclusive checks).
4. **Cleanup & Evidence Confirmation**: confirm owned processes/temp runtime state were torn down and proof artifacts still exist on disk.
5. **Next Step**: recommend the single clearest follow-up (for example, fixing a confirmed `product-regression`, running `audit-cases()`, or expanding coverage).
