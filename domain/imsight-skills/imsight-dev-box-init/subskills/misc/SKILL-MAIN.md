---
name: misc
description: Use when an Imsight dev-box task installs supported utilities or agent skills outside the coding-agent and Houmao domains, currently Ponytail, Tavily CLI and skills, Context7 CLI and its agent skill, or BaiduPCS-Go Netdisk CLI.
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

# Miscellaneous Dev-Box Utilities

## Overview

Use this subskill for maintained Imsight utility and agent-skill setup that does not belong to the coding-agent or Houmao resource domains.

## Workflow

1. Select the applicable utility command from **Subcommands**.
2. Load its linked reference and resolve the target agent and installation scope.
3. Follow the reference's prerequisites, credential rules, and verification steps.
4. Report installed commands, skills, and any remaining authentication action.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this subskill's commands, resources, constraints, and user request, then execute the plan.

## Invocation Contract

- Invoke `imsight-dev-box-init->misc` to summarize this subskill.
- Invoke a command as `imsight-dev-box-init->misc-><subcommand>()`.
- Invoke `imsight-dev-box-init->misc->help()` to list the commands below.

## Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `install-ponytail` | Install Ponytail skills only by default, or install the full Claude Code or Codex plugin with hooks when explicitly requested. | `references/install-ponytail.md` |
| `tavily-setup` | Install and authenticate Tavily CLI or install Tavily agent skills. | `references/tavily-cli-and-skills.md` |
| `context7-setup` | Install Context7 CLI and its agent skill without configuring Context7 MCP. | `references/context7-cli-setup.md` |
| `baidupcs-go-setup` | Install and configure BaiduPCS-Go, build static binary, and perform headless QR authentication with Playwright. | `references/baidupcs-go-setup.md` |
| `help` | Explain this subskill and list its commands. | This entrypoint |

## Resource Ownership

This subskill owns the Ponytail, Tavily, Context7, and BaiduPCS-Go references plus Tavily skill installation/verification scripts and the BaiduPCS-Go Playwright login helper script.

## Guardrails

- DO NOT expose API keys during utility authentication.
- DO NOT install utilities or skills into an unrequested scope.
- DO NOT install Ponytail hooks when the user requests or accepts the default skill-only mode.
- DO NOT configure Context7 MCP when the requested route is the maintained CLI integration.
