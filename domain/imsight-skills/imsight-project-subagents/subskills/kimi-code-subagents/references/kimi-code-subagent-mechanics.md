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

Thinking-effort resolution for a pool-bound spawn: the section's `default_effort` wins when set; otherwise the bound `[models]` entry's `default_effort`, then the global `[thinking].effort`, then the middle of the entry's `support_efforts`. Pool-bound spawns do not inherit the caller's effort. A requested effort the model does not support falls back to the model entry's `default_effort`; a model entry whose own `default_effort` is not in its `support_efforts` is a configuration error. For per-entry efforts, leave the section `default_effort` unset and register variant aliases of the same underlying model differing only in `default_effort` (copy the full entry; variants inherit nothing).

Configuration errors fail loudly: session creation fails when `default_model` is missing or not a pool key, a pool key does not resolve to a configured `[models]` entry, or `force` is miscombined. Pool aliases referencing a later-deleted provider or model break startup until fixed.

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
