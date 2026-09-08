# Set Brooks Rules

## Workflow

1. Require one or more selectors, allowing `none` as the explicit empty selection.
2. Resolve every selector using `../references/state.md`; reject `none` when combined with another selector.
3. If any selector is invalid or ambiguous, make no change and report valid alternatives.
4. Replace the retained selection with exactly the expanded canonical set without changing activation.
5. Report added codes, removed codes, resulting selection, current effectiveness, and persistence scope.

If the task does not map cleanly to these steps, use the native planning tool to derive one explicit replacement set and apply it atomically.

## Semantics

Use set when the user defines the complete desired Brooks mentality, for example “only production plus T1 and T2.” The corresponding selection is `production`, `t1`, and `t2`.

## Guardrails

- DO NOT interpret an omitted selector list as `none`.
- DO NOT change activation as a side effect of replacing the selection.
- DO NOT combine `none` with any other selector.
