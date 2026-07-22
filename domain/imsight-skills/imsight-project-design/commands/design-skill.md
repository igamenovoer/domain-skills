# Design Skill

## Workflow

When this subcommand is invoked, execute the following steps in order.

1. **Confirm the task and capture intent**. See **Intent Capture**.
2. **Classify the skill type** based on what it must do. See **Skill Type**.
3. **Choose the subcommand structure flavor**. See **Subcommand Structure**. Default to a multi-subcommand skill with a `help` subcommand unless the task clearly maps to a single technique or pattern.
4. **Propose a name and description** that conform to the Imsight skill format. See **Authoring the Proposed SKILL.md**.
5. **Resolve the output location** using **Output Contract**.
6. **Draft the design overview document** by reading and adapting **Design Document Template**.
7. **Validate the design document** using **Validation**.
8. **Write the output file** and return a concise chat summary with the file path, proposed skill name, and next recommended step.

If the user's task does not map cleanly to these steps, make reasonable assumptions, document them in `## Open Questions`, and flag them for the designer.

## Intent Capture

Start by understanding what the user wants the proposed skill to do. If the current conversation already contains a workflow the user wants to capture, extract answers from the conversation history first: the tools used, the sequence of steps, corrections the user made, and input/output formats observed.

If the user did not already provide the following, ask before drafting:

1. What should this skill enable the agent to do?
2. When should this skill be invoked? (user phrases or contexts)
3. What is the expected output format?

If the intent is unclear, make reasonable assumptions, document them in `## Open Questions`, and flag them for the designer.

## Skill Type

Choose the type that best matches the skill's purpose. The type influences how the design is tested and hardened later.

| Type | Description | Example |
| --- | --- | --- |
| Technique | Concrete method with steps to follow | condition-based-waiting |
| Pattern | Way of thinking about problems | flatten-with-flags |
| Reference | API docs, syntax guides, tool documentation | office docs |
| Discipline-enforcing | Rules that agents might rationalize away | TDD, verify-before-completion |

## Subcommand Structure

Default to a **multi-subcommand** skill that includes a `help` subcommand. This shape is general enough to handle procedural workflows, collections of routines, and mixed skills.

Use the **collection-of-routines** flavor when subcommands are peer routines, tools, or functions and their calling order is absent, flexible, or task-specific. Under `## Subcommands Design`, write one plain table.

Use the **complex-procedure** flavor when the skill describes a multi-step procedure, each step may have its own sub-workflow or reference page, and some steps depend on artifacts produced by earlier steps. Under `## Subcommands Design`, split subcommands into:

- `### Helper Subcommands` for lower-level implementation commands called by procedural subcommands.
- `### Procedural Subcommands` for user-facing workflow steps.
- `### Misc Subcommands` for `help` and public shortcuts such as `fast-forward` or `step-by-step`.

For complex-procedure skills, put procedural subcommands in user-facing workflow order within their table, keep helper subcommands out of help output unless promoted, and say `No helper subcommands are currently exposed.` when the helper group is empty.

Override the multi-subcommand default only when the task clearly maps to a single technique or pattern with no meaningful subcommands. Document the override reason in the design overview.

### Subcommand Design Guide

Group CRUD operations that target the same domain object into one subcommand with action arguments. Prefer `manage-toolbox` over separate `list-toolboxes`, `show-toolbox`, `enable-toolbox`, `disable-toolbox`, and `uninstall-toolbox` subcommands unless the actions have different audiences, safety gates, or workflow dependencies.

Use separate subcommands for different user goals, not for every verb. A smaller subcommand surface is easier to route, document, test, and explain.

Example:

- Do: `manage-toolbox` with actions such as `list`, `show`, `enable`, `disable`, `update-source`, and `uninstall`.
- Do not: separate public subcommands named `list-toolboxes`, `show-toolbox`, `enable-toolbox`, `disable-toolbox`, `update-toolbox-source`, and `uninstall-toolbox`.

## Authoring the Proposed Skill

Define the proposed skill's frontmatter and core sections. Do not embed a full `SKILL.md` draft inside the design document; instead, capture the skill shape concisely and list subcommands in `## Subcommands Design`.

### Required Frontmatter

```yaml
---
name: <skill-name>
description: Use when <specific triggering conditions and symptoms>
---
```

Rules for the frontmatter:

- `name` must use letters, numbers, and hyphens only.
- `description` must start with "Use when..." and describe triggering conditions only. Do not summarize the workflow.
- Keep the description under 500 characters if possible, 1024 maximum.
- Write in third person.
- Include keywords agents would search for: error messages, symptoms, tools, library names.

### Design Content to Capture

1. **Purpose** — why the skill exists and who owns routing, blockers, and final output.
2. **Concepts** — small user-facing vocabulary needed to read the workflow and examples.
3. **Core Workflow** — concise numbered steps plus a freeform fallback.
4. **Subcommands Design** — subcommands derived from **Subcommand Structure**.
5. **External Calls** — services or skills the proposed skill depends on instead of reimplementing.

When the proposed skill has subcommands, apply **Subcommand Structure** before writing `## Subcommands Design`.

For discipline-enforcing skills, also include:

- A foundational principle such as "Violating the letter of the rules is violating the spirit of the rules."
- A rationalization table.
- A red flags list.

## Output Contract

By default, this subcommand writes one Markdown document named `design-overview.md` inside the already-resolved project-design feature directory. The feature directory is resolved by the entry workflow before this subcommand runs; do not re-resolve it.

Write the design overview to `<feature-dir>/design/<slug>/design-overview.md`, where `<slug>` is derived from the proposed skill name and contains no more than six words.

Derive `<slug>` from the proposed skill `name` by taking up to the first six meaningful words, lowercasing, and joining with hyphens. If the skill name is shorter than six words, use the full name.

Do not write any other skill files. Do not create `SKILL.md`, `agents/openai.yaml`, `references/`, `commands/`, `scripts/`, or `assets/` directories for the proposed skill.

## Design Document Template

Read `assets/templates/feature/design/skill-design-overview.md` and use it as the default scaffold for `design-overview.md`. Copy the template, replace placeholders with concrete content from the proposed skill design, remove sections that do not apply, and keep the document self-contained.

Keep the overview concise. Prefer the sections in the template over older heavy sections such as `Proposed File Inventory`, `Formal Skill Process`, `Skill Process Explanation`, or `Evidence Handoffs`.

When adapting the template:

- Keep `## Concepts` to the small user-facing vocabulary needed to read the workflow and examples.
- Use `## Subcommands Design` for exposed workflows and lower-level primitives.
- Use `## Core Workflow Diagram` for the normal request-to-result sequence.
- Use `## Calls To External Skills` only for dependencies outside the proposed skill, not internal helper subcommands.

## Validation

Validate the design document before writing the output file:

1. Confirm the proposed skill frontmatter has valid YAML with `name` and `description`.
2. Confirm `name` uses letters, numbers, and hyphens only.
3. Confirm the description starts with "Use when...", is in third person, and does not summarize the workflow.
4. Confirm the design document includes `Purpose`, `Concepts`, `Core Workflow`, `Subcommands Design`, `Core Workflow Diagram`, `Calls To External Skills`, examples, and open questions.
5. Confirm the core workflow is a concise numbered list with a freeform fallback.
6. Confirm long procedural detail has been moved out of the workflow into dedicated sections or future reference pages.
7. If subcommands exist, confirm the selected subcommand structure flavor matches the proposed skill functionality and the subcommands are listed in the correct table(s).
8. Confirm `Calls To External Skills` lists only external dependencies, not internal helper subcommands.
9. Confirm the output location is inside the already-resolved project-design feature directory.
10. Confirm the design document does not propose writing actual skill files.
11. If the design includes user/AI chat examples, confirm they include the example-content warning.

Report any validation failures and fix them before writing the output file.

## Chat Response

Return a brief response with:

- output file path,
- proposed skill name,
- subcommand structure flavor chosen,
- validation notes or unresolved assumptions,
- next recommended step (usually continue with `design-interface` for non-skill contracts or move to `design-agent-task`).
