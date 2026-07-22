# Raw OpenSpec Apply-Change Invocation

Use this invocation leaf when the master wants a Houmao-managed slave to implement tasks from an existing OpenSpec change.

## Meaning

This dispatch invokes the slave-local OpenSpec apply-change skill directly. It is an implementation phase for a known OpenSpec change.

## Prerequisites

- A selected Houmao-managed slave.
- A target repository or workspace.
- An existing OpenSpec change id, path, or unambiguous implementation request.
- Tool lane metadata from [../../../references/primitives/inspect-slave.md](../../../references/primitives/inspect-slave.md).

## Implications

- This invocation can mutate application code, tests, docs, and OpenSpec task checkboxes in the slave workspace.
- The slave is expected to run focused verification appropriate to the change.
- Use a workflow page first if the master is unsure whether a proposal exists or whether implementation is the right next phase.

## Command

- Codex slave:
  ```text
  $openspec-apply-change <change-or-request>
  ```
- Claude slave:
  ```text
  /openspec-apply-change <change-or-request>
  ```

## Workflow

1. Read [../../../references/primitives/inspect-slave.md](../../../references/primitives/inspect-slave.md).
2. Preserve the implementation request, including change name/path, repository/workspace, verification expectations, and constraints.
3. Render the command using [../../../references/primitives/render-invocation.md](../../../references/primitives/render-invocation.md).
4. Deliver with [../../../references/primitives/deliver-to-slave.md](../../../references/primitives/deliver-to-slave.md).
5. After delivery is accepted, finish the turn by default.

If the task does not map cleanly to these steps, plan only from this invocation's prerequisites, rendering, delivery, and guardrails; do not broaden the implementation request.

## Guardrails

- DO NOT implement the change in the master workspace when the request is slave dispatch.
- DO NOT inspect tests, logs, TUI state, or slave output after delivery unless explicitly asked.
