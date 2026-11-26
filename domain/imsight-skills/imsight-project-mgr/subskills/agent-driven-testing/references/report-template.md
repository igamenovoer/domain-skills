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

This reference defines report destinations, verdict and triage taxonomies, and the report format used by `run-case()`, `audit-case()`, and `report-results()`. Apply the judgment rules in [principles.md](principles.md) when evaluating evidence.

## Report Destination Priority (Part 3: Test Reports)

Test reports are curated, secret-redacted Markdown files stored separately from tracked test definitions (`<cases-dir>/<case-slug>/`) and ignored raw test outputs (`<output-dir>/<test-slug>/`). Projects and users may choose to track reports in Git. Resolve the destination in order:

1. **User-specified file or directory.**
2. **`IMSIGHT_SKILL_OUTPUT_DIR`** resolved from the owning project.
3. **Default durable report root:**
   - Attached metaproj: `<meta-root>/.imsight-arts/project-mgr/agent-driven-testing/reports/<timestamp>-<run-slug>.md`
   - Standalone realwork: `<realwork-root>/.imsight-arts/project-mgr/agent-driven-testing/reports/<timestamp>-<run-slug>.md`

Optionally place a copy or pointer at `<output-dir>/<test-slug>/report.md`. Never write reports into `<cases-dir>`.

## Verdict Taxonomy (Forced Decision — No `INCONCLUSIVE`)

Assign **exactly one** verdict per scenario. Whenever a scenario executes, the runner must decide `PASS` or `FAIL` and record any residual ambiguity, caveats, or open questions in the report body rather than deferring the verdict:

| Verdict | Meaning | Required Proof |
| --- | --- | --- |
| `PASS` | Real boundary ran, all **Quantified checks** held, and the runner judges all **Qualitative checks** satisfied from disk-backed evidence and independent cross-checks | Commands/actions run, quantified check values, qualitative judgment rationale citing surviving files in `<output-dir>/<test-slug>/evidence/`, and second-view result |
| `FAIL` | Target reached the scenario, and execution violated a quantified check or failed a qualitative check | Failing step, violated check or qualitative rationale, expected vs. observed state, surviving evidence paths, and triage label(s) |
| `BLOCKED` | Harness or target could not reach a valid drivable state (build/launch/preflight/`Doctor` failure) | Exact blocking command, error/`Doctor` output, and what stopped execution |
| `VERIFIED-UNREACHABLE` | Harness worked, but a concrete external prerequisite (credentials, hardware, entitlement, external service) was unavailable | Attempted command/path and exact unmet prerequisite |

For `audit-case()`, also state one run-level audit outcome: **`clean`** (full source + live coverage, no definition edits needed), **`changed`** (proven `doc-drift` or `harness-gap` edits applied inside `<cases-dir>/<case-slug>/` and re-verified live), or **`blocked`** (coverage or verification blocked; blocker named).

## Triage Categories

Multiple labels may apply when distinct issues surface in one scenario, and **`usability-issue` applies to `PASS` scenarios as well** whenever the system misled or confused the executing agent along the way:

- `doc-drift`: intentional product behavior (confirmed from source, specs, or commit history) where `<cases-dir>/<case-slug>/` is stale.
- `harness-gap`: product works cleanly for a user/caller, but the driver or helper in `<cases-dir>/<case-slug>/` fails to drive or observe it reliably.
- `product-regression`: product breaks its intended contract, quantified invariant, or qualitative expectation on the real surface.
- `usability-issue`: counter-intuitive behavior, misleading cues/flags/states, or opaque error feedback that confused the executing agent or forced trial-and-error (**if it confuses the agent, it will likely confuse users too**).

## Durable Markdown Report Template

```markdown
# Instructional Test Report: <run-slug>

Date: YYYY-MM-DD HH:MM UTC | Overall Status: <PASS | FAIL | MIXED | BLOCKED> | Mode: <run-case | audit-case | before-after-fix | blinded-eval>

## Run Identity and Environment

- **Realwork checkout**: `<path>` (branch `<branch>`, commit `<sha>`, working tree `<clean | dirty: summary>`)
- **Enclosing metaproj**: `<path or none (standalone)>`
- **Test definitions (tracked)**: `<cases-dir>/<case-slug>/` (`draft` or `proven`, untouched during `run-case()`)
- **Test output root (ignored)**: `<output-dir>/<test-slug>/`
- **Evidence root (verified post-cleanup)**: `<output-dir>/<test-slug>/evidence/`
- **Versions & environment**: `<binary/service/runtime/model versions observed by Doctor + any stand-in deltas>`

## Summary Table

| Bundle / Scenario | Entry Point(s) | Verdict | Triage | Doctor | Surviving Evidence | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `<case-slug>/<scenario-slug>` | `<entry point>` | `PASS` | `none` (or `usability-issue`, ...) | `pass` | `<output-dir>/<test-slug>/evidence/<case-slug>/<scenario-slug>/...>` | `<1-line summary>` |

## Per-Case Details

### `<case-slug>/<scenario-slug>` — `<VERDICT>`

- **Preconditions & Doctor**: `<observed readiness, version, and isolation check>`
- **Executed path & second view**: `<commands/actions run + independent read-only cross-check>`
- **Quantified checks**: `<pass/fail results with observed counts, codes, headers, or values>`
- **Qualitative judgment**: `<n/a, or why the runner judged PASS/FAIL on each qualitative criterion, citing exact artifact files>`
- **Usability observations**: `<none, or what misled/confused the agent and what error feedback was missing>`
- **Uncertainty & caveats**: `<none, or borderline calls, assumptions, and open questions>`
- **Artifacts & triage**: `<verified surviving paths under <output-dir>/<test-slug>/evidence/... + triage/follow-up>`

## Usability Issues

- `<Aggregate every usability-issue across all scenarios (including PASS runs) with what happened, why it misleads users/agents, missing feedback, and evidence path; or "None.">`

## Uncertainty and Open Questions

- `<Aggregate borderline qualitative calls, environment caveats, or open questions for human review; or "None.">`

## Cleanup and Next Steps

- **Cleanup & preservation**: `<stopped PIDs/resources, preserved <output-dir>/<test-slug>/evidence/, untouched <cases-dir>/<case-slug>/ during run-case(), any residue>`
- **Unverified scope & next steps**: `<skipped cases/entry points, whether a draft bundle is ready for explicit author-case() promotion to proven, or recommended product/usability/harness follow-ups>`
```

## In-Chat Summary Contract

Pair the durable report with a concise summary covering: (1) checkout SHA, `<cases-dir>/<case-slug>/`, `<output-dir>/<test-slug>/`, and report link; (2) verdict + triage table; (3) concrete findings for every failure, `usability-issue`, and notable uncertainty; (4) cleanup + read-only definition confirmation; and (5) the single clearest next step.
