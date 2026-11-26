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

Synthesize verified execution artifacts from `<output-dir>/<test-slug>/` into a durable Markdown test report (Part 3, optionally Git-tracked) and a concise in-chat summary without modifying tracked test definitions (`<cases-dir>/<case-slug>/`).

## Predecessors

- Requires an existing `<output-dir>/<test-slug>/` containing `run-meta.json` and `evidence/` from `run-case()` or `audit-case()`; otherwise stop and point to `run-case()`.

## Workflow

When `imsight-project-mgr->agent-driven-testing->report-results()` is invoked, execute the following steps in order while applying [principles.md](../references/principles.md) (`v2`–`v7`).

1. **Inspect run identity and verify disk proof (`v4`, `v7`).** Read `run-meta.json` and check every cited file under `<output-dir>/<test-slug>/evidence/`. Confirm each file exists post-cleanup, is non-empty, matches the reported commit SHA and entry point, and includes the independent read-only second view (`v3`) plus any stand-in delta disclosure. Downgrade any unbacked `PASS` to `FAIL` or `BLOCKED`.
2. **Validate verdicts, criteria checks, usability issues, and uncertainty (`v2`, `v5`, `v6`).** Apply [report-template.md](../references/report-template.md): every scenario carries `PASS`, `FAIL`, `BLOCKED`, or `VERIFIED-UNREACHABLE` (never `INCONCLUSIVE`), lists observed **Quantified checks** and artifact-cited **Qualitative judgment**, aggregates all `usability-issue` items (including on `PASS` runs) under `## Usability Issues`, and captures borderline calls or open questions under `## Uncertainty and Open Questions`.
3. **Redact secrets.** Confirm no credentials, API keys, tokens, or private session material appear in the report (especially since reports may be Git-tracked).
4. **Write the durable Markdown report and return the in-chat summary** per [report-template.md](../references/report-template.md).

If aggregating multiple `<output-dir>/<test-slug>/` runs (such as baseline vs. patched builds or parallel slices), use your native planning tool to verify each slice's SHA and disk artifacts before synthesizing one report.

## Guardrails

- DO NOT emit an `INCONCLUSIVE` verdict, or report `PASS` when cited evidence is missing, empty, or from another commit SHA.
- DO NOT omit `usability-issue` friction (even on passing runs), skipped entry points, dropped parallel slices, or residual uncertainty.
- DO NOT include secrets or tokens in reports, write reports inside `<cases-dir>`, modify `<cases-dir>/<case-slug>/`, or commit raw files from `<output-dir>/<test-slug>/`.
- DO NOT relabel a `product-regression` or `usability-issue` as `doc-drift` or `PASS`.
