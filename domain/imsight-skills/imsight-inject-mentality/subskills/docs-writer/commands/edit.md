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

# Edit Docs Writer Rules

Use this single command for all selection mutations. Rule inventory belongs to the separate `list` command.

## Workflow

1. Resolve current Docs Writer state from `../references/state.md`.
2. Resolve all requested selectors according to `../references/state.md`; reject the whole request on the first unknown or ambiguous selector.
3. Apply exactly one mutation form from **Forms** and leave `enabled` unchanged.
4. Apply the application order from `../../../references/runtime-injection.md`, defaulting to the managed `AGENTS.md` directive and synchronized Docs Writer rules artifact.
5. Report the form applied, resulting selection, enabled state, `AGENTS.md` destination, and rules artifact destination.

If the task does not map cleanly to these steps, use the native planning tool to perform one atomic selection update without changing enabled state.

## Forms

| Form | Selection result |
| --- | --- |
| `edit add <selectors>` | Union resolved rules into the retained selection. |
| `edit remove <selectors>` | Subtract resolved rules from the retained selection. |
| `edit set <selectors>` | Replace the selection with exactly the resolved rules. |
| `edit set none` | Replace the selection with the empty set. |
| `edit reset` | Restore all canonical Docs Writer rules. |

The canonical full invocation is `imsight-inject-mentality->docs-writer->edit()`, with the desired mutation supplied as arguments or natural-language intent. There are no child subcommands below `edit`. With no mutation, show concise edit syntax and refer rule inventory requests to `list`; do not infer a state change.

## Guardrails

- DO NOT enable or disable Docs Writer as a side effect of editing its selection.
- DO NOT apply a partial selection change when any selector is invalid.
- DO NOT treat selector groups or aliases as storable rule codes.
