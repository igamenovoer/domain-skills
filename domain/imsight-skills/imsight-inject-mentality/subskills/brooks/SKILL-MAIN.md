---
name: brooks
description: Use when an Imsight mentality request targets Brooks, or when coding and test-design work arrives with Brooks enabled. Do not use for post-hoc Brooks Lint auditing, scoring, or unrelated non-coding work.
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

# Brooks Mentality

## Overview

Brooks is a preventive coding mentality: write and verify code so Brooks Lint's decay risks are addressed during construction rather than discovered afterward. It optimizes comprehension, changeability, faithful domain modeling, and trustworthy tests—not short code.

Selected rules apply before, during, and after editing. Treating them as a final cosmetic checklist violates their purpose.

## When to Use

Use this subskill when the user selects the Brooks mentality, changes its enabled state or rule selection, persists it to project rules or conversation context, or asks for coding work while resolved state says Brooks is enabled.

Do not use it to produce a Brooks Lint review, health score, finding list, or automatic refactoring sweep. Those are diagnostic Brooks Lint workflows, not this mentality.

## Workflow

1. Determine whether the request is a control operation from **Subcommands** or an applicable coding task with Brooks already enabled.
2. Resolve Brooks state according to [references/state.md](references/state.md); never invent persistence.
3. For a control operation, load and execute only the linked command page.
4. For an applicable coding task, read [references/principles.md](references/principles.md) and render only the selected rules.
5. Apply the selected rules while understanding the existing code, choosing the change boundary, implementing, and verifying behavior.
6. For every state-changing control operation, follow the application order in [../../references/runtime-injection.md](../../references/runtime-injection.md); project summary and rule index are the default.
7. Report the task result normally; mention Brooks only when its guidance caused a material tradeoff or the user requested status.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the selected Brooks rules, current task, and repository constraints, then execute it without turning the mentality into a lint report.

## Invocation Contract

- Invoke `imsight-inject-mentality->brooks` without a command to show Brooks status and concise help. It does not enable Brooks implicitly.
- Invoke `imsight-inject-mentality->brooks->enable()` or `imsight-inject-mentality->brooks->disable()` to change whether the retained selection is applied.
- Invoke `imsight-inject-mentality->brooks->enable-all()` or `imsight-inject-mentality->brooks->disable-all()` to add or remove every Brooks rule without changing whether Brooks is enabled.
- Invoke `imsight-inject-mentality->brooks->status()` to inspect effective state.
- Invoke `imsight-inject-mentality->brooks->list()` to inspect the rule catalog and selection; `imsight-inject-mentality->brooks->ls()` is an accepted alias.
- Invoke `imsight-inject-mentality->brooks->edit()` to atomically modify the rule selection.
- Natural invocation may use `$imsight-inject-mentality brooks edit remove r4`.

The removed `on`, `off`, and nested `rules` command forms are not aliases. If one is requested, show the corresponding current command instead of silently accepting the obsolete form.

## Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `enable` | Apply Brooks using its retained selection or the built-in default selection. | `commands/enable.md` |
| `disable` | Stop applying Brooks without losing its retained rule selection. | `commands/disable.md` |
| `enable-all` | Add all canonical Brooks rules to the selection without changing enabled state. | `commands/enable-all.md` |
| `disable-all` | Remove all Brooks rules from the selection without changing enabled state. | `commands/disable-all.md` |
| `edit` | Atomically add, remove, set, or reset selected Brooks rules. | `commands/edit.md` |
| `list` | Show available, selected, and effective rules; accepts `ls` as an alias. | `commands/list.md` |
| `status` | Show enabled state, selected rules, effective rules, and persistence scope. | `commands/status.md` |
| `help` | Explain this mentality and list its public commands. | This entrypoint |

## Applying the Mentality

When Brooks is enabled and the task changes or designs code:

1. Read the existing flow and relevant callers before selecting a change boundary.
2. Load the selected rule definitions from [references/principles.md](references/principles.md).
3. Treat thresholds and symptoms as prompts for judgment, never automatic verdicts.
4. Implement the smallest coherent change that satisfies the selected rules and the user's requirements.
5. Verify behavior and test architecture in proportion to the affected risk.

For injection, render each selected rule as its compact constructive reminder. Do not inject unselected rules, Brooks severity language, scoring, or report templates.

## Rule Catalog

Brooks canonical IDs, compact reminders, examples, and judgment notes live at `references/principles.md` relative to this subskill. Default project-rule persistence names the entrance skill `imsight-inject-mentality` and the selected canonical IDs; after loading, the entrance skill owns routing to this entrypoint and catalog. Wrap the persisted section in the runtime contract's invisible `imsight-skill:imsight-inject-mentality/brooks` managed fence so later control operations replace the same source-owned block.

## Rationalization Table

| Rationalization | Counter |
| --- | --- |
| “Brooks Lint can catch this later.” | The mentality exists to shape the design before debt is embedded. |
| “This change is too small for the rules.” | Apply selected rules proportionately; small duplicated decisions and wrong boundaries still propagate. |
| “More abstraction is cleaner.” | R4 requires present value; a hypothetical future consumer is not evidence. |
| “Fewer lines means simpler code.” | Brooks measures comprehension and change cost, not line-count minimalism. |
| “The tests pass, so test design is fine.” | Passing tests may still be obscure, brittle, duplicated, mock-bound, or aimed at the wrong risks. |
| “A threshold was crossed, so refactoring is mandatory.” | Thresholds are review signals; context and the documented exceptions still govern. |

## Red Flags

- Planning to clean up structure only after the feature works.
- Copying a business decision because extracting it feels premature.
- Adding a layer, option, dependency, or interface for an imagined future need.
- Testing private state or mock choreography instead of observable behavior.
- Moving domain rules into generic services or infrastructure-oriented models.
- Treating a numeric symptom as proof without examining context.

## Guardrails

- DO NOT shorten code merely to reduce lines when comprehension or domain fidelity would worsen.
- DO NOT run a Brooks Lint audit or invent findings when the task is to apply the mentality.
- DO NOT apply a rule that the current Brooks state has not selected.
- DO NOT treat heuristic thresholds as automatic refactoring requirements.
- DO NOT let Brooks override explicit task requirements or repository instructions.
- DO NOT claim conversation state survives context loss or a new conversation without host support.
- DO NOT copy rule text into a project instruction file unless the user explicitly requests the inline-copy variant.
