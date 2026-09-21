---
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

# Mark-Life Style

## Workflow

1. Bind this explicit choice to `human-speak/mark-life-style` for this invocation.
2. Resolve the shared action from arguments or a pending request; absent action means recall/help, not enable.
3. Validate selectors and scope through [state.md](../references/state.md), then execute the relevant shared action or apply effective rules below.
4. Report action effects using [Memory Confirmation](../../../references/runtime-injection.md#memory-confirmation) when applicable.

For other requests, use the native planning tool without widening communication scope or task authority.

## Purpose

Put the conclusion where readers can find it; retain useful evidence and limits while reducing reading effort.

## Arguments

Accept the parent's shared actions with normal scope/selector defaults. Example: `imsight-mentality-mgr->human-speak->mark-life-style()` with `enable-memory h1 h4`. `disable-project all` leaves a reference-only entry with no family priority. Actions are arguments, not nested commands. `agent-to-human` is an upstream title, not an invocation alias.

## Applying the Flavor

Resolve effective h1–h8 and retain only needed [definitions, comparisons, and judgment](../references/mark-life-style-principles.md) through [Definition Retention](../../../references/runtime-injection.md#definition-retention). Apply them during ordinary human-facing writing. Honor the requested detail and output format. Preserve material conditions and accurate evidence status; no sentence, word, or bullet quota applies.

Examples teach judgment, not templates. These rules create no extra research, testing, review, mandatory editing pass, or code-edit authority; they may shape an independently authorized review's presentation.

## Catalog Publication

Publish `.imsight-arts/mentality/human-speak-mark-life-style-principles.md` using [flavor bindings](../references/state.md#flavor-bindings) and the shared [catalog contract](../../../references/runtime-injection.md#catalog-artifact). Copy complete `Purpose`, `Principle Index`, `Communication Principles`, and `Applicability and Judgment` from [the catalog](../references/mark-life-style-principles.md), including every original comparison and judgment note. Exclude workflow, activation state, and References.

## References

Optional attribution/background only; open on explicit request. Excluded from deployed catalogs.

| Reference | Rules concerned |
| --- | --- |
| [Mark-Life agent-to-human](https://github.com/Mark-Life/agent-skills/blob/0696ebb51867d4a89ce747527e4899f5306ed464/skills/communication/agent-to-human/SKILL.md) | h1–h8: answer priority, relevant detail, evidence status, language, sentence focus, actors, layout, and references. |

## Guardrails

- DO NOT remove material conditions, uncertainty, or required detail for brevity.
- DO NOT turn writing guidance into extra work or treat examples as mandatory layouts.
- DO NOT alter another flavor or enable this one through bare invocation.
