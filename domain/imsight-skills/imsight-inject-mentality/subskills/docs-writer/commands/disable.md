# Disable Docs Writer

## Workflow

1. Resolve current Docs Writer state from `../references/state.md`.
2. Set `enabled` to `false`.
3. Retain the complete selected rule set unchanged.
4. Apply the application order from `../../../references/runtime-injection.md`, defaulting to the managed `AGENTS.md` directive and synchronized Docs Writer rules artifact.
5. Report whether Docs Writer was newly disabled or already disabled, retained rule IDs, `AGENTS.md` destination, and rules artifact destination.

If the task does not map cleanly to these steps, use the native planning tool to disable only Docs Writer while preserving its retained selection and sibling mentality state.

## Guardrails

- DO NOT clear Docs Writer rules as a side effect of disabling it.
- DO NOT interpret `disable` as `disable-all`; selection and enabled state are independent.
- DO NOT disable another mentality.
