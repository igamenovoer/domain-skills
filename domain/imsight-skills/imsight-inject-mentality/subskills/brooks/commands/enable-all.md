# Enable All Brooks Rules

## Workflow

1. Resolve current Brooks state from `../references/state.md`.
2. Add all twelve canonical Brooks rule IDs to the retained selection.
3. Leave `enabled` unchanged.
4. Derive the effective rules from the resulting state.
5. Apply the application order from `../../../references/runtime-injection.md`, defaulting to the compact project summary and rule index.
6. Report newly added IDs, resulting selection, enabled state, and persistence destination.

If the task does not map cleanly to these steps, use the native planning tool to perform one idempotent all-rules selection update without changing enabled state.

## Guardrails

- DO NOT enable Brooks as a side effect of selecting all rules.
- DO NOT confuse `enable-all` with `enable`; this command changes selection, not enabled state.
- DO NOT modify another mentality's selection.
