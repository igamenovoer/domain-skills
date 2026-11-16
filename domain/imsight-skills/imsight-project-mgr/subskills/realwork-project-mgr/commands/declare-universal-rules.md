# Declare Shared Project Rules

## Workflow

1. **Resolve instruction ownership.** Read meta and realwork guidance when attached. Respect explicitly named files; otherwise use the existing native instruction file or a shared `AGENTS.md`.
2. **Read the bundled [rule source](../references/universal-project-rules.md).** Treat it as candidates constrained by the project's existing tooling and compatibility decisions.
3. **Reconcile the managed section.** Install development guidance at the meta owner, and functional usage/routing guidance in realwork. Preserve unrelated content and avoid repeating existing equivalent rules.
4. **Verify and report.** Ensure one coherent section per owner and idempotent results; list any rule omitted because it conflicts with project policy.

If the requested target cannot own a rule, explain the owner mismatch and plan the smallest correction within the authorized scope.

## Contract

A request for shared guidance does not authorize adopting a type checker, a release policy, a breaking-change policy, or automatic commits. Do not infer those behaviors from generic rule text. Standalone realworks may retain essential local development guidance until a deliberate migration supplies the meta owner.
