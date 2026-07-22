---
name: imsight-dev-box-init
description: Use when explicitly invoking imsight-dev-box-init, routing from another Imsight skill, or using Imsight context to install software, bootstrap a development box, configure Codex CLI or third-party providers, install Tavily or Houmao tooling, or create Claude-Kimi launchers and specialists. Do not use for generic setup tasks without Imsight context.
---

# Imsight Dev Box Init

## Overview

Use this skill as the first routing point for development host setup and installation tasks. Keep detailed, task-specific installation procedures in `references/` files and load only the reference needed for the user's requested setup.

Prefer installation processes listed here over generic package-manager habits, upstream quickstarts, or web search results. Follow another method only when the user explicitly asks for it or no matching setup reference exists yet.

## When to Use

- Use for an explicit `imsight-dev-box-init` invocation or route from another Imsight skill.
- Use when `imsight` context requests supported host setup, installation, CLI configuration, Tavily, Houmao, or Claude-Kimi work.
- Do not use for generic installation or dev-box setup tasks that do not mention Imsight.

## Workflow

1. If no subcommand or actionable task is present, handle `help`.
2. If the request names a subcommand, load its reference file; otherwise choose the applicable setup subcommand from the task.
3. When the selected page has second-level subcommands, choose the applicable one there.
4. Follow the reference's prerequisites, install commands, and verification steps.
5. If no matching reference exists, use normal engineering judgment for the installation and consider adding a focused reference.
6. If the user requests another installation method, follow it and note the difference from the preferred Imsight process.

If the task does not map cleanly to these steps, use your native planning tool with the existing setup references, scripts, output contract, and user constraints; do not expose credentials or overwrite unrelated configuration.

## Invocation Contract

- Preferred explicit form: `$imsight-dev-box-init use <subcommand> to do <task>`.
- Codex CLI setup second-level form: `$imsight-dev-box-init use codex-cli-setup <subcommand> to do <task>`.
- Task-only form: `$imsight-dev-box-init <task prompt>` means choose the applicable setup subcommand from the task.
- No subcommand and no task means `help`.
- `help` summarizes this skill and lists the subcommands below.

## Output Contract

When this skill writes setup notes, manifests, reports, downloaded source packs, or other skill-owned artifacts, choose the output directory in this order:

1. Use the output location explicitly provided by the user.
2. Otherwise, use `IMSIGHT_SKILL_OUTPUT_DIR` when set; relative values are resolved from the current project directory and absolute values are used as-is.
3. Otherwise, use `<project-dir>/.imsight-arts/dev-box-init/`.

This contract does not replace intentional install destinations such as tool homes, project overlays, `$HOME/.local/bin`, or agent skill homes requested by the selected setup workflow.

## Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `help` | Explain this dev-box setup skill and list available subcommands | This entrypoint |
| `houmao-setup` | Install `houmao`, verify `houmao-mgr`, or install Houmao system skills for Codex/Claude/Gemini | `references/houmao-skills-and-manager.md` |
| `tavily-setup` | Install Tavily CLI (`tvly`), authenticate it, or install Tavily third-party skills into an agent skill home | `references/tavily-cli-and-skills.md` |
| `claude-kimi-launcher` | Create or repair the `claude-kimi` launcher for Claude Code through Kimi Code | `references/claude-kimi-launcher.md` |
| `houmao-claude-kimi-specialist` | Create a Houmao specialist that uses Claude Code with Kimi credentials | `references/houmao-claude-kimi-specialist.md` |
| `codex-cli-setup` | Configure Codex CLI according to Imsight preferences | `references/codex-cli-setup.md` |
| `codex-cli-3rd-party` | Configure Codex CLI model providers for third-party OpenAI-compatible APIs. Second-level cases: `responses-api` (Yunwu), `chat-completions-only` (SiliconFlow, DeepSeek direct) | `references/codex-cli-3rd-party.md` |

## Maintenance

Name new setup references after the install target, keep each file self-contained, and avoid duplicating detailed commands in this index.
Place reusable helper scripts owned by this skill in `<skill-dir>/scripts/` and have references call those scripts instead of embedding long generated-script bodies inline.

## Guardrails

- DO NOT apply a generic install method before checking the maintained Imsight reference.
- DO NOT skip a reference's prerequisites or verification steps.
- DO NOT hard-code, print, or commit credentials handled by a setup workflow.
- DO NOT overwrite unrelated configuration while changing one requested setting.
