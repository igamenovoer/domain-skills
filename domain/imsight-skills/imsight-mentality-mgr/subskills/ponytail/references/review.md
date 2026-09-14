# Ponytail Review

## Overview

Find supported opportunities to simplify implementation through reuse, removal, or consolidation within the assigned task and resolved edit boundary. Keep the upstream review's compact actionable style while requiring evidence that the proposed replacement preserves behavior. This is a simplification review, not shipping approval or a substitute for a general correctness review.

## Workflow

1. **Resolve criteria and axes** through **Review Selection**, [state.md](state.md), and [shared rule selection](../../../references/review-common.md#rule-selection). Validate the whole request before scanning.
2. **Establish the target and task baseline** through [shared code scope](../../../references/review-common.md#code-scope) and the Ponytail [edit boundary](state.md#edit-boundary). Identify eligible new code or task-related existing infrastructure; existing context is not automatically a recommendation target.
3. **Read the relevant contract and flow**: callers, existing helpers, supported runtime, failure handling, tests, and any claimed operational limits. Load selected [principle definitions](principles.md) or valid deployed definitions under the shared runtime policy.
4. **Inspect applicable opportunities** using [review-patterns.md](review-patterns.md), filtered by selected IDs and permitted surface. Support each candidate with its specific replacement, preserved behavior, and connection to the assigned task.
5. **Challenge the candidate** under **Finding Evidence**: check edge cases, defensive guarantees, existing consumers, and whether the proposed reduction just moves complexity elsewhere. Mark material unknowns as blocked opportunities rather than approved cuts.
6. **Report findings and limits** through **Report Format** and the shared coverage contract. Follow [read-only effects](../../../references/review-common.md#read-only-effects); save only through the shared explicit report protocol.

If the request does not map cleanly to these steps, use the native planning tool to preserve the selected criteria, known task baseline, and read-only boundary without inventing activation or a codebase-wide refactor.

## Review Selection

Invoke `imsight-mentality-mgr->ponytail->review()` with a PR, diff, files, or pasted code; without a target, use the shared code-scope contract. A natural example is `$imsight-mentality-mgr ponytail review normal new-code-only` followed by the target.

Criteria accept explicit p1–p12, canonical names, or `all`, or alternatively `intensity=safe|normal|extreme`. Optional `edit-scope=new-code-only|destructive` overrides only this review's boundary. Unambiguous short intensity and edit-scope names are accepted. Do not combine explicit rule selectors with an intensity parameter. Review settings never persist, and destructive scope never applies fixes or installs upstream tools.

Apply shared selection with Ponytail's canonical IDs. Explicit intensity expands into R for this invocation, including normally memory-disabled rules; label its source review-request. Explicit individual selectors instead define a custom R. Omitted criteria use E unchanged. An empty E stops only a default review; explicit valid criteria can run without prior activation or deployment. Unknown settings or selectors reject the complete request rather than falling back to all.

Resolve edit scope separately, using an explicit review parameter first, then agent memory, project, and the default new-code-only. An explicit destructive parameter allows recommendations affecting task-related infrastructure; it enables no rule and applies no edit. Without it, increasing intensity or passing all leaves the resolved edit boundary unchanged. If memory is unavailable, report that uncertainty rather than claiming a known inherited scope; an explicit invocation boundary can resolve the review without repairing stored state.

For new-code-only, recommendations concern new task code and its use of existing infrastructure. Read old helpers to verify contracts but do not recommend deleting or replacing them. For destructive, each recommendation must serve the task at hand, including required caller/contract updates, with minimal impact. Do not inventory unrelated abstractions, flags, or dependencies for cleanup unless the assigned task explicitly requests that breadth.

If the target contains only established infrastructure and scope is new-code-only, report no eligible new-code target and the resulting coverage limit. Do not call it lean, silently switch to destructive, or label the whole file new because the task renamed or rewrote it.

## Finding Evidence

Retain a supported finding only when it identifies:

- A precise file/line or snippet location, applicable p IDs, and the current implementation burden.
- The proposed cut or consolidation and the concrete replacement, including a named existing helper, native feature, or standard function when applicable.
- Evidence that the replacement preserves the material behavior affected by the task, including meaningful boundary or failure behavior where relevant. Use existing tests, contracts, and code inspection; this is not a checklist requiring new tests for every category. State what was inspected rather than claiming execution.
- Why the change fits the task and edit scope. For existing-infrastructure changes, explain the necessary connection and affected callers; an unrelated potential saving is outside scope.
- A specific evidence gap or follow-up check when confidence is incomplete. A candidate whose equivalence is unknown remains conditional and is not presented as a supported removal.

Check [Validity Requirements](principles.md#validity-requirements) before accepting any simplification, regardless of intensity or selected IDs. A single caller or implementation is not proof of unnecessary structure. An uncommon input is not proof a guard is unnecessary. Savings in lines or dependencies do not establish a benefit if the proposal increases hidden obligations or weakens defenses.

Selected p4, p6, or p7 can identify a placement, verification, or limitation issue without a line-saving claim. Keep those notes tied to the proposed task implementation or simplification. Do not expand into unrelated bug hunting, a test-suite overhaul, or automatic debt harvesting. A directly observed issue that invalidates a proposed cut belongs in its evidence discussion.

For p6, identify a plausible material regression and the specific gap in existing evidence before recommending additional tests. Missing new tests for an edited function is not itself a finding. Prefer an existing product-level check or a focused addition at a suitable boundary; adequate coverage needs no extra suite, runtime conformance tests, or duplicate checks at every level.

## Report Format

Use [shared coverage and reporting](../../../references/review-common.md#coverage-and-reporting), including R, derived intensity or custom label, resolved edit scope and source, task baseline, and coverage gaps. Group common coverage statuses to keep reports concise. For findings, use a compact form that can expand when evidence needs explanation:

```text
<file>:<line> — <tag> [p IDs]: <what to simplify> → <replacement>.
Evidence: <why the required behavior remains covered and the change fits this task>.
Check/limit: <a material remaining condition, if any>.
```

The tags and ID mapping live in review-patterns.md. State findings in the user's language, preserve IDs, and give enough detail to justify the change; no strict one-line or three-line limit applies. Separate supported simplifications from conditional opportunities and boundary conflicts. Prioritize relevance, confidence, and maintenance benefit over raw deletion size; do not double-count a change under several tags.

An optional net line/dependency estimate is allowed only when the concrete replacements and non-overlapping scope make it defensible. Label it an estimate, include necessary caller/test changes, and omit it when evidence is insufficient. Do not import upstream performance, cost, or safety percentages. No numeric quality score is produced.

With no supported findings, report no supported simplification within the assessed criteria and scope, qualified by any gaps. Empty criteria or no eligible target is a review not performed; neither result implies that the code is safe to ship.

## Saved Reports

Follow [shared saved reports](../../../references/review-common.md#saved-reports) only on an explicit save request. Identify Ponytail and record the review criteria, intensity, edit scope, task baseline, findings, and limits as historical evidence. The artifact does not change AGENTS.md, catalogs, agent memory, or future modes and cannot supply another agent's settings.

## Guardrails

- DO NOT let extreme or all imply destructive edit scope.
- DO NOT recommend changes outside the assigned task or resolved edit boundary.
- DO NOT approve a cut whose edge-case equivalence or required behavior remains unknown.
- DO NOT treat reduced lines or dependencies as proof of correctness or maintenance benefit.
- DO NOT apply fixes, persist configuration, or automatically launch audit/debt workflows during review.
