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

# Brooks Rules

## Workflow

1. Select a child operation from **Subcommands**.
2. Resolve every supplied selector using `../references/state.md` and `../references/principles.md`.
3. Load and execute only the selected child detail page.
4. Report the resulting selection, whether it is currently effective, and persistence scope.

If the task does not map cleanly to these steps, use the native planning tool to translate the user's requested Brooks rule change into one atomic child operation, then execute it without changing activation.

## Terminal Behavior

Terminal invocation of `imsight-inject-mentality->brooks->rules()` lists the child operations, valid selector groups, and a concise current selection summary. It does not mutate state.

## Subcommands

| Subcommand | Use For | Full invocation | Load |
| --- | --- | --- | --- |
| `list` | Show available, selected, and effective Brooks rules. | `imsight-inject-mentality->brooks->rules()->list()` | `rules-list.md` |
| `add` | Union selected rules into the retained set. | `imsight-inject-mentality->brooks->rules()->add()` | `rules-add.md` |
| `remove` | Subtract selected rules from the retained set. | `imsight-inject-mentality->brooks->rules()->remove()` | `rules-remove.md` |
| `set` | Replace the retained set exactly. | `imsight-inject-mentality->brooks->rules()->set()` | `rules-set.md` |
| `reset` | Restore the built-in all-rules selection. | `imsight-inject-mentality->brooks->rules()->reset()` | `rules-reset.md` |

## Selectors

- Individual codes: `r1`–`r6`, `t1`–`t6`.
- Canonical names: for example `change-boundary`, `essential-complexity`, or `mock-boundaries`.
- Groups: `production`, `tests`, and `all`.
- `none` is valid only for the set operation.

Conversational “remember” and “forget” phrasing maps to add and remove respectively, but add/remove are the canonical operations.

## Guardrails

- DO NOT mutate activation while changing rules.
- DO NOT apply any part of a request until all selectors validate.
- DO NOT treat a group or alias as a stored canonical rule.
