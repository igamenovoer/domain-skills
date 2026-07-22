# Define Feature

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the feature design directory** and inspect `README.md`, existing `feature-requirement.md`, and nearby feature design folders for local style.
2. **Capture the feature definition** from the request and available context: goal, target users or stakeholders, non-goals, inputs, outputs, workflows, boundaries, persistence expectations, operational constraints, assumptions, and open questions.
3. **Create or update `feature-requirement.md`**. If the file is still a scaffold template, replace placeholders with substantive content. If it already has content, preserve stable decisions and update only affected sections.
4. **Keep detailed interface contracts out of the requirement** when they grow large. Put request/response schemas, CLI shapes, file formats, routes, storage contracts, or event contracts in `design/` through `design-interface`.
5. **Report the definition**. Summarize changed sections and ask which use case should be designed next.

If the task does not map cleanly to these steps, write the clearest partial feature requirement and list the missing decisions that block a stronger definition.

## Required Sections

Use these sections unless the existing feature requirement has a stronger local convention: `# <Feature Name> Feature Requirement`, `## Goal`, `## Non-Goals`, `## Users And Workflows`, `## Functional Requirements`, `## System Boundaries`, `## Operational Constraints`, `## Assumptions`, and `## Open Questions`.
