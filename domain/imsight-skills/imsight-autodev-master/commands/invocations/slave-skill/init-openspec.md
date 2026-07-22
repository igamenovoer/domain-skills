# Slave Skill Init-OpenSpec Invocation

Use this invocation leaf when the master wants a Houmao-managed slave to initialize `openspec/` in the slave's own target workdir.

## Meaning

This dispatch invokes the predefined `imsight-autodev-slave init-openspec` operation. The slave, not the master, checks and mutates its local filesystem.

## Prerequisites

- A selected Houmao-managed slave.
- A clear target workdir hint or confidence that the slave's current working directory is the desired target.
- Tool lane metadata from [../../../references/primitives/inspect-slave.md](../../../references/primitives/inspect-slave.md).

## Implications

- This invocation can create `openspec/` in the slave workspace.
- The master must not run `openspec init`, copy `openspec/`, or mutate the slave workdir directly.
- The slave operation is expected to no-op when `openspec/` already exists.

## Command

- Codex slave:
  ```text
  $imsight-autodev-slave init-openspec <request>
  ```
- Claude slave:
  ```text
  /imsight-autodev-slave init-openspec <request>
  ```

## Workflow

1. Read [../../../references/primitives/inspect-slave.md](../../../references/primitives/inspect-slave.md).
2. Preserve any target-workdir hint from the master request.
3. Render the command using [../../../references/primitives/render-invocation.md](../../../references/primitives/render-invocation.md).
4. Deliver with [../../../references/primitives/deliver-to-slave.md](../../../references/primitives/deliver-to-slave.md).
5. After delivery is accepted, finish the turn by default.

If the task does not map cleanly to these steps, plan only from the existing slave initialization invocation and its guardrails; preserve any workdir hint and do not initialize directly.

## Guardrails

- DO NOT run `openspec init` from the master for the slave.
- DO NOT copy files into the slave workdir from the master.
- DO NOT assume the master can see the same filesystem as the slave.
- DO NOT monitor, poll, or inspect the slave after delivery unless explicitly asked.
