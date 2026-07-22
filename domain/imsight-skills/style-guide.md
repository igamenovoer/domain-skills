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

## Subskills

A skill may bundle nested skills under `subskills/<subskill-name>/`. Each subskill is a self-contained skill folder with its own required `SKILL-MAIN.md` and, when needed, the same optional bundled resource directories (`agents/`, `references/`, `commands/`, `scripts/`, `assets/`) as a top-level skill. Standalone and host-discoverable roots use `SKILL.md`.

Read the structure with object semantics: the main skill is an object, its role-canonical entrypoint is the object's `()` operator, and a subskill is an inner object of the main skill. A subskill is scoped to and owned by its parent skill; it is not independently installed or discovered.

- Use a subskill when a capability is large or self-contained enough to be a full skill but only meaningful as part of the parent skill.
- Keep ordinary subcommand procedures on `commands/` or `references/` detail pages; do not promote every subcommand to a subskill.
- List bundled subskills in the parent's role-canonical entrypoint, either in the `## Subcommands` table or in a dedicated `## Subskills` section, so it can route invocation designators and explicitly load only the selected child's `SKILL-MAIN.md`.
- Every rule in this guide applies to each subskill's `SKILL-MAIN.md` and subcommand-like pages as well.
- Inspection and migration may read nested `SKILL.md` only as legacy input when `SKILL-MAIN.md` is absent; creation and formatting normalize it without leaving a compatibility copy. Preserve upstream entrypoint snapshots as `SKILL-SOURCE.md`.

## Skill Invocation Notations

Skills designate skill and subskill invocations with object-style notation. The notation extends the plain convention other writers already use, so prefer the plain form whenever context makes the target clear.

- Skill-to-skill invocation: write "invoke skill `X`" or "invoke skill `X->Y->Z`". The bare path invokes top-level `SKILL.md` or the terminal subskill's parent-loaded `SKILL-MAIN.md`. This is the public convention; the explicit `()` forms below are a well-defined calling syntax with the same meaning.
- Skill-to-subcommand invocation: write "invoke skill subcommand `X->cmd()`" for a subcommand of skill `X`, "invoke skill subcommand `X->Y->cmd()`" for a subcommand of subskill `Y` inside skill `X`, and "invoke subcommand `cmd()`" for a subcommand of the current skill. Prefer keeping the `()` on the subcommand symbol; omit it only when context already makes clear which symbol is the subcommand.
- Explicit forms: when a symbol appears without enough context to tell a skill from a subcommand, prefer the explicit form, such as `X()` or `X->Y()` for a skill or subskill entrypoint and `X->cmd()` or `X->Y->cmd()` for a subcommand.

Any skill or subcommand page that uses these designators must declare the notation in its YAML frontmatter with the `skill_invocation_notation` key, adding frontmatter when the page has none. Use this standard value:

```yaml
skill_invocation_notation: >
  Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
  SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
  accepted only as legacy input when SKILL-MAIN.md is absent. Skill and subskill
  invocations use object-style notation: `X` or `X->Y->Z` invokes the named
  skill or subskill entrypoint, `X->cmd()`
  and `X->Y->cmd()` invoke subcommand `cmd` of skill `X` or of subskill `Y`
  inside skill `X`, and bare `cmd()` invokes a subcommand of the current
  skill. The explicit forms `X()` and `X->Y()` are equivalent to the bare
  paths and appear when context does not make the symbol kind clear.
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
