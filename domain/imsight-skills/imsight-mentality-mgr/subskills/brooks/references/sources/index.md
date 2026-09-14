# Brooks Offline Sources

Origin: [hyhmrright/brooks-lint](https://github.com/hyhmrright/brooks-lint/tree/1892f7857802f4175ba191b8dae42b5cfbc5f292), revision `1892f7857802f4175ba191b8dae42b5cfbc5f292`. License: [MIT](license.md).

The original production-risk, test-risk, and source-coverage documents are copied locally with origin records. The rule notes below summarize that bundled grounding and explain how the catalog's original teaching examples use it. They are not copied passages from the books or articles. The earlier web attributions are retained as optional further reading, not as required source files; full books and those web pages are not bundled. No network lookup is needed to interpret a rule or example.

| Local source | Contents |
| --- | --- |
| [Production risks](production-risks.md) | All six original production risks, symptoms, source mappings, and exceptions. |
| [Test risks](test-risks.md) | All six original test risks, symptoms, source mappings, and exceptions. |
| [Source coverage](source-coverage.md) | Original twelve-book interpretation notes and tradeoffs. |

These files preserve historical evidence, not active thresholds, modes, or activation instructions. Use the maintained mentality's selected rules and judgment. Copy this whole directory, including the index and license, when deploying the catalog.

## r1

Bundled original: [R1 risk reference](production-risks.md#risk-1-cognitive-overload-r1).

Keep names, responsibilities, and abstraction levels understandable together. A long cohesive routine can be clearer than several shallow helpers.

Earlier web attribution, optional: [Software Engineering at Google — Style Guides](https://abseil.io/resources/swe-book/html/ch08.html).

## r2

Bundled original: [R2 risk reference](production-risks.md#risk-2-change-propagation-r2).

A decision that leaks into several consumers forces coordinated changes. Put it at its natural owner without inventing a shared abstraction for unrelated meanings.

Earlier web attribution, optional: [Martin Fowler — the Shotgun Surgery problem](https://martinfowler.com/articles/modularizing-react-apps.html).

## r3

Bundled original: [R3 risk reference](production-risks.md#risk-3-knowledge-duplication-r3).

Centralize a shared business decision, not every similar expression. Similar syntax in separate contexts may represent different knowledge.

Earlier web attribution, optional: [The Pragmatic Programmer — DRY](https://books.pragprog.com/tips/).

## r4

Bundled original: [R4 risk reference](production-risks.md#risk-4-accidental-complexity-r4).

Require layers, options, and factories to serve a current need. Retain thin adapters that hide an actual volatile dependency or contract.

Earlier web attribution, optional: [Martin Fowler — YAGNI](https://martinfowler.com/bliki/Yagni.html).

## r5

Bundled original: [R5 risk reference](production-risks.md#risk-5-dependency-disorder-r5).

Keep policy independent of concrete infrastructure where the boundary matters. Composition roots and explicit translation adapters may know concrete types.

Earlier web attribution, optional: [Microsoft — Clean architecture](https://learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures).

## r6

Bundled original: [R6 risk reference](production-risks.md#risk-6-domain-model-distortion-r6).

Use the domain language and protect invariants at their owner. DTOs and straightforward CRUD do not require elaborate domain models.

Earlier web attribution, optional: [Microsoft — Designing a DDD domain model](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-domain-model).

## t1

Bundled original: [T1 risk reference](test-risks.md#risk-t1-test-obscurity).

Make the scenario and expected outcome visible in test names and setup. Several assertions can describe one coherent behavior.

Earlier web attribution, optional: [Google Testing Blog — Writing Descriptive Test Names](https://testing.googleblog.com/2014/10/testing-on-toilet-writing-descriptive.html).

## t2

Bundled original: [T2 risk reference](test-risks.md#risk-t2-test-brittleness).

Test the public contract rather than private state or internal choreography. A required external interaction can itself be observable behavior.

Earlier web attribution, optional: [Software Engineering at Google — Unit Testing](https://abseil.io/resources/swe-book/html/ch12.html).

## t3

Bundled original: [T3 risk reference](test-risks.md#risk-t3-test-duplication).

Reuse valid setup while keeping the scenario-specific difference visible. Duplicate checks across levels need a distinct risk to justify their cost.

Earlier web attribution, optional: [Google Testing Blog — Cleanly Create Test Data](https://testing.googleblog.com/2018/02/testing-on-toilet-cleanly-create-test.html).

## t4

Bundled original: [T4 risk reference](test-risks.md#risk-t4-mock-abuse).

Choose doubles for actual external or nondeterministic boundaries. Prefer behavioral assertions to a fully mocked call graph.

Earlier web attribution, optional: [Google Testing Blog — Don't Overuse Mocks](https://testing.googleblog.com/2013/05/testing-on-toilet-dont-overuse-mocks.html).

## t5

Bundled original: [T5 risk reference](test-risks.md#risk-t5-coverage-illusion).

Use coverage as evidence about material changed risks, not a percentage target. Protect the relevant boundary or failure behavior without prescribing a new test for every edit.

Earlier web attribution, optional: [Google Testing Blog — Understanding Your Coverage Data](https://testing.googleblog.com/2008/03/tott-understanding-your-coverage-data.html).

## t6

Bundled original: [T6 risk reference](test-risks.md#risk-t6-architecture-mismatch).

Choose test levels for meaningful feedback and product risk. Suite ratios are heuristics; an existing suitable check may already provide enough evidence.

Earlier web attribution, optional: [Google Testing Blog — Just Say No to More End-to-End Tests](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html).
