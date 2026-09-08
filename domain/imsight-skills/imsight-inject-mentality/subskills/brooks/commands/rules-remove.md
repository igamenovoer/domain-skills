# Remove Brooks Rules

## Workflow

1. Require at least one selector and resolve all selectors using `../references/state.md`.
2. If any selector is invalid or ambiguous, make no change and report valid alternatives.
3. Subtract the expanded canonical codes from the retained selection without changing activation.
4. Report newly removed codes, codes already absent, resulting selection, current effectiveness, and persistence scope.

If the task does not map cleanly to these steps, use the native planning tool to produce one atomic subtraction operation from the user's unambiguous Brooks rule request.

## Semantics

This operation is idempotent. If Brooks is on, removed rules leave the injected mentality immediately. If Brooks is off, the retained selection changes for the next activation.

“Forget R4” and “remove essential complexity” are natural-language aliases for the same state transition.

## Guardrails

- DO NOT turn Brooks off as a side effect of removing rules.
- DO NOT partially remove a selector list containing an error.
