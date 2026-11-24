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

Synthesize verified execution artifacts from `<project-tmp-root>/instructional-tests/<run-id>/` into a durable Markdown test report and a concise, decision-ready in-chat summary.

## Workflow

When `imsight-project-mgr->agent-driven-testing->report-results()` is invoked, execute the following steps in order.

1. **Collect run identity and evidence.** Locate `<run-tmp> = <project-tmp-root>/instructional-tests/<run-id>/`, read `run-meta.json` (checkout path, branch, commit SHA, dirty state, tool versions, spawned resources), and inspect every artifact under `<run-tmp>/evidence/`.
2. **Verify evidence integrity on disk.** Confirm each claimed artifact path actually exists after cleanup, is non-empty, and matches the executed commit SHA and case entry point. Downgrade any claim lacking disk-backed proof from `PASS` to `BLOCKED` or unverified.
3. **Classify every case and finding.** Apply the verdict taxonomy (`PASS`, `FAIL`, `BLOCKED`, `VERIFIED-UNREACHABLE`), audit outcome (`clean`, `changed`, `blocked` when reporting an audit), and triage labels (`doc-drift`, `harness-gap`, `product-regression`) defined in [report-template.md](../references/report-template.md).
4. **Redaction and hygiene check.** Confirm no secrets, API keys, sign-in ticket URLs, session cookies, or private credentials appear in the report text or cited filenames.
5. **Resolve the report destination and write the durable Markdown report.** Follow **Report Destination Priority** in [report-template.md](../references/report-template.md) to write the Markdown report, and optionally place a run-local copy or pointer at `<run-tmp>/report.md`.
6. **Return the concise in-chat summary.** Present the run identity, summary table, concrete defects/triage findings, cleanup confirmation, link to the durable report, and next recommended action.

If the user wants to aggregate multiple run directories (for example, comparing a baseline run against a patched run, or combining parallel swarm slices), use your native planning tool to validate every slice's SHA and evidence paths before synthesizing one unified report.

## Evidence Verification Checks

Before writing `PASS` for any case, verify all four items:

- **Identity match**: the artifact came from the reported realwork checkout and commit SHA (and both baseline and patched SHAs for before-and-after verification).
- **Surface match**: the evidence proves the real user-facing surface named by the case, not a unit test, dry-run proxy, or different entry point.
- **Cross-check present**: mutation or agent-behavior cases include the read-only second view (file read-back, DB/mailbox query, or agent transcript inspection), not just a toast notification or agent self-report.
- **Stand-in disclosure**: if any part of the run used a local stand-in instead of the production target, list every setup step the stand-in supplied so readers know what stays unverified.

## Guardrails

- DO NOT report `PASS` for a case whose proof artifacts are missing, empty, uninspected, or from a different commit SHA.
- DO NOT include raw credentials, API keys, sign-in ticket URLs, or session cookies in durable reports or chat summaries.
- DO NOT write durable reports inside `<realwork>/tests/instructional/` or commit disposable temp files from `<project-tmp-root>` into Git.
- DO NOT omit skipped cases, dropped swarm workers, or unverified entry points from the summary.
- DO NOT relabel a `product-regression` as `doc-drift` or `PASS`.
