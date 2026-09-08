# Turn Brooks On

## Workflow

1. Resolve current Brooks state from `../references/state.md`.
2. Set `active` to `true` without changing a retained rule selection.
3. If no selection exists, initialize it to all twelve built-in rules.
4. Derive the effective rule set and report activation, selected rules, and persistence scope.

If the task does not map cleanly to these steps, use the native planning tool to activate only the Brooks namespace while preserving the state contract.

## Output

Keep confirmation compact. State whether Brooks was newly activated or already on, summarize the effective rule codes, and label the state `host-persisted` or `session-scoped`.

## Guardrails

- DO NOT rewrite a valid retained selection when activating Brooks.
- DO NOT imply that activation installed a runtime hook.
