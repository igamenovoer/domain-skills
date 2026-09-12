# Enable All Docs Writer Rules

## Workflow

1. Resolve current Docs Writer state from `../references/state.md`.
2. Add all canonical Docs Writer rule IDs to the retained selection.
3. Leave `enabled` unchanged.
4. Derive the effective rules from the resulting state.
5. Apply the application order from `../../../references/runtime-injection.md`, defaulting to the managed `AGENTS.md` directive and synchronized Docs Writer rules artifact.
6. Report newly added IDs, resulting selection, enabled state, `AGENTS.md` destination, and rules artifact destination.

If the task does not map cleanly to these steps, use the native planning tool to perform one idempotent all-rules selection update without changing enabled state.

## Guardrails

- DO NOT enable Docs Writer as a side effect of selecting all rules.
- DO NOT confuse `enable-all` with `enable`; this command changes selection, not enabled state.
- DO NOT modify another mentality's selection.
