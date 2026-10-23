---
name: kimi-code-subagents
description: Use when a project needs Kimi Code CLI subagent definitions — model-agnostic Markdown agent files under `.kimi-code/agents/` with role, tool allowlist, and output contract, optionally starting from the bundled default-coder, expert-coder, default-planner, and default-reviewer templates. Definitions never pin models; after creating them, suggest the user bind models through their Kimi `AGENTS.md` instruction file.
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

# Kimi Code Subagent Definitions

## Overview

Equip a Kimi Code CLI project with custom subagents: one Markdown agent file per subagent under an agent discovery directory. The durable product is the definition itself — role, tool boundary, and output contract. Model binding is deliberately not part of this skill: an agent file cannot pin its own model, and choosing aliases or editing configuration is the user's decision. After the definitions exist, suggest how the user can bind them by adding a routing table to `$KIMI_CODE_HOME/AGENTS.md`.

Field-level mechanics — frontmatter fields, discovery order, and validation — are specified in `references/kimi-code-subagent-mechanics.md`. The model-binding handoff format and the minimal resolution facts are specified in `references/kimi-code-subagent-model-mapping.md`. Consult both instead of relying on memory.

## When to Use

- Use when the user or parent skill asks to create, add, or port Kimi Code subagent definitions in a project, including recreating the bundled default-coder, expert-coder, default-planner, and default-reviewer roster.
- Use when an existing Kimi Code subagent roster needs a new member or a role, tool-boundary, or output-contract update.
- Do not use for other agent runtimes (their definition formats differ), for runtime delegation decisions in an ordinary coding session, or for Kimi Code product questions unrelated to subagent definitions.
- Do not use this skill to choose model aliases, register models, or bind subagents to models; that is a separate user decision.

## Workflow

When this subskill is invoked, execute the following steps in order.

1. **Confirm routing**. Continue only when the user explicitly invoked `imsight-project-subagents->kimi-code-subagents` or the parent skill routed the operation here.
2. **Resolve the project root and scope**. Use the user-provided project directory, or the current repository root when the task clearly targets it. Project-scoped definitions go under `<project-root>/.kimi-code/agents/`; user-level definitions go under `~/.kimi-code/agents/` (see **Agent Locations** in the mechanics reference). Default to project scope unless the user asks otherwise.
3. **Choose the definitions to create**. See **Bundled Agent Templates** and adapt them, or author new definitions from the user's description. Never copy a template verbatim into a project without adapting project-specific details (toolchain commands, scratch paths, placement rules) to the target project's actual conventions.
4. **Write each agent file**. One `<kebab-name>.md` per subagent: YAML frontmatter (`name`, `description`, optional `whenToUse`, `tools`/`disallowedTools`, `subagents`) plus a Markdown body that is the subagent's system prompt. Quote frontmatter scalars that contain a colon followed by a space. State in the body that the final message is the complete, self-contained handoff to the caller. Keep the definition model-agnostic: do not name a model alias or thinking effort in the frontmatter or body. See **Agent File Format** in the mechanics reference.
5. **Hand off model binding; do not perform it**. After the definitions are written, prepare a suggested routing table for the user to add to `$KIMI_CODE_HOME/AGENTS.md`. Map each custom subagent type to a placeholder or to an alias the user names; do not choose aliases, do not edit `config.toml`, and do not write the `AGENTS.md` file unless the user explicitly asks. See `references/kimi-code-subagent-model-mapping.md` for the handoff format and the resolution facts to explain.
6. **Validate**. Parse every new agent file's frontmatter as YAML; confirm each `name` is kebab-case and matches its file name, the `description` is present, and every `tools`/`disallowedTools` entry names a real built-in tool or a well-formed `mcp__<server>__*` glob. Confirm the definitions contain no model alias or effort claims. If the user supplied aliases for the suggested routing table, confirm each alias resolves to a configured `[models]` entry. A fresh session's `Agent`-tool catalog listing is the reliable runtime confirmation; a running session may keep a stale catalog, so verify in a fresh session when it matters.
7. **Report the result**. List the definitions written, the validation result, and the suggested `$KIMI_CODE_HOME/AGENTS.md` location with the routing-table snippet. State explicitly that no model binding was applied and that the user owns the alias choice.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the constraints in this subskill and the two references, then execute the plan.

## Invocation Contract

- Preferred explicit form: invoke skill `imsight-project-subagents->kimi-code-subagents` with the target project and the requested roster or definition change.
- No actionable task means `help`, which summarizes this subskill and its bundled templates.

## Bundled Agent Templates

`assets/agents/` holds an example four-agent roster from one project (synced 2026-10-23); it is illustrative, not a prescribed roster. Each file is a complete, model-agnostic Kimi Code agent definition with its role, tool boundary, and output contract. No template names or assumes a model; binding is the user's decision.

| Template | Role |
| --- | --- |
| `default-coder.md` | Default coding work: features, fixes, refactors, tests, glue, and maintenance; the first choice for coding tasks, with a suggested escalation to `expert-coder` after repeated failure |
| `expert-coder.md` | Escalation for hard problems that `default-coder` has repeatedly failed to solve; diagnoses prior failures, fixes the root cause, and verifies the failing scenario |
| `default-planner.md` | Read-only planning: states known facts, open questions for explore, and a verifiable implementation plan |
| `default-reviewer.md` | Default reviewer: bug finding by source inspection, correctness, and architectural review; read-only except for throwaway reproduction scripts under a git-ignored `tmp/` tree |

Adaptation duties when instantiating a template in a new project: replace project-specific check commands and directory conventions with the target project's own, and keep the roster's division of labor consistent — the templates reference each other by name in their routing hints, so rename all references together. Do not add model aliases or effort claims to the definitions; after adapting them, suggest the user's model routing in `$KIMI_CODE_HOME/AGENTS.md`.

## Guardrails

- DO NOT choose or assign specific model aliases, model IDs, or thinking efforts for the user's subagents.
- DO NOT edit `config.toml` or add `[secondary_model]` entries to bind models; that is the user's decision.
- DO NOT write `$KIMI_CODE_HOME/AGENTS.md` unless the user explicitly asks; suggest the routing table instead.
- DO NOT add a `model` field to agent frontmatter expecting it to take effect; Kimi Code ignores it.
- DO NOT invent config keys, frontmatter fields, or tool names; everything this subskill writes must trace to `references/kimi-code-subagent-mechanics.md`, `references/kimi-code-subagent-model-mapping.md`, or the project's existing files.
- DO NOT overwrite existing agent files; merge new definitions into the existing `.kimi-code/agents/` roster.
- DO NOT leave a frontmatter scalar unquoted when it contains `: `; the file is silently skipped on discovery.
- DO NOT copy bundled templates into a project verbatim; adapt toolchain commands, paths, and conventions to the target project first.

## Troubleshooting Guide

- A new agent file never appears in the subagent catalog.
  - If the CLI logs a skipped-file warning, then validate the frontmatter YAML — most often an unquoted scalar containing a colon followed by a space, or a non-kebab-case `name`.
  - If the file parses but stays invisible, then confirm it sits in a discovered directory (`.kimi-code/agents/`, `.agents/agents/`, or a configured `extra_agent_dirs` entry) under the effective `KIMI_CODE_HOME`.
- A dispatched subagent runs on the wrong model.
  - This skill does not bind models. Check the routing entry the user added to `$KIMI_CODE_HOME/AGENTS.md`; if the `model` argument is omitted, Kimi falls back to `[secondary_model] default_model`.
  - If an explicit alias was rejected, confirm the alias is listed in `[secondary_model.models]`; the parameter accepts only pool aliases and `primary`.
- A subagent binds an unexpected thinking effort.
  - Check the bound model entry's `default_effort` and any section-wide `[secondary_model] default_effort` in the user's configuration; the skill does not choose effort.

## Maintenance

Keep this entrypoint as the procedure and roster catalog. Keep runtime mechanics in `references/kimi-code-subagent-mechanics.md`, the model-binding handoff in `references/kimi-code-subagent-model-mapping.md`, and reusable definitions in `assets/agents/`; when the roster templates change, update the **Bundled Agent Templates** table in the same edit.
