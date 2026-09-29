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

# Daily Developer

## Workflow

1. Bind this explicit choice to `rigor-control/daily-developer` for this invocation.
2. Resolve the shared action from arguments or a pending request; absent action means recall and help, not enable.
3. Validate selectors and scope through [state.md](../references/state.md), then execute the relevant shared action or apply effective rules below.
4. Report action effects using [Memory Confirmation](../../../references/runtime-injection.md#memory-confirmation) when applicable.

For other requests, use the native planning tool without widening task authority or silently changing the assurance target.

## Purpose

Make everyday development and internal experiments produce results the developer can trust and act on. Keep evidence honest through run-time code-version stamps and code-logic impact judgment, keep iteration cheap after failures, and defer rigor intended for external review or publication.

## Arguments

Accept the parent's shared actions with normal scope and selector defaults. Example: `imsight-mentality-mgr->rigor-control->daily-developer()` with `enable-memory all`. `disable-project all` leaves a reference-only entry with no family priority. Actions are arguments, not nested commands.

## Applying the Flavor

Resolve effective `rc1`–`rc5` and retain only needed [definitions, comparisons, and judgment](../references/daily-developer-principles.md) through [Definition Retention](../../../references/runtime-injection.md#definition-retention). Apply them while planning, implementing, debugging, measuring, and verifying everyday work.

Treat the developer's own next decision and repeated daily use as the target level of rigor. Keep results usable and stamped with code version at run time; judge from code logic whether a change can materially affect each claim and refresh only the affected evidence; treat failed attempts as cheap recorded iterations rather than consumed assets. Stop when additional work primarily serves external review, publication, or audit. Explicit task requirements remain authoritative.

## Catalog Publication

Publish `.imsight-arts/mentality/rigor-control-daily-developer-principles.md` using [flavor bindings](../references/state.md#flavor-bindings) and the shared [catalog contract](../../../references/runtime-injection.md#catalog-artifact). Copy complete `Purpose`, `Principle Index`, `Daily Developer Principles`, and `Applicability` from [the catalog](../references/daily-developer-principles.md), including every original comparison and judgment note. Exclude workflow and activation state.

## Guardrails

- DO NOT override explicit task requirements with this rigor flavor.
- DO NOT alter another flavor or enable this one through bare invocation.
- DO NOT use daily-developer calibration where results must satisfy publication, release, compliance, or audit review.
