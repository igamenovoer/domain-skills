---
name: imsight-reporting
description: Use when explicitly invoking imsight-reporting, routing from another Imsight skill, or using Imsight context to produce a daily work log from Git commits, staged or unstaged diffs, nested repositories, research-topic artifacts, build records, specifications, or other project evidence.
---

# Imsight Reporting

## Overview

Use this skill to turn repository activity and project evidence into a concise daily work report for readers who did not follow the implementation. Treat Git as an evidence source, not the report structure: synthesize related changes into outcomes, explain their value, and calibrate every completion claim to the available proof.

## When to Use

- Use for a daily report, day log, end-of-day update, stand-up summary, or same-day work recap grounded in project evidence.
- Use when the report must include commits, staged or unstaged changes, relevant nested repositories, and non-Git project outputs such as research records, build results, specifications, or validation reports.
- Use when the audience needs project names and concrete outcomes without needing to understand repository paths, internal abbreviations, schema versions, or individual commits.
- Do not use for release notes, a raw changelog, a commit-by-commit digest, a time sheet, or a general retrospective that is not tied to one reporting day.

## Workflow

When this skill is invoked, execute the following steps in order.

1. **Resolve the reporting context**. Identify the reporting date, timezone, project scope, requested language, requested point count, and whether the result should be returned in chat or written to a file.
2. **Select a subcommand** from **Subcommands**. If no actionable task is present, handle `help`; otherwise use `write-day-log`.
3. **Collect same-day evidence**. Inspect all relevant Git history, staged and unstaged diffs, untracked work, project-owned nested repositories, and authoritative project materials using the selected command workflow.
4. **Synthesize outcomes**. Group related evidence by user-visible or engineering outcome rather than by commit, file, tool, or chronology; apply [references/day-log-principles.md](references/day-log-principles.md).
5. **Write for an external project reader**. Explain what changed, why it matters, and what result or validation exists without assuming the reader has seen the repository.
6. **Deliver the report**. Use the requested language and destination, or the defaults in **Output Contract**, then report the written path and any material evidence gaps.

If the user's task does not map cleanly to these steps, use the native planning tool to build a bounded reporting plan from the requested scope, evidence sources, audience, language, output destination, and principles in this skill, then execute the plan.

## Invocation Contract

- Preferred explicit form: `$imsight-reporting use write-day-log to prepare the report for <date>`.
- Task-only form: `$imsight-reporting <reporting request>` means use `write-day-log` with the supplied scope and constraints.
- No subcommand and no actionable task means `help`.
- `help` explains the evidence sources, audience posture, output defaults, and public subcommands.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `write-day-log` | Inspect one day's Git and project evidence, synthesize outcome-oriented points, and optionally save the report | [commands/write-day-log.md](commands/write-day-log.md) |
| `help` | Explain this reporting skill and its defaults | This entrypoint |

## Project Scope

Use the project or repository paths explicitly named by the user. Otherwise, start from the current project root and include only project-owned nested repositories, worktrees, or external checkouts that are directly relevant to the day's work; do not scan unrelated repositories elsewhere on the host.

## Output Contract

Default to English and three numbered, outcome-oriented points unless the user requests another language, format, or count. Each point should state the completed or advanced outcome, its practical value, and one concrete result or verification signal in one compact paragraph.

Return the report in chat unless the user asks to save it. When durable output is requested, resolve the destination in this order:

1. Use the exact file or directory supplied by the user.
2. Otherwise, preserve an established project day-log location when nearby dated reports make that convention unambiguous.
3. Otherwise, use `IMSIGHT_SKILL_OUTPUT_DIR` when set, writing `daylog/<YYYY-MM-DD>.md` below it.
4. Otherwise, write `<project-dir>/tmp/daylog/<YYYY-MM-DD>.md`.

Read an existing dated report before revising it. Preserve manual material that remains accurate, and replace or remove stale claims only when the evidence supports the change.

## Guardrails

- DO NOT present a commit-by-commit or file-by-file inventory as the daily report.
- DO NOT claim implementation, completion, validation, or publication from proposal text or filenames alone.
- DO NOT omit relevant staged, unstaged, untracked, nested-repository, or non-Git project evidence merely because it is not committed.
- DO NOT assume the reader understands repository layout, internal abbreviations, command names, schema versions, or issue identifiers.
- DO NOT hide uncertainty about incomplete, conflicting, generated-only, or unverified evidence.
- DO NOT expose credentials, private endpoints, personal data, or sensitive diff content in the report.
