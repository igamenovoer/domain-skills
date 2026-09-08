# Add Brooks Rules

## Workflow

1. Require at least one selector and resolve all selectors using `../references/state.md`.
2. If any selector is invalid or ambiguous, make no change and report valid alternatives.
3. Union the expanded canonical codes into the retained selection without changing activation.
4. Report newly added codes, codes already selected, resulting selection, current effectiveness, and persistence scope.

If the task does not map cleanly to these steps, use the native planning tool to produce one atomic union operation from the user's unambiguous Brooks rule request.

## Semantics

This operation is idempotent. If Brooks is on, newly selected applicable rules enter the injected mentality immediately. If Brooks is off, they are retained for the next activation.

“Remember R5” and “add dependency direction” are natural-language aliases for the same state transition.

## Guardrails

- DO NOT turn Brooks on as a side effect of adding rules.
- DO NOT partially add a selector list containing an error.
