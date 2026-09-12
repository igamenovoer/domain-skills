# Disable All Docs Writer Rules

## Workflow

1. Resolve current Docs Writer state from `../references/state.md`.
2. Remove all canonical Docs Writer rule IDs from the retained selection.
3. Leave `enabled` unchanged.
4. Derive the effective rules from the resulting state.
5. Apply the application order from `../../../references/runtime-injection.md`, defaulting to the managed `AGENTS.md` directive and synchronized Docs Writer rules artifact.
6. Report removed IDs, the empty selection, enabled state, `AGENTS.md` destination, and rules artifact destination.

If the task does not map cleanly to these steps, use the native planning tool to perform one idempotent all-rules removal without changing enabled state.

## Guardrails

- DO NOT disable Docs Writer as a side effect of clearing all rules.
- DO NOT confuse `disable-all` with `disable`; this command changes selection, not enabled state.
- DO NOT erase another mentality's selection.
