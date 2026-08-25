---
name: houmao-system
description: Use when an Imsight dev-box task installs Houmao, manages Houmao system skills, or creates a Houmao specialist that launches Claude Code with Kimi credentials.
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

# Houmao System Setup

## Overview

Use this subskill for Houmao installation, system-skill management, and maintained specialist setup.

## Workflow

1. Select the applicable command from **Subcommands**.
2. Load its linked reference and resolve the requested Houmao target.
3. Follow the reference's prerequisites, approval boundaries, and verification steps.
4. Report the resulting Houmao installation or specialist state.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this subskill's commands, resources, constraints, and user request, then execute the plan.

## Invocation Contract

- Invoke `imsight-dev-box-init->houmao-system` to summarize this subskill.
- Invoke a command as `imsight-dev-box-init->houmao-system-><subcommand>()`.
- Invoke `imsight-dev-box-init->houmao-system->help()` to list the commands below.

## Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `houmao-setup` | Install Houmao, verify `houmao-mgr`, or install Houmao system skills. | `references/houmao-skills-and-manager.md` |
| `houmao-claude-kimi-specialist` | Create a Houmao specialist that launches Claude Code with Kimi credentials. | `references/houmao-claude-kimi-specialist.md` |
| `help` | Explain this subskill and list its commands. | This entrypoint |

## Resource Ownership

This subskill owns Houmao installation and specialist procedures. It may load coding-agent Kimi guidance when a specialist needs the shared provider model and credential rules.

## Guardrails

- DO NOT overwrite an existing Houmao specialist without explicit authorization.
- DO NOT print or persist credentials outside the selected Houmao credential mechanism.
- DO NOT change unrelated project-overlay state.
