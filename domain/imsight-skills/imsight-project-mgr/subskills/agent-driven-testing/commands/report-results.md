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

# Report Instructional Test Results

Synthesize verified execution artifacts from test output (`<output-dir>/<test-slug>/`) into a durable Markdown test report (Part 3, such as `.imsight-arts/...`, which may be chosen to be Git-tracked) and a concise, decision-ready in-chat summary without modifying tracked test definitions (`<cases-dir>/<case-slug>/`).

## Predecessors

- Requires an existing test output directory `<output-dir>/<test-slug>/` containing `run-meta.json` and captured artifacts under `evidence/` produced by `imsight-project-mgr->agent-driven-testing->run-case()` or `imsight-project-mgr->agent-driven-testing->audit-case()`.
- If no test output directory exists, stop and point the user to `imsight-project-mgr->agent-driven-testing->run-case()`.

## Workflow

When `imsight-project-mgr->agent-driven-testing->report-results()` is invoked, execute the following steps in order.

1. **Collect run identity and evidence.** Locate `<output-dir>/<test-slug>/`, read `run-meta.json` (checkout path, branch, commit SHA, dirty state, test definitions path, tool versions, spawned resources), and inspect every artifact under `<output-dir>/<test-slug>/evidence/` (plus any additional diagnostic files referenced from `<output-dir>/<test-slug>/`).
2. **Verify evidence integrity on disk.** Confirm each claimed artifact path actually exists after cleanup, is non-empty, and matches the executed commit SHA and case entry point. Downgrade any claim lacking disk-backed proof from `PASS` to `FAIL` or `BLOCKED` as appropriate.
3. **Verify forced verdicts, soft-goal rationale, usability issues, and triage.** Apply the exact four-verdict taxonomy (`PASS`, `FAIL`, `BLOCKED`, `VERIFIED-UNREACHABLE` — no `INCONCLUSIVE`), audit outcome (`clean`, `changed`, `blocked` when reporting an audit), and triage labels (`doc-drift`, `harness-gap`, `product-regression`, `usability-issue`) defined in [report-template.md](../references/report-template.md). Confirm every executed case has an evidence-cited soft-goal judgment rationale, every `usability-issue` (including on passing cases) is aggregated under `## Usability Issues`, and all residual uncertainty, caveats, and open questions are captured explicitly in the report.
4. **Redaction and hygiene check.** Confirm no secrets, API keys, sign-in ticket URLs, session cookies, or private credentials appear in the report text or cited filenames (especially because test reports may be Git-tracked).
5. **Resolve the report destination and write the durable Markdown report.** Follow **Report Destination Priority** in [report-template.md](../references/report-template.md) to write the durable Markdown report (separate from both `<cases-dir>` and raw `<output-dir>/<test-slug>/`), and optionally place a run-local copy or pointer at `<output-dir>/<test-slug>/report.md`. Never write reports into `<cases-dir>`.
6. **Return the concise in-chat summary.** Present the run identity, summary table, concrete defects/triage findings, highlighted usability issues and uncertainty/open questions, cleanup and read-only confirmation, link to the durable report, and next recommended action.

If the user wants to aggregate multiple `<output-dir>/<test-slug>/` directories (for example, comparing a baseline run against a patched run, or combining parallel swarm slices), use your native planning tool to validate every slice's SHA and evidence paths before synthesizing one unified report.

## Evidence Verification Checks

Before writing `PASS` for any case, verify all five items:

- **Identity match**: the artifact came from the reported realwork checkout and commit SHA (and both baseline and patched SHAs for before-and-after verification).
- **Surface match**: the evidence proves the real user-facing surface named by the case, not a unit test, dry-run proxy, or different entry point.
- **Cross-check present**: mutation or agent-behavior cases include the read-only second view (file read-back, DB/mailbox query, or agent transcript inspection), not just a toast notification or agent self-report.
- **Soft-goal rationale & disqualifier check**: no hard disqualifier triggered, each qualitative soft goal is explicitly linked to surviving evidence files under `<output-dir>/<test-slug>/`, any `usability-issue` is surfaced rather than hidden, and any caveats or open questions are recorded rather than deferred.
- **Stand-in disclosure**: if any part of the run used a local stand-in instead of the production target, list every setup step the stand-in supplied so readers know what stays unverified.

## Guardrails

- DO NOT emit an `INCONCLUSIVE` verdict; every case must carry one of `PASS`, `FAIL`, `BLOCKED`, or `VERIFIED-UNREACHABLE`, with uncertainty and open questions recorded in the report body.
- DO NOT omit `usability-issue` findings encountered during execution, even when the scenario passed.
- DO NOT report `PASS` for a case whose proof artifacts are missing, empty, uninspected, or from a different commit SHA.
- DO NOT include raw credentials, API keys, sign-in ticket URLs, or session cookies in durable reports or chat summaries.
- DO NOT modify `<cases-dir>/<case-slug>/` or write durable reports inside `<cases-dir>`, and DO NOT commit raw test outputs from `<output-dir>/<test-slug>/` into Git.
- DO NOT omit skipped cases, dropped swarm workers, unverified entry points, or residual uncertainty from the report.
- DO NOT relabel a `product-regression` or `usability-issue` as `doc-drift` or `PASS`.
