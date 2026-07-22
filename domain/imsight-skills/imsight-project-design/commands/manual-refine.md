# Manual Refine

Use this subcommand to accept user-directed design refinements, record them as ADRs, and propagate them into existing feature-design artifacts. For this page, `<design-output-dir>` means the feature design directory resolved by the entrypoint.

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the existing design output directory**. Read its top-level `README.md` when present. Do not create a new feature design through this subcommand.
2. **Detect a concrete refinement instruction**. If none is present, enter the **Waiting Posture**, return its readiness response, and yield without writing files.
3. **Load the design baseline**. Read `feature-requirement.md`, use-case and design indexes, relevant use cases and design docs, `agent-task.md` when present, and existing `adrs/*.md`.
4. **Qualify and split the instruction**. Apply only decision-bearing corrections, constraints, additions, removals, or clarifications. Split independent decisions into separate ADR transactions; keep coupled changes together.
5. **Classify each ADR transaction** using **ADR Matching And Relationships**.
6. **Record the refinement** under `<design-output-dir>/adrs/` using **ADR Recording**.
7. **Apply the refinement** to every affected existing artifact using **Artifact Impact Routing**. Preserve unrelated content.
8. **Run a consistency review** across the design output directory. See **Consistency Review**.
9. **Report the transaction** using **Completion Report**, then remain ready for another refinement unless the user exits manual refinement.

If the task does not map cleanly to these steps, use your native planning tool only with the existing ADR, design-artifact, and consistency rules in this command. Do not invent a design stage, create implementation work, or treat non-decision conversation as a refinement.

## Waiting Posture

Waiting is conversational: return a short readiness response and yield the turn. Do not start a background process or write a session-state file.

- If `<design-output-dir>` is safely resolved, say that manual refinement is active for that directory and ask for the next design correction, constraint, decision, or clarification.
- If the directory is unresolved, ask the next refinement instruction to include the target design output directory.
- Treat a later message as a refinement only when it is decision-bearing. Questions, tentative suggestions, acknowledgements, and unrelated requests do not create ADRs.
- Remain in manual refinement after each applied transaction.
- Exit when the user says `done`, `stop`, or `cancel`, explicitly invokes another subcommand or skill, or clearly switches tasks.

If conversational context no longer establishes that manual refinement is active, require the user to invoke `manual-refine` again.

## ADR Matching And Relationships

Classify each cohesive decision in this order:

1. Use an explicitly named ADR identifier when provided.
2. If an existing ADR covers the same decision and the new instruction is compatible, update it as a follow-up.
3. If the instruction reverses or replaces an existing decision, create a new ADR, mark the old ADR `superseded by ADR-NNNN`, and link the new ADR back with `Supersedes: ADR-NNNN`.
4. If no ADR covers the decision, create a new ADR.
5. If the relationship is uncertain, create a new related ADR unless choosing follow-up versus supersession would materially affect the design history; ask one focused question in that case.
6. If the same instruction is already recorded and applied, report an idempotent no-op instead of duplicating it.

## ADR Recording

Create `adrs/` lazily on the first concrete refinement. For a new ADR, scan existing filenames, increment the highest four-digit prefix, and write `adrs/<NNNN>-<kebab-decision>.md` from `assets/templates/feature/adrs/adr.md`.

Direct, concrete user refinement instructions are accepted decisions. Tentative language such as “consider” or an unresolved question is not accepted until the user confirms a direction.

For a new ADR:

- Keep the context, current decision, and rationale concise.
- Record a faithful instruction summary; preserve literal names, values, commands, and contract wording exactly when they matter.
- List every artifact affected or examined.
- Initialize `## Refinement History` with the first instruction and applied changes.

For a compatible follow-up:

- Update the ADR's current decision to the consolidated effective decision.
- Append a dated entry under `## Refinement History` with the instruction, decision delta, and applied artifact changes.
- Preserve prior history.

When the first ADR is created, add an ADR link to the top-level feature `README.md` artifact map when that map exists. Do not require or create `adrs/README.md`.

## Artifact Impact Routing

| Refinement Concern | Update When Present |
| --- | --- |
| Goal, non-goals, users, workflows, requirements, boundaries, constraints | `feature-requirement.md` |
| Actor goals, actions, flows, errors, outputs, AI examples | Relevant `usecases/uc-*.md` and `usecases/README.md` when its index metadata changes |
| Commands, APIs, schemas, files, events, lifecycle, persistence | `design/public-interfaces.md` or the relevant module design |
| Module responsibility or design-document inventory | `design/README.md` |
| Agent-skill UX, workflow, subcommands, or external calls | Relevant `design/<slug>/design-overview.md` |
| Implementation scope, evidence, verification, or exclusions | Existing `agent-task.md` |
| Feature status, artifact map, related context, or open questions | Top-level `README.md` |

Revise only existing affected stage artifacts. If the decision requires a missing artifact, record the ADR, update the nearest existing source of truth when possible, and report the owning subcommand that should materialize the missing artifact. Do not invent a complete stage artifact through `manual-refine`.

## Consistency Review

Before reporting completion:

1. Confirm the ADR's current decision matches every changed artifact.
2. Search the remaining feature-design documents for stale terms, contradicted decisions, affected identifiers, and obsolete open questions.
3. Update directly affected indexes and cross-references.
4. Confirm no unrelated sections, public contracts, identifiers, or file paths changed.
5. Confirm no placeholders, implementation edits, or unrequested new stage artifacts were introduced.

If a contradiction cannot be resolved from the instruction, stop further document propagation, preserve the ADR draft only when its accepted meaning is clear, and ask the smallest question needed.

## Completion Report

Report:

- whether manual refinement is waiting, applied, or an idempotent no-op;
- ADR files created, updated, related, or superseded;
- design artifacts updated;
- the interpreted decision and any assumptions;
- consistency checks and unresolved questions;
- missing stage artifacts and their owning subcommands;
- that manual refinement remains active, unless the user exited it.

Do not start implementation through this subcommand.
