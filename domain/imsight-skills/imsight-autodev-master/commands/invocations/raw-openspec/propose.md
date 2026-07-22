# Raw OpenSpec Propose Invocation

Use this invocation leaf when the master wants a Houmao-managed slave to create or continue OpenSpec proposal artifacts for a described change.

## Meaning

This dispatch invokes the slave-local OpenSpec proposal skill directly. It asks the slave to turn requirements into OpenSpec artifacts such as proposal, design, specs, and tasks.

## Prerequisites

- A selected Houmao-managed slave.
- A target repository or workspace.
- A clear change idea, desired change name, or continuation context.
- Tool lane metadata from [../../../references/primitives/inspect-slave.md](../../../references/primitives/inspect-slave.md).

## Implications

- This invocation can mutate OpenSpec artifacts in the slave workspace.
- It should not implement application code.
- It is appropriate when requirements are ready to formalize, not when the master wants the slave to run the full lifecycle.

## Command

- Codex slave:
  ```text
  $openspec-propose <request>
  ```
- Claude slave:
  ```text
  /openspec-propose <request>
  ```

## Workflow

1. Read [../../../references/primitives/inspect-slave.md](../../../references/primitives/inspect-slave.md).
2. Preserve the proposal request, including desired change name when provided, repository/workspace, requirements, constraints, and exploration notes.
3. Render the command using [../../../references/primitives/render-invocation.md](../../../references/primitives/render-invocation.md).
4. Deliver with [../../../references/primitives/deliver-to-slave.md](../../../references/primitives/deliver-to-slave.md).
5. After delivery is accepted, finish the turn by default.

If the task does not map cleanly to these steps, plan only from this proposal invocation's prerequisites, rendering, delivery, and guardrails; preserve the requested proposal scope.

## Guardrails

- DO NOT ask the master to create proposal artifacts locally when the intent is slave dispatch.
- DO NOT inspect the slave's follow-up unless the user explicitly asks.
