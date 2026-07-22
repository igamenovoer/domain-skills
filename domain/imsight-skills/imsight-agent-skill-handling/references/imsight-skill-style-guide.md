# Imsight Skill Style Guide

This is the local bundled copy of the Imsight skill style guide used by `format`. Do not depend on a style-guide file outside this skill directory at runtime.

## Overview

This guide specifies a small set of structural rules that every skill must follow. It is intentionally minimal: it does not prescribe a fixed section order, dictate writing style, or prevent skill writers from adding additional sections as they see fit. Writers may include any other sections (references, examples, configuration notes, etc.) in whatever order and style works best for their skill, as long as the rules below are satisfied.

## Workflow section (required)

Every skill and subcommand-like page must have a `## Workflow` section near the top. This is the agent's entrypoint.

- Write it as **numbered steps** the agent executes in order.
- Keep each step concise. If a step needs detailed rules, reference another section: `See **Pre-Exploration Scan**.`
- End with a fallback for freeform tasks: if the task does not map cleanly to the default steps, tell the agent to use its native planning tool to build a step-by-step plan using the tools, constraints, or subcommands provided by the skill, then execute the plan.

## Referencing details

When a step needs detail that is too long for the workflow line, state the step at a high level and reference the detailed section by name. Do not inline long procedures inside the workflow.

## Multiple-choice steps

When a workflow step involves choosing among modes, subcommands, or procedures:

- State the choice in the workflow step, for example: "Select an exploration mode from the **Exploration Modes** table."
- Let the agent decide which option fits the user's task, using the information provided in the skill.
- Do not hardcode the choice; present the options and constraints so the agent can reason about them.

## Subcommand structure flavor

Choose the subcommand structure from the skill's functionality.

### Collection-of-routines flavor

Use one plain `## Subcommands` section when the skill is a collection of related routines rather than a complex procedure.

This flavor fits skills where:

- Subcommands are peer functions, tools, or routines.
- The normal calling order is absent, flexible, or task-specific.
- The skill does not describe one complex multi-step workflow.
- Most subcommands can be invoked independently without predecessor artifacts from earlier subcommands.

For this flavor, one table is enough:

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `analyze` | Analyze existing data | `commands/analyze.md` |
| `generate` | Generate new artifacts | `commands/generate.md` |

### Complex-procedure flavor

Use the three-type split when the skill describes a complex procedure with multiple steps, where each step has its own sub-workflow and a separate detail page.

This flavor fits skills where:

- The skill has a normal user-facing execution flow.
- Several workflow steps have their own reference pages.
- Some steps depend on artifacts produced by earlier steps.
- The skill benefits from shortcuts such as `fast-forward` or `step-by-step`.

For this flavor, divide the `## Subcommands` section into Procedural Subcommands, Helper Subcommands, and Misc Subcommands.

### Procedural subcommands

Procedural subcommands are the user-facing single-step workflow API. They represent the normal public execution steps a caller may invoke directly.

- Name them as short kebab-case verb phrases, such as `init-topic`, `derive-gate`, or `verify-gate`.
- Put them in the user-facing workflow order when an order exists.
- State required predecessor artifacts on the subcommand detail page. If those artifacts are missing, the subcommand should refuse to run and explain which earlier subcommand should create them.
- Include procedural subcommands in help output.

### Helper subcommands

Helper subcommands are lower-level implementation commands called by procedural subcommands. They are analogous to private API: callers can still invoke them, but the skill should not steer ordinary users toward them.

- Add helper subcommands only when they reduce real complexity or repetition.
- Keep helper names short, kebab-case, and action-oriented.
- Keep helper subcommands out of help output unless the helper is promoted to a public workflow step.
- If a complex skill has no helper subcommands, say so explicitly: `No helper subcommands are currently exposed.`

### Misc subcommands

Misc subcommands are public support commands and shortcuts that do not represent one normal procedural step.

- Put `help` here when the skill supports help.
- Put shortcuts such as `fast-forward` or `step-by-step` here. `fast-forward` should run the full procedural workflow automatically. `step-by-step` should run the same required workflow but pause for user confirmation between stages.
- Include misc subcommands in help output because they are part of the public interface.

### Nested subcommands

A subcommand may define child subcommands. Treat such a parent subcommand as an object generator: when another `->child()` component follows it, the parent establishes the scoped command context and exposes only the children declared by its own `## Subcommands` section.

- List every direct child in the immediate parent subcommand page and link the child's executable detail page.
- Use `X->parent()->child()` to invoke child subcommand `child` defined by parent subcommand `parent` of skill `X`. A child may generate another command object, so chains may continue to any declared depth.
- Treat the complete chain as one invocation of the terminal child. An intermediate parent applies only generator or inherited-context behavior that its contract explicitly declares; it does not automatically execute its standalone terminal action.
- When `X->parent()` is terminal, invoke the parent subcommand's own declared workflow. A routing-only parent must define its terminal help, selection, or blocker behavior explicitly.
- Once a command chain begins, every remaining component is a subcommand and therefore includes `()`. Do not route from an intermediate subcommand to a bare skill or subskill component.
- A child name is scoped to its immediate parent command. Record and validate the full command chain rather than resolving the child by its unqualified name.
- Keep nested subcommands inside the resource boundary of their containing skill or subskill. A parent command may own child routes and detail pages, but it does not own a private bundled-resource root.

## Subskills

A skill may bundle nested skills under `subskills/<subskill-name>/`. Each subskill is a self-contained skill folder with its own required `SKILL-MAIN.md` and, when needed, the same optional bundled resource directories (`agents/`, `references/`, `commands/`, `scripts/`, `assets/`) as a top-level skill. Standalone and host-discoverable roots use `SKILL.md`; the distinct nested filename prevents exact-`SKILL.md` scanners from registering the subskill independently.

Read the structure with object semantics: the main skill is an object, its role-canonical entrypoint is the object's entrypoint, and a subskill is an inner object of the main skill. A subskill is scoped to and owned by its parent skill; it is not independently installed or discovered.

- Use a subskill when a capability needs its own private resource boundary, such as dedicated `scripts/`, `references/`, `commands/`, `assets/`, templates, or runtime metadata, while remaining meaningful only as part of the parent skill. Private means scoped ownership here, not secrecy or access control.
- Use a subcommand, including a nested subcommand, when the procedure can operate with resources owned by its containing skill or subskill. A subcommand may have an executable detail page and child subcommands, but it does not own an independent bundled-resource tree.
- Promote a subcommand to a subskill when it acquires resources that should be maintained, loaded, validated, or distributed as its own bundle. Size or workflow complexity alone does not require promotion.
- List bundled subskills in the parent's role-canonical entrypoint, either in the `## Subcommands` table or in a dedicated `## Subskills` section, so the entrypoint can route invocation designators.
- Give every direct subskill one `When to Route Here` sentence in that parent table. Synthesize the sentence from the child's frontmatter description and `## When to Use` guidance, omit context already established by the parent, retain the condition that distinguishes sibling routes, and do not copy the child description or agent short description verbatim. The sentence is routing guidance, not a replacement for explicitly loading the selected child's `SKILL-MAIN.md`.
- Every rule in this guide applies to each subskill's `SKILL-MAIN.md` and subcommand-like pages as well.
- Inspection and migration may read a nested `SKILL.md` only as legacy input when `SKILL-MAIN.md` is absent. Creation and formatting normalize it to `SKILL-MAIN.md` without leaving a compatibility copy, and a folder containing both candidates is invalid.
- Preserve an upstream entrypoint under `org/src/` as `SKILL-SOURCE.md`; provenance is not a runtime entrypoint.

## Skill Invocation Notations

Skills designate skill, subskill, and subcommand invocations with object-style notation. Bare components form the skill and subskill path; parenthesized components form a possibly nested subcommand chain:

```text
skill-path := skill-name ("->" subskill-name)*
subcommand-chain := subcommand-name "()" ("->" subcommand-name "()")*
invocation := skill-path | skill-path "->" subcommand-chain
relative-subcommand-invocation := subcommand-chain
```

- Skill and subskill entrypoint invocation: write "invoke skill `X`" or "invoke skill `X->Y->Z`". A bare object path invokes the named entrypoint: top-level `SKILL.md` for `X`, or parent-loaded `SKILL-MAIN.md` for a terminal subskill. Never append `()` to a skill or subskill entrypoint.
- Skill-to-subcommand invocation: write "invoke skill subcommand `X->cmd()`" for a direct subcommand of skill `X`, "invoke skill subcommand `X->Y->cmd()`" for a direct subcommand of subskill `Y`, and "invoke subcommand `cmd()`" for a direct subcommand of the current skill or command context.
- Nested-subcommand invocation: write `X->parent()->child()` for child subcommand `child` owned by parent subcommand `parent`, and continue the parenthesized chain for deeper descendants. Every subcommand component includes `()`, including intermediate object generators.
- Same-name routing: a direct subskill and direct subcommand may share a name because the component syntax remains authoritative. For example, `X->Y` invokes subskill `Y`, while `X->Y()` invokes subcommand `Y` of skill `X`.

Forms such as `X()` and `X->Y()` do not invoke skill or subskill entrypoints. Under this grammar, `X->Y()` means subcommand `Y` of skill `X`, and `X->parent()->child()` means child subcommand `child` of parent subcommand `parent`.

Any skill or subcommand page that uses these designators must declare the notation in its YAML frontmatter with the `skill_invocation_notation` key, adding frontmatter when the page has none. Use this standard value:

```yaml
skill_invocation_notation: >
  Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
  SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
  accepted only as legacy input when SKILL-MAIN.md is absent.
  Skill and subskill entrypoints use bare object paths: `X` invokes skill X and
  `X->Y->Z` invokes subskill Z. Subcommands use parenthesized components:
  `X->cmd()` invokes a direct subcommand, `X->Y->cmd()` invokes a subcommand of
  subskill Y, and `X->parent()->child()` invokes child subcommand child exposed
  by parent subcommand parent. Intermediate subcommands act as object generators.
  Forms such as `X()` and `X->Y()` are invalid for skill or subskill entrypoints.
```

A skill that never uses these designators does not need the key.

## Freeform skills

If the skill mainly provides tools, constraints, or subcommands rather than a rigid procedure:

- The workflow should tell the agent to use its native planning tool to plan execution steps based on the available tools, constraints, subcommands, and the user's specific task.
- The rest of the skill serves as reference material for that plan.

These rules do not prevent adding other sections. They only enforce that every skill has a clear, actionable workflow entrypoint.

## Guardrail Authoring

Every skill entrypoint must have a concise `## Guardrails` section focused exclusively on negative-action prevention. Subcommand-like pages may add their own guardrails when they need page-specific prohibitions.

- Start every guardrail with `DO NOT ...` and state one prohibited action.
- Include only prohibitions that materially protect the skill's design intent.
- Put positive actions, required operations, ordering, recipes, and output requirements in the workflow, core pattern, procedure, contract, or another substantive section.
- Do not use guardrails to present operation steps, repeat the workflow, or create a second procedural checklist.
- Omit universal common-sense warnings that do not address a failure specific to the skill.

## Example skeleton

Below is a minimal collection-of-routines skill that follows these rules. Writers may add any other sections they need.

```md
---
name: example-skill
description: Short description of what this skill does and when to use it.
---

# Example Skill

## Overview

One-paragraph explanation of the skill's purpose.

## Workflow

When this skill is invoked, execute the following steps in order.

1. **Determine the target directory**. See **Project Directory**.
2. **Resolve the output location**. See **Output Directory Discovery**.
3. **Select the appropriate subcommand** from the **Subcommands** section below.
   Let the agent choose the subcommand that best matches the user's task.
4. **Execute the selected subcommand's workflow**. See the linked detail page.
5. **Capture results** following the artifact rules in **Capturing Knowledge**.

If the user's task does not map cleanly to these steps, use your native
planning tool to build a step-by-step plan using the subcommands and
constraints provided by this skill, then execute the plan.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `analyze` | Analyze existing data | `commands/analyze.md` |
| `generate` | Generate new artifacts | `commands/generate.md` |
| `help` | Explain this skill and list public subcommands | This entrypoint |

## Project Directory

Use the directory explicitly provided by the user, or the current working
directory if none is given.

## Output Directory Discovery

Resolve `<output-dir>` in this priority:

1. User-provided location.
2. `EXAMPLE_SKILL_OUTPUT_DIR` environment variable.
3. `<project-dir>/.example-skill/output/` by default.

## Capturing Knowledge

Write results to `<output-dir>/results/<timestamp>-<what>.md`.

## Guardrails

- DO NOT write results outside the resolved output directory.

## Additional sections

Writers can add any other sections here: configuration notes, references,
examples, safety warnings, etc. Use whatever order and style works best.
```
