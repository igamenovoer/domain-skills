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

This reference defines report destinations, verdict and triage taxonomies (including `usability-issue`), the forced-decision soft-goal reporting rule, the durable Markdown report template, and the concise in-chat summary contract used by `imsight-project-mgr->agent-driven-testing->report-results()` and the reporting step of `run-case()` and `audit-case()`.

## Report Destination Priority (Part 3: Test Reports)

Test reports are durable Markdown documents kept separate from both tracked test definitions (`<cases-dir>/<case-slug>/`) and raw test outputs (`<output-dir>/<test-slug>/`). Projects and users may choose to Git-track test reports (for example under `.imsight-arts/...`). Resolve where the durable Markdown report is written in this priority order:

1. **User-specified destination**: an explicit file or directory requested by the user (for example, a debug campaign folder or PR handoff note).
2. **Environment override**: `IMSIGHT_SKILL_OUTPUT_DIR` resolved from the owning project.
3. **Default durable report root**:
   - Attached metaproj: `<meta-root>/.imsight-arts/project-mgr/agent-driven-testing/reports/<timestamp>-<run-slug>.md`
   - Standalone realwork: `<realwork-root>/.imsight-arts/project-mgr/agent-driven-testing/reports/<timestamp>-<run-slug>.md`

Keep raw test outputs (screenshots, ARIA snapshots, terminal transcripts, JSON dumps, logs, temporary scripts, and any ad-hoc diagnostics) inside `<output-dir>/<test-slug>/` (and optionally place a run-local copy or pointer at `<output-dir>/<test-slug>/report.md`). Never write test reports or raw outputs into `<cases-dir>`, and never commit Git-ignored `<output-dir>/<test-slug>/` files into the realwork repository.

## Verdict Taxonomy

Assign **exactly one** of these four verdicts to each executed case (and sub-case when granular reporting is helpful). **There is no `INCONCLUSIVE` verdict:** when a case actually executes, the runner must make a definitive `PASS` or `FAIL` decision against the case's soft goals and document any residual uncertainty, caveats, or open questions in the report.

| Verdict | Meaning | Required Evidence |
| --- | --- | --- |
| `PASS` | The real user path ran, no hard disqualifier triggered, and the runner judges all soft goals satisfied based on disk-backed evidence and read-only cross-checks | Exact commands, exit codes/outputs, read-only cross-check result, evidence-cited soft-goal rationale, and surviving artifact paths in `<output-dir>/<test-slug>/evidence/` |
| `FAIL` | The target launched and reached the feature, and real execution triggered a hard disqualifier or failed to satisfy one or more soft goals | Exact failing step, soft-goal rationale / disqualifier hit, expected vs. observed state, surviving artifact paths, and triage classification |
| `BLOCKED` | The harness or target could not reach a valid drivable state (build/launch failure, `Doctor` failure not resolved by an authorized audit harness fix, or missing required capability) | Exact blocking command/error, `Doctor` output, and what stopped execution |
| `VERIFIED-UNREACHABLE` | The harness ran cleanly, but a concrete external prerequisite (missing credential, entitlement, OS feature, or offline external service) prevented reaching the case | Attempted route/command, concrete unmet prerequisite, and note of whether the prerequisite is documented in `Gotchas` |

### Run-Level Outcome (for `audit-case()`)

- `clean`: every mapped case received source and live coverage with no drift, harness gap, or regression to fix.
- `changed`: proven fixes were applied strictly inside `<cases-dir>/<case-slug>/` (doc drift or harness gap) and re-verified live.
- `blocked`: coverage could not complete or a proven harness fix could not be verified safely; exact blocker named.

## Triage Categories

Classify every non-passing finding honestly so product bugs and usability problems are never buried as test-doc updates. Multiple labels may apply when distinct issues appear in the same scenario, and `usability-issue` may also be attached to a `PASS` scenario whenever the system confused or misled the executing agent along the way:

- `doc-drift`: the product behaves as intended (confirmed from source, specs, or commit history), while `<cases-dir>/<case-slug>/` describes stale flags, routes, labels, or omitted prerequisites.
- `harness-gap`: the product works cleanly for a human user, but the harness script or selector in `<cases-dir>/<case-slug>/` cannot drive or observe it reliably.
- `product-regression`: the product violates its documented or intended contract on the real surface. Record the repro steps, observed vs. expected behavior, and commit SHA; do not mask it by weakening the case.
- `usability-issue`: the system under test behaves in a counter-intuitive way, misleads the executing agent into a wrong mental model or wrong operation, confuses the agent about current state, or lacks actionable feedback when an error occurs so figuring out the correct operation is unnecessarily hard. **Principle: if something confuses the executing agent, it will likely confuse human users as well.** Always record the exact confusing interaction, what the agent was misled to believe or try, what feedback was missing or unclear, and the supporting artifact path in `<output-dir>/<test-slug>/`.

## Durable Markdown Report Template

Write the Markdown report without hard-wrapping normal paragraphs, filling every section from observed run evidence:

```markdown
# Instructional Test Report: <run-slug>

Date: YYYY-MM-DD HH:MM UTC | Overall Status: <PASS | FAIL | MIXED | BLOCKED> | Mode: <run-case | audit-case | before-after-fix | blinded-eval>

## Run Identity and Environment

- **Realwork checkout**: `<path>` (branch `<branch>`, commit `<sha>`, working tree `<clean | dirty: summary>`)
- **Enclosing metaproj**: `<path or none (standalone)>`
- **Test definitions (tracked)**: `<cases-dir>/<case-slug>/` (`draft` or `proven`, strictly untouched during `run-case()`)
- **Test output root (ignored)**: `<output-dir>/<test-slug>/`
- **Evidence root (verified post-cleanup)**: `<output-dir>/<test-slug>/evidence/`
- **Temporary scripts used**: `<list under scripts/ or none>`
- **Harness & tool versions**: `<app/CLI/browser/model versions actually observed by Doctor>`
- **Stand-in or environment deltas**: `<none, or exact setup steps performed by a local stand-in that the production target will not perform>`

## Summary Table

| Bundle / Scenario | Entry Point(s) Tested | Verdict | Triage | Doctor | Surviving Evidence | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `<case-slug>/<scenario-slug>` | `<cli / web / ...>` | `PASS` | `none` (or `usability-issue`, ...) | `pass` | `<output-dir>/<test-slug>/evidence/<case-slug>/<scenario-slug>/...>` | `<1-line summary>` |

## Per-Case Details

### `<case-slug>/<scenario-slug>` — `<VERDICT>`

- **Preconditions & Doctor**: `<exact doctor check and observed app identity/version>`
- **Executed path**: `<ordered steps or commands run>`
- **Expected soft goals vs. observed**: `<concrete outputs, exit codes, UI/state observations>`
- **Read-only cross-check**: `<independent verification of files, DB, mailbox, or transcript>`
- **Soft-goal judgment rationale**: `<why the runner judged PASS or FAIL against each soft goal and hard disqualifier, citing specific artifact files>`
- **Usability observations**: `<none, or specific counter-intuitive behavior, misleading cues, or missing error feedback encountered during this scenario>`
- **Uncertainty & caveats**: `<none, or borderline observations, judgment assumptions, and open questions for the human reviewer>`
- **Artifacts**: `<exact paths under <output-dir>/<test-slug>/evidence/<case-slug>/<scenario-slug>/ verified present after cleanup>`
- **Triage & follow-up**: `<none, or doc-drift / harness-gap / product-regression / usability-issue with exact file/line or recommended explicit author-case() / product-fix follow-up>`

## Usability Issues

- `<Aggregate every `usability-issue` observed across the run (including on PASS cases): what happened, why it misled or confused the agent, what feedback was missing, why it affects users, and the exact evidence path under <output-dir>/<test-slug>/; write "None." if no usability friction occurred>`

## Uncertainty and Open Questions

- `<Aggregate any qualitative judgment caveats, borderline soft-goal calls, environment ambiguities, or design questions that remain open for human follow-up; write "None." if completely clear>`

## Cleanup Verification

- **Stopped/removed**: `<exact PIDs, gateways, isolated tmux sockets, and disposable runtime/ directories cleaned>`
- **Preserved**: `<confirmation that <output-dir>/<test-slug>/evidence/ files still exist, <cases-dir>/<case-slug>/ test definitions were not modified during run-case(), and user-owned sessions were untouched>`
- **Residual items**: `<none, or any leaked resource and why>`

## Unverified Scope and Next Steps

- `<List skipped cases, unverified entry points, deferred lanes, whether any `draft` bundle is ready for explicit `author-case()` promotion to `proven`, or recommended product/usability/harness follow-ups>`
```

## In-Chat Summary Contract

Always pair the durable report with a concise in-chat summary containing:

1. **Target & Run Identity**: realwork checkout, commit SHA, test definitions path (`<cases-dir>/<case-slug>/`), test output path (`<output-dir>/<test-slug>/`), and link to the durable Markdown report.
2. **Result Table**: case name, definitive verdict (`PASS` / `FAIL` / `BLOCKED` / `VERIFIED-UNREACHABLE`), triage labels (`doc-drift`, `harness-gap`, `product-regression`, `usability-issue`, or `none`), and primary evidence path.
3. **Key Findings, Usability Issues & Uncertainty**: concrete rationale for every `FAIL`, `BLOCKED`, `doc-drift`, `harness-gap`, `product-regression`, and `usability-issue` item (including usability friction found on passing runs), plus brief highlights of any notable uncertainty or open questions recorded in the report.
4. **Cleanup & Read-Only Confirmation**: confirm owned processes/disposable runtime state were torn down, proof artifacts still exist under `<output-dir>/<test-slug>/evidence/`, and `<cases-dir>/<case-slug>/` remained untouched (for `run-case()`).
5. **Next Step**: recommend the single clearest follow-up (for example, fixing a confirmed `product-regression` or `usability-issue`, explicitly invoking `author-case()` to promote `status: draft` -> `proven` or fix a `harness-gap`, or invoking `audit-case()`).
