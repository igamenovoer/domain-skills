# Brooks Constructive Principles

This catalog converts Brooks Lint's diagnostic risks into preventive reminders for writing production code and tests. It is derived from the upstream Brooks Lint risk references at `skills/_shared/decay-risks.md` and `skills/_shared/test-decay-risks.md`; the reminders are intentionally constructive rather than finding-oriented.

## Workflow

1. Load the current selected codes from Brooks state.
2. Use only the matching compact reminders from **Production Rules** and **Test Rules**.
3. Apply their judgment notes while planning, implementing, and verifying the current change.
4. Render selected reminders without diagnostic scoring or unselected content.

If the task does not map cleanly to these steps, use the native planning tool to apply the selected reminders proportionately to the code and tests in scope.

## Production Rules

| Code | Canonical name | Compact injected reminder |
| --- | --- | --- |
| `r1` | `comprehension` | Keep the concepts a reader must hold manageable with precise names, cohesive flow, and consistent abstraction levels. |
| `r2` | `change-boundary` | Put the change at the narrowest correct shared boundary; trace callers and hide decisions that should not propagate. |
| `r3` | `decision-ownership` | Give each business decision one clear source of truth; remove duplicated knowledge, not merely similar syntax. |
| `r4` | `essential-complexity` | Require every abstraction, layer, option, and dependency to justify its present cost; simplicity is not code golf. |
| `r5` | `dependency-direction` | Keep policy independent of concrete infrastructure, avoid cycles, and introduce interfaces only at real boundaries. |
| `r6` | `domain-fidelity` | Use the domain's language and keep invariants with the model that owns them; translate explicitly across bounded contexts. |

### Judgment notes

- R1: Function length, nesting, parameter count, and fan-out are review signals. Clear linear code or a deep module may be healthy despite a threshold.
- R2: A composition root may wire concrete dependencies. Coordinated changes inside one bounded context are not automatically propagation debt.
- R3: Similar code in separate bounded contexts may represent different decisions. Local repetition can be clearer than false sharing.
- R4: Thin wrappers are justified when they absorb vendor churn or isolate instability. A closed protocol switch is not automatically missing polymorphism.
- R5: Adapters may depend on both domain and infrastructure to translate between them. High orchestration fan-out can be intentional.
- R6: DTOs, persistence records, and API payloads may be data-only. Simple CRUD may not need a rich domain model.

## Test Rules

| Code | Canonical name | Compact injected reminder |
| --- | --- | --- |
| `t1` | `test-intent` | Make the scenario, action, and expected outcome obvious in the test name and visible setup. |
| `t2` | `test-resilience` | Assert observable behavior through stable interfaces and control nondeterminism so refactoring does not break valid tests. |
| `t3` | `test-knowledge` | Give shared test knowledge one owner while keeping scenario-specific data and intent visible. |
| `t4` | `mock-boundaries` | Mock genuine external, slow, or nondeterministic boundaries; prefer behavior evidence over internal call choreography. |
| `t5` | `risk-coverage` | Cover material success, failure, boundary, side-effect, and regression risks instead of treating line coverage as proof. |
| `t6` | `test-architecture` | Match test levels, seams, fixtures, and feedback speed to the system's architecture and risk profile. |

### Judgment notes

- T1: Several assertions are fine when they tell one coherent behavioral story. Shared setup is fine when it is relevant and visible.
- T2: An emitted command or external interaction can be observable behavior. Fakes and spies are acceptable when assertions remain behavioral.
- T3: The same scenario may appear at several levels when each protects a distinct risk. Small local setup duplication can improve clarity.
- T4: Interaction assertions are appropriate when the interaction itself is the contract. Realistic fakes are not mock abuse by default.
- T5: Coverage metrics are useful evidence when paired with boundary, branch, and change-path reasoning.
- T6: Test-pyramid ratios and runtime thresholds are heuristics. Platform constraints and product risk can justify a different shape.

## Applicability

- Apply production rules to new or modified production code, architecture, APIs, and dependency decisions.
- Apply test rules when adding, changing, selecting, or reviewing tests for the requested implementation.
- A selected test rule may influence production seams only when doing so serves a real testability and architecture boundary.
- If the task is non-coding, Brooks is not applicable and renders no injection.

## Provenance

The diagnostic taxonomy and exceptions originate from [Brooks Lint](https://github.com/hyhmrright/brooks-lint). This mentality does not copy its audit workflow, severity system, health score, or Iron Law because its purpose is preventive authorship rather than post-hoc diagnosis.

## Guardrails

- DO NOT turn a compact reminder into an unconditional numeric threshold.
- DO NOT inject rules that are absent from the selected state.
- DO NOT reproduce Brooks Lint report language when guiding implementation.
