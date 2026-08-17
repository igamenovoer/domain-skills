# Plan Feature

Use this subcommand to create or update `<feature-dir>/feature-milestones.md`, a high-level milestone list describing how to implement the feature in verifiable stages.

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the feature design directory** and read `README.md`, `feature-requirement.md`, relevant `usecases/uc-*.md`, `design/` docs, and any existing `feature-milestones.md`.
2. **Check predecessor artifacts**. `feature-requirement.md` must exist with substantive content. If it is missing or still a scaffold placeholder, refuse to plan and tell the user to run `define-feature` first.
3. **Derive the milestone sequence** from the feature goal, functional requirements, use cases, and interface designs. Follow **Milestone Principles**.
4. **Create or update `feature-milestones.md`** following **Milestones Format**. Use the template at `assets/templates/feature/feature-milestones.md` when creating a new file. Preserve settled milestones when updating and revise only affected ones.
5. **Update the feature `README.md`** artifact map and current stage when they do not mention the milestone plan.
6. **Report the plan**. Summarize the milestone sequence, assumptions, open questions, and the suggested next subcommand, usually `design-agent-task`.

If the task does not map cleanly to these steps, write the smallest useful milestone list and list the missing decisions that block a stronger plan.

## Milestone Principles

- Each milestone describes **what must be enabled** after it completes: an observable capability, workflow, or behavior that a user or another system can exercise.
- Keep milestones high level. Describe outcomes and capabilities, not tasks. Do not name files, modules, classes, or code changes; that level of detail belongs to `agent-task.md` and implementation planning.
- Order milestones so each one builds on capabilities enabled by earlier milestones and can be verified on its own.
- Prefer few meaningful milestones over many small ones; three to seven milestones fit most features.
- The final milestone must enable the complete feature requirement, including operational constraints that are part of the goal.

## Milestones Format

Prefer these sections: `# <Feature Name> Milestones`, `## Overview`, then one `## Milestone M<N> - <Title>` section per milestone, and `## Open Questions` when relevant.

The **Overview** holds a milestone checklist: one `- [ ] M<N> - <Title>` line per milestone, so progress can be tracked by ticking milestones off.

Each milestone section includes:

- **Goal**: one or two sentences on the stage's intent.
- **Enables**: checklist of capabilities that must work after the milestone, phrased as observable behavior.
- **Depends On**: earlier milestones or external prerequisites; omit when none.
- **Done When**: a short checklist of verifiable outcomes that mark the milestone complete.

## Tickbox Rule

Render every item that represents a completable, trackable unit of work as a Markdown checkbox (`- [ ]`): the milestone lines in the overview and the `Enables` and `Done When` items inside each milestone. Keep prose content plain: goals, dependency notes, and open questions are not todo items and do not get checkboxes. When updating an existing `feature-milestones.md`, preserve the checked or unchecked state of items the change does not touch.

## Guardrails

- DO NOT write implementation steps, file paths, or code-level tasks into a milestone.
- DO NOT create `feature-milestones.md` before `feature-requirement.md` has substantive content.
- DO NOT duplicate requirement or use case prose; reference the source artifacts instead.
