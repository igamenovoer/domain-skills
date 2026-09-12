# Enable Docs Writer

## Workflow

1. Resolve current Docs Writer state from `../references/state.md`.
2. Set `enabled` to `true` without changing a retained rule selection.
3. If no selection exists, initialize it to all canonical Docs Writer rules.
4. Derive the effective rules.
5. Apply the application order from `../../../references/runtime-injection.md`, defaulting to the managed `AGENTS.md` directive and synchronized Docs Writer rules artifact.
6. Report whether Docs Writer was newly enabled or already enabled, effective rule IDs, `AGENTS.md` destination, and rules artifact destination.

If the task does not map cleanly to these steps, use the native planning tool to enable only the Docs Writer namespace while preserving its rule selection and sibling mentality state.

## Guardrails

- DO NOT rewrite a valid retained selection when enabling Docs Writer.
- DO NOT interpret `enable` as `enable-all`; selection and enabled state are independent.
- DO NOT imply that enabling Docs Writer installed a runtime hook.
