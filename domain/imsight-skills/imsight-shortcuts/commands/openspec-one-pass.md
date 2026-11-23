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

# OpenSpec One-Pass

## Workflow

1. Resolve the development request, target workspace, user constraints, and any requested execution mode.
2. Load [Imsight Project Automation](../../imsight-project-automation/SKILL.md) and invoke [`imsight-project-automation->openspec-one-pass()`](../../imsight-project-automation/commands/openspec-one-pass.md) with those inputs. Use its execution modes and stage boundaries.
3. Return the workflow's result. At an interactive pause or blocker, report the stage reached and follow the workflow's continuation rules.

For requests outside the one-pass lifecycle, use the native planning tool to plan and execute the applicable project automation commands within the requested scope.
