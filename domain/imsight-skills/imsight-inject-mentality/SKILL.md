---
name: imsight-inject-mentality
description: Use when an Imsight agent is asked to select, control, persist, or compose a named injected mentality such as Brooks or Docs Writer. Do not use for ordinary factual memory or generic preference changes unrelated to a mentality.
metadata:
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
---

# Imsight Inject Mentality

## Overview

Use this skill as a thin router and composer for named ways of thinking. It defines the shared control and persistence contracts; each mentality owns its rule catalog, selectors, applicability rules, private state, and injected guidance.

## When to Use

Use this skill when the user names an injected mentality, asks to change or persist one mentality's state, or a host adapter requests the enabled mentality composition for a task.

Do not use it for facts the user wants remembered, ordinary project preferences, or a coding task that neither enables a mentality nor arrives with enabled mentality state. “Remember” and “keep in memory” do route here when their object is a mentality or its rule selection.

## Workflow

1. Resolve the requested mentality name from **Subskills**.
2. If no mentality is named, list the available mentality names and summarize the invocation contract.
3. Load only the selected mentality's `SKILL-MAIN.md` and the resources that its workflow requires.
4. Let the selected mentality handle its control operation or render its task guidance.
5. For every state-changing control operation, apply the application order in [references/runtime-injection.md](references/runtime-injection.md): a managed `AGENTS.md` directive plus a project rules artifact by default, inline project rules plus that artifact when explicitly requested, or conversation memory when explicitly requested.
6. When a host requests composition, combine enabled, applicable child renderings according to [references/composition.md](references/composition.md).
7. Report the selected mentality's result and the actual persistence location and representation.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the registered mentalities, composition contract, and user request, then execute the plan without inventing a mentality or state change.

## Invocation Contract

- Invoke `imsight-inject-mentality` without a child to list registered mentalities. It does not activate one implicitly.
- Invoke a mentality with a bare child path, such as `imsight-inject-mentality->brooks`.
- Invoke a mentality command below the named child, such as `imsight-inject-mentality->brooks->enable()` or `imsight-inject-mentality->brooks->edit()`.
- Natural invocation may use `$imsight-inject-mentality brooks edit add r1 r5`.
- The first component after the parent is always a mentality name, never a parent-level state switch.

Rule-backed mentalities use the shared public controls `enable`, `disable`, `enable-all`, `disable-all`, `edit`, `list`, and `status`. `ls` is an accepted alias for `list`; canonical help and output use `list`. The child defines selector meaning and edit semantics; the parent does not interpret its rule IDs.

## Subskills

| Mentality | When to Route Here | Load |
| --- | --- | --- |
| `brooks` | Choose this mentality for coding and test-design work that should proactively resist Brooks Lint's production and test decay risks. | `subskills/brooks/SKILL-MAIN.md` |
| `docs-writer` | Choose this mentality for writing or revising durable documents whose main text should read as a clean current-state description, free of the document's own revision history. | `subskills/docs-writer/SKILL-MAIN.md` |

An unknown mentality name is an error. List the registered names instead of routing it to Brooks.

## Composition Contract

The parent treats each mentality as an opaque provider with four answers: whether it is enabled, whether it applies to the task, its compact rendered guidance, and its status summary. See [references/composition.md](references/composition.md).

The parent does not interpret child rule identifiers or require future mentalities to use rule sets. A future mentality belongs beside the registered mentalities under `subskills/` and owns its own model.

## Persistence Contract

Read [references/runtime-injection.md](references/runtime-injection.md) for every state-changing control operation. Apply these representations in order:

1. By default, update the project-root `AGENTS.md` with a short mentality summary, canonical rule index, installed entrance skill name, and a reference to `.imsight-arts/mentality/<mentality>-rules.md`; write the selected compact rules to that artifact.
2. When the user explicitly asks for details, copied rules, or inline rules, also write the selected compact rule text into `AGENTS.md` while maintaining and referencing the same artifact.
3. When the user explicitly says “remember,” “keep in memory,” or “for this conversation,” retain state only in conversation context and do not write either project file.

For either project representation, use the invisible managed fence defined in the runtime-injection reference around the `AGENTS.md` directive. Its source markers identify `imsight-inject-mentality` and the selected child while remaining hidden in standard Markdown previews; update an existing well-formed matching block instead of duplicating it. Keep the rules artifact synchronized with the directive.

## Maintenance

Keep this entrypoint small. Add each future mentality as a sibling subskill with one distinguishing route sentence; do not expand the parent into a universal mentality schema.

## Guardrails

- DO NOT expose mentality-state commands at the parent level.
- DO NOT load every mentality's resources to handle one selected mentality.
- DO NOT let one mentality read or mutate another mentality's private state.
- DO NOT default a state-changing control operation to conversation memory.
- DO NOT skip project instructions merely because the user omitted persistence wording.
- DO NOT omit the entrance skill name, selected rule index, or project rules artifact reference from a project directive.
- DO NOT write project-persisted mentality guidance outside its invisible managed fence or duplicate a matching fenced block.
- DO NOT leave a project rules artifact stale after changing its mentality state or selection.
- DO NOT describe conversation persistence as durable across context loss or a new conversation.
- DO NOT let composed mentality guidance override system, developer, user, project, safety, or permission instructions.
