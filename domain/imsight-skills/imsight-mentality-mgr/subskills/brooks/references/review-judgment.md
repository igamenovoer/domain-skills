# Brooks Review Judgment

Use these considerations to evaluate competing remedies after establishing a concrete finding. They add no selectable rules, source-reading step, or automatic severity threshold.

## Resolving Tradeoffs

- **Local clarity versus shared ownership:** extract shared policy when independent copies can drift; retain small local repetition when a shared helper would hide each scenario's meaning.
- **Information hiding versus extra layers:** an abstraction earns its place by hiding a current decision or volatile boundary. A speculative extension point with no present value does not become useful because it resembles an architectural pattern.
- **Isolation versus integration evidence:** isolate policy where that gives faster, reliable feedback; retain boundary tests for contracts, persistence, serialization, and actual system risks. A passing mock cannot establish those contracts alone.
- **Domain fidelity versus ceremony:** keep invariants and language coherent using a model suited to the domain. Methods on every data record and rich aggregates for simple CRUD are not required.
- **Compatibility versus authorized change:** real supported callers matter, while an explicit project decision to break an interface changes the remedy. Review the requested transition and affected repository consumers under that policy.
- **Review breadth versus evidence:** preserve selected criteria while honestly marking gaps. A short diff can support a serious finding; a large diff does not prove poor boundaries, and a sampled review cannot establish whole-project health.

When selected principles pull in different directions, follow the shared scope precedence for effective criteria or the explicit task's criteria and requirements for that review. Explain material residual tradeoffs. Do not erase a principle from project or memory state to settle a finding.
