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

# Product Showcase

## Workflow

1. Bind this explicit choice to `rigor-control/product-showcase` for this invocation.
2. Resolve the shared action from arguments or a pending request; absent action means recall and help, not enable.
3. Validate selectors and scope through [state.md](../references/state.md), then execute the relevant shared action or apply effective rules below.
4. Report action effects using [Memory Confirmation](../../../references/runtime-injection.md#memory-confirmation) when applicable.

For other requests, use the native planning tool without widening task authority or silently changing the assurance target.

## Purpose

Prepare a product for a short event showcase in which ordinary users concentrate on its core feature. Make that feature reliable under plausible event pressure without taking on rigor intended for massive sustained use or standardized committee-like inspection.

## Arguments

Accept the parent's shared actions with normal scope and selector defaults. Example: `imsight-mentality-mgr->rigor-control->product-showcase()` with `enable-memory all`. `disable-project all` leaves a reference-only entry with no family priority. Actions are arguments, not nested commands.

## Applying the Flavor

Resolve effective `rc1`–`rc5` and retain only needed [definitions, comparisons, and judgment](../references/product-showcase-principles.md) through [Definition Retention](../../../references/runtime-injection.md#definition-retention). Apply them while planning, implementing, debugging, and verifying showcase work.

Treat the approximate ten-minute ordinary-use session as the target level of rigor. Protect the core feature under the concurrency, bursts, varied inputs, and spontaneous edge cases plausible at the event. Judge equivalence by differences that materially affect the showcase experience, and keep presented numbers valid for their claims without invalidating evidence for immaterial changes. Stop when additional work primarily serves massive sustained use or standardized inspection. Explicit task requirements remain authoritative.

## Catalog Publication

Publish `.imsight-arts/mentality/rigor-control-product-showcase-principles.md` using [flavor bindings](../references/state.md#flavor-bindings) and the shared [catalog contract](../../../references/runtime-injection.md#catalog-artifact). Copy complete `Purpose`, `Principle Index`, `Product Showcase Principles`, and `Applicability` from [the catalog](../references/product-showcase-principles.md), including every original comparison and judgment note. Exclude workflow and activation state.

## Guardrails

- DO NOT override explicit task requirements with this rigor flavor.
- DO NOT alter another flavor or enable this one through bare invocation.
