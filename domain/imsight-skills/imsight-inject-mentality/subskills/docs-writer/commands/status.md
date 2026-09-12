# Docs Writer Status

## Workflow

1. Resolve current Docs Writer state from `../references/state.md` without mutating it.
2. Derive effective rules from enabled state and retained selection.
3. Map rule codes to canonical names using `../references/principles.md`.
4. Report enabled state, retained selection, effective rules, persistence destination, and both project files when project persistence applies.

If the task does not map cleanly to these steps, use the native planning tool to produce a read-only status summary from the available state evidence.

## Output

Use this concise shape:

```text
Docs Writer: enabled | disabled | unset
Selected rules: <codes or none>
Effective: <codes or none>
Persistence: project-rule-reference | project-rule-inline | host-persisted | conversation-scoped | unset
Project instructions: <AGENTS.md path when project-persisted>
Rules artifact: <docs-writer-rules.md path when project-persisted>
```

When state is unset, explain that the built-in retained selection is all rules but Docs Writer remains disabled. When project persistence is in effect, also name `AGENTS.md` and the referenced Docs Writer rules artifact.

## Guardrails

- DO NOT change state while reporting status.
