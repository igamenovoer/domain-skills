# Prepare Slave For OpenSpec

Use this workflow when the master wants the slave to ensure OpenSpec is initialized in the slave's own target workdir.

## Decision

The slave owns the filesystem check because it may be running in an isolated environment. The master should dispatch [../invocations/slave-skill/init-openspec.md](../invocations/slave-skill/init-openspec.md) and stop after accepted delivery.

## Workflow

1. Read [../../references/primitives/inspect-slave.md](../../references/primitives/inspect-slave.md) and recover slave metadata.
2. Preserve the target workdir hint from the request when provided.
3. Read [../invocations/slave-skill/init-openspec.md](../invocations/slave-skill/init-openspec.md) for command semantics.
4. Render the `imsight-autodev-slave init-openspec` command with [../../references/primitives/render-invocation.md](../../references/primitives/render-invocation.md).
5. Deliver with [../../references/primitives/deliver-to-slave.md](../../references/primitives/deliver-to-slave.md).
6. After delivery is accepted, finish the turn by default.

If the task does not map cleanly to these steps, plan only from the existing inspection, rendering, and delivery primitives; do not initialize the slave workdir directly.

## Guardrails

- DO NOT check the slave filesystem from the master unless the user explicitly asks for inspection and the path is actually local.
- DO NOT initialize or copy `openspec/` from the master.
- DO NOT inspect follow-up unless explicitly asked.
