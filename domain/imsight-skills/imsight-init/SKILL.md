---
name: imsight-init
description: Use when an agent must recover or verify Imsight skill discovery because its harness omitted sibling imsight-* skills, reported an incomplete skill inventory, or exposed this bootstrap skill as the only reliable Imsight entrypoint. Do not use for installing, updating, or removing skills.
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

# Imsight Init

## Overview

Use this bootstrap skill to recover awareness of Imsight skills that already exist beside it but were omitted from an agent harness's inventory. Its scripts report valid sibling skill entrypoints without installing, loading, or modifying them.

## When to Use

Use this skill when the visible skill inventory appears incomplete, an Imsight skill requested by the user is missing from harness-provided discovery, or a host exposes `imsight-init` as a fallback bootstrap entrypoint.

Do not use it to install or update skills, recursively inspect bundled subskills, or replace normal harness discovery when the harness inventory is complete.

## Workflow

1. Select the bundled script for the current shell under **Execution**.
2. Run the script by its path inside this skill; do not assume a working directory.
3. Read the emitted sibling skill names and absolute `SKILL.md` paths according to **Awareness Contract**.
4. Inspect only the YAML `name` and `description` frontmatter from each listed entrypoint to recover routing awareness.
5. When the user invokes a discovered skill or the current task matches its description, read that `SKILL.md` completely and follow it normally.
6. Report the recovered inventory or the script's explicit no-siblings failure.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the bundled scripts, awareness contract, and user request, then execute the plan.

## Execution

For Bash or another POSIX environment with Bash available:

```bash
bash <imsight-init-dir>/scripts/imsight-init.sh
```

For PowerShell:

```powershell
& "<imsight-init-dir>/scripts/imsight-init.ps1"
```

Both scripts locate their own `scripts/` directory, derive the containing skill and its parent, and inspect only direct sibling directories named `imsight-*` that contain `SKILL.md`. The current `imsight-init` directory is excluded.

## Awareness Contract

Successful output contains the absolute sibling root, one deterministic name-and-entrypoint line per discovered skill, and an agent instruction explaining how to rebuild routing awareness from entrypoint frontmatter. Discovery makes those entrypoints available for routing in the current context; it does not invoke every skill or prove that the harness has persisted them.

The scripts exit successfully when at least one valid sibling is found. They write a clear error and exit nonzero when the expected sibling root is unavailable or contains no other valid Imsight skill entrypoints.

## Guardrails

- DO NOT treat discovery output as proof that skills were installed or registered persistently.
- DO NOT invoke or fully load every listed skill merely because it was discovered.
- DO NOT search beyond the direct sibling directory unless the user explicitly expands the scope.
- DO NOT modify discovered skill directories while building the recovery inventory.
