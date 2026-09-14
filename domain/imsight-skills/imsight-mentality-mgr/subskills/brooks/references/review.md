# Brooks Review

## Overview

Review existing code for maintainability and test risks using the Brooks principle IDs already owned by this mentality. The workflow, all twelve diagnostic dimensions, judgment guidance, and [shared review contract](../../../references/review-common.md) are bundled inside this mentality manager. Prior deployment, a separately installed Brooks skill, upstream configuration, and access to source books are not prerequisites.

## Workflow

1. **Resolve the request and project** from the explicit review target and the shared [runtime contract](../../../references/runtime-injection.md). Identify requested selectors and whether a saved report was requested.
2. **Resolve review criteria** using **Rule Selection** and [state.md](state.md). Stop the diagnostic scan if there are no selected criteria or their resolution is materially uncertain; report the scope issue without changing state.
3. **Establish code scope** using **Code Scope**. Read the purpose, applicable repository instructions, relevant definitions, changed code, callers, and related tests. Record the revision or working-tree evidence inspected.
4. **Inspect selected dimensions** using **Diagnostic Pass** and the matching entries in [review-risks.md](review-risks.md). Load selected constructive definitions from the deployed catalog when valid, otherwise [principles.md](principles.md), following the shared runtime's definition policy.
5. **Validate each candidate** against **Evidence and Severity** and [review-sources.md](review-sources.md). Complete diagnosis before proposing a remedy; check counterexamples, causal consequences, and duplicate findings.
6. **Report coverage and findings** using **Report Contract**. Save only when explicitly requested, following **Saved Reports**. Preserve project and agent-memory selections throughout.

If the task does not map cleanly to these steps, use the native planning tool to build a bounded review from the requested criteria, available evidence, and read-only contract without assuming activation or expanding into a repository-wide audit.

## Rule Selection

Invoke `imsight-mentality-mgr->brooks->review()` with a PR, diff, files, directory, or pasted code; without a target, follow **Code Scope**. A natural example is `$imsight-mentality-mgr brooks review r1 t2` followed by the target. Results return in chat; only an explicit save request permits a report file, and review changes neither activation nor code.

Follow [shared rule selection](../../../references/review-common.md#rule-selection) with Brooks selectors from [state.md](state.md). Omitted selectors use effective rules; explicit selectors replace criteria for this review only. Explicit all or full Brooks review selects r1–r6 and t1–t6 without changing activation. Empty effective selection stops only default review, not an explicit valid selection.

Explicit selectors may be codes, canonical names, groups such as `production` or `tests`, or `all`. “Review with Brooks” alone uses effective rules; it does not request every criterion.

### Selection examples

| State and request | Expected result |
| --- | --- |
| P = r1,r5; this agent M+ = t2 and M- = r5; default review | R = r1,t2. r5 stays suppressed. |
| Same state; review explicitly selects r5 | R = r5 with source review-request. Subsequent recall remains r1,t2. |
| Same project; a second fresh agent has no overrides | Its default review uses r1,r5, independently of the first agent. |
| Empty project and fresh memory; explicit all | R contains twelve IDs for this review; subsequent recall remains empty. |

## Code Scope

Follow [shared code scope](../../../references/review-common.md#code-scope), including both local diff layers, evidence-based PR/branch bases, generated-file checks, and explicit sampling limits. Brooks has no Ponytail intensity or edit-scope setting; its requested review target remains authoritative.

## Diagnostic Pass

Read each selected rule's definition, diagnostic entry, and relevant source notes. Inspect production dimensions in this order when selected and applicable: r2 change boundaries, r1 comprehension, r3 decision ownership, r4 essential complexity, r5 dependencies, then r6 domain fidelity. This order guides investigation and does not establish rule priority.

For selected test dimensions, inspect related test bodies and fixtures, including existing tests for changed behavior. Assess t5 behavior protection, t4 boundary doubles, t1 readable intent, t2 resilience, t3 shared knowledge, and t6 suite placement/seams as applicable. Test-only changes still receive selected test checks. The bundled diagnostics cover all six test IDs; this is not limited to the upstream three-signal quick check.

No new test file is not proof of missing protection: trace the changed behavior to existing assertions, including integration evidence. Likewise, absence of tests from a pasted snippet is missing evidence, not proof the repository lacks tests. For t6, examine relevant seams and test configuration when available; a single diff rarely establishes suite-wide timings or architecture. Report that limit without inventing suite metrics or automatically launching a broader audit.

Follow [shared read-only effects](../../../references/review-common.md#read-only-effects).

## Evidence and Severity

Every finding follows **Symptom → Source → Consequence → Remedy**:

- **Symptom:** observable behavior or structure, with exact file and line evidence and relevant callers. For pasted code, use snippet line numbers or a named symbol; never invent repository locations.
- **Source:** canonical rule ID/name and the matching conceptual source from the bundled source notes. Book attribution explains the principle; it does not prove a code defect. Avoid unverified quotations or page numbers.
- **Consequence:** a concrete failure or maintenance cost with a supported causal path. Distinguish demonstrated behavior from a conditional risk and state the condition. Hypothetical future consumers do not justify speculative findings.
- **Remedy:** a specific target, action, and reason proportional to the observed problem. Explain a necessary design choice when evidence cannot determine it. Describing a remedy does not authorize applying it.

Before retaining a finding, check the documented counterexamples and any justified project tradeoff. Prefer one finding for one underlying cause, with related IDs when useful; do not double-count the same coupling as r2, r3, and r5. If only a threshold or an unsupported suspicion remains, omit it as a finding and record a material evidence gap when useful.

| Severity | Evidence needed |
| --- | --- |
| Critical | Demonstrated severe impact or a concrete near-term production/change-safety risk on an exercised path. State the trigger and impact. |
| Warning | A supported causal maintenance or regression risk in the affected work, with identifiable callers, decisions, or failure modes. |
| Suggestion | A concrete local improvement with modest demonstrated benefit and proportionate cost. Pure taste does not qualify. |

Apply consequence-based severity after diagnosis. Line counts, mock counts, fan-out, file counts, coverage percentages, and test ratios are prompts to inspect context, never automatic severity assignments. This procedure produces no numeric health score or trend comparison.

## Report Contract

Follow [shared coverage and reporting](../../../references/review-common.md#coverage-and-reporting), preserving the Brooks finding fields: severity, concise title, canonical ID/name, exact location, and Symptom / Source / Consequence / Remedy. Sort Critical, Warning, then Suggestion. With many findings, give a short fix order based on dependencies and impact. A small review may use compact prose while retaining evidence and scope limits.

Do not offer automatic accept/dismiss/defer triage or persist suppressions. Neither `.brooks-lint.yaml` nor old reports supply selectors, severity overrides, custom risks, or activation state. The supported vocabulary is the twelve bundled IDs. If no findings remain, say no supported findings within the assessed criteria and scope, qualified by gaps; empty selection is a review not performed.

## Saved Reports

Use the [shared saved-report protocol](../../../references/review-common.md#saved-reports) only when explicitly requested. Identify Brooks as the mentality; saving changes no project or memory selection.

## Guardrails

- DO NOT treat an explicit review selector as a project or memory enable.
- DO NOT silently replace empty, invalid, or unavailable effective selection with all rules.
- DO NOT import activation, suppression, scoring, or custom-risk state from upstream configuration or report files.
- DO NOT report threshold crossings or missing snippets as established defects without causal evidence.
- DO NOT claim full review coverage when selected dimensions were sampled, inapplicable, or unassessed.
- DO NOT write files during review except for an explicitly requested report.
- DO NOT apply remedies, automatically run other Brooks skills, or load provenance snapshots as runtime instructions.
