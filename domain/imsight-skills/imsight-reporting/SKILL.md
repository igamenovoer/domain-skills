---
name: imsight-reporting
description: Use when explicitly invoking imsight-reporting, routing from another Imsight skill, or using Imsight context to produce a daily or weekly work report from Git history, uncommitted changes, nested repositories, research-topic artifacts, build records, specifications, or a project's own reporting instructions.
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

# Imsight Reporting

## Overview

Use this skill to turn repository activity and project evidence into a concise work report for readers who did not follow the implementation. Treat Git as an evidence source, not as the report structure: synthesize related changes into outcomes, explain their value, and calibrate every completion claim to the available proof. A report covers one day or one defined period and takes either a compact form or a structured engineering form, selected by the project's own reporting contract when one exists.

## When to Use

- Use for a daily report, day log, end-of-day update, stand-up summary, or same-day work recap grounded in project evidence.
- Use for a weekly report, period summary, sprint or cycle recap, or any grouped report covering more than one day.
- Use when the report must include commits, staged or unstaged changes, relevant nested repositories, and non-Git project outputs such as research records, build results, specifications, or validation reports.
- Use when the project defines its own report sections, filename, body language, or style, and the report must follow them.
- Use when the audience needs project names and concrete outcomes without needing to understand repository paths, internal abbreviations, schema versions, or individual commits.
- Do not use for release notes, a raw changelog, a commit-by-commit digest, a time sheet, or a general retrospective that is not tied to one reporting period.

## Workflow

When this skill is invoked, execute the following steps in order.

1. **Resolve the reporting context**. Identify the reporting date or period, timezone, project scope, requested language, requested length or point count, and whether the result should be returned in chat or written to a file.
2. **Select a subcommand** from **Subcommands**. If no actionable task is present, handle `help()`; otherwise use `write-day-log()` for one day and `write-week-report()` for a defined multi-day period.
3. **Load the project report contract**. Find and extract the project's own reporting rules, or record that none exists. See **Project Report Contract**.
4. **Select the report shape**. Choose the compact form or the structured engineering form from **Report Shapes**, using the contract and the user's request.
5. **Collect evidence**. Inspect all relevant Git history, staged and unstaged diffs, untracked work, project-owned nested repositories, earlier reports in the same series, and authoritative project materials using the selected command workflow.
6. **Synthesize outcomes**. Group related evidence by user-visible or engineering outcome rather than by commit, file, tool, or chronology; apply [references/day-log-principles.md](references/day-log-principles.md).
7. **Write for an external project reader**. Explain what changed, why it matters, and what result or validation exists without assuming the reader has seen the repository.
8. **Deliver the report**. Use the requested language and destination, or the defaults in **Output Contract**, then report the written path and any material evidence gaps.

If the user's task does not map cleanly to these steps, use the native planning tool to build a bounded reporting plan from the requested scope, evidence sources, audience, language, output destination, and principles in this skill, then execute the plan.

## Invocation Contract

- Preferred explicit form: `$imsight-reporting use write-day-log() to prepare the report for <date>`.
- Period form: `$imsight-reporting use write-week-report() for <week>`.
- Task-only form: `$imsight-reporting <reporting request>` means use the subcommand that matches the requested artifact, with the supplied scope and constraints.
- No subcommand and no actionable task means `help()`.
- `help()` explains the evidence sources, audience posture, report shapes, output defaults, and public subcommands.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `write-day-log()` | Inspect one day's Git and project evidence, synthesize outcome-oriented points, and optionally save the report | [commands/write-day-log.md](commands/write-day-log.md) |
| `write-week-report()` | Inspect a defined period's reports and evidence, reconcile changed conclusions, and optionally save one outcome-grouped report | [commands/write-week-report.md](commands/write-week-report.md) |
| `help()` | Explain this reporting skill and its defaults | This entrypoint |

## Report Shapes

| Shape | Produces | Use when |
| --- | --- | --- |
| Compact | A dated heading and a small number of numbered outcome paragraphs in the requested language | No contract selects a structure, or the user asks for a short recap |
| Structured | Contract-defined sections organized over three purposes: capability, investigation, and remaining work | The contract defines report sections, or the user asks for an engineering report |

Resolve the shape from the contract first, then from the user's request, then from an unambiguous existing series. State the choice only when the request does not already make it clear. Apply [references/structured-report-shape.md](references/structured-report-shape.md) for the structured shape.

## Project Report Contract

A project may define its own artifact kinds, filenames, title form, body language, section set, numbering, table rules, and style sources. Discover that contract before drafting, and let it supply those fields in place of the defaults on this page. Sources rank as the user's instruction for this report, then the project contract, then this skill's defaults.

A contract changes shape and style only. The evidence authority order, claim calibration, conclusion separation, and no-invention rule remain in force regardless of what the project declares. See [references/project-report-contract.md](references/project-report-contract.md) for discovery order, the extraction checklist, precedence, and the non-overridable floor.

## Project Scope

Use the project or repository paths explicitly named by the user. Otherwise, start from the current project root and include only project-owned nested repositories, worktrees, or external checkouts that are directly relevant to the period's work; do not scan unrelated repositories elsewhere on the host.

## Output Contract

Default to the language, length, and format the user requested. When the user requests none, use the contract's declared values; absent a contract, return English and three numbered, outcome-oriented points. Each point states the completed or advanced outcome, its practical value, and one concrete result or verification signal in one compact paragraph.

Return the report in chat unless the user asks to save it. When durable output is requested, resolve the destination in this order:

1. Use the exact file or directory supplied by the user.
2. Use the contract's declared filename and directory pattern.
3. Otherwise, use `IMSIGHT_SKILL_OUTPUT_DIR` when set, writing `daylog/<artifact-name>` below it.
4. Otherwise, write `<project-dir>/tmp/daylog/<artifact-name>`.

Name the artifact `YYYY-MM-DD.md` for a daily report and `YYYY-Www.md` for a weekly report, using the ISO week of the period's start, unless the contract declares another pattern.

Read an existing artifact before revising it. Preserve manual material that remains accurate, and replace or remove stale claims only when the evidence supports the change.

## Guardrails

- DO NOT present a commit-by-commit or file-by-file inventory as the report.
- DO NOT claim implementation, completion, validation, or publication from proposal text or filenames alone.
- DO NOT omit relevant staged, unstaged, untracked, nested-repository, or non-Git project evidence merely because it is not committed.
- DO NOT assume the reader understands repository layout, internal abbreviations, command names, schema versions, or issue identifiers.
- DO NOT hide uncertainty about incomplete, conflicting, generated-only, or unverified evidence.
- DO NOT expose credentials, private endpoints, personal data, or sensitive diff content in the report.
- DO NOT apply a section set, numbering scheme, body language, or filename that neither the contract nor the user established.
- DO NOT let a project contract relax evidence authority, claim calibration, conclusion separation, or the no-invention rule.
