---
name: agile-experimenter
description: Use when an Imsight mentality request names Agile Experimenter, or experiment planning, benchmarking, profiling, or technical interpretation has effective Agile Experimenter principles. Do not use for unrelated implementation cleanup or as permission to relax explicit validation requirements.
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

# Agile Experimenter Mentality

Reach an honest, decision-useful experimental conclusion with the least sufficient effort. Increase precision only when it could change the decision; preserve evidence validity.

## Workflow

1. Resolve intent and [selectors](references/state.md).
2. Execute a shared management action below, or resolve effective rules for relevant work.
3. Retain selected meanings through [Definition Retention](../../references/runtime-injection.md#definition-retention), then apply them within the task.
4. Report management effects or substantive findings and limits.

For other requests, use the native planning tool without inferring activation or new authority.

## Subcommands

Shared actions inherit the parent contract.

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `deploy` | Publish the complete catalog without enabling principles. | [Shared definition](../../references/actions.md#deploy) |
| `enable-project` | Add selected principles to project requirements. | [Shared definition](../../references/actions.md#enable-project) |
| `disable-project` | Remove selected principles from project requirements. | [Shared definition](../../references/actions.md#disable-project) |
| `enable-memory` | Remember enabled overrides for this agent only. | [Shared definition](../../references/actions.md#enable-memory) |
| `disable-memory` | Remember disabled overrides for this agent only. | [Shared definition](../../references/actions.md#disable-memory) |
| `recall` | Explain project, memory, and effective selections. | [Shared definition](../../references/actions.md#recall) |
| `help` | Explain the principles and shared actions without changing state. | This entrypoint |

## Applying the Mentality

Use selected [definitions and judgment](references/principles.md) for experiment planning, benchmarking, profiling, and interpretation:

1. State the question, intended claim, and useful resolution; reuse applicable evidence (`e1`, `e3`).
2. Choose the smallest valid next experiment and a first-evidence checkpoint; surface scope conflicts before narrowing work (`e2`, `e5`).
3. Use the working execution path and necessary safety/interpretation checks to obtain measurements (`e2`, `e4`).
4. Stop with a supported answer, make the cheapest material discriminating check, or report bounded inconclusion (`e3`).
5. Report findings, evidence, limits, and useful next action; distinguish preparation from results (`e6`).

Use existing plans, run directories, and reporting conventions. No new harness, manifest, scheduler, or checklist is required. Explicit precision, release, publication, safety, and validation requirements remain authoritative.

## Catalog Publication

Publish `.imsight-arts/mentality/agile-experimenter-principles.md` through the shared [catalog contract](../../references/runtime-injection.md#catalog-artifact). Copy complete `Concepts`, `Principle Index`, `Experiment Principles`, `Validity and Claim Boundaries`, `Applicability`, and `Provenance` sections from [principles.md](references/principles.md), including all examples and judgment notes. Exclude workflow, activation state, and control instructions.

## Guardrails

- DO NOT sacrifice work accounting, controls, or resource safety for apparent speed.
- DO NOT claim equivalence from unresolved noise or full parity from limited diagnostics.
- DO NOT weaken explicit requirements or keep sampling solely against immaterial hypothetical objections.
- DO NOT treat activation as permission for unrelated experiments or infrastructure edits.
