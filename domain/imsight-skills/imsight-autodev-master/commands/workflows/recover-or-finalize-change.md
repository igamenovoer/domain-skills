# Recover Or Finalize Change

Use this workflow when the master asks a slave to recover partial OpenSpec work, reconcile state, sync specs, or finalize an implemented change.

## Decision Table

| Situation | Invocation leaf |
| --- | --- |
| Failure or partial state needs diagnosis only | [../invocations/raw-openspec/explore.md](../invocations/raw-openspec/explore.md) |
| Remaining implementation tasks are known | [../invocations/raw-openspec/apply-change.md](../invocations/raw-openspec/apply-change.md) |
| Specs need to be synced without archive | [../invocations/raw-openspec/sync-specs.md](../invocations/raw-openspec/sync-specs.md) |
| Work is complete and should be finalized | [../invocations/raw-openspec/archive-change.md](../invocations/raw-openspec/archive-change.md) |

## Workflow

1. Preserve the change id/path, target repository, last known failure, and requested final state.
2. Choose the smallest invocation leaf that moves the change toward the requested state.
3. Use archive only when finalization is intended; use sync when the request is spec update without archival.
4. Dispatch through the selected invocation leaf and stop after accepted delivery.

If the task does not map cleanly to these steps, plan only from the existing recovery, sync, and archive routes; preserve the requested final state and ask when it is unclear.

## Guardrails

- DO NOT combine recovery and archive into one master-side sequence unless the user explicitly asked for that full chain.
- DO NOT watch results after dispatch unless explicitly asked.
- DO NOT change mail-notifier appendix text to force a one-off recovery behavior.
