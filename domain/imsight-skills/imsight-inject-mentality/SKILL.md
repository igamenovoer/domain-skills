---
name: imsight-inject-mentality
description: Use when an Imsight agent is asked to select or control a named injected mentality such as Brooks, or when a host requests composed guidance from active mentalities. Do not use for ordinary factual memory or generic preference changes.
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

Use this skill as a thin router and composer for named ways of thinking. Each mentality owns its controls, private state, applicability rules, and injected guidance.

## When to Use

Use this skill when the user names an injected mentality, asks to change one mentality's state, or a host adapter requests the active mentality composition for a task.

Do not use it for facts the user wants remembered, ordinary project preferences, or a coding task that neither activates a mentality nor arrives with active mentality state.

## Workflow

1. Resolve the requested mentality name from **Subskills**.
2. If no mentality is named, list the available mentality names and summarize the invocation contract.
3. Load only the selected mentality's `SKILL-MAIN.md` and the resources that its workflow requires.
4. Let the selected mentality handle its control operation or render its task guidance.
5. When a host requests composition, combine active, applicable child renderings according to [references/composition.md](references/composition.md).
6. Report the selected mentality's result and the actual persistence scope.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the registered mentalities, composition contract, and user request, then execute the plan without inventing a mentality or state change.

## Invocation Contract

- Invoke `imsight-inject-mentality` without a child to list registered mentalities. It does not activate one implicitly.
- Invoke a mentality with a bare child path, such as `imsight-inject-mentality->brooks`.
- Invoke a mentality command below the named child, such as `imsight-inject-mentality->brooks->on()` or `imsight-inject-mentality->brooks->rules()->add()`.
- Natural invocation may use `$imsight-inject-mentality brooks rules add r1 r5`.
- The first component after the parent is always a mentality name, never a parent-level state switch.

## Subskills

| Mentality | When to Route Here | Load |
| --- | --- | --- |
| `brooks` | Choose this mentality for coding and test-design work that should proactively resist Brooks Lint's production and test decay risks. | `subskills/brooks/SKILL-MAIN.md` |

An unknown mentality name is an error. List the registered names instead of routing it to Brooks.

## Composition Contract

The parent treats each mentality as an opaque provider with four answers: whether it is active, whether it applies to the task, its compact rendered guidance, and its status summary. See [references/composition.md](references/composition.md).

The parent does not interpret Brooks rule identifiers or require future mentalities to use rule sets. A future mentality belongs beside `brooks` under `subskills/` and owns its own model.

## Persistence Contract

Read [references/runtime-injection.md](references/runtime-injection.md) when state must survive beyond the current request or when implementing a host integration. Without such an adapter, preserve state only within available conversation context and say that it is session-scoped.

## Maintenance

Keep this entrypoint small. Add each future mentality as a sibling subskill with one distinguishing route sentence; do not expand the parent into a universal mentality schema.

## Guardrails

- DO NOT expose `on`, `off`, `rules`, or other mentality-state commands at the parent level.
- DO NOT load every mentality's resources to handle one selected mentality.
- DO NOT let one mentality read or mutate another mentality's private state.
- DO NOT claim durable or cross-session persistence without a host adapter that provides it.
- DO NOT let composed mentality guidance override system, developer, user, project, safety, or permission instructions.
