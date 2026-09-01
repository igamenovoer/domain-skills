---
name: imsight-project-design
description: Use when explicitly asked to use Imsight project design, Imsight SOP, this exact skill, or an Imsight-authored process to scaffold or revise feature planning, define a feature, propose or design use cases, design interfaces or agent skills, propose or design optional verification gates, plan high-level feature milestones, manually refine recorded design decisions, or write an implementation handoff.
---

# Imsight Project Design

## Overview

Use this skill as an Imsight project-design umbrella for designing staged aspects of a development project. The current supported scope is feature planning, so the available subcommands create or revise feature-design planning artifacts.

The skill behaves like a main command with subcommands: complete the requested project-design stage within the supported scope, report what changed, then pause unless the user explicitly asks for another stage.

This skill is portable across host projects. Resolve repository layout, package names, planning frameworks, and source trees from files the user provides or files discovered in the active host project.

## When to Use

- Use for explicit Imsight project-design or Imsight SOP requests.
- Use for the supported feature-planning stages listed below.
- Use `manual-refine` for conversational, user-directed design decisions that must be recorded as ADRs and propagated across existing artifacts.
- Use command form such as `$imsight-project-design use define-feature to ...`, or infer the narrowest command from a task-only request.

## Workflow

When this skill is invoked, execute these steps in order.

1. **Select a subcommand** from the **Subcommands** table. If the user wrote `use <subcommand>`, use that subcommand. If the user provided a task prompt without a subcommand, infer the narrowest applicable subcommand. If no subcommand is named and the task is ambiguous, run `help`.
2. **Resolve the feature design directory** when the current feature-planning subcommand writes artifacts. See **Feature Planning Output Directory**.
3. **Load the command detail page** from the **Subcommands** table and execute its workflow.
4. **Pause after the subcommand**. Summarize created or changed files, unresolved decisions, and the likely next subcommand. Do not continue into another stage unless the user explicitly asks.

If the task does not map cleanly to the currently supported feature-planning workflow, explain the closest available subcommand and ask for the missing decision before writing artifacts. If the task concerns another project-design aspect, state that the skill is intended to expand in that direction but the current command set only supports feature planning.

## Subcommands

### Procedural Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `scaffold` | Create a feature design directory and placeholder planning skeleton | `commands/scaffold.md` |
| `define-feature` | Create or update `<feature-dir>/feature-requirement.md` | `commands/define-feature.md` |
| `propose-usecase` | Propose new use case candidates in chat without writing files until the user confirms a selection or delegates the decision | `commands/propose-usecase.md` |
| `design-usecase` | Create or update one matched use case under `<feature-dir>/usecases/` | `commands/design-usecase.md` |
| `design-interface` | Create or update interface and contract docs under `<feature-dir>/design/` | `commands/design-interface.md` |
| `design-skill` | Generate a skill design overview under `<feature-dir>/design/<slug>/` for agent-skill features | `commands/design-skill.md` |
| `propose-gates` | Propose verification gate candidates in chat without writing files until the user confirms a selection or delegates the decision | `commands/propose-gates.md` |
| `design-gates` | Create or update optional verification gates under `<feature-dir>/gates/` | `commands/design-gates.md` |
| `plan-feature` | Create or update `<feature-dir>/feature-milestones.md` as a high-level milestone plan | `commands/plan-feature.md` |
| `design-agent-task` | Create or update `<feature-dir>/agent-task.md` as an implementation handoff | `commands/design-agent-task.md` |

### Helper Subcommands

No helper subcommands are currently exposed.

### Misc Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `manual-refine` | Wait for user-directed refinements, record them as ADRs, and update affected design artifacts | `commands/manual-refine.md` |
| `help` | Explain this skill and list subcommands | `commands/help.md` |

## Feature Planning Output Directory

When output artifacts are involved, resolve the feature design directory in this order:

1. Use an absolute or host-project-relative output location explicitly provided by the user.
2. If the user is targeting an OpenSpec change directory and is not continuing an existing feature design directory, use `<openspec-change-dir>/imsight-design/`. An OpenSpec change directory contains `.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md`, and/or `specs/`. [OpenSpec](https://github.com/Fission-AI/OpenSpec) is a structured, artifact-driven spec workflow; when the prompt names a change directory or references change-specific artifacts, treat that change as the design scope.
3. If no user location is provided and `IMSIGHT_SKILL_OUTPUT_DIR` is set, use that directory. Resolve relative values against the active host project directory.
4. If neither is provided, use `<host-project-dir>/.imsight-arts/feature-design/<YYYY-MM-DD-kebab-feature-name>/` with the current local date.

If the user gives an artifact root and a feature name, create or update `<artifact-root>/<YYYY-MM-DD-kebab-feature-name>/` unless the root already names the intended feature design directory. If the task appears to continue an existing feature, search the user-provided location, then `IMSIGHT_SKILL_OUTPUT_DIR`, then `.imsight-arts/feature-design/`, then `<openspec-change-dir>/imsight-design/` when applicable, for matching directory names, README titles, feature requirement titles, or use case summaries before creating a new directory.

For update subcommands, preserve unrelated sections and revise only the target artifact.

### OpenSpec synchronization

When the feature design directory is inside an OpenSpec change (i.e., `<openspec-change-dir>/imsight-design/`), also scan the OpenSpec change artifacts — `proposal.md`, `design.md`, `tasks.md`, and specs under `specs/` — for references to the same goals, interfaces, terms, or decisions. If a new design artifact contradicts or extends the OpenSpec artifacts, update the relevant OpenSpec documents or flag the inconsistency to the user before proceeding.

## Current Artifact Contracts

`README.md`: Feature design index with purpose, status, artifact map, related context, and open questions.

`feature-requirement.md`: Feature requirement baseline with goal, non-goals, users or stakeholders, workflows, functional requirements, system boundaries, operational constraints, assumptions, and open questions.

`usecases/README.md`: Use-case index with identifiers, titles, status, and notes.

`usecases/uc-XX-<slug>.md`: One feature use case describing an actor-system or system-system workflow, supported actions, main flow, alternative/error flows, durable outputs, assumptions, and open questions. For agent-skill designs, include an example prompt and expected example AI response.

`design/README.md`: Design index and module/interface map.

`design/public-interfaces.md`: Default public interface and contract design file. Split into module-specific files only when the interface surface becomes large, files already exist, or the user asks for module files.

`design/<slug>/design-overview.md`: Skill design overview generated by the `design-skill` subcommand for agent-skill features. `<slug>` is derived from the proposed skill name in no more than six words.

`gates/NN-<slug>.md`: One optional verification gate created by `design-gates`, with gate ID, status, cadence, rationale, evaluation data, expected results, functionality checked, and an audit-evidence contract. Gates form an ordered ladder from cheap checks to release-only qualification. Create `gates/` lazily only when the user asks for gates; gate files are planning-stage specs and never contain run results, verdicts, or evidence links. The feature `README.md` carries the gate index.

`feature-milestones.md`: High-level implementation milestone plan created by `plan-feature`. Each milestone states the capabilities it enables and the verifiable outcomes that mark it done, without prescribing files, modules, or code changes. Milestones, enabled capabilities, and done-when outcomes are Markdown checkboxes so progress can be ticked off.

`adrs/<NNNN>-<slug>.md`: A user-directed design decision or follow-up refinement recorded by `manual-refine`, with its current decision, affected artifacts, and refinement history. Create `adrs/` lazily when the first concrete refinement is applied.

`agent-task.md`: Compact implementation handoff with objective, use case references, design references, implementation instructions, verification expectations, required evidence, out-of-scope work, and open questions.

## Templates

Use placeholder templates from `assets/templates/feature/` when creating new files. `scaffold` copies only the baseline folder skeleton templates. Design subcommands may copy the more specific templates before replacing placeholders with substantive content. `design-gates` uses `assets/templates/feature/gates/gate.md` for new gates but does not add gates during scaffolding. `manual-refine` uses `assets/templates/feature/adrs/adr.md` for new ADRs but does not add ADRs during scaffolding.

## Guardrails

- DO NOT overwrite an existing feature design folder during `scaffold` unless the user explicitly asks.
- DO NOT assume a host-project layout or convention that user input and repository inspection did not establish.
- DO NOT treat activation, questions, tentative suggestions, or unrelated conversation as approved refinements.

## Troubleshooting Guide

- Running every subcommand end to end
  - If you are running every subcommand end to end, then complete only the requested subcommand and pause for review.
- Treating `scaffold` as design
  - If you are treating `scaffold` as design, then copy only the placeholder templates and defer substantive design to the appropriate design subcommand.
- Treating feature planning as the permanent boundary of this skill
  - If you are treating feature planning as the permanent boundary of this skill, then preserve the broader project-design framing and recognize feature planning as only the currently supported scope.
- Ignoring the Imsight output contract
  - If you are ignoring the Imsight output contract, then resolve the feature design directory by explicit user location first, then `IMSIGHT_SKILL_OUTPUT_DIR`, then `.imsight-arts/feature-design/`.
- Creating duplicate use cases for the same workflow
  - If you are creating duplicate use cases for the same workflow, then match existing use case titles, slugs, actors, goals, and summaries before choosing the next identifier.
- Writing use case files when the user asked only for proposals
  - If you are writing use case files when the user asked only for proposals, then route to `propose-usecase` and keep candidates in chat until the user confirms a selection or delegates the decision.
- Designing interfaces without reading use cases
  - If you are designing interfaces without reading use cases, then derive commands, routes, schemas, files, events, storage contracts, or service boundaries from actual use case flows.
- Making `agent-task.md` too broad
  - If you are making `agent-task.md` too broad, then write minimal implementation instructions tied to stabilized feature, use case, and interface artifacts.
- Writing milestones as an implementation plan
  - If you are writing milestones as an implementation plan, then keep each milestone at the capability level and describe what must be enabled after it, not what code goes in which file.
- Using `design-interface` to design an agent skill
  - If you are using `design-interface` to design an agent skill, then invoke `design-skill` instead because `design-interface` writes non-skill interface and contract artifacts.
- Scaffolding gates by default
  - If you are scaffolding gates by default, then leave `gates/` out of the skeleton because gates are optional and only `design-gates` creates them when asked.
- Writing gate files when the user asked only for proposals
  - If you are writing gate files when the user asked only for proposals, then route to `propose-gates` and keep candidates in chat until the user confirms a selection or delegates the decision.
- Writing execution results into gates
  - If you are writing execution results into gates, then remove run verdicts, run identifiers, and evidence links because `design-gates` writes planning-stage specs and execution updates status and evidence later.
- Updating one artifact without propagating a recorded refinement to other affected design documents
  - If you are updating one artifact without propagating a recorded refinement to other affected design documents, then run the `manual-refine` consistency review across affected artifacts.
