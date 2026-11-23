---
name: imsight-shortcuts
description: Use when the user invokes imsight-shortcuts or requests a maintained shortcut such as elighten-me, graph-it for ASCII diagrams, or a local OpenSpec one-pass run.
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

# Imsight Shortcuts

Use shortcuts for chat explanations and workflows that combine Imsight skills, subskills, and subcommands.

## Workflow

1. Select a shortcut from **Subcommands**. Bare invocation and `help` show the list. For a task-only invocation, choose the shortcut whose purpose matches the task.
2. Read the selected command page. Resolve its inputs and locate the skills it uses through the available skill inventory or the linked entrypoints in the Imsight suite.
3. Execute the declared steps in order. Pass results between steps as specified and follow each called skill's scope and approval requirements. If a required route is unavailable, name it and stop the steps that depend on it.

For other requests, use the native planning tool to build and execute a plan from the applicable listed commands and their constraints. If none applies, show the available shortcuts.

## Invocation

Invoke a command directly, such as `imsight-shortcuts->openspec-one-pass()` with a development request, or use `$imsight-shortcuts use <subcommand>` with the command's inputs.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `help` | List the available shortcuts and what they do. | This entrypoint |
| `elighten-me` | Explain a supplied subject or the previous substantive reply using a selected mentality. | [Elighten Me](commands/elighten-me.md) |
| `graph-it` | Explain a supplied subject or the previous substantive reply with ASCII diagrams. | [Graph It](commands/graph-it.md) |
| `openspec-one-pass` | Run a development request through the OpenSpec lifecycle in the target workspace. | [OpenSpec One-Pass](commands/openspec-one-pass.md) |

## Maintenance

Give each shortcut a distinctive name and a page under `commands/`. Specify the inputs and defaults, fully qualified routes, step order, and what each step passes to the next or returns to the user. Link to the owning skill for its procedure.

## Guardrails

- DO NOT run an unlisted shortcut.
- DO NOT use a shortcut to expand the user's authorization or bypass a called command's requirements.
