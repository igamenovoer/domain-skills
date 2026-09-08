# Troubleshoot an Inference Estimate

## Overview

Diagnose why observed or modeled memory, latency, throughput, scaling, offload, or
speculative/MTP behavior disagrees with expectation. Work from the discrepancy outward:
first prove scenario and metric identity, then test accounting and causal assumptions,
then choose the smallest discriminating measurement.

## When to Use

- Use when a run OOMs despite an apparent fit, uses much less memory than predicted,
  misses latency or throughput expectations, scales poorly, or changes unexpectedly
  across batch, sequence, hardware, topology, or scheduler settings.
- Use when offload/prefetch appears free or catastrophically slow, or when drafted,
  verified, and accepted tokens produce contradictory speedups.
- Use when simulator output, profiler evidence, and application behavior disagree.
- Do not use for a routine new estimate with no discrepancy; use `estimate`.
- Do not use for a formal read-only review of an inherited artifact set; use
  `audit-estimate`.

## Workflow

1. **Capture the discrepancy**. Record observed value/range, expected value/range,
   direction, magnitude, reproducibility, first bad revision, and operational impact.
2. **Freeze observed and expected scenarios**. Load `references/scenario-contract.md`;
   make hidden differences in model, workload, hardware, topology, runtime, scheduler,
   cache state, warmup, and metric timing explicit.
3. **Run cheap global checks**. Load `references/units-metrics-evidence.md` and
   `references/failure-modes.md`; verify units, scope, denominator, revision, artifact
   lineage, and evidence class before changing efficiency factors.
4. **Localize the failing layer**. Test state/placement, event/critical path,
   topology/contention, serving/admission, calibration transfer, and measurement method
   in that order until one layer explains the discrepancy.
5. **Choose a discriminating tool**. Load `references/tool-map.md`; collect the smallest
   source fact, allocation trace, event trace, counter, topology fact, or controlled
   benchmark that separates the leading hypotheses.
6. **Bisect one assumption at a time**. Hold the frozen scenario constant while
   replacing or disabling one suspect input, event, runtime feature, or scheduling
   mechanism; rerun all affected invariants.
7. **Repair upstream and regenerate**. Correct the scenario, evidence ledger,
   placement, event graph, profile, or scheduler model that owns the defect, then
   regenerate every dependent table, chart, and conclusion.
8. **Verify closure**. Reproduce the original symptom or its absence, reconcile the new
   estimate with independent anchors, and record residual error and confidence.

If the task does not map cleanly to these steps, use the native planning tool to build
a step-by-step diagnosis from the symptom, candidate layers, failure signatures,
available tools, and authorization boundaries, then execute the plan.

## Discrepancy Record

Create this record before investigating:

| Field | Required content |
| --- | --- |
| Symptom | OOM, underuse, TTFT, TPOT, E2E, throughput, goodput, scaling, offload, MTP/speculation, or other |
| Expected | Value/range, source artifact, scenario ID, evidence class |
| Observed | Raw value/range, sample count, run IDs/logs, environment fingerprint |
| Difference | Absolute, relative, and direction; no rounded headline-only comparison |
| Scope | Per request, user, replica, rank, stage, node, or deployment |
| Reproduction | Exact command/config when available, warmup, synchronization, load duration |
| First bad point | Revision, scale, load, sequence length, node boundary, or policy switch |
| Impact | Decision, SLO, capacity, cost, or correctness at risk |

## Diagnostic Ladder

Stop at the first layer that explains the discrepancy and then test it directly. Do not
fit downstream factors while an upstream invariant is broken.

### 1. Identity and measurement

- Confirm the exact model/checkpoint and runtime/kernel build actually loaded.
- Confirm prompt, output, active sequences, prefix-cache state, and request completion.
- Check asynchronous timing, missing device synchronization, warmup, graph capture,
  compilation, clock state, and mixed cold/steady samples.
- Recalculate the metric from raw timestamps or counters using the declared start/end
  events and numerator.

### 2. Units, scope, and lineage

- Reconcile bits versus bytes, decimal versus binary capacity, one-way versus aggregate
  bandwidth, and FMA conventions.
- Reconcile per-rank versus aggregate and requested versus accepted/emitted tokens.
- Trace the plotted or reported value to the current generated data, not a stale table,
  cached profile, or hand-edited workbook cell.

### 3. Model state and placement

- Reinspect tensor-level dtype, quantization exclusions, scales/zeros, tied/shared
  weights, KV geometry, sliding/recurrent state, expert placement, and duplicate runtime
  copies.
- Compare logical bytes, allocator allocated/reserved bytes, driver/device usage, and
  peak liveness. These are different boundaries and need not match directly.
- Check per-rank imbalance, cache blocks, fragmentation, workspace cliffs, and admission
  rounding when OOM appears near a capacity edge.

### 4. Work and critical path

- Reconcile operator/event counts by phase and sequence position.
- Look for missing conversions, logits/sampling, draft/verify work, cache management,
  host transfers, collectives, launch gaps, and CPU orchestration.
- Replace unjustified overlap with causal sequencing and account for background work on
  shared service resources.

### 5. Topology and contention

- Verify rank-to-device/node placement and the actual collective path.
- Distinguish link wire rate from payload throughput and unidirectional from aggregate
  figures.
- Check shared NIC, PCIe switch, DMA engine, CPU/NUMA memory, HBM, and pipeline-stage
  contention. A link may be idle while a different shared resource is saturated.

### 6. Serving and admission

- Distinguish offered load, admitted requests, active sequences, completed requests,
  and emitted tokens.
- Check dynamic batching, chunked prefill, preemption, prefix-cache policy, priority,
  timeouts, and rejected/SLO-missed work.
- Examine the entire load curve. A single utilization percentage does not identify the
  request count or queueing regime.

### 7. Calibration and model coverage

- Verify the calibration used the same phase, kernel family, dtype, tensor shape,
  sequence/load regime, topology, clocks, and contention conditions.
- Inspect simulator profile coverage, interpolation region, fallback operators,
  clamping, and extrapolation.
- Preserve the analytical bound. A fitted factor that violates it diagnoses the model
  or measurement, not super-physical hardware.

## Hypothesis Discipline

For each candidate cause, record:

- the observation it explains,
- the observation it fails to explain,
- one test whose outcome differs between the leading hypotheses,
- the expected direction and approximate magnitude,
- the tool and authorization needed,
- the acceptance/rejection result.

Prefer a small controlled run or metadata inspection over a broad profiler capture.
Collect a heavier trace only when a cheaper test cannot distinguish the hypotheses.

## Output Contract

Return or write a diagnostic report containing:

1. discrepancy record and frozen observed/expected scenario diff,
2. hypotheses ranked by current evidence,
3. checks performed with raw evidence locations,
4. root cause or narrowest unresolved layer with confidence,
5. upstream correction and all regenerated dependents,
6. before/after invariant and result comparison,
7. residual mismatch, operational limitation, and next discriminating test.

If the cause remains unresolved, do not provide a blended guess. State which hypotheses
remain live, what evidence would separate them, and why the current environment cannot
collect it.

## Guardrails

- DO NOT tune an efficiency factor before checking scenario identity, units, ownership, and event coverage.
- DO NOT run invasive, high-volume, privileged, or production-impacting profiling without applicable authorization.
- DO NOT change multiple model, runtime, topology, or scheduler variables in one diagnostic experiment.
- DO NOT treat allocator, driver, and logical-state memory readings as the same boundary.
- DO NOT repair a derived chart or table without correcting and regenerating its upstream source.
- DO NOT declare closure when the repaired model explains one headline but breaks physical or conservation checks.
