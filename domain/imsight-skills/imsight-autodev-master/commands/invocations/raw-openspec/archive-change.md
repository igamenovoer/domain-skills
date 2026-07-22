# Raw OpenSpec Archive-Change Invocation

Use this invocation leaf when the master wants a Houmao-managed slave to archive or finalize a completed OpenSpec change.

## Meaning

This dispatch invokes the slave-local OpenSpec archive-change skill directly. It is a finalization phase for completed OpenSpec work.

## Prerequisites

- A selected Houmao-managed slave.
- A target repository or workspace.
- An existing OpenSpec change that is implemented or ready for finalization.
- Tool lane metadata from [../../../references/primitives/inspect-slave.md](../../../references/primitives/inspect-slave.md).

## Implications

- This invocation can sync final specs and move or archive change artifacts in the slave workspace.
- It should happen after implementation and verification have been attempted.
- Use [sync-specs.md](sync-specs.md) first only when the local workflow requires explicit sync before archive.

## Command

- Codex slave:
  ```text
  $openspec-archive-change <change-or-request>
  ```
- Claude slave:
  ```text
  /openspec-archive-change <change-or-request>
  ```

## Workflow

1. Read [../../../references/primitives/inspect-slave.md](../../../references/primitives/inspect-slave.md).
2. Preserve the archive request, including change name/path, repository/workspace, sync expectations, and final validation constraints.
3. Render the command using [../../../references/primitives/render-invocation.md](../../../references/primitives/render-invocation.md).
4. Deliver with [../../../references/primitives/deliver-to-slave.md](../../../references/primitives/deliver-to-slave.md).
5. After delivery is accepted, finish the turn by default.

If the task does not map cleanly to these steps, plan only from this invocation's prerequisites, rendering, delivery, and guardrails; ask for missing finalization intent.

## Guardrails

- DO NOT archive locally when the request is slave dispatch.
- DO NOT inspect the slave's follow-up unless the user explicitly asks.
