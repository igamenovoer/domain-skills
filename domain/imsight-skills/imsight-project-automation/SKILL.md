---
name: imsight-project-automation
description: Use when the user explicitly invokes imsight-project-automation or requests a maintained routine for adding subtask-plan tracking guidance to OpenSpec tasks, running an OpenSpec lifecycle in one pass, or testing followed by minimal OpenSpec bug fixes.
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

# Imsight Project Automation

## Overview

This skill is an entrypoint for focused project-automation routines. Keep `SKILL.md` small; reusable behavior belongs in subcommand pages.

## When to Use

Use this skill only when explicitly invoked by name or when the request clearly targets a maintained automation routine, such as:

- a request to run OpenSpec explore, propose, apply, sync, and archive in one pass,
- a request to execute user-provided test cases, collect unexpected outcomes, and fix confirmed product bugs through OpenSpec,
- a request to add subtask-plan progress tracking guidance to an OpenSpec change's `tasks.md`,
- explicit mention of `imsight-project-automation` or one of its subcommands,
- a routed command or message that names this skill as the handler.

Do not activate it implicitly for ordinary development tasks that do not name `imsight-project-automation` or one of its maintained operations.

## Workflow

1. Read the request and identify the requested subcommand.
2. If no subcommand or actionable task is present, handle `help`.
3. For a task-only request, choose the applicable subcommand.
4. For `openspec-subtask-planning`, load `commands/openspec-subtask-planning.md`.
5. For `openspec-one-pass`, load `commands/openspec-one-pass.md`.
6. For `openspec-test-and-fix`, load `commands/openspec-test-and-fix.md`.
7. Ask for the smallest clarification when the subcommand or request body is ambiguous.
8. Do not invent additional stages; add a command page when a new automation routine becomes reusable.

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
| `openspec-subtask-planning` | Add a concise reminder to an OpenSpec `tasks.md` requiring task-specific plan documents for progress tracking, with optional subagent planning when requested. | [commands/openspec-subtask-planning.md](commands/openspec-subtask-planning.md) |
| `openspec-one-pass` | Given one development request, run an OpenSpec lifecycle in one pass: explore, propose, apply, sync, and archive. | [commands/openspec-one-pass.md](commands/openspec-one-pass.md) |
| `openspec-test-and-fix` | Run user-provided tests, document unexpected outcomes, make minimal continuation patches, then propose and apply confirmed bug fixes through OpenSpec. | [commands/openspec-test-and-fix.md](commands/openspec-test-and-fix.md) |

## Guardrails

- DO NOT route ordinary ad-hoc tasks through this skill.
- DO NOT skip the subcommand page and inline a complex automation workflow in `SKILL.md`.
- DO NOT invent unsupported subcommands that are not backed by a command page.
- DO NOT treat discovery-time continuation patches as a substitute for the required OpenSpec proposal and apply stages.
