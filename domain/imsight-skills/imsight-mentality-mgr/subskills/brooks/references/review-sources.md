# Brooks Review Sources and Judgment

Use these bundled notes to interpret selected [review risks](review-risks.md), ground findings, and check counterexamples before assigning severity under the [review contract](review.md). These are adapted conceptual summaries, not quotations or a requirement to retrieve the books. Attribution alone never establishes a code defect.

## Source Coverage

| Source | Relevant contribution | Check before citing |
| --- | --- | --- |
| Frederick Brooks — The Mythical Man-Month | Coordination costs in r2, Second-System Effect in r4, conceptual integrity in r5. | Show a leaked decision, unnecessary generality, or inconsistent design policy. Large size and several modules alone prove none of these. |
| Steve McConnell — Code Complete | Routine design, naming, abstraction levels, and defensive flow in r1; proportionate construction decisions in r4. | Explain the reader obligation or hidden failure path. Long, linear routines and clear guard clauses can be healthy. |
| Martin Fowler — Refactoring | Local smells supporting r1–r4 and r6: Long Method, Flag Arguments, Primitive Obsession, Shotgun Surgery, Divergent Change, Duplicate Code, Speculative Generality, Feature Envy, Refused Bequest. | A smell suggests investigation. Locate the consequence and the natural owner of a proposed extraction; DTOs and temporary migration duplication can be justified. |
| Robert C. Martin — Clean Architecture | Direction and stability of dependencies, cycles, interface segregation, and policy boundaries in r5; substitution contracts in r6. | Trace actual edges or the violated caller contract. Composition roots and explicit adapters may depend on concrete details by design. |
| Andrew Hunt and David Thomas — The Pragmatic Programmer | Orthogonality in r2/t2, knowledge ownership in r3/t3, decoupling in r5, proportionate design in r4. | Distinguish shared decisions from similar syntax and accidental coupling from a deliberate cohesive boundary. |
| Eric Evans — Domain-Driven Design | Ubiquitous Language, Bounded Context, aggregate/invariant ownership, entities and value objects in r6, with naming implications for r1/r3. | Use the project's real business vocabulary. Simple CRUD, transaction scripts, boundary records, and functional invariant ownership can be appropriate. |
| John Ousterhout — A Philosophy of Software Design | Deep modules in r1, information leakage in r2, strategic design and abstraction value in r4. | Compare interface complexity with the decisions hidden. A small adapter that absorbs volatility can have real value. |
| Titus Winters, Tom Manshreck, and Hyrum Wright — Software Engineering at Google | Observable contracts and sustainability in r2; dependency management and upgrade costs in r5. | Identify real consumers and supported obligations. Honor explicit project compatibility policy; do not invent an external compatibility burden. |
| Gerard Meszaros — xUnit Test Patterns | Assertion Roulette, Mystery Guest, General Fixture in t1; Eager/Erratic Tests in t2; duplicate/lazy tests in t3; behavior verification/data in t4; Slow Tests in t6. | Evaluate clarity, coupling, and feedback cost. Several assertions can tell one story; shared fixtures can be relevant and visible. |
| Roy Osherove — The Art of Unit Testing | Readable intent in t1, isolation in t2, suitable and complete doubles in t4, behavior completeness in t5. | Behavior can include a contractual interaction. Naming and mock-count heuristics do not replace judgment. |
| Michael Feathers — Working Effectively with Legacy Code | Sensing and separation in t4, protection for risky changing behavior in t5, seams and characterization in t6. | Show why the change needs protection and where a seam belongs. Do not prescribe tests or interfaces for every stable, low-risk line. |
| James Whittaker, Jason Arbon, and Jeff Carollo — How Google Tests Software | Risk-based behavior protection in t5 and the suite portfolio/feedback tradeoff in t6. | Examine the actual product risks and available suite evidence. Test ratios and coverage percentages are useful context, not universal targets. |

## Resolving Tradeoffs

- **Local clarity versus shared ownership:** extract shared policy when independent copies can drift; retain small local repetition when a shared helper would hide each scenario's meaning.
- **Information hiding versus extra layers:** an abstraction earns its place by hiding a current decision or volatile boundary. A speculative extension point with no present value does not become useful because it resembles an architectural pattern.
- **Isolation versus integration evidence:** isolate policy where that gives faster, reliable feedback; retain boundary tests for contracts, persistence, serialization, and actual system risks. A passing mock cannot establish those contracts alone.
- **Domain fidelity versus ceremony:** keep invariants and language coherent using a model suited to the domain. Methods on every data record and rich aggregates for simple CRUD are not required.
- **Compatibility versus authorized change:** real supported callers matter, while an explicit project decision to break an interface changes the remedy. Review the requested transition and affected repository consumers under that policy.
- **Review breadth versus evidence:** preserve selected criteria while honestly marking gaps. A short diff can support a serious finding; a large diff does not prove poor boundaries, and a sampled review cannot establish whole-project health.

When selected principles pull in different directions, follow the shared scope precedence for effective criteria or the explicit task's criteria and requirements for that review. Explain material residual tradeoffs. Do not erase a principle from project or memory state to settle a finding.

## Provenance

Adapted from Brooks Lint's shared source coverage and diagnostic references. The local [source inventory](../org/README.md) records the exact upstream revision and adaptation boundary; its [MIT license](../org/src/LICENSE) retains the original copyright and permission notice. The active review procedure and this reference are sufficient to execute the review without reading the snapshot or accessing upstream resources.
