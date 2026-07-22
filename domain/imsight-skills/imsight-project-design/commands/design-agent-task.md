# Design Agent Task

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the feature design directory** and read `README.md`, `feature-requirement.md`, use cases, and design docs.
2. **Determine implementation scope** from stabilized artifacts. If requirements, use cases, or interfaces are still too vague, write a blocked note in chat rather than inventing implementation work.
3. **Create or update `agent-task.md`** as a compact implementation handoff. Make the design guidance explicit but allow the implementer to revise architecture when justified.
4. **Include required evidence**. Require per-use case or per-workstream evidence packs with inputs, outputs, and a short `README.md`; state whether evidence belongs under ignored temporary output and should not be committed.
5. **Include execution constraints** such as local versus remote execution, dependency and network assumptions, data or model location, and verification commands when relevant.
6. **Report the handoff**. Summarize the implementation objective, evidence expectations, and any blockers left for the user.

If the task does not map cleanly to these steps, write the smallest useful handoff and list which design artifacts need more discussion before implementation can safely start.

## Handoff Shape

Prefer these sections: `# Agent Task`, `## Objective`, `## Required Use Cases`, `## Design References`, `## Implementation Instructions`, `## Verification`, `## Required Evidence`, `## Out Of Scope`, and `## Open Questions`.
