# Kimi Code Subagent Mechanics

Distilled from the official Kimi Code documentation. When this page conflicts with the live documentation, the documentation wins; do not extend this page with unverified claims.

Sources:

- [Agents and Sub-Agents](https://www.kimi.com/code/docs/en/kimi-code-cli/customization/agents.html)
- [Configuration files](https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/config-files.html) (`models`, `secondary_model`, `thinking` sections)

## Agent Locations

Kimi Code discovers agent definition files by scope; more specific scopes win on a name collision. Each directory is scanned recursively for `.md` files.

| Scope | Locations |
| --- | --- |
| Explicit | `--agent-file <path>` at launch; highest priority, current launch only |
| Project | `<project-root>/.kimi-code/agents/`, `<project-root>/.agents/agents/` (project root = nearest ancestor containing `.git`) |
| Extra | Directories in top-level `extra_agent_dirs` in `config.toml` |
| User | `$KIMI_CODE_HOME/agents/` (default `~/.kimi-code/agents/`), `~/.agents/agents/` |
| Plugin | Enabled plugin manifest `agents` directories |
| Built-in | `coder`, `explore`, `plan`, shipped with the CLI; lowest priority |

A directory-discovered file does not override a same-name built-in agent unless its frontmatter declares `override: true`. Project-level files come from the repository itself, so treat `.kimi-code/agents/` in an unfamiliar repository with the same caution as scripts: a file named `agent.md` with `override: true` replaces the default main agent's whole system prompt, and a file without a `tools` list keeps every tool.

The CLI watches these directories and `config.toml` and hot-reloads them; new or changed definitions appear in the running session without a restart.

## Agent File Format

An agent file is Markdown with a YAML frontmatter block. The body is the agent's system prompt.

```markdown
---
name: reviewer
description: Strict code reviewer that reports severity-ranked findings
whenToUse: Code reviews and PR checks
override: false
tools:
  - Read
  - Grep
  - Glob
  - mcp__github__*
disallowedTools:
  - Bash
---

You are a strict code reviewer. ...
```

| Field | Required | Description |
| --- | --- | --- |
| `name` | no | Unique kebab-case identifier; defaults to the file name without extension. A missing or non-kebab-case name skips the file with a warning |
| `description` | yes | What the agent does; shown to the main agent when it picks a sub-agent. Write it to guide delegation decisions |
| `whenToUse` | no | Extra hint describing when the agent should be used |
| `override` | no | Whether the file may replace a same-name built-in agent; defaults to `false` |
| `tools` | no | Tool allowlist. Built-in tools match by exact case-sensitive name; entries starting with `mcp__` match MCP tools as globs. Omit or use a lone `*` to allow all tools; `tools: []` disables all tools |
| `disallowedTools` | no | Denylist with the same syntax, applied after `tools` |
| `subagents` | no | Sub-agent allowlist for further delegation; omit to inherit the built-in default (`coder`, `explore`, `plan`) |

Unknown fields are ignored, including fields from other agent tools such as Claude Code's `model` — an agent file cannot pin its own model. Three tool-entry shapes never match anything and are warned about: a bare `*` in `disallowedTools`, an incomplete `mcp__` literal like `mcp__github` (use `mcp__github__*`), and a name no registered tool has.

Custom agents delegated as sub-agents run without the built-in sub-agent framing, so a delegation-bound agent's body must state that its final message is the complete, self-contained result for the caller.

## Model Binding

Subagents inherit the caller's model unless a `[secondary_model]` section in `config.toml` defines a pool. A configured pool adds a `model` parameter to the `Agent`/`AgentSwarm` tools, and the pool's per-alias hint text is what steers the main agent's choice at dispatch time.

```toml
[secondary_model]
default_model = "kimi-code/k3-256k"
default_effort = "max"

[secondary_model.models]
"kimi-code/k3-256k" = "Default subagent model at max thinking effort. General implementation, exploration, and planning tasks."
"openlux-gpt/gpt-6-astra" = "GPT-6 Astra. Always bind this model when dispatching default-reviewer for code and architectural reviews."
```

| Field | Default | Description |
| --- | --- | --- |
| `default_model` | — | The default model for subagents; required and must be a pool key when a `models` table exists |
| `models` | — | Pool: each key an alias of a configured `[models]` entry, each value a selection hint |
| `force` | `false` | Pin every subagent to `default_model`; cannot combine with a `models` table |
| `default_effort` | — | Section-wide thinking effort bound on every spawn; outranks the bound model entry's own `default_effort` |

Spawn-time model resolution: an explicit `model` argument wins; otherwise `default_model` applies. The `model` parameter accepts pool aliases and the reserved alias `primary` (the caller's own model and effort); anything else fails the spawn with an error listing the choices.

Thinking-effort resolution for a pool-bound spawn: the section's `default_effort` wins when set; otherwise the bound `[models]` entry's `default_effort`, then the global `[thinking].effort`, then the middle of the entry's `support_efforts`. Pool-bound spawns do not inherit the caller's effort. A requested effort the model does not support falls back to the model entry's `default_effort`; a model entry whose own `default_effort` is not in its `support_efforts` is a configuration error.

Configuration errors fail loudly: session creation fails when `default_model` is missing or not a pool key, a pool key does not resolve to a configured `[models]` entry, or `force` is miscombined. Pool aliases referencing a later-deleted provider or model break startup until fixed.

## Thinking-Effort Contract

The resolution rules above allow several ways to control effort, and they interact confusingly (a section-wide `[secondary_model] default_effort` silently overrides every model entry's own default). Keep the configuration least-surprising by following four rules:

1. **Do not touch settings that managed refreshes rewrite.** For `managed:kimi-code` models provisioned by `/login` (the `kimi-code/*` aliases), never edit the entry's top-level `default_effort` or `support_efforts`; a login or catalog refresh restores the provider's values.
2. **Want a different default for a Kimi model? Use model overrides.** Pin `[models."<alias>".overrides] default_effort = "<level>"`; overrides survive managed refreshes and outrank the top-level field for every runtime consumer. The value must be a member of the entry's `support_efforts`.
3. **Defaults for non-managed models live in their own entries.** For user-defined providers, set `default_effort` (and the other fields) directly in the `[models]` entry; nothing refreshes them, so no override table is needed.
4. **Need a subagent-specific thinking level? Use a suffixed derived model.** Register `<provider>/<model>-<effort>` as a standalone `[models]` entry for the same underlying model with only `default_effort` changed (copy every other field in full; variants inherit nothing), add it to the pool, and name that alias — with its effort — in the subagent definition's `description`. Keep the bare alias on the model's own default, and keep `[secondary_model] default_effort` unset so each bound alias speaks for itself.

Under this contract, effort is a pure function of the bound alias: read the alias name, and you know the thinking level.

### Registering a model for subagent use

When a subagent should run on a model that is not yet configured — including an unreleased or newly served model id — register it before binding:

1. **Check whether the model is already provisioned.** Managed providers (`managed:kimi-code`) may already list it after a `/login` or catalog refresh; if so, only overrides are ever needed. User-defined providers require manual entries.
2. **Resolve the model's facts from live sources**, never from memory or from this page: the provider's `/models` catalog or documentation for the exact id, context window, input modalities, and supported reasoning levels; the current Kimi Code documentation for the config fields. Record the source and the resolution date in the final report.
3. **Write or extend the `[models]` entry**: `provider`, upstream `model` id, a justified positive `max_context_size`, `capabilities` (add `"thinking"` and `"tool_use"` when verified), `support_efforts` as the intersection of the model's discovered levels and the Kimi Code vocabulary (`low`, `medium`, `high`, `xhigh`, `max`), and `default_effort` per rules 2-3 of the contract.
4. **Mint a suffixed variant only when the subagent needs a non-default effort** (rule 4); otherwise bind the bare alias.
5. **Add the pool entry** under `[secondary_model.models]` with a hint naming the subagent it serves, then validate: TOML parses, the alias resolves, the effective effort is in `support_efforts`, and the CLI's change notification or a fresh `Agent`-tool catalog confirms hot-reload.

Dated example (recorded 2026-10-23, Kimi Code 2.x; re-resolve before relying on it): a project runs four subagents on three providers — `default-coder` on `kimi-code/k3-256k` pinned to `max` through `[models."kimi-code/k3-256k".overrides]` because the managed entry ships `high`; `default-planner` on `openlux-gpt/gpt-6-astra` at its entry default `xhigh`; `default-reviewer` on the derived `openlux-gpt/gpt-6-astra-max` entry for a subagent-specific `max`; `fast-coder` on `deepseek/deepseek-flash` with `default_effort = "max"` set directly in its user-provider entry. The pool carries no section-wide `default_effort`.

## Dispatch Form

Once defined, a custom subagent is dispatched by the main agent with the pool alias that serves it:

```text
Agent(subagent_type="default-reviewer", model="openlux-gpt/gpt-6-astra", prompt="Review ...")
```

Omitting `model` lands the subagent on the pool's `default_model`, not on the model its author intended — which is why pool hint text must name the subagent each alias serves.

## Validation Recipe

After writing or changing definitions, verify mechanically before reporting done:

1. Parse `config.toml` as TOML; confirm every `[secondary_model.models]` key resolves to a configured `[models]` entry and `default_model` is a pool key.
2. Parse every new agent file's frontmatter as YAML; confirm `name` is kebab-case (matching the file name), `description` is present, and every `tools`/`disallowedTools` entry names a real built-in tool or a well-formed `mcp__<server>__*` glob.
3. In a running session, treat the change-notification of added profiles and pool models, or a fresh `Agent`-tool catalog listing, as runtime confirmation that discovery and hot-reload succeeded.
