# Ponytail Constructive Principles

This catalog describes available principles, not activation state. Project or agent selections determine which principles apply. Every selected principle operates within the resolved task and edit boundary; all simplifications must preserve the required contract and sensible edge-case defenses.

## Principle Index

| ID | Canonical name | First intensity | Reminder |
| --- | --- | --- | --- |
| p1 | reuse-existing | safe | Reuse suitable project helpers and conventions after checking their behavior. |
| p2 | prefer-proven-primitives | safe | Prefer suitable standard-library and native facilities with the required semantics. |
| p3 | avoid-unneeded-dependencies | safe | Avoid a new dependency when a reliable existing solution suffices. |
| p4 | fix-owning-boundary | safe | Trace affected callers and fix the root cause at the correct boundary. |
| p5 | remove-proven-redundancy | safe | Remove demonstrably dead or redundant work whose purpose is already satisfied. |
| p6 | verify-changed-risks | safe | Verify normal behavior, meaningful boundaries, and anticipated failures proportionately. |
| p7 | document-real-limits | safe | Make deliberate constraints, ceilings, and revisit triggers explicit. |
| p8 | collapse-structure | normal | Consider collapsing structures whose present value does not justify their cost. |
| p9 | compact-implementation | normal | Consolidate implementation when it reduces maintenance effort without obscuring behavior. |
| p10 | remove-unused-flexibility | extreme | Consider removing variation points without an established requirement or consumer. |
| p11 | replace-existing-dependencies | extreme | Consider replacing an existing dependency after checking contracts and migration costs. |
| p12 | challenge-speculative-work | extreme | Question machinery for hypothetical needs while delivering the complete requested outcome. |

Safe contains p1–p7. Normal adds p8 and p9. Extreme adds p10–p12. Presets select increasingly broad simplification opportunities; they do not weaken the validity requirements below or imply permission to revise existing infrastructure. Edit scope is independent: new-code-only preserves established infrastructure; destructive permits only minimal revisions of infrastructure related to the assigned task. Broad codebase refactoring requires that explicit assignment.

## Safe Rules

### p1 — reuse-existing

Search the relevant codebase for a helper, type, or convention before writing another implementation. Check its input, error, normalization, and side-effect contract; similarity in name is not proof of suitability.

**Example:** A new export endpoint needs slug generation. Reuse the project's slug helper if its transliteration and collision behavior meet the endpoint's requirements. A short regex that drops accented characters may be less code but a different product behavior.

**Judgment:** Reuse must not force callers into the wrong bounded context or require restructuring an unrelated module. Under new-code-only, call the existing helper as supported; do not rewrite it merely to make the new caller shorter.

### p2 — prefer-proven-primitives

Prefer a standard-library or native platform facility when its actual semantics, supported versions, and accessibility meet the task. Compare behavior before accepting a smaller implementation.

**Example:** Use a standard CSV reader instead of splitting lines on commas when fields can be quoted. Preserve the required policy for empty fields and malformed rows; replacing a parser does not authorize deleting that policy. A native date input is suitable only if it supports the requested interaction and accessibility needs.

**Judgment:** Standard availability is not universal equivalence. A native primitive that lacks required timezone, validation, or platform behavior does not satisfy the task. If new-code-only scope requires a caller to use an established infrastructure abstraction, reuse that abstraction rather than bypassing it to reach a primitive directly.

### p3 — avoid-unneeded-dependencies

Before adding a package, compare suitable installed dependencies, native facilities, and a small maintainable implementation. Consider ongoing updates and integration costs, not just the number of package entries.

**Example:** Do not install a formatting library for a call the supported runtime already implements. Conversely, an established protocol or cryptography library can cost less to own than a superficially short custom implementation with incomplete edge handling.

**Judgment:** This rule concerns avoiding unnecessary additions. It does not by itself call for removing an existing dependency; that is p11 and still subject to edit scope. Adding a small feature must not become a dependency migration project.

### p4 — fix-owning-boundary

Read the affected flow and relevant callers before choosing a fix location. Prefer one correct change at the decision's owner over repeated symptom patches, when that location is permitted by the task and edit scope.

**Example:** Transfers and withdrawals both use a shared debit operation. A report mentioning transfers does not justify fixing only their caller while withdrawals still bypass the same invariant. Trace both callers and identify the shared defect.

**Judgment:** New-code-only cannot silently widen into a shared-infrastructure repair. If the valid fix requires that change, use a precise existing task authorization or surface the boundary conflict; do not create a misleading caller-only workaround. In destructive scope, update only the affected boundary and necessary callers, not surrounding services that happen to be nearby.

### p5 — remove-proven-redundancy

Remove dead code, duplicated calculations, or repeated checks only after establishing that no supported behavior depends on them. Examine actual callers, entry points, and invariants; a text search with no hits may miss reflective or external uses.

**Example:** A validated internal object may make a repeated representation check redundant if every supported entry point guarantees that representation. A network handler's validation remains necessary when untrusted input can reach it independently.

**Judgment:** A rare condition is not an impossible one. Preserve checks that defend different boundaries, prevent data loss, or express distinct domain constraints. Under new-code-only, cleanup is limited to new task code; established infrastructure is context, not a cleanup target.

### p6 — verify-changed-risks

Use existing tests, contracts, and focused checks to verify the behavior affected by a simplification. Cover meaningful normal, boundary, and anticipated failure cases according to risk and repository conventions.

**Example:** When simplifying a duration parser, inspect or add appropriate checks for a normal duration, zero, and malformed input, preserving the specified rejection behavior. Reuse the project's test runner rather than introducing a separate demo framework or embedding test scaffolding into production code.

**Judgment:** There is no exact-one-test rule and no ban on frameworks or fixtures. Existing tests may already supply the evidence; trivial reversible edits do not need mechanical tests that merely mirror the implementation. Passing one happy-path example does not establish equivalence. In a read-only review, describe available evidence and missing checks without executing or writing them automatically.

### p7 — document-real-limits

Record a deliberate simplification's actual ceiling and the condition that would justify changing it when those facts matter to future maintainers. Preserve necessary tuning, calibration, and operational controls.

**Example:** A global lock may meet the current concurrency requirement. A concise comment can identify its serialization limit and a measured-contention trigger for per-account locking. A sensor's calibration parameter should remain when physical tolerances require it, even if a fixed value makes the code shorter.

**Judgment:** Use the repository's established comment or decision-record convention; a `ponytail:` prefix is optional when compatible. Add a note only for a real limitation, not every simple implementation. A comment does not make a violated requirement acceptable, and an unknown ceiling should not be presented as measured. New-code-only scope does not authorize editing unrelated old comments.

## Normal Additions

### p8 — collapse-structure

Actively consider collapsing wrappers, factories, interfaces, or layers when they add coordination cost without hiding a useful decision, protecting a contract, or serving a current requirement.

**Example:** A newly added factory and wrapper only forward unchanged arguments to an existing service and introduce no lifecycle, policy, or substitution boundary. Calling that service directly may make the new feature easier to own. Under destructive scope, the same question may be asked of existing task-related structures.

**Judgment:** One implementation or caller alone is not enough evidence. Retain interfaces that isolate volatile dependencies, test seams that protect behavior, public contracts, and adapters with real translation responsibilities. A new-code-only task preserves those established structures even if a reviewer would design them differently today.

### p9 — compact-implementation

Consider consolidating functions, files, and control flow when it reduces the concepts and locations needed to maintain the task's behavior. Prefer explicit readable control flow over line-count targets.

**Example:** Two new functions split one simple transformation so that neither has a meaningful independent responsibility. A cohesive function may be clearer. Keep explicit branches when they explain malformed-input handling instead of replacing them with a dense expression that hides the error path.

**Judgment:** Fewer files is not universally better. Preserve repository placement conventions, clear ownership boundaries, and useful names. Under new-code-only, compact only the newly introduced implementation; moving existing infrastructure into a new file is still an existing-code change.

## Extreme Additions

### p10 — remove-unused-flexibility

Consider removing configuration, extension points, optional branches, and supported variations only when evidence establishes that they have no required consumer or operational role within the assigned task.

**Example:** A new exporter adds plugin discovery and three unused transport modes for an unspecified future integration. Implementing the requested transport through the established interface can satisfy the task without those new variation points.

**Judgment:** No in-repository setter is not proof that an environment option is unused. Preserve external consumers, rollback controls, accessibility features, and calibration knobs required by the actual contract. Under destructive scope, investigate only relevant variation points; do not scan the codebase for unrelated flags to delete.

### p11 — replace-existing-dependencies

Consider replacing a dependency with a suitable runtime facility or smaller maintained solution after accounting for semantic differences, affected consumers, and transition costs.

**Example:** A task-related date-formatting dependency might be removable if the supported runtime covers its actual locale and timezone behavior and all affected calls can be updated coherently. Similar output for one date does not establish equivalence.

**Judgment:** Security, parser, internationalization, and platform edge behavior often justify a mature dependency. Do not hand-roll those contracts to reduce package count. Under new-code-only, a rule whose target is an existing dependency replacement is inapplicable; adding new code that avoids an unnecessary new dependency is instead covered by p3. Destructive scope still requires the replacement to serve the assigned task.

### p12 — challenge-speculative-work

Question mechanisms justified only by hypothetical future scale, consumers, or variation. Choose a smaller complete solution when it meets every assigned requirement; explain a meaningful deferred option and its trigger when useful.

**Example:** If a task asks for efficient repeated lookup, evaluate the actual data size and existing indexing before inventing a distributed cache. If the task explicitly requires caching with expiration, a permanent memoization shortcut does not satisfy it.

**Judgment:** Do not ship a reduced requirement and ask whether the user wanted the full version. Preserve requested features and explanations. Extreme intensity changes the opportunities considered, not the user's goal. Repository-wide deletion or restructuring requires that explicit assignment even in destructive scope.

## Validity Requirements

These determine whether a simplification is acceptable at any intensity; they are not optional selectable rules or automatic project activation. Preserve the required input and output contract, anticipated invalid-input handling, meaningful boundary conditions, security and accessibility requirements, and error behavior that prevents data loss. Keep necessary runtime compatibility, hardware calibration, and operational controls.

A shorter replacement must handle the cases relevant to the task, not merely its easiest example. An email validator cannot be replaced with an at-sign check without establishing that this meets the actual validation contract. An idempotent operation can still require retries for transient failures. A rare edge case remains relevant unless a validated invariant excludes it or it is demonstrably outside the supported contract.

Unknown equivalence is an evidence gap. Retain the behavior or identify the missing evidence instead of treating uncertainty as permission to remove it. Avoid speculative defensive scaffolding at every internal call, but do not discard an existing safeguard without understanding the guarantee it provides.

Preserve the assigned task boundary as well as behavior. In destructive scope, make the smallest coherent infrastructure change related to the task, including necessary caller updates. Do not use a nearby simplification opportunity to initiate unrelated cleanup or codebase-wide refactoring. In new-code-only scope, preserve existing infrastructure and apply selected rules to newly written callers and additions.

## Applicability

Apply selected rules to coding, design, fixes, and explicit simplification reviews within the resolved task and edit scope. Existing code may be read as context even when it cannot be revised. A selected rule without a permitted target is inapplicable; it does not grant a broader edit surface. Non-coding prose is outside this mentality, and requested explanations remain part of the task.

The ordered reuse preferences apply only when their rules are selected and alternatives satisfy the contract. Deployment lists all principles for discovery without enabling them. Review may use explicit criteria for one invocation while leaving project and agent selections unchanged.

## Provenance

Adapted from Ponytail by DietrichGebert, revision 356918eba965ee1eac64bd3a7f0dd02108350de5, under the MIT license. The mentality manager bundles the upstream source snapshot and permission notice. This adaptation replaces persistent persona/intensity hooks and blanket shortest-code rules with scoped principle selection, three cumulative intensities, independent edit boundaries, and explicit behavior-preservation requirements. No upstream installation, mode file, or service is needed to use these definitions.
