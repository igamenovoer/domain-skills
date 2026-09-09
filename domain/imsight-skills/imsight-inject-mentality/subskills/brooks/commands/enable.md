# Enable Brooks

## Workflow

1. Resolve current Brooks state from `../references/state.md`.
2. Set `enabled` to `true` without changing a retained rule selection.
3. If no selection exists, initialize it to all twelve built-in rules.
4. Derive the effective rules.
5. Apply the requested persistence lane from `../../../references/runtime-injection.md`.
6. Report whether Brooks was newly enabled or already enabled, effective rule IDs, and persistence destination.

If the task does not map cleanly to these steps, use the native planning tool to enable only the Brooks namespace while preserving its rule selection and sibling mentality state.

## Guardrails

- DO NOT rewrite a valid retained selection when enabling Brooks.
- DO NOT interpret `enable` as `enable-all`; selection and enabled state are independent.
- DO NOT imply that enabling Brooks installed a runtime hook.
