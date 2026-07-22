# Raw OpenSpec Explore Invocation

Use this invocation leaf when the master wants a Houmao-managed slave to explore a development idea, problem, or change without implementing it.

## Meaning

This dispatch invokes the slave-local OpenSpec explore skill directly. It is a bounded thinking and investigation phase, not a proposal or implementation workflow.

## Prerequisites

- A selected Houmao-managed slave.
- Enough request context for the slave to know the target repository, problem, idea, or questions to investigate.
- Tool lane metadata from [../../../references/primitives/inspect-slave.md](../../../references/primitives/inspect-slave.md).

## Implications

- The slave should not implement code changes as part of this invocation.
- The slave may inspect the codebase and OpenSpec context.
- The slave should create or update artifacts only when the request explicitly asks for capture during exploration.

## Command

- Codex slave:
  ```text
  $openspec-explore <request>
  ```
- Claude slave:
  ```text
  /openspec-explore <request>
  ```

## Workflow

1. Read [../../../references/primitives/inspect-slave.md](../../../references/primitives/inspect-slave.md).
2. Preserve the explore request, including repository, change name if any, context, and questions to investigate.
3. Render the command using [../../../references/primitives/render-invocation.md](../../../references/primitives/render-invocation.md).
4. Deliver with [../../../references/primitives/deliver-to-slave.md](../../../references/primitives/deliver-to-slave.md).
5. After delivery is accepted, finish the turn by default.

If the task does not map cleanly to these steps, plan only from this bounded exploration invocation and its guardrails; do not convert it into proposal or implementation work.

## Guardrails

- DO NOT convert explore dispatch into proposal or implementation work.
- DO NOT inspect the slave's follow-up unless the user explicitly asks.
