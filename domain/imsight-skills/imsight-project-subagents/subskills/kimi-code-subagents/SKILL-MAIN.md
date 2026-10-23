---
name: kimi-code-subagents
description: Use when a project needs Kimi Code CLI subagent definitions — Markdown agent files under `.kimi-code/agents/` with tool allowlists, plus `[secondary_model]` pool entries in `config.toml` that pin each subagent to a configured model alias and thinking effort, optionally starting from the bundled default-coder, default-reviewer, and fast-coder templates.
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

Equip a Kimi Code CLI project with custom subagents: one Markdown agent file per subagent under an agent discovery directory, plus model bindings in `config.toml`, because the agent file format carries no effective model field. The durable products are the agent definitions (role, tool boundary, output contract) and the `[secondary_model]` pool entries that let the main agent bind each subagent to a configured model alias and thinking effort at dispatch time. All mechanics — frontmatter fields, discovery order, pool resolution, effort fallback — are specified in `references/kimi-code-subagent-mechanics.md`; consult it instead of relying on memory.

## When to Use

- Use when the user or parent skill asks to create, add, or port Kimi Code subagent definitions in a project, including recreating the bundled coder/reviewer/fast-coder roster.
- Use when an existing Kimi Code subagent roster needs a new member, a model rebinding, or a thinking-effort change.
- Do not use for other agent runtimes (their definition formats differ), for runtime delegation decisions in an ordinary coding session, or for Kimi Code product questions unrelated to subagent definitions.

## Workflow

When this subskill is invoked, execute the following steps in order.

1. **Confirm routing**. Continue only when the user explicitly invoked `imsight-project-subagents->kimi-code-subagents` or the parent skill routed the operation here.
2. **Resolve the project root and scope**. Use the user-provided project directory, or the current repository root when the task clearly targets it. Project-scoped definitions go under `<project-root>/.kimi-code/agents/`; user-level definitions go under `~/.kimi-code/agents/` (see **Agent Locations** in the mechanics reference). Default to project scope unless the user asks otherwise.
3. **Choose the definitions to create**. See **Bundled Agent Templates** and adapt them, or author new definitions from the user's description. Never copy a template verbatim into a project without adapting project-specific details (toolchain commands, scratch paths, placement rules) to the target project's actual conventions.
4. **Write each agent file**. One `<kebab-name>.md` per subagent: YAML frontmatter (`name`, `description`, optional `whenToUse`, `tools`/`disallowedTools`, `subagents`) plus a Markdown body that is the subagent's system prompt. Quote frontmatter scalars that contain a colon followed by a space. State in the body that the final message is the complete, self-contained handoff to the caller. See **Agent File Format** in the mechanics reference.
5. **Bind models through the pool**. Add each needed model alias to `[secondary_model.models]` in the project's `.kimi-code/config.toml` with a selection hint that names the subagent it serves, following the **Thinking-Effort Contract** in the mechanics reference: overrides for managed Kimi models, direct entry fields for user providers, a suffixed derived model for any subagent-specific effort, and no section-wide `default_effort`. When the subagent's model is not yet configured, register it first per **Registering a model for subagent use** in the mechanics reference. Merge into an existing `[secondary_model]` section; never rewrite unrelated config. An agent file cannot pin its own model — the binding happens at dispatch through the pool, so the hint text and the alias named in the agent's `description` are the steering mechanism.
6. **Validate**. Parse `config.toml` as TOML and every new agent file's frontmatter as YAML; confirm each `name` is kebab-case and matches its file name, every pool alias resolves to a configured `[models]` entry, and `default_model` is a pool key when a `models` table exists. A running Kimi Code session hot-reloads both files; treat a change notification or fresh `Agent`-tool catalog listing as runtime confirmation.
7. **Report the result**. List the definitions written, the config changes made, the validation result, and the exact dispatch form, for example `Agent(subagent_type="default-reviewer", model="openlux-gpt/gpt-6-astra", prompt="...")`.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the constraints in this subskill and the mechanics reference, then execute the plan.

## Invocation Contract

- Preferred explicit form: invoke skill `imsight-project-subagents->kimi-code-subagents` with the target project and the requested roster or definition change.
- No actionable task means `help`, which summarizes this subskill and its bundled templates.

## Bundled Agent Templates

`assets/agents/` holds a proven four-agent roster from a real project (synced 2026-10-23). Each file is a complete Kimi Code agent definition with its own tool boundary and output contract, and each `description` names the exact model alias and thinking effort it expects.

| Template | Role | Model binding it expects |
| --- | --- | --- |
| `default-coder.md` | Repo-tracked product code that must be well-maintained: features, fixes, refactors in source and test trees, with the project's real quality gates run before reporting done | `kimi-code/k3-256k` pinned to `max` through model overrides (managed entry ships `high`) |
| `default-reviewer.md` | Default reviewer: bug finding by source inspection, correctness, and architectural review; read-only except for throwaway reproduction scripts under a git-ignored `tmp/` tree, monkeypatching preferred over touching source | `openlux-gpt/gpt-6-astra-max`, a suffixed derived entry at `max` |
| `default-planner.md` | Default planner: implementation planning and architectural decisions; read-only, returns a self-contained plan with decisions, ordered verifiable steps, risks, and verification approach | `openlux-gpt/gpt-6-astra` at its entry default `xhigh` |
| `fast-coder.md` | Easy, well-scoped work: CRUD, glue code, environment management, repo scans, running experiments, summarizing results; full tool access, minimal scoped changes | `deepseek/deepseek-flash` with `default_effort = "max"` set directly in its user-provider entry |

Adaptation duties when instantiating a template in a new project: replace the model bindings with aliases configured in that project's `config.toml` (re-resolving the model facts rather than trusting the ones named here), replace project-specific check commands and directory conventions with the target project's own, and keep the roster's division of labor consistent — the four templates reference each other by name in their routing hints, so rename all references together.

## Guardrails

- DO NOT invent config keys, frontmatter fields, or model IDs; everything this subskill writes must trace to `references/kimi-code-subagent-mechanics.md` or the project's existing `config.toml`.
- DO NOT present concrete model ids, context windows, effort levels, or observed CLI behaviors from this subskill's examples as current; they are dated observations — re-resolve them against the live provider catalog and current Kimi Code documentation.
- DO NOT add a `model` field to agent frontmatter expecting it to take effect; Kimi Code ignores it — bind models through the `[secondary_model]` pool instead.
- DO NOT overwrite existing agent files or rewrite unrelated `config.toml` sections; merge pool entries into the existing `[secondary_model]` table.
- DO NOT leave a frontmatter scalar unquoted when it contains `: `; the file is silently skipped on discovery.
- DO NOT copy bundled templates into a project verbatim; adapt toolchain commands, paths, and conventions to the target project first.

## Troubleshooting Guide

- A new agent file never appears in the subagent catalog.
  - If the CLI logs a skipped-file warning, then validate the frontmatter YAML — most often an unquoted scalar containing a colon followed by a space, or a non-kebab-case `name`.
  - If the file parses but stays invisible, then confirm it sits in a discovered directory (`.kimi-code/agents/`, `.agents/agents/`, or a configured `extra_agent_dirs` entry) under the effective `KIMI_CODE_HOME`.
- A dispatched subagent runs on the wrong model.
  - If the `model` parameter was omitted, then check `[secondary_model] default_model`; subagents inherit the pool default, not the agent file's intent.
  - If an explicit alias was rejected, then confirm the alias is listed in `[secondary_model.models]`; the parameter accepts only pool aliases and `primary`.
- A subagent binds an unexpected thinking effort.
  - If every spawn binds one effort regardless of model, then check the section-wide `[secondary_model] default_effort`, which outranks each model entry's own default; use per-model variant entries when different pool entries need different efforts.

## Maintenance

Keep this entrypoint as the procedure and roster catalog. Keep runtime mechanics in `references/kimi-code-subagent-mechanics.md` and reusable definitions in `assets/agents/`; when the roster templates change, update the **Bundled Agent Templates** table in the same edit.
