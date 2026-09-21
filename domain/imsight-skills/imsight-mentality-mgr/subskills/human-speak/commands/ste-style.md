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

# STE Style

## Workflow

1. Bind this explicit choice to `human-speak/ste-style` for this invocation.
2. Resolve the shared action from arguments or a pending request; absent action means recall/help, not enable.
3. Validate selectors and scope through [state.md](../references/state.md), then execute the relevant shared action or apply effective rules below.
4. Report action effects using [Memory Confirmation](../../../references/runtime-injection.md#memory-confirmation) when applicable.

For other requests, use the native planning tool without widening communication scope or task authority.

## Purpose

Use consistent terms, explicit relationships, direct language, faithful claim strength, and enough wording for clarity.

## Arguments

Accept the parent's shared actions with normal scope/selector defaults. Example: `imsight-mentality-mgr->human-speak->ste-style()` with `enable-memory h1 h4`. `disable-project all` leaves a reference-only entry with no family priority. Actions are arguments, not nested commands.

## Applying the Flavor

Resolve effective h1–h5 and retain only needed [definitions, comparisons, and judgment](../references/ste-style-principles.md) through [Definition Retention](../../../references/runtime-injection.md#definition-retention). Apply them during ordinary human-facing writing. This is STE-inspired readability, not ASD-STE100 enforcement or certification. Impose no fixed vocabulary, grammar bans, quotas, modes, or required linting.

Examples teach judgment, not templates. These rules create no extra research, testing, review, mandatory editing pass, or code-edit authority; they may shape an independently authorized review's presentation.

## Catalog Publication

Publish `.imsight-arts/mentality/human-speak-ste-style-principles.md` using [flavor bindings](../references/state.md#flavor-bindings) and the shared [catalog contract](../../../references/runtime-injection.md#catalog-artifact). Copy complete `Purpose`, `Principle Index`, `Communication Principles`, and `Applicability and Judgment` from [the catalog](../references/ste-style-principles.md), including every original comparison and judgment note. Exclude workflow, activation state, and References.

## References

Optional attribution/background only; open on explicit request. Excluded from deployed catalogs.

| Reference | Rules concerned |
| --- | --- |
| [Dustin Yuchen Teng asd-ste100 skill](https://github.com/danyuchn/asd-ste100-skill/blob/7d4a135a199a5d7447c4886bcd7ffe742a627bc9/SKILL.md) | h1–h5: consistent terminology, explicit relationships, direct language, claim strength, and clarity. |
| [Writing-rule summary](https://github.com/danyuchn/asd-ste100-skill/blob/7d4a135a199a5d7447c4886bcd7ffe742a627bc9/references/writing-rules.md) | h1–h5: ambiguity-reduction concepts; strict structural requirements are outside this flavor. |
| [Before/after discussions](https://github.com/danyuchn/asd-ste100-skill/blob/7d4a135a199a5d7447c4886bcd7ffe742a627bc9/examples/before-after.md) | h2, h4, h5: conditions, uncertainty, and preserving meaning. These examples are not bundled or reused. |

## Guardrails

- DO NOT remove material conditions, uncertainty, or required detail for brevity.
- DO NOT turn writing guidance into extra work or treat examples as mandatory layouts.
- DO NOT alter another flavor or enable this one through bare invocation.
