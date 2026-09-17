---
name: coding-agent
description: Use when an Imsight dev-box task configures Codex CLI, third-party Codex providers, Claude Code launchers for Kimi, GAC, or OpenLux, Antigravity CLI launchers for OpenLux, or Kimi Code CLI multi-credential launchers with an isolated KIMI_CODE_HOME.
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

# Coding Agent Setup

## Overview

Use this subskill for coding-agent configuration owned by Imsight dev-box setup.

## Workflow

1. Select the applicable command from **Subcommands**.
2. Load its linked reference and resolve any nested command there.
3. Follow the reference's prerequisites, configuration procedure, and verification steps.
4. Report the configured agent route and any remaining user action.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this subskill's commands, resources, constraints, and user request, then execute the plan.

## Invocation Contract

- Invoke `imsight-dev-box-init->coding-agent` to summarize this subskill.
- Invoke a command as `imsight-dev-box-init->coding-agent-><subcommand>()`.
- Invoke `imsight-dev-box-init->coding-agent->help()` to list the commands below.

## Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `codex-cli-setup` | Configure Imsight-preferred Codex CLI behavior. | `references/codex-cli-setup.md` |
| `codex-cli-3rd-party` | Configure Codex CLI for third-party OpenAI-compatible APIs. | `references/codex-cli-3rd-party.md` |
| `codex-gac-launcher` | Create or repair `codex-gac` or `codex-gac-<suffix>` with a dedicated GAC profile and embedded key while leaving plain `codex` official. | `references/codex-gac-launcher.md` |
| `codex-openlux-launcher` | Create or repair `codex-openlux` or `codex-openlux-<suffix>` with a dedicated OpenLux profile and embedded key while leaving plain `codex` official. | `references/codex-openlux-launcher.md` |
| `claude-kimi-launcher` | Create or repair `claude-kimi` or `claude-kimi-<suffix>`, including Kimi Coding Plan thinking effort. | `references/claude-kimi-launcher.md` |
| `claude-gac-launcher` | Create or repair `claude-gac` or `claude-gac-<suffix>` with the endpoint and key embedded, without Claude JSON changes. | `references/claude-gac-launcher.md` |
| `claude-openlux-launcher` | Create or repair `claude-openlux` or `claude-openlux-<suffix>`, replacing the retired Yunwu relay. | `references/claude-openlux-launcher.md` |
| `agy-openlux-launcher` | Create or repair a Windows, Linux, or macOS Antigravity launcher named `agy-openlux` or `agy-openlux-<suffix>` that uses OpenLux without changing plain `agy`. | `references/agy-openlux-launcher.md` |
| `kimi-multi-credential` | Create Kimi Code CLI launchers named `kimi-<suffix>`, each with an isolated OAuth credential home and `--auto` startup default unless no-auto mode is explicitly requested. | `references/kimi-multi-credential.md` |
| `help` | Explain this subskill and list its commands. | This entrypoint |

## Resource Ownership

This subskill owns its Codex, Codex-GAC, Codex-OpenLux, Claude-Kimi, Claude-GAC, Claude-OpenLux, Antigravity-OpenLux, and Kimi multi-credential references, the cross-platform Claude-Kimi and Claude-GAC launcher generators, and the Unix Kimi Code credential launcher generator under `scripts/`.

## Custom Launcher Permission Policy

Apply this policy to every custom launcher created or repaired by this subskill, including future agent CLIs:

- Default to the target CLI's most permissive documented execution mode. For the launchers currently covered here, that means `--dangerously-skip-permissions` for Claude Code and Antigravity CLI, `--dangerously-bypass-approvals-and-sandbox` for Codex CLI, and `--auto` for Kimi Code CLI.
- Treat permission prompts, approvals, or sandboxing as an opt-out. Use the less-permissive path only when the user's initial launcher request explicitly rejects the permissive mode. Silence is not an opt-out, and the agent must not ask the user to reconfirm the default.
- When the user opts out at the beginning, use the target launcher generator's permission-prompting option or omit the permissive flag from a hand-written launcher. Preserve that choice when repairing or regenerating the launcher.
- For a future agent CLI, inspect its current help or authoritative documentation and use its strongest supported approval-free or sandbox-bypass launcher option. Do not copy another CLI's flag by name when the target CLI does not support it.
- Report which permission mode the launcher uses. A permissive launcher changes the launched agent's runtime behavior; it does not expand the scope of the setup task or authorize unrelated changes.

## Custom Launcher Naming Policy

- Use the provider-family base name when the user gives no suffix: `codex-gac`, `codex-openlux`, `claude-gac`, `claude-kimi`, `claude-openlux`, or `agy-openlux`.
- When the user gives a suffix, append exactly one hyphen and the suffix: `<base-name>-<suffix>`. Accept lowercase letters, digits, and internal hyphens; ask for a portable replacement when the value contains uppercase letters, spaces, path separators, or shell metacharacters.
- Treat the suffix only as a friendly launcher/profile namespace for distinguishing variants. Do not infer endpoint, account, model, routing, pricing, permission, or credential behavior from its text.
- Use the resolved full launcher name consistently for the executable or function, managed-block marker, and isolated profile namespace. Use a matching credential-file namespace only when the provider guide stores credentials in side files.
- Omit the suffix and separator when the user does not provide one. Do not ask for a suffix merely because the guide supports it.
- Keep `kimi-<suffix>` suffix-required in the Kimi Code multi-credential workflow because the unsuffixed `kimi` name belongs to the upstream CLI; its suffix remains only a user-facing credential/profile label.

## Launcher Guide Authoring Contract

Write and apply custom-launcher guidance principle-first:

1. State the stable runtime contract before showing commands: target agent CLI, provider endpoint and authentication lane, credential placement, environment isolation, permission mode, executable discovery, argument forwarding, and exit-code behavior.
2. Separate durable principles from version-sensitive details such as CLI flags, model names, endpoint quirks, config keys, and install paths. Re-check the installed CLI's version and help plus the provider's current authoritative documentation before implementing those details.
3. Choose an OS-native implementation: Bash or another native shell on Linux/macOS, and PowerShell functions or scripts on Windows. Preserve the caller's environment when an in-process function temporarily changes variables.
4. Present bundled generators, vendor snippets, and inline templates as reference implementations. Use them unchanged only when their recorded assumptions match the current CLI version, provider behavior, OS, and user request; otherwise adapt the implementation while preserving the stated contract.
5. Verify observable behavior rather than merely confirming that a helper script ran: inspect the generated launcher safely, exercise argument forwarding and exit codes, and confirm the active endpoint, auth lane, model discovery, and permission mode.

Do not reduce a launcher guide to “run this script.” The guide must remain usable when the example script, CLI, operating system, or provider API changes.

## Guardrails

- DO NOT expose API keys while configuring a provider or launcher.
- DO NOT overwrite unrelated Codex, Claude Code, or Antigravity settings.
- DO NOT bypass a selected reference's compatibility checks.
- DO NOT silently generate a permission-prompting or sandboxed custom launcher when the initial request did not explicitly opt out of permissive mode.
