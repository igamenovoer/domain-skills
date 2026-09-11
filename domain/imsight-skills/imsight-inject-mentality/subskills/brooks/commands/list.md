# List Brooks Rules

`list` is the canonical read-only rule-inventory command. Accept `ls` as an invocation alias, but use `list` in help, status guidance, and output.

## Workflow

1. Resolve Brooks state from `../references/state.md` without mutating it.
2. Read the rule catalog from `../references/principles.md`.
3. Mark every canonical rule as selected or unselected and derive whether it is effective.
4. Report production rules, test rules, selector groups, enabled state, persistence destination, and both project files when project persistence applies.

If the task does not map cleanly to these steps, use the native planning tool to produce a read-only rule inventory from valid state and catalog data.

## Output

Prefer a compact table with code, canonical name, selected state, and effective state. A selected rule is effective only while Brooks is enabled and applicable to the current task.

## Guardrails

- DO NOT mutate state while listing rules.
- DO NOT omit unselected rules from an inventory explicitly requested by the user.
- DO NOT present `ls` as a second command; it is only an alias for canonical `list`.
