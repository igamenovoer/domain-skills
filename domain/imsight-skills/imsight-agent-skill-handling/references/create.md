# Create Skill

## Workflow

Use this reference to create a new skill from a user request. Because `imsight-agent-skill-handling` is manually invoked, respect the user's intent: do not force a failing baseline or a post-creation verification run. Capture what the user wants, choose the right shape for the skill, write a minimal and format-compliant role-canonical entrypoint, validate its structure, and return a brief summary. Leave pressure testing to the explicit `test` subcommand.

1. **Confirm the task and locate the skill home**. See **Skill Home**.
2. **Capture intent** from the user's request and conversation history. See **Intent Capture**.
3. **Classify the skill type** based on what it must do. See **Skill Type**.
4. **Choose the subcommand structure flavor** if the skill needs subcommands. See **Subcommand Structure**.
5. **Initialize the standard skill layout** in the skill home. See **Skill Layout**. Create only the directories and files the skill's shape requires; skip anything that already exists and never overwrite existing files.
6. **Author a minimal role-canonical entrypoint** that captures the requested behavior and is already format-compliant. Use `SKILL.md` for the top-level skill and `SKILL-MAIN.md` for each bundled subskill. See **Authoring the Skill**.
7. **Validate** the skill frontmatter and structure. See **Validation**.
8. **Return a brief in-chat summary** that lists the files written and the validation result.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the available writing guidance and the user's request, then execute the plan.

## Skill Home

Use the skill home explicitly provided by the user. Agent runtimes typically discover skills at runtime through `.agents/skills/`, which may be a real folder or a symlink to a committed skill location such as `skillset/`.

- If the user provides a target path, use it as the skill home.
- Otherwise, default to `.agents/skills/<skill-name>/` under the current project root.
- If the directory does not exist, create it.

## Intent Capture

Start by understanding what the user wants the skill to do. If the current conversation already contains a workflow the user wants to capture (for example, "turn this into a skill"), extract answers from the conversation history first: the tools used, the sequence of steps, corrections the user made, and input/output formats observed.

Resolve these questions before writing:

1. What should this skill enable the agent to do?
2. When should this skill be invoked? (user phrases or contexts)
3. What is the expected output format?

Confirm the answers with the user before proceeding to the next step.

## Skill Type

Choose the type that best matches the skill's purpose:

| Type | Description | Example |
| --- | --- | --- |
| Technique | Concrete method with steps to follow | condition-based-waiting |
| Pattern | Way of thinking about problems | flatten-with-flags |
| Reference | API docs, syntax guides, tool documentation | office docs |
| Discipline-enforcing | Rules that agents might rationalize away | TDD, verify-before-completion |

The skill type determines how you test and harden it.

## Subcommand Structure

If the skill needs subcommands, choose the structure from the skill's functionality.

Use the collection-of-routines flavor when subcommands are peer routines, tools, or functions and their calling order is absent, flexible, or task-specific. Write one plain `## Subcommands` section with a table.

Use the complex-procedure flavor when the skill describes a multi-step procedure, each step may have its own sub-workflow or reference page, and some steps depend on artifacts produced by earlier steps. Split `## Subcommands` into:

- `### Procedural Subcommands` for user-facing workflow steps.
- `### Helper Subcommands` for lower-level implementation commands called by procedural subcommands.
- `### Misc Subcommands` for `help` and public shortcuts such as `fast-forward` or `step-by-step`.

For complex-procedure skills, put procedural subcommands in user-facing workflow order, keep helper subcommands out of help output unless promoted, and say `No helper subcommands are currently exposed.` when the helper group is empty.

A subcommand may own child subcommands when it represents a command object with its own scoped operations. Put a `## Subcommands` table on the parent command page, link each direct child detail page there, and record the full invocation chain. Treat an intermediate `parent()` as an object generator for its child rather than automatically executing the parent's standalone action. Use nesting only when the child is meaningful specifically within the parent command context; keep independent peer operations as direct subcommands. Keep all command detail and support files within the containing skill or subskill's resource boundary.

Use resource ownership as the subcommand-versus-subskill decision. Keep a capability as a direct or nested subcommand when it can use resources owned by its containing skill or subskill. Make it a bundled subskill under `subskills/<subskill-name>/` when it needs its own private `scripts/`, `references/`, `commands/`, `assets/`, templates, runtime metadata, or other resource tree. Private means scoped ownership, not secrecy. See **Skill Layout** and [skill-layout.md](skill-layout.md).

When the shape includes subskills, capture the decisive trigger for each child and write one parent-oriented `When to Route Here` sentence in the parent's subskill inventory. Use the child frontmatter, agent summary, and `## When to Use` guidance as evidence, but remove context already established by the parent and do not copy those source descriptions verbatim. Keep the child's complete trigger boundaries and workflow in its own `SKILL-MAIN.md`; the parent sentence only supports route selection.

## Skill Layout

A host-discoverable skill folder follows the OpenAI skill-creator layout: a required `SKILL.md`, a recommended `agents/openai.yaml`, and optional bundled resource directories (`scripts/`, `references/`, `assets/`). A parent-scoped subskill follows the same resource layout but uses `SKILL-MAIN.md` so recursive exact-`SKILL.md` scanners do not register it independently. See [skill-layout.md](skill-layout.md) for the full layout, including the Imsight `commands/` convention for subcommand detail pages and the Imsight `subskills/` convention for bundled nested skills.

When initializing a skill:

- Create `SKILL.md` for the top-level skill root.
- Create `agents/openai.yaml` unless it already exists. Generate it from the skill content.
- Create `scripts/` only when the skill bundles executable code.
- Create `references/` only when the skill has detail pages, style guides, schemas, or other reference material.
- Create `assets/` only when the skill bundles static resources used in output.
- Create `commands/` only when the skill has subcommand detail pages.
- Create `subskills/` only when a nested capability needs its own private bundled-resource boundary. Each subskill is a self-contained skill folder with its own `SKILL-MAIN.md` and follows the resource layout recursively; if that subskill owns children, those children also use `SKILL-MAIN.md`.
- Do not create empty directories purely for symmetry.
- If the target skill home already exists, do not overwrite or remove any existing files or directories. If the role-canonical entrypoint already exists and conflicts with the new skill, stop and report the conflict. If both `SKILL.md` and `SKILL-MAIN.md` exist, report ambiguous scope and do not choose one silently.

## Authoring the Skill

Write a minimal role-canonical entrypoint that captures the user's request: `SKILL.md` for the top-level skill and `SKILL-MAIN.md` for each parent-scoped subskill. Write it in format-compliant form from the start; do not rely on a later `format` pass to fix structure or description.

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
- Add the optional `skill_invocation_notation` key when the page uses object-style invocation designators; use the standard value from `references/imsight-skill-style-guide.md`.

### Required Sections

1. **## Overview** — core principle in 1-2 sentences.
2. **## When to Use** — symptoms and contexts that trigger this skill. Include when NOT to use.
3. **## Workflow** or **Core Pattern** — the technique, pattern, or rule the agent must follow.
4. **## Guardrails** — a short bullet list of "DO NOT ..." rules that prevents actions contrary to the skill's design intent.

### Optional Sections

- **## Troubleshooting Guide** — a nested bullet list of problems the agent may encounter while executing the skill and the corrective action to take for each. Include this section only when the skill writer sees fit; do not add it as a placeholder.

Write guardrails as a concise bullet list. Start every item with **"DO NOT ..."** and state one prohibited action. Keep the list sparse and include only prohibitions that materially protect the skill's intent.

Put positive actions, required operations, ordering, recipes, and output requirements in the workflow, core pattern, procedure, contract, or another substantive section of the skill. Do not use guardrails to present operation steps, repeat the workflow, or create a second procedural checklist.

Write the troubleshooting guide as a two-level nested bullet list. The first level names the problem. The second level states the solution or corrective action. Use the form "If <problem>, then <action>." for the solution.

Focus on problems tightly related to the actions described by this skill. Avoid universal common-sense troubleshooting that applies to any skill. Keep the list sparse, concise, and stick to essentials; include only problems an agent is likely to hit while executing this skill's workflow. Do not restate guardrails or general workflow steps.

Write the workflow as numbered steps. Keep each step concise and point to a detail section when it needs more explanation. If a main step has several internal branches or substeps, present them as a nested list under that step instead of a long paragraph. Keep the nesting depth to three levels or fewer. End with a fallback for freeform tasks. Move long procedural detail, examples, edge cases, and configuration notes out of the workflow into dedicated sections or `references/<page>.md` files.

When the skill has subcommands, apply **Subcommand Structure** before writing the `## Subcommands` section. Do not use the three-type split for a simple collection of unordered routines.

When the skill bundles subskills, list them in the `## Subcommands` table or a dedicated `## Subskills` section of the parent's role-canonical entrypoint so it can route invocation designators. Include one `When to Route Here` sentence for every direct subskill, written from the parent entrypoint's context and distinct from the child's frontmatter description or agent short description. Tell the parent to load only the selected child's `SKILL-MAIN.md` and required local resources. Write skill and subskill entrypoints as bare paths such as `X->Y`. Write every subcommand component with `()`, including intermediate object generators in chains such as `X->parent()->child()`, and never use `X()` or `X->Y()` for an entrypoint. Once a command chain begins, do not append a bare skill or subskill component. A direct subskill and direct subcommand may share a name because their component forms distinguish them. When any page uses these object-style invocation designators, declare the notation in that page's YAML frontmatter with the `skill_invocation_notation` key; use the standard value from `references/imsight-skill-style-guide.md`.

For discipline-enforcing skills, also include:

- A foundational principle such as "Violating the letter of the rules is violating the spirit of the rules."
- A rationalization table.
- A red flags list.

### Form That Matches the Purpose

Choose the guidance form based on what the skill must prevent or produce:

| Problem the skill solves | Right form |
| --- | --- |
| Skips/violates a rule under pressure | Prohibition + rationalization table + red flags |
| Output has wrong shape | Positive recipe or contract: state what the output IS |
| Omits a required element | Structural: REQUIRED field or slot in template |
| Behavior should depend on a condition | Conditional keyed to an observable predicate |

Keep the skill concise. One excellent example beats many mediocre ones.

### Skill-Based Use Case Examples

When the user asks for a skill-based use case, or when a new skill includes use-case or chat-turn examples, design the example around the visible conversational contract:

- Show the triggering user prompt or user action.
- Show the expected final AI response shape: decisions, files, commands, diagnostics, durable outputs, validation, or next-step guidance.
- Do not show hidden reasoning, chain-of-thought, scratchpad notes, private tool-selection deliberation, or a thinking process as part of the AI response unless the user explicitly asks the skill to document that process.
- If process context matters, express it as observable actions or decisions, such as "I will inspect the manifest, then run validation," rather than internal thoughts.
- Keep the example concrete enough to guide implementation, but avoid a brittle full transcript unless the user requests transcript fidelity.
- Add a visible warning near the examples stating that the user/AI chat content is for example purposes only and that implementations should learn its style, intent, and semantics rather than hardcoding the example content.

## Validation

Validate the skill before finishing:

1. Confirm the top-level `SKILL.md` exists and has valid YAML frontmatter with `name` and `description`.
2. Confirm `name` matches the directory name for project-scoped skills.
3. Confirm the description starts with "Use when...", is in third person, and does not summarize the workflow.
4. Confirm the overview, when-to-use, and workflow/core-pattern sections exist. Confirm a guardrails section exists, every guardrail starts with "DO NOT ...", and the section contains no positive requirements or operation steps.
5. Confirm the workflow is a concise numbered list with a freeform fallback.
6. Confirm long detail has been moved out of the workflow into dedicated sections or reference pages.
7. If subcommands exist, confirm the selected subcommand structure flavor matches the skill functionality.
8. If the skill bundles subskills, confirm each `subskills/<subskill-name>/SKILL-MAIN.md` exists with valid frontmatter, no sibling `SKILL.md`, and follows this same checklist; confirm the parent's role-canonical entrypoint lists every direct subskill in its `## Subcommands` table or a `## Subskills` section, explicitly loads the selected child's `SKILL-MAIN.md`, and gives every row one context-aware `When to Route Here` sentence that distinguishes sibling routes without copying child metadata.
9. If a subcommand owns children, confirm its page declares each direct child in `## Subcommands`, links the child detail page, defines terminal behavior for invoking the parent without a child, and keeps all child support resources within the containing skill or subskill's resource boundary.
10. If any page uses object-style invocation designators such as `X->Y`, `X->Y->cmd()`, or `X->parent()->child()`, confirm that page declares the `skill_invocation_notation` key in its YAML frontmatter.
11. Confirm every skill or subskill entrypoint designator is a bare object path, every subcommand component has `()`, every intermediate command resolves to the immediate child it declares, and no command chain returns to a bare skill or subskill component.
12. If a direct subskill and direct subcommand share a name, confirm their declarations and uses preserve the bare subskill form and parenthesized subcommand form.
13. Confirm every capability with a private bundled-resource tree is a skill or subskill rather than a subcommand, and confirm each subcommand uses resources owned by its containing skill or subskill.
14. If the skill includes use-case or chat-turn examples, confirm AI response examples show only visible response content and do not expose hidden reasoning or thinking process unless the user explicitly requested that, and confirm the examples include a visible warning that the user/AI chat content is for example purposes only and that implementations should learn its style, intent, and semantics rather than hardcoding the example content.
15. If a skill validator such as `skill-creator/scripts/quick_validate.py` is available, run it on the target skill folder.

Report any validation failures and fix them before returning the summary.

## Pressure Testing

Do not run pressure scenarios as part of `create`. After the skill is written, the user can run the `test` subcommand explicitly to baseline natural failure or verify compliance. If the user wants a failing baseline before writing, invoke `test` in baseline mode first, then run `create`, then invoke `test` in verify mode.

## Output Contract

By default, `create` writes files inside the target skill folder and returns a brief chat summary. It does not produce analysis reports under `<output-dir>`.

The chat summary must include:

- The skill folder path.
- The skill type chosen.
- Files written or changed.
- Validation result.
- Next recommended step (for example, run `test` pressure scenarios or hand off for review).
