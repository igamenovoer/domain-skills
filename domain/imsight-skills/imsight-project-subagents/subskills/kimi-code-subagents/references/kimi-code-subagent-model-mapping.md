# Kimi Code Subagent Model Binding Handoff

This skill creates model-agnostic subagent definitions. It does not choose model aliases, does not edit `config.toml`, and does not add model claims to agent files. After the definitions exist, suggest that the user bind them by adding a routing table to `$KIMI_CODE_HOME/AGENTS.md`.

## What the Skill Does Not Do

- It does not select a model or thinking effort for any subagent.
- It does not edit `[secondary_model]` or register `[models]` entries.
- It does not write `$KIMI_CODE_HOME/AGENTS.md` unless the user explicitly asks.

Agent frontmatter has no effective `model` field; Kimi Code ignores it. The binding is resolved at dispatch time, so it belongs to the user's runtime configuration.

## Suggested Handoff

After writing the definitions, give the user a routing table like this and tell them to add it to `$KIMI_CODE_HOME/AGENTS.md`:

```markdown
## Subagent model routing

When dispatching one of the custom subagents below with `Agent` or `AgentSwarm`, pass the `model` argument explicitly:

| Subagent type | Model alias |
| --- | --- |
| `<subagent-type>` | `<alias>` |

Rules:

- Use aliases configured in `[secondary_model.models]`.
- Do not pass `model` for built-in subagents unless the user asks to override them.
- If an alias is unavailable, report the failure instead of substituting another model.
```

Replace the placeholders with the subagent types the skill created. Leave the alias cells as placeholders unless the user names the aliases to put there. The user decides which model each role should use.

Do not write the file yourself unless the user explicitly asks. State the path and the snippet in the final report.

## Where the Binding Lives

- `$KIMI_CODE_HOME/AGENTS.md` is Kimi Code's additive instruction file. It is Kimi-specific, so other coding agents do not read it.
- A project-scoped definition may use `<project-root>/.kimi-code/AGENTS.md` when `KIMI_CODE_HOME` points into the project; otherwise use the effective Kimi home.
- Avoid putting Kimi-specific aliases in a shared project `AGENTS.md` that other agents also read.
- `SYSTEM.md` has system-prompt authority but replaces the default main-agent prompt, so do not suggest it for a simple routing table unless the user asks. If used, it needs `${base_prompt}`.

## Resolution Facts to Explain

- The `Agent` and `AgentSwarm` `model` parameter accepts aliases listed in `[secondary_model.models]` and the reserved `primary`, which inherits the caller's model and thinking effort.
- If `model` is omitted, the spawn uses `[secondary_model].default_model`.
- `[secondary_model].force = true` pins every spawn to `default_model` and cannot be combined with a `models` table; explicit `model` arguments are rejected.
- A section-wide `[secondary_model].default_effort` outranks each model entry's `default_effort`; per-entry variants are the way to give different roles different efforts.
- An alias that does not resolve to a configured `[models]` entry fails the spawn.
- A pool alias binds that alias's effective effort; `primary` binds the caller's effort.

## Validation

1. Confirm the suggested file path is `$KIMI_CODE_HOME/AGENTS.md`, or the project-local equivalent the user chose.
2. Confirm the routing table lists only the subagent types that were actually created.
3. If the user supplied aliases, confirm each one resolves to a configured `[models]` entry and is listed in `[secondary_model.models]`.
4. Do not dispatch a probe subagent unless the user asks; the handoff is a suggestion, not an applied change.
