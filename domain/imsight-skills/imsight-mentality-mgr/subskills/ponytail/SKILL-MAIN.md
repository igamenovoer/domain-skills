---
name: ponytail
description: Use when an Imsight mentality request names Ponytail, applicable coding work has effective Ponytail rules, or the user explicitly requests a Ponytail simplification review. Supports independent simplification intensity and edit scope. Do not use for unrelated prose, automatic repository cleanup, or global persona activation.
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

# Ponytail Mentality

Simplify implementation while preserving required behavior, edge-case defenses, and task boundaries. Intensity selects rules; edit scope independently limits existing-code changes.

## Workflow

1. Resolve action, selectors, and axes through [state.md](references/state.md). Persistent configuration requires explicit project or memory scope; omitted axes stay unchanged, and no arguments means help.
2. Execute the shared or child action below. Load [review.md](references/review.md) only for an explicit review.
3. For implementation, establish the task's starting code boundary and apply only effective rules within it.
4. Report effects and material tradeoffs. Recall includes selected IDs, derived intensity, edit scope, and provenance.

For other requests, use the native planning tool without enlarging the task or activating rules.

## Subcommands

Shared actions inherit the parent contract.

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `deploy` | Publish the complete catalog without enabling rules or choosing axes. | [Shared definition](../../references/actions.md#deploy) |
| `configure-project` | Replace project intensity and/or set project edit scope. | [Configure Project](references/state.md#configure-project) |
| `configure-memory` | Replace this agent's intensity and/or set its edit-scope override. | [Configure Memory](references/state.md#configure-memory) |
| `enable-project` | Add named individual rules to project selection. | [Shared definition](../../references/actions.md#enable-project) |
| `disable-project` | Remove named individual rules from project selection. | [Shared definition](../../references/actions.md#disable-project) |
| `enable-memory` | Remember enabled rule overrides; omitted selectors mean all current rules. | [Shared definition](../../references/actions.md#enable-memory) |
| `disable-memory` | Remember disabled rule overrides; omitted selectors mean all current rules. | [Shared definition](../../references/actions.md#disable-memory) |
| `recall` | Report selected rules, intensity, edit scope, and their provenance. | [Recall](references/state.md#recall) |
| `review` | Find supported simplifications within the selected criteria and edit boundary. | [Review](references/review.md) |
| `help` | Explain actions, axes, and rule IDs without changing state. | This entrypoint |

## Intensity and Edit Scope

| Intensity | Rules |
| --- | --- |
| `safe` | p1–p7: reuse, primitives, dependency restraint, root-cause placement, proven redundancy, focused verification, real limits. |
| `normal` | Safe plus p8 collapse-structure and p9 compact-implementation. |
| `extreme` | Normal plus p10 remove-unused-flexibility, p11 replace-existing-dependencies, p12 challenge-speculative-work. |

| Edit scope | Boundary |
| --- | --- |
| `new-code-only` | New task code using established infrastructure; minimal compatible wiring is allowed. |
| `destructive` | Also existing task-related infrastructure, with minimal impact. Broad refactoring needs that assignment. |

No rules are enabled by default; missing edit scope means `new-code-only`. Recommend safe plus new-code-only when asked for a starting configuration. Even extreme/destructive preserves required defenses. Detailed configuration and baselines live in [state.md](references/state.md).

## Applying the Mentality

Read affected behavior, callers, and edge/failure conditions. Retain selected [definitions and comparisons](references/principles.md) plus settings through [Definition Retention](../../references/runtime-injection.md#definition-retention).

For selected reuse rules, prefer a suitable project solution, then proven native/standard facilities, then installed dependencies, before custom machinery. Suitability includes behavior and supported runtimes. Apply structural simplifications only for demonstrated benefit inside the [edit boundary](references/state.md#edit-boundary).

Use existing evidence and required checks. Selected p6 calls for proportionate verification, not a new test for every edit. Report actual checks and material uncertainty. If a correct fix crosses new-code-only scope, honor a precise existing task authorization or surface the conflict; do not hide it in a caller-specific workaround.

## Catalog Publication

Publish `.imsight-arts/mentality/ponytail-principles.md` through the shared [catalog contract](../../references/runtime-injection.md#catalog-artifact). Copy complete `Principle Index`, `Safe Rules`, `Normal Additions`, `Extreme Additions`, `Validity Requirements`, and `Applicability` from [principles.md](references/principles.md), including original comparisons, assumptions, and judgment. Exclude control workflows, activation/settings state, and References.

## References

Optional attribution/background only; open on explicit request. Excluded from deployed catalogs.

| Reference | Rules concerned |
| --- | --- |
| [Ponytail rules](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/skills/ponytail/SKILL.md#rules) | p1–p12: simplification themes; p7: explaining real limits. |
| [Reuse and caller-tracing cases](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/benchmarks/agentic/tasks.py) | p1, p4: reuse and owning-boundary reasoning. |
| [Grouping example](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/examples/group-by.md) | p2: proven primitives. |
| [Cloning example](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/examples/deep-clone.md) | p3, p6: dependency restraint and behavior preservation. |
| [Debounce examples](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/examples/debounce.md) | p5, p8, p10: redundancy, structure, and flexibility. |
| [CSV example](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/examples/csv-sum.md) | p9: compact implementation. |
| [Formatting example](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/examples/number-formatting.md) | p11: dependency replacement. |
| [Countdown example](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/examples/react-countdown.md) | p12: speculative machinery. |
| [Ponytail review](https://github.com/DietrichGebert/ponytail/blob/356918eba965ee1eac64bd3a7f0dd02108350de5/skills/ponytail-review/SKILL.md) | p1–p12: simplification review framing. |

## Guardrails

- DO NOT remove required defenses or infer redundancy from line counts, one caller, or one implementation.
- DO NOT let intensity widen edit scope, or destructive scope enlarge the assigned task.
- DO NOT rewrite existing infrastructure under new-code-only without precise task authorization.
- DO NOT pursue unrelated cleanup or apply review recommendations during review.
