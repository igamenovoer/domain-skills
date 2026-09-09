# Edit Brooks Rules

Use this single command for all selection mutations. Rule inventory belongs to the separate `list` command.

## Forms

| Form | Selection result |
| --- | --- |
| `edit add <selectors>` | Union resolved rules into the retained selection. |
| `edit remove <selectors>` | Subtract resolved rules from the retained selection. |
| `edit set <selectors>` | Replace the selection with exactly the resolved rules. |
| `edit set none` | Replace the selection with the empty set. |
| `edit reset` | Restore all twelve built-in rules. |

The canonical full invocation is `imsight-inject-mentality->brooks->edit()`, with the desired mutation supplied as arguments or natural-language intent. There are no child subcommands below `edit`. With no mutation, show concise edit syntax and refer rule inventory requests to `list`; do not infer a state change.

## Workflow

1. Resolve current Brooks state and selectors from `../references/state.md`.
2. Require a complete add, remove, set, or reset form; with no form, show edit help without mutating state.
3. Validate every supplied selector before changing state.
4. Apply exactly one atomic add, remove, set, or reset transition; leave `enabled` unchanged.
5. Apply the requested persistence lane from `../../../references/runtime-injection.md`.
6. Report added and removed canonical IDs, resulting selection, current effectiveness, and persistence destination.

If the task does not map cleanly to these forms, use the native planning tool to translate the user's unambiguous desired selection into one atomic edit. Ask for clarification only when different edits would produce materially different state.

## Selector Rules

- Individual codes: `r1`–`r6`, `t1`–`t6`.
- Canonical names: for example `change-boundary`, `essential-complexity`, or `mock-boundaries`.
- Groups: `production`, `tests`, and `all`.
- `none` is valid only with `edit set` and cannot be combined with another selector.
- Duplicate selectors are idempotent; unknown or ambiguous selectors reject the entire edit.

Natural wording such as “add dependency direction,” “remove R4,” or “keep only production plus T1” maps to the corresponding edit form. “Remember” and “keep in memory” choose conversation persistence; they are not edit forms by themselves.

## Guardrails

- DO NOT change enabled state as a side effect of an edit.
- DO NOT partially apply a request containing an invalid selector.
- DO NOT interpret an omitted selector list as `none`.
- DO NOT list the rule catalog through `edit`; route that request to `list`.
- DO NOT expose add, remove, set, or reset as nested subcommands.
- DO NOT treat a group or alias as a stored canonical rule.
