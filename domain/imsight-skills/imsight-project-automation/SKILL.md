---
name: imsight-project-automation
description: Use when the user explicitly invokes imsight-project-automation or requests one of its maintained project routines, including an OpenSpec lifecycle in one pass or user-directed testing followed by minimal bug fixes through OpenSpec.
---

# Imsight Project Automation

## Overview

This skill is an entrypoint for focused project-automation routines. Keep `SKILL.md` small; reusable behavior belongs in subcommand pages.

## When to Use

Use this skill only when explicitly invoked by name or when the request clearly targets a maintained automation routine, such as:

- a request to run OpenSpec explore, propose, apply, sync, and archive in one pass,
- a request to execute user-provided test cases, collect unexpected outcomes, and fix confirmed product bugs through OpenSpec,
- explicit mention of `imsight-project-automation` or one of its subcommands,
- a routed command or message that names this skill as the handler.

Do not activate it implicitly for ordinary development tasks that do not name `imsight-project-automation` or one of its maintained operations.

## Workflow

1. Read the request and identify the requested subcommand.
2. If no subcommand or actionable task is present, handle `help`.
3. For a task-only request, choose the applicable subcommand.
4. For `openspec-one-pass`, load `commands/openspec-one-pass.md`.
5. For `openspec-test-and-fix`, load `commands/openspec-test-and-fix.md`.
6. Ask for the smallest clarification when the subcommand or request body is ambiguous.
7. Do not invent additional stages; add a command page when a new automation routine becomes reusable.

If the task does not map cleanly to these steps, use your native planning tool only with the existing subcommands and constraints; report when no maintained routine matches.

## Invocation Contract

- Preferred explicit form: `$imsight-project-automation use <subcommand> to do <task>`.
- Task-only form: `$imsight-project-automation <task prompt>` means choose the applicable subcommand from the task.
- No subcommand and no task means `help`.
- `help` summarizes this skill and lists the subcommands below.

## Output Contract

When this skill writes skill-owned auxiliary artifacts, choose the output directory in this order:

1. Use the output location explicitly provided by the user or request.
2. Otherwise, use `IMSIGHT_PROJECT_AUTOMATION_OUTPUT_DIR` when set; relative values are resolved from the current project directory and absolute values are used as-is.
3. Otherwise, use `<project-dir>/.imsight-arts/project-automation/`.

This contract does not relocate OpenSpec changes, implementation edits, or initialized `openspec/` trees; those stay in the target workdir required by the selected OpenSpec workflow.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `help` | Explain this skill and list public subcommands | This entrypoint |
| `openspec-one-pass` | Given one development request, run an OpenSpec lifecycle in one pass: explore, propose, apply, sync, and archive. | [commands/openspec-one-pass.md](commands/openspec-one-pass.md) |
| `openspec-test-and-fix` | Run user-provided tests, document unexpected outcomes, make minimal continuation patches, then propose and apply confirmed bug fixes through OpenSpec. | [commands/openspec-test-and-fix.md](commands/openspec-test-and-fix.md) |

## Guardrails

- DO NOT route ordinary ad-hoc tasks through this skill.
- DO NOT skip the subcommand page and inline a complex automation workflow in `SKILL.md`.
- DO NOT invent unsupported subcommands that are not backed by a subskill page.
- DO NOT treat discovery-time continuation patches as a substitute for the required OpenSpec proposal and apply stages.
