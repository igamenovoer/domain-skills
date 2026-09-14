# Ponytail Review Patterns

Use these patterns with the selected rules from [principles.md](principles.md) and the [review evidence contract](review.md#finding-evidence). Tags describe findings; they are not another selector or state namespace. Filter by selected IDs and the resolved edit boundary before investigating an opportunity.

## Pattern Index

| Tag | Relevant rules | Evidence to seek |
| --- | --- | --- |
| reuse | p1, p3 | A suitable maintained helper or installed capability already satisfies the task. |
| stdlib | p2 | A supported standard-library facility preserves the required semantics. |
| native | p2 | A supported native feature meets the actual interaction, data, and accessibility contract. |
| delete | p5, p10 | Code or flexibility has no required consumer, guarantee, or operational role. |
| yagni | p8, p10, p12 | Structural or speculative machinery adds present cost without serving a current requirement. |
| shrink | p9 | Consolidation improves clarity or ownership without hiding error paths. |
| dependency | p11 | A task-related dependency replacement preserves contracts and has a justified transition cost. |
| boundary | p4 | The task fix belongs at a permitted shared boundary instead of repeated symptom patches. |
| check | p6 | A plausible material regression remains unsupported by existing evidence; a new test is not automatically needed. |
| limit | p7 | A real simplification ceiling or necessary calibration/operational control is unclear. |

## Reuse and Proven Primitives

Search for existing project helpers before recommending a replacement. Compare normalization, error behavior, supported input shapes, and side effects, not just names. Confirm the primitive is available in the project's supported runtime and fits its established infrastructure. New-code-only recommendations can replace new custom code with calls to existing infrastructure; they cannot rewrite or bypass that infrastructure's required contract.

**Supported example:** A new hand-written comma splitter can use the existing CSV reader while keeping the requested malformed-row policy and quoted-field behavior.

**Counterexample:** Replacing email validation with an at-sign check loses required rejection behavior. Replacing a feature-rich date control with a native input is unsupported when requested interaction or accessibility would be lost. A new dependency is justified when a reliable implementation costs less to maintain than a custom substitute.

## Deletion and Unused Flexibility

Trace callers, configuration inputs, extension mechanisms, and documented operational uses. Establish what guarantee or capability would disappear and why it is unnecessary within the actual contract. Removing a validation check requires a proven upstream invariant on every supported entry point, not an assumption that the invalid case is rare.

**Supported example:** New code calculates the same pure value twice under unchanged inputs; one calculation can serve both uses.

**Counterexample:** No in-repository reference does not prove a plugin hook or environment flag is unused. A fallback may protect partial failure; an idempotent operation may still require retry handling. In new-code-only, an existing unused flag remains outside the recommendation surface. In destructive, a flag unrelated to the assigned task also remains outside it.

## Structure and Consolidation

For p8, identify the wrapper's or interface's actual responsibility before proposing collapse. For p9, compare the reader obligations before and after consolidation. Explain where translation, lifecycle, policy, or error handling would live afterward, including necessary callers and tests when permitted.

**Supported example:** A new single-use wrapper forwards unchanged parameters and contributes no contract or policy; using the existing service directly can remove coordination overhead.

**Counterexample:** A single-implementation interface may preserve a real seam or public boundary. A thin adapter can contain vendor-specific errors. Turning clear validation branches into an opaque one-liner is not a supported reduction. Moving old infrastructure to a newly named file does not turn it into new code.

## Dependency Replacement and Speculation

Inspect the dependency's actual use, supported runtime, edge behavior, and affected task consumers. Determine whether replacement is necessary or useful to the assigned outcome rather than a nearby opportunity to reduce package count. For speculative mechanisms, distinguish a hypothetical future need from a present explicit requirement.

**Supported example:** A new feature adds an unrequested plugin-discovery system for a hypothetical second backend. The requested behavior can use the existing backend interface directly.

**Counterexample:** A memoization decorator does not meet a requested expiration policy. Rewriting a mature parser or security library merely to remove a dependency can increase obligations. p11 is inapplicable to existing dependency replacement under new-code-only; extreme intensity does not change that. Destructive scope never turns an unrelated feature task into a package-migration campaign.

## Placement, Verification, and Limits

Use p4 to trace the affected flow and locate the defect owner, p6 to assess available behavioral evidence, and p7 to identify genuine ceilings and revisit triggers. These checks can justify retaining code or flagging a blocked opportunity; they need not generate a deletion.

For p6, start with existing coverage and observable product behavior. Reusing a sufficient regression test is a complete outcome. Recommend more verification only for a concrete material gap; avoid a test per changed helper, unrelated built-in edge cases, and repeated coverage across levels without a distinct risk.

**Supported example:** A proposed smaller caller patch leaves a sibling caller violating the same shared invariant. Identify the real boundary; if new-code-only prevents the required repair and it was not explicitly authorized by the task, report the scope conflict rather than endorsing the partial fix.

**Counterexample:** If malformed-input behavior changes and remains uncovered, a happy-path assertion alone may be insufficient. Conversely, an internal refactor with adequate existing behavioral coverage does not need a new fine-grained suite. A missing test in a snippet does not prove the project has no tests. A known hardware calibration knob is not dead flexibility merely because its default usually works. Use the project's established verification approach; frameworks and fixtures are not automatically bloat.

## Scope Examples

| Configuration and task | Review boundary |
| --- | --- |
| normal + new-code-only; add a caller of an existing repository | Evaluate new wrappers and control flow; preserve the existing repository interface. |
| normal + destructive; task requires revising that repository boundary | Consider collapsing only structures involved in the task, with necessary caller updates and preserved behavior. |
| extreme + new-code-only; add an exporter | Challenge new speculative flexibility; keep existing dependencies and infrastructure intact. |
| safe + destructive; fix a shared validator | Consider the task-related root-cause repair and proven redundancy; do not begin broader structural cleanup. |
| extreme + destructive; add one endpoint | Inspect only opportunities tied to that endpoint and required infrastructure changes; do not propose a repository-wide refactor. |

## Provenance

The delete/stdlib/native/yagni/shrink tags originate in the upstream Ponytail reviewer. This adaptation adds explicit reuse, dependency, boundary, check, and limit evidence, maps all patterns to the shared Ponytail principle IDs, and replaces unconditional deletion/line-count verdicts with task and contract checks. The [source inventory and MIT notice](../org/README.md) are bundled for provenance, not runtime execution.
