# Kimi Code Subagent Mechanics

Distilled from the official Kimi Code documentation. When this page conflicts with the live documentation, the documentation wins; do not extend this page with unverified claims.

Sources:

- [Agents and Sub-Agents](https://www.kimi.com/code/docs/en/kimi-code-cli/customization/agents.html)
- [Configuration files](https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/config-files.html) (agent discovery and workspace settings)

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

The CLI watches these directories and `config.toml` and hot-reloads them; new or changed definitions appear in the running session without a restart. A fresh session remains the reliable check when a running catalog looks stale.

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

## Model Binding Is a Separate User Decision

An agent file cannot pin its own model: Kimi Code ignores a `model` frontmatter field. Subagents inherit the caller's model unless the user configures a `[secondary_model]` pool or passes a `model` argument at dispatch. This skill does not choose aliases, edit `config.toml`, or add model claims to definitions.

After writing the definitions, suggest the user add a routing table to `$KIMI_CODE_HOME/AGENTS.md`; `references/kimi-code-subagent-model-mapping.md` provides the handoff format and the minimal resolution facts to explain. Do not write that file unless the user explicitly asks.

## Validation Recipe

After writing or changing definitions, verify mechanically before reporting done:

1. Parse every new agent file's frontmatter as YAML; confirm `name` is kebab-case (matching the file name), `description` is present, and every `tools`/`disallowedTools` entry names a real built-in tool or a well-formed `mcp__<server>__*` glob.
2. Confirm the definitions contain no model alias, model ID, or thinking-effort claim.
3. In a running session, treat the change notification of added profiles, or a fresh `Agent`-tool catalog listing, as runtime confirmation that discovery succeeded. A fresh session is the reliable check when the catalog looks stale.
