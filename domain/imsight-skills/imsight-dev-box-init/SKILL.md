---
name: imsight-dev-box-init
description: Use when explicitly invoking imsight-dev-box-init, routing from another Imsight skill, or using Imsight context to configure coding agents, Houmao systems, Hermes Agent with Kimi, Hindsight, or Feishu, Tavily, Context7, BaiduPCS-Go, or related development-host tooling. Do not use for generic setup tasks without Imsight context.
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

# Imsight Dev Box Init

## Overview

Use this skill as the parent router for Imsight development-host setup. Detailed procedures and their resources are owned by the selected subskill.

## Workflow

1. Select a subskill from **Subskills** based on the requested setup domain.
2. Load the selected subskill's `SKILL-MAIN.md`.
3. Select and execute the applicable subcommand from that subskill.
4. Follow the selected procedure's prerequisites, approval boundaries, and verification steps.
5. Report changed host state, validation results, and any remaining user action.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the available subskills, constraints, and user request, then execute the plan.

## Invocation Contract

- Invoke `imsight-dev-box-init` with no child route to summarize the available subskills.
- Invoke a subskill with a bare object path, such as `imsight-dev-box-init->coding-agent` or `imsight-dev-box-init->misc`.
- Invoke a subskill command with a parenthesized command component, such as `imsight-dev-box-init->misc->baidupcs-go-setup()`.
- Invoke `imsight-dev-box-init->help()` to list the routes below.

## Subskills

| Subskill | When to Route Here | Load |
| --- | --- | --- |
| `coding-agent` | Choose this branch for coding-client configuration that runs through Codex CLI or a Claude Code launcher. | `subskills/coding-agent/SKILL-MAIN.md` |
| `houmao-system` | Choose this branch whenever Houmao owns the installed system skills, project overlay, credentials, or specialist. | `subskills/houmao-system/SKILL-MAIN.md` |
| `hermes-mgr` | Choose this branch for Hermes model routing, Feishu gateway integration and approval callbacks, a Kimi-backed local Hindsight server, persistent memory integration, or memory lifecycle operations. | `subskills/hermes-mgr/SKILL-MAIN.md` |
| `misc` | Choose this branch for standalone search, documentation, and cloud storage utilities, currently Tavily, Context7, and BaiduPCS-Go. | `subskills/misc/SKILL-MAIN.md` |

## Subcommands

| Subcommand | Use For |
| --- | --- |
| `help` | Explain this parent skill and list its subskill routes. |

## Output Contract

When a selected workflow writes setup notes, manifests, reports, downloaded source packs, or other skill-owned artifacts, choose the output directory in this order:

1. Use the output location explicitly provided by the user.
2. Otherwise, use `IMSIGHT_SKILL_OUTPUT_DIR` when set; resolve relative values from the current project directory.
3. Otherwise, use `<project-dir>/.imsight-arts/dev-box-init/`.

This contract does not replace intentional install destinations such as tool homes, project overlays, user-local launchers, or agent skill homes requested by a selected workflow.

## Maintenance

Keep this parent entrypoint as a small router. Place detailed procedures and private resources under their owning subskill.

## Guardrails

- DO NOT apply a generic install method before checking the selected subskill's maintained procedure.
- DO NOT skip a selected procedure's prerequisites or verification steps.
- DO NOT hard-code, print, or commit credentials handled by a setup workflow.
- DO NOT overwrite unrelated configuration while changing one requested setting.
