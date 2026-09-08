# Brooks Status

## Workflow

1. Resolve current Brooks state from `../references/state.md` without mutating it.
2. Derive effective rules from activation and retained selection.
3. Group rule codes into production and test rules using `../references/principles.md`.
4. Report activation, retained selection, effective rules, and persistence scope.

If the task does not map cleanly to these steps, use the native planning tool to produce a read-only status summary from the available state evidence.

## Output

Use this concise shape:

```text
Brooks: on | off | unset
Selected production: <codes or none>
Selected tests: <codes or none>
Effective: <codes or none>
Persistence: host-persisted | session-scoped | unset
```

When state is unset, explain that the built-in retained selection is all rules but Brooks remains off.

## Guardrails

- DO NOT change state while reporting status.
- DO NOT report selected rules as effective while Brooks is off.
