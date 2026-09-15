# Brooks Review Risks

These diagnostic lenses use the canonical IDs and constructive definitions in [principles.md](principles.md). They do not introduce selectable state. Follow [review.md](review.md) for selection, evidence, severity, and reporting; use [review-judgment.md](review-judgment.md) for practical tradeoffs. Read only the entries selected for the review.


## Rule Mapping

| ID | Canonical principle | Diagnostic lens |
| --- | --- | --- |
| r1 | comprehension | Cognitive Overload |
| r2 | change-boundary | Change Propagation |
| r3 | decision-ownership | Knowledge Duplication |
| r4 | essential-complexity | Accidental Complexity |
| r5 | dependency-direction | Dependency Disorder |
| r6 | domain-fidelity | Domain Model Distortion |
| t1 | test-intent | Test Obscurity |
| t2 | test-resilience | Test Brittleness |
| t3 | test-knowledge | Test Duplication |
| t4 | mock-boundaries | Mock Abuse |
| t5 | risk-coverage | Coverage Illusion |
| t6 | test-architecture | Architecture Mismatch |

Selector codes normalize to lowercase IDs. Each entry supplies signals, evidence to seek, a representative finding/remedy, and counterexamples. Severity comes from the actual consequence, not a per-risk numeric threshold.

## r1 — comprehension

**Question:** What must a reader understand simultaneously to change this code safely?

**Signals and evidence:** Mixed abstraction levels, deeply nested paths, unclear names, unexplained values, long parameter lists, boolean flags selecting unrelated behaviors, primitive values whose meaning callers must reconstruct, and interfaces more complex than the decisions they hide. Trace where these obscure a branch, invariant, or caller obligation. Length over twenty lines, nesting beyond three levels, or more than four parameters merely identify places to inspect.

**Example and remedy:** A checkout routine interleaves retries, currency conversion, and persistence, forcing each caller to choose incompatible flags. Show the affected paths and explain how they permit an invalid combination; separate the distinct operations or make the valid policy explicit at the owning boundary. Extraction is useful only when it reduces the concepts callers must retain.

**Counterexamples:** A long, linear, cohesive routine with clear names and guards can be easier to understand than fragmented helpers. Domain terminology may be unfamiliar to a reviewer yet correct. A deep module can hide substantial internal complexity behind a simple interface.


## r2 — change-boundary

**Question:** Why does one decision require changes outside its natural boundary?

**Signals and evidence:** Coordinated edits in unrelated modules, classes changing for unrelated business reasons, direct access to another object's internals, leaked formats or policy choices, and callers relying on undocumented observable behavior. Trace the shared decision and affected callers; count alone does not establish propagation debt. Compatibility concerns require actual supported consumers and must respect the project's explicit compatibility policy.

**Example and remedy:** Adding a payment type requires editing unrelated logging, caching, and notification switches because each knows the provider's internal status codes. Identify the leaked mapping and the missed-update risk; translate it at its owner and let consumers use an appropriate stable event or result.

**Counterexamples:** Coordinated changes within one bounded context, deliberate API migrations, generated fan-out, and composition-root wiring may be coherent. A supported public API creates an intentional obligation rather than automatic debt. Do not invent external users to argue against an authorized breaking change.


## r3 — decision-ownership

**Question:** Is the same business or technical decision independently maintained in several places?

**Signals and evidence:** Repeated policy calculations or constants, parallel hierarchies that must evolve together, and conflicting names for one concept within one context. Establish that the copies represent the same decision and should change together; duplicated syntax alone is insufficient.

**Example and remedy:** The same regional tax rule is implemented in invoice and refund paths, and the patch updates only one. Identify the divergence and affected transactions; give that policy one owner and make both paths use it, with focused evidence for the boundary cases.

**Counterexamples:** Similar logic across bounded contexts can have independent ownership and lifecycles. Small repeated setup or protocol literals at explicit boundaries may preserve clarity. Temporary duplication in a documented extraction can be a deliberate migration step.


## r4 — essential-complexity

**Question:** What present requirement justifies this abstraction, layer, or option?

**Signals and evidence:** Extension frameworks without a consumer, unused configurable behaviors, wrappers that only expose underlying details, speculative second versions, or accumulated tactical workarounds. Compare the maintenance/interface cost with a real current requirement, including isolation from volatile dependencies.

**Example and remedy:** One local export format gains a plugin registry, lifecycle hooks, and unused compatibility modes. Identify the extra paths maintainers must coordinate; implement the current export through a focused boundary and remove unsupported variation points when they provide no present value.

**Counterexamples:** A thin adapter can earn its cost by containing vendor churn. A single implementation can still justify an interface at a real boundary. A switch over a closed enum or wire format can be clearer than polymorphism. A larger replacement does not establish unnecessary generality by itself.


## r5 — dependency-direction

**Question:** Do dependency edges preserve the project's intended policy boundaries and independent change?

**Signals and evidence:** New cycles, policy importing a concrete persistence or transport implementation, stable modules depending on volatile details, interfaces forcing unused dependencies, inconsistent architectural rules, or dependency constraints blocking real upgrades. Show the specific edges and their consequence; a claimed cycle needs a complete path back to its start.

**Example and remedy:** Pricing policy imports a database driver and its vendor row types, preventing independent pricing tests and coupling a schema change to the policy API. Locate both ends of the dependency; expose the needed domain data through a boundary owned at the appropriate layer and keep translation in the adapter.

**Counterexamples:** Composition roots intentionally depend on implementations. Adapters can import both sides of a boundary. Orchestration modules and stable facades may have high fan-out. Direct access within a cohesive aggregate need not violate encapsulation.


## r6 — domain-fidelity

**Question:** Do names, contracts, and invariant ownership match the problem being solved?

**Signals and evidence:** Important invariants scattered through services, inconsistent business names, logic manipulating another model's private decisions, untranslated bounded-context crossings, inheritance that violates a parent's behavioral contract, or value concepts given inappropriate mutable identity. Read actual domain contracts before prescribing a model.

**Example and remedy:** An order's cancellation rule is duplicated in controllers while another caller can mutate status directly. Show the bypass and resulting invalid transition; locate the invariant at the order's supported transition boundary and translate external status names at the boundary.

**Counterexamples:** DTOs, persistence records, and API payloads can be data-only. Simple CRUD or transaction scripts may suit a simple domain. A functional design can own invariants in functions without methods on every data type. Do not impose a rich object model solely to remove data bags.


## t1 — test-intent

**Question:** Can a reader tell what scenario failed and why without reconstructing hidden setup?

**Signals and evidence:** Vague names, invisible file/database state, oversized fixtures irrelevant to the scenario, and assertions that fail without identifying the behavior. Inspect the framework's actual assertion diagnostics and setup visibility; missing custom messages are not sufficient evidence.

**Example and remedy:** `test_process` relies on a shared database row and checks unrelated outcomes, so its failure does not identify the precondition or behavior. Make the relevant setup and expected outcome visible; split unrelated scenarios while retaining cohesive assertions for one behavior.

**Counterexamples:** Multiple assertions with clear framework diagnostics can tell one coherent story. Shared setup is appropriate when its values matter to nearly every test. Concise names are sufficient when the scenario and outcome remain obvious.


## t2 — test-resilience

**Question:** Would a behavior-preserving change or uncontrolled environment variation invalidate this test?

**Signals and evidence:** Private-state assertions, irrelevant call-order constraints, several unrelated behaviors in one test, dependence on real clocks, random data, ordering, or shared mutable state. Distinguish an observed flaky failure from a susceptibility supported by code; do not claim repeated failures without execution evidence.

**Example and remedy:** A cache test asserts a private helper's call order even though the public result is unchanged by extracting the helper. Show that this order is outside the contract; assert the observable result and expiry behavior through a controlled clock or stable seam.

**Counterexamples:** Published events, emitted commands, and ordering explicitly required by a protocol are behavior. A fake adapter is useful when it preserves that contract. Several assertions can support one behavioral claim.


## t3 — test-knowledge

**Question:** Are tests maintaining duplicate scenario knowledge without protecting distinct risks?

**Signals and evidence:** Repeated domain setup that must change in lockstep, identical scenarios with no changed inputs or outcomes, and the same expensive checks repeated at several layers without a layer-specific purpose. Compare the behavior claims and failure modes before proposing consolidation.

**Example and remedy:** Many tests reproduce the same required account policy fields, so a policy change requires inconsistent edits throughout the suite. Put those defaults in a focused builder while keeping each test's meaningful differences visible. Consolidate duplicate scenarios only after identifying which risk each layer protects.

**Counterexamples:** Unit and integration tests can exercise a similar scenario to verify logic and serialization separately. Small local setup duplication can be clearer than a fixture maze. Similar assertions for independently owned domain rules are not automatically duplication.


## t4 — mock-boundaries

**Question:** Do test doubles isolate a real boundary while preserving evidence about behavior?

**Signals and evidence:** Elaborate internal mock choreography, incomplete or unrealistic doubles, assertions that mirror implementation without observing a required outcome, and production hooks used solely to reach internals. Trace what can break while the test still passes. Mock count and setup length are inspection signals only.

**Example and remedy:** A repository mock accepts fields that the real schema rejects, so a save test passes for an invalid record. Identify the mismatch; make the fake contract realistic and add or locate integration coverage for the mapping. Prefer a real lightweight collaborator when it simplifies the test without losing isolation.

**Counterexamples:** An interaction assertion is appropriate when the interaction is the required behavior, such as publishing one cancellation command. A few mocks around slow or nondeterministic boundaries are useful. Testability seams that improve production boundaries are not test-only contamination.


## t5 — risk-coverage

**Question:** What relevant failure could still occur while the available tests pass?

**Signals and evidence:** Missing assertions for changed error paths, boundaries, side effects, or regressions; actively changed uncertain behavior without protection; and coverage percentages used in place of behavioral evidence. Search related existing tests and their assertions before asserting absence. State the search boundary when evidence is incomplete.

**Example and remedy:** Retry behavior is changed, but available assertions only check the final success result and never detect a duplicated charge. Explain the triggering retry path and search evidence; add a test at the boundary that observes the charge count or idempotency effect.

**Counterexamples:** Existing tests can already protect new implementations and pure refactors. Side-effect checks may live at integration level. A low-risk private helper may not warrant an isolated test. High coverage can be useful alongside meaningful branch and change-path evidence.


## t6 — test-architecture

**Question:** Are test levels, seams, and feedback costs appropriate for the actual risks?

**Signals and evidence:** Broad system tests used for cheaply isolated policy decisions, no usable seam for risky changing behavior, unclear legacy behavior changed without characterization, duplicated expensive setup, or a slow feedback path unsupported by the risk it covers. Inspect test configuration and available timing evidence; do not infer suite distribution or duration from one file.

**Example and remedy:** Every pricing boundary case boots a complete service stack, while network behavior is irrelevant to those cases. Identify the unnecessary dependencies and observed feedback cost if available; exercise pricing through a focused seam and retain integration tests for persistence/transport risks. For unclear legacy behavior, capture the relevant behavior before changing the seam.

**Counterexamples:** An integration-heavy suite can be healthy for a data-bound product with fast, reliable feedback. Ratios such as 70:20:10 and durations such as ten minutes are context prompts, not requirements. A small set of critical end-to-end tests is useful. Limited architecture evidence must be reported as limited coverage rather than a clean suite assessment.
