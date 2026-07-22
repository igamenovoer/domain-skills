---
name: imsight-autodev-slave
description: Use when a human request, gateway message, mailbox notification, direct command, Imsight route, or relevant Imsight context explicitly names imsight-autodev-slave for maintained Houmao slave operations such as init-openspec or the one-pass OpenSpec lifecycle. Do not use implicitly for ordinary development tasks.
---

# Imsight Autodev Slave

## Overview

This skill receives a master's request, selects the matching maintained slave operation, and processes the request through that operation. Keep reusable behavior in command pages.

## When to Use

- Use only when explicitly invoked by a human/operator or master agent.
- Accept `$imsight-autodev-slave ...` for Codex and `/imsight-autodev-slave ...` for Claude.
- Use when a named maintained operation is delivered through a prompt, gateway, mailbox, direct command, Imsight route, or relevant `imsight` context.
- Do not activate implicitly for ordinary development tasks that do not name this skill or one of its maintained operations.

## Workflow

1. Read the master's request, preserve its task semantics and constraints, and identify the requested slave subcommand.
2. If no subcommand or actionable task is present, handle `help`.
3. If the request is task-only, choose the applicable subcommand from the task.
4. Load `commands/openspec-one-pass.md` for `openspec-one-pass` or `commands/init-openspec.md` for `init-openspec`.
5. If the subcommand or required request body is ambiguous, ask for the smallest clarification needed.
6. Do not invent additional stages; add a command page when a new slave operation becomes reusable.

If the task does not map cleanly to these steps, use your native planning tool only to select and execute the existing maintained operations under their current constraints; otherwise report that no maintained operation matches.

## Invocation Contract

- Preferred explicit form: `$imsight-autodev-slave use <subcommand> to do <task>`.
- Task-only form: `$imsight-autodev-slave <task prompt>` means choose the applicable subcommand from the task.
- No subcommand and no task means `help`.
- `help` summarizes this skill and lists the subcommands below.

## Output Contract

When this skill writes slave-side notes, reports, manifests, or other skill-owned auxiliary artifacts, choose the output directory in this order:

1. Use the output location explicitly provided by the user or master request.
2. Otherwise, use `IMSIGHT_SKILL_OUTPUT_DIR` when set; relative values are resolved from the current project directory and absolute values are used as-is.
3. Otherwise, use `<project-dir>/.imsight-arts/autodev-slave/`.

This contract does not relocate OpenSpec changes, implementation edits, or initialized `openspec/` trees; those stay in the target workdir required by the selected OpenSpec workflow.

## Workspace and Failure Handling

Keep implementation, verification, sync, and archiving inside the current repository or an explicitly provided workspace. If a required OpenSpec skill is unavailable, an OpenSpec command fails, or the repository lacks the expected OpenSpec structure, stop and report the failure and the affected operation clearly.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `help` | Explain this slave request-processing skill and list available subcommands | This entrypoint |
| `openspec-one-pass` | Run explore, propose, apply, sync, and archive for one master request | `commands/openspec-one-pass.md` |
| `init-openspec` | Initialize `openspec/` in the slave's target workdir when missing | `commands/init-openspec.md` |

## Guardrails

- DO NOT activate the skill without an explicit named operation.
- DO NOT continue after a required OpenSpec skill is unavailable, an OpenSpec command fails, or the repository lacks the expected OpenSpec structure.
