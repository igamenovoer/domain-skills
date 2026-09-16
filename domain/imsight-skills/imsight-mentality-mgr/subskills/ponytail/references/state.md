# Ponytail Selectors, Configuration, and Edit Boundary

## Workflow

1. Resolve the action and explicit configuration scope. Shared enable/disable uses the [parent defaults](../../../references/actions.md#enabledisable-decision-tree).
2. Validate selectors/axes below; resolve state and settings independently.
3. Execute configuration or a shared action. For application/review, establish **Edit Boundary** first.
4. Report resulting rules, axes, provenance, and effects through **Recall** and shared confirmation.

For other requests, use the native planning tool without inventing scope or activation.

## Selectors and Axes

The [principle index](principles.md#principle-index) owns p1–p12 and canonical names. Normalize case, accept explicit `all`, and deduplicate. Shared rule actions add/remove individual rules; presets belong to configuration or review.

| Axis | Values |
| --- | --- |
| Intensity | `safe`: p1–p7; `normal`: p1–p9; `extreme`: p1–p12. |
| Edit scope | `new-code-only` or `destructive`, defined below. |

Configuration requires explicit project or memory scope and accepts either/both named axes or unambiguous short values such as `normal new-code-only`. No arguments means help; omitted axes preserve their values. Reject conflicting repeated values, unknown modes, mixed preset/individual selectors, and unsupported lite/full/ultra/off inputs before effects.

Route clear preset requests to configuration and explain replacement semantics. Setting safe after extreme removes higher-intensity rules; it is not additive enable.

## State and Precedence

Use shared `E = (P union M+) minus M-` and [family priorities](../../../references/priorities.md). Intensity stores expanded IDs, never a competing mode flag. Derive safe/normal/extreme only for exact matches; otherwise report custom, none, or unresolved. Catalog refreshes do not re-expand IDs.

Rule enables and intensity replacement allocate fresh family priority; disable retains it while rules remain. Edit-scope-only changes allocate nothing. Resolve edit scope from explicit memory, then project, then default `new-code-only`. Missing memory value means inherit, not an explicit override. Rule actions preserve this setting, and intensity never widens it implicitly.

Unknown IDs/settings remain unresolved; resolve or obtain explicit replacement before an update erases them. Lost memory is unavailable, not empty; do not authorize existing-code edits from guessed settings.

### Storage

- Catalog: `.imsight-arts/mentality/ponytail-principles.md`.
- Unified instruction entry and memory namespace: `ponytail`.
- Memory: enabled/disabled IDs, family priority if enabled, optional edit scope; the counter is shared by this agent's families in the project.

Retain rules, presets, and edit-boundary meanings through [Definition Retention](../../../references/runtime-injection.md#definition-retention). Resolve each separately; catalogs may define rules but omit a setting. For example, memory configuration `normal new-code-only` retains p1–p9 enabled, p10–p12 disabled, fresh priority, and explicit scope, using inline boundary content if undeployed.

Keep project IDs, priority, catalog link, and explicit edit scope in one [unified entry](../../../references/runtime-injection.md#unified-mentality-section). With no rules, keep reference-only availability and explicit settings but no family priority or application instruction; see the [example](../../../references/instruction-examples.md#retain-an-independent-setting).

## Configure Project

1. Validate explicit project scope and at least one axis; run [Project application preparation](../../../references/runtime-injection.md#project-application-preparation) without an intermediate instruction-file write.
2. For supplied intensity, replace P with the preset's exact IDs and allocate fresh project priority. For supplied edit scope, replace that value. Preserve omitted axes, unrelated families, and all memory overrides; scope-only changes preserve priority/counter values.
3. Rewrite each target's unified section once with final Ponytail state and counter through the shared write protocol. With no rules, retain only availability/settings.
4. Verify and report selections, priority changes, derived intensity, edit scope, and file effects. A fresh intensity request reprioritizes even unchanged IDs.

## Configure Memory

1. Validate explicit memory scope and at least one axis; read requested meanings without deployment.
2. For intensity S from current rule universe U, replace `M+ = S` and `M- = U minus S`; allocate fresh memory priority. This replaces this child's earlier overrides and masks project rules outside S.
3. For edit scope, set the supplied override. Memory-only `edit-scope=inherit` clears that setting override without changing rule overrides. Preserve omitted axes and other families.
4. Retain state, counter, and meanings only in this agent's context; use [Memory Confirmation](../../../references/runtime-injection.md#memory-confirmation). No files change.

Example: safe after extreme yields p1–p7 even if project scope is extreme; later enabling p8 makes a custom selection. Disabling all rules preserves explicit edit scope and creates no off mode.

## Edit Boundary

Use the assigned task's starting baseline. Existing infrastructure includes helpers, services, interfaces, contracts, dependencies, configuration, callers, and test/build support, including pre-existing uncommitted work. New code is task-owned additions using those contracts, possibly within old files. Copying, moving, renaming, or rewriting existing code does not make it new; reinvocation/compaction does not reset the baseline.

Retain task purpose and baseline in context/handoff, using initial diff/status, a named revision, or supplied artifacts. Review uses the task/patch baseline; added/untracked status alone is insufficient. If provenance is missing, disclose classification limits and obtain the needed baseline rather than assuming everything is new. Create no shared session file.

### New-code-only

Apply selected simplifications to new task code while preserving established infrastructure and behavior. Allow minimal compatible wiring, such as registration or an import/call, and new tests using existing runners/fixtures. Replacing helpers, changing shared signatures, deleting abstractions/dependencies, or reorganizing test support edits existing infrastructure regardless of diff size.

Normal/extreme may simplify new scaffolding only. With no eligible target, a rule is inapplicable. For a necessary infrastructure fix, honor a precise existing task instruction authorizing it or surface the boundary conflict; do not hide it behind a new caller workaround. A general feature request does not authorize surrounding infrastructure redesign.

### Destructive

Make the smallest coherent task-related change, including necessary caller/contract updates. Identify each existing-code change's connection to the requested outcome and preserve required behavior. Follow dependencies needed for correctness; stop at unrelated cleanup. Codebase-wide refactoring requires that assignment and remains bound by its requirements.

Destructive permits scoped source revision, not deleting user data, changing external services, or applying review fixes. Intensity never enlarges this boundary.

## Recall

Add to shared recall: project and memory IDs/priorities; derived project/effective intensity; project, memory, and effective edit scope with provenance; and task baseline plus applicable, boundary-blocked, or unresolved rules. Use custom IDs when no preset matches and label unavailable memory. Without a task, applicability is not evaluated.

Review-only settings belong to that report, not subsequent recall. Same-agent handoffs retain overrides, counter, meanings, and baseline; subagents receive only explicitly assigned overrides/boundaries and their own sequence.

## Guardrails

- DO NOT equate missing overrides with explicit settings, or widen edit scope through intensity/rule actions.
- DO NOT implement preset downgrade as a union or persist a competing intensity flag.
- DO NOT reclassify rewritten infrastructure as new or pursue unrelated destructive edits.
- DO NOT change configuration during recall or review.
