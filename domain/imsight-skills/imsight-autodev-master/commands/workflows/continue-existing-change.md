# Continue Existing Change

Use this workflow when the master request names an existing OpenSpec change and asks the slave to continue work from that state.

## Decision Table

| Existing-change state or request | Invocation leaf |
| --- | --- |
| Needs implementation or remaining tasks | [../invocations/raw-openspec/apply-change.md](../invocations/raw-openspec/apply-change.md) |
| Implementation complete but specs need sync | [../invocations/raw-openspec/sync-specs.md](../invocations/raw-openspec/sync-specs.md) |
| Ready for finalization or archival | [../invocations/raw-openspec/archive-change.md](../invocations/raw-openspec/archive-change.md) |
| State is unclear and the user wants investigation | [../invocations/raw-openspec/explore.md](../invocations/raw-openspec/explore.md) |

## Workflow

1. Preserve the change id, path, target repository, and any known progress state.
2. Select the invocation leaf that matches the requested next phase.
3. If the next phase is ambiguous, ask for the smallest clarification needed.
4. Dispatch through the selected invocation leaf and stop after accepted delivery.

If the task does not map cleanly to these steps, plan only from the existing change state and invocation leaves; preserve identifiers and ask which next phase is intended.

## Guardrails

- DO NOT invent a change id.
- DO NOT apply, sync, or archive locally when the request is slave dispatch.
- DO NOT inspect slave follow-up unless explicitly asked.
