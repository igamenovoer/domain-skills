# Delegated OpenSpec Lifecycle

Use this workflow when the master needs to delegate OpenSpec-oriented development work and must choose between one-pass automation and bounded phase dispatch.

## Decision Table

| User intent | Use |
| --- | --- |
| "Do the whole thing", autonomous implementation, one focused pass | [../invocations/slave-skill/openspec-one-pass.md](../invocations/slave-skill/openspec-one-pass.md) |
| Thinking only, no implementation | [bounded-openspec-phase.md](bounded-openspec-phase.md) with explore |
| Proposal artifacts only | [bounded-openspec-phase.md](bounded-openspec-phase.md) with propose |
| Existing change implementation | [continue-existing-change.md](continue-existing-change.md) |
| Finalization, sync, or archive | [recover-or-finalize-change.md](recover-or-finalize-change.md) |

## Workflow

1. Identify whether the master request asks for whole-lifecycle delegation or a bounded phase.
2. If it asks for whole-lifecycle delegation, use [../invocations/slave-skill/openspec-one-pass.md](../invocations/slave-skill/openspec-one-pass.md).
3. If it asks for one bounded phase, use [bounded-openspec-phase.md](bounded-openspec-phase.md).
4. If it names an existing change, use [continue-existing-change.md](continue-existing-change.md) unless the request is clearly finalization-only.
5. Dispatch through the selected invocation leaf and stop after accepted delivery.

If the task does not map cleanly to these steps, plan only from the existing lifecycle routes and guardrails; ask whether whole-lifecycle or bounded-phase delegation is intended.

## Guardrails

- DO NOT duplicate command rendering in this workflow.
- DO NOT turn a bounded phase request into one-pass automation.
- DO NOT inspect slave follow-up unless explicitly asked.
