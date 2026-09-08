# List Brooks Rules

## Workflow

1. Resolve Brooks state without mutating it.
2. Read the rule catalog from `../references/principles.md`.
3. Mark every rule as selected or unselected and derive whether it is effective.
4. Report production rules, test rules, selector groups, activation, and persistence scope.

If the task does not map cleanly to these steps, use the native planning tool to produce a read-only rule inventory from valid state and catalog data.

## Output

Prefer a compact table with code, canonical name, selected state, and effective state. A selected rule is effective only while Brooks is on and applicable to the current task.

## Guardrails

- DO NOT mutate state while listing rules.
- DO NOT omit unselected rules from an inventory explicitly requested by the user.
