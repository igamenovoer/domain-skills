# Disable Brooks

## Workflow

1. Resolve current Brooks state from `../references/state.md`.
2. Set `enabled` to `false`.
3. Retain the complete selected rule set unchanged.
4. Apply the application order from `../../../references/runtime-injection.md`, defaulting to the managed `AGENTS.md` directive and synchronized Brooks rules artifact.
5. Report whether Brooks was newly disabled or already disabled, retained rule IDs, `AGENTS.md` destination, and rules artifact destination.

If the task does not map cleanly to these steps, use the native planning tool to disable only Brooks while preserving its retained selection and sibling mentality state.

## Guardrails

- DO NOT clear Brooks rules as a side effect of disabling it.
- DO NOT interpret `disable` as `disable-all`; selection and enabled state are independent.
- DO NOT disable another mentality.
