# Audit an Inference Estimate

## Overview

Reconstruct an existing estimate, chart, spreadsheet, simulator output, or written claim
from sources to result. The audit tests scenario identity, units, evidence, ownership,
placement, causal composition, topology, serving semantics, and artifact lineage before
deciding whether the result is supported.

An audit is read-only by default. It reports a repair plan; it does not silently replace
the original result with a new methodology.

## When to Use

- Use when an inference estimate looks too optimistic, too pessimistic, internally
  inconsistent, or impossible to reproduce.
- Use before relying on a third-party simulator, spreadsheet, benchmark graph, or
  inherited capacity model.
- Use when the source calculation and presentation artifacts may have drifted.
- Do not use when no prior claim exists and the user wants a new full estimate; use
  `estimate`.
- Do not use to debug a live operational regression unless an estimate/model mismatch
  is the object of investigation; use `troubleshoot` for symptom-led diagnosis.

## Workflow

1. **Inventory the claim set**. Identify every reported metric, table, chart, conclusion,
   scenario label, source file, generator, and intermediate artifact in scope.
2. **Reconstruct the scenario**. Load `references/scenario-contract.md`; recover exact
   revisions, workload, topology, runtime, scheduler, cache, and metric semantics without
   filling gaps from intuition.
3. **Trace numeric lineage**. Load `references/units-metrics-evidence.md`; map each output
   through formulas or code to its inputs, units, scope, evidence class, and revision.
4. **Audit state and placement**. Recompute logical state, replication/sharding, per-rank
   placement, liveness, workspace, reserve, and admission independently of the headline.
5. **Audit work and causality**. Reconcile operator/event coverage, execution counts,
   prefill/decode separation, dependency edges, critical-path composition, background
   work, and overlap claims.
6. **Audit hardware and topology**. Check dtype-specific rates, bandwidth level,
   payload-versus-wire rate, collective path, process mapping, contention, and the
   calibration transfer domain.
7. **Audit serving identities**. Recalculate request rate, output-token throughput,
   per-user throughput, concurrency, queue time, goodput, and load from their declared
   numerators and denominators.
8. **Cross-check independently**. Use at least one different calculation path, limiting
   case, measurement, or trusted physical anchor for every material conclusion.
9. **Classify findings and write the audit**. Separate source-model defects, stale
   derived artifacts, unsupported assumptions, presentation defects, and residual
   uncertainty; propose the smallest upstream repair that regenerates all dependents.

If the task does not map cleanly to these steps, use the native planning tool to build
a step-by-step audit from the available artifacts, traceable claims, physical
invariants, and requested assurance level, then execute the plan.

## Audit Order

Audit cheap, global failure modes before tuning local parameters:

1. scenario identity and revision drift,
2. unit, scope, and denominator consistency,
3. source-to-output lineage,
4. logical state and physical placement,
5. event ownership and causal composition,
6. topology and shared-resource limits,
7. scheduler, admission, and queueing semantics,
8. calibration and extrapolation validity,
9. presentation and rounding.

This order prevents a plausible calibration tweak from hiding a more fundamental double
count, missing event, wrong dtype, or per-rank error.

## Required Checks

### Scenario checks

- Every result resolves to one immutable scenario ID.
- The exact model/checkpoint, runtime, engine, kernel set, hardware, and relevant
  configuration revisions are known or explicitly missing.
- Prompt, output, batch, arrival, cache-hit, and concurrency distributions match the
  workload used by the calculation or measurement.
- Metric start/end events, percentile aggregation, and token numerator are explicit.

### Reconciliation checks

- Sum logical state components independently, then reconcile them with physical copies
  per rank, stage, node, and replica.
- Sum event counts, FLOPs, bytes, and messages independently of total time.
- Verify each event and state component has exactly one owner.
- Check that all generated tables and charts can be regenerated from the audited
  machine-readable source and have no hand-edited cells.

### Physical checks

- Memory never exceeds usable capacity at any liveness peak.
- Latency never beats an applicable physical floor without a corrected work/byte count.
- Aggregate capacity does not exceed the limiting compute, memory, DMA, link, CPU, or
  slowest-stage service rate.
- Scaling does not exceed available parallel work or ignore replicated/serial work.

### Serving checks

- Offered requests and emitted tokens reconcile with the stated load and duration.
- Per-user and aggregate throughput share an explicit active-user accounting rule.
- Admission feasibility is not reported as latency SLO success.
- P95/P99 claims are derived from a distribution-aware measurement or model, not an
  average multiplied by an unexplained factor.

## Finding Severity

| Severity | Definition | Required response |
| --- | --- | --- |
| Blocker | Scenario cannot be identified, result is not reproducible, or a defect can reverse the decision | Do not publish or use the conclusion until repaired |
| Major | Material metric or range is wrong, unsupported, or outside the calibration/coverage domain | Repair upstream and regenerate dependent outputs |
| Minor | Presentation, labeling, or low-sensitivity precision issue that does not change the decision | Correct before final publication when practical |
| Note | Valid limitation or improvement opportunity | Record without treating it as a defect |

## Output Contract

Write `audit.md` with:

1. audited scope and artifact inventory,
2. reconstructed scenario and missing fields,
3. claim matrix containing claimed value, independently recomputed value/range,
   difference, evidence class, and verdict,
4. lineage and reproducibility findings,
5. state/placement, event/causality, topology, serving, and calibration checks,
6. findings ordered by severity with file/table/field evidence,
7. smallest upstream repair and all artifacts that must be regenerated,
8. residual uncertainty and whether the original decision remains supported.

When machine-readable artifacts are available, also write or update a separate
`validation.json` for the audit run without overwriting the audited original. Preserve
raw inputs and original outputs byte-for-byte unless the user separately authorizes a
repair.

## Guardrails

- DO NOT infer missing source values from the headline result and then claim independent verification.
- DO NOT repair the original estimate during a read-only audit or overwrite its raw evidence.
- DO NOT downgrade a reproducibility or scenario-identity failure because the headline looks plausible.
- DO NOT use the same opaque simulator output as both the audited claim and its independent anchor.
- DO NOT fix only a presentation table when the upstream source model is defective.
