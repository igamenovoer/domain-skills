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

Turn repository activity and project evidence into a clear, readable daily or weekly work report for stakeholders who did not follow the implementation and will not open the repository. Instead of checking off a rigid writing recipe, internalize the reporting mentality in [references/reporting-principles.md](references/reporting-principles.md) and apply those principles directly while selecting focus, weighing evidence, and writing.

## When to Use

- Use for a daily report, day log, stand-up summary, or end-of-day progress update grounded in repository and project evidence.
- Use for a weekly report, sprint summary, or multi-day period recap that synthesizes outcomes across days and repositories.
- Use when the report must follow a project's own reporting guide, section layout, language, or terminology while keeping claims honest and readable for external stakeholders.
- Do not use for release notes, raw changelogs, commit-by-commit digests, time sheets, or engineering audit dumps unless the user explicitly asks for an audit view.

## Workflow

When this skill is invoked, execute the following steps in order.

1. **Resolve the reporting context**. Identify the target date or period, timezone, repository scope, requested language, and output destination.
2. **Select a subcommand** from **Subcommands**. Use `write-day-log()` for one day, `write-week-report()` for a multi-day period, or `help()` when no actionable reporting request is given.
3. **Load the project report contract**. Check for the project's own reporting instructions and honor its structure, section order, language, naming, and terminology. See **Project Report Contract**.
4. **Internalize the reporting mentality**. Read [references/reporting-principles.md](references/reporting-principles.md) (`r1`–`r9`), remember those principles, and apply them directly while gathering evidence, choosing focus, and drafting.
5. **Execute the selected subcommand** and deliver the report using **Output Contract**, noting the written path if saved.

If the user's request does not map cleanly to these steps, use the native planning tool to build a bounded reporting plan grounded in the project contract, the reporting principles, and the available evidence, then execute the plan.

## Invocation Contract

- Preferred daily form: `$imsight-reporting use write-day-log() to prepare the report for <date>`.
- Preferred weekly form: `$imsight-reporting use write-week-report() for <week>`.
- Task-only form: `$imsight-reporting <reporting request>` routes to the matching subcommand with the supplied scope and constraints.
- Bare invocation with no actionable task runs `help()`, explaining the reporting mentality, subcommands, contract precedence, and output defaults.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `write-day-log` | Gather one day's evidence and write a stakeholder-ready daily report | [commands/write-day-log.md](commands/write-day-log.md) |
| `write-week-report` | Synthesize a multi-day period by project-relevant outcomes and write a weekly report | [commands/write-week-report.md](commands/write-week-report.md) |
| `help` | Explain this reporting skill, its mentality principles, and its defaults | This entrypoint |

## Project Report Contract

A project may declare its own report kinds, filenames, title format, body language, section set and order, table conventions, and terminology rules. Discover that contract before drafting so the report fits its series seamlessly. Precedence runs: user instruction for this report, then the project contract, then this skill's defaults.

A project contract owns shape, section order, and style; it never relaxes evidence honesty, scope precision, or secret exclusion. See [references/project-report-contract.md](references/project-report-contract.md).

## Project Scope

Start from repositories explicitly named by the user, or from the current project root plus project-owned submodules, nested repositories, or external checkouts directly relevant to the period's work. Do not scan unrelated repositories elsewhere on the host. When inspecting an external or orphan checkout whose latest commit predates the reporting cutoff, check whether it needs syncing or note the exact revision boundary covered.

## Output Contract

Follow the language, length, and layout requested by the user, then the project contract. When neither declares a structure, return a concise English report with a dated heading and compact outcome paragraphs (typically three dominant outcomes).

Return the report in chat unless the user asks to save it. When saving to disk, resolve the path in this order:

1. Exact file or directory supplied by the user.
2. Filename and directory pattern declared by the project contract.
3. `$IMSIGHT_SKILL_OUTPUT_DIR/daylog/<artifact-name>` when that variable is set.
4. `<project-dir>/tmp/daylog/<artifact-name>` by default.

Default filenames are `YYYY-MM-DD.md` for daily reports and `YYYY-Www.md` for weekly reports (ISO week of the period's start) unless the project contract specifies another pattern. Read an existing report before revising it so accurate manual content is preserved.

## Guardrails

- DO NOT report routine developer hygiene—unit tests, test counts, lint, typecheck, docs builds, spec validation, or internal code-debt scores—as management progress unless the user explicitly asks for an engineering audit.
- DO NOT present a commit-by-commit inventory, file list, or concatenation of daily reports as the report.
- DO NOT claim completion, validation, or higher-level research goals from proposals, draft files, or low-level building blocks alone.
- DO NOT expose repository paths, function names, commit hashes, issue IDs, credentials, private endpoints, or personal data in external-facing report prose unless requested.
- DO NOT ignore a project report contract's declared section order, body language, or terminology, and do not let a contract weaken evidence honesty or secret exclusion.
