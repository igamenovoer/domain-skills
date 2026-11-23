---
name: shortcuts
description: Use when an Imsight mentality shortcut is requested for an explanation of a topic or the previous reply using Han Style or a named mentality.
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

# Shortcuts

## Workflow

1. Select a shortcut from **Subcommands**. A bare invocation with no task shows the list.
2. Load the selected command and follow its workflow.

For other requests, use your native planning tool to build and execute a step-by-step plan using the available shortcuts and their scope.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `revelio` | Explain a supplied subject or the previous reply using Han Style by default. | [Revelio](commands/revelio.md) |

## Maintenance

Choose distinctive command names that help agents route requests to the intended shortcut. Prefer a Harry Potter spell name when its meaning fits the action.

## Guardrails

- DO NOT persist a shortcut's mentality selection.
