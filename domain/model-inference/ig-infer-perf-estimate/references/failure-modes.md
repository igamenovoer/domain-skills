# Failure Modes and Diagnostic Signatures

Use this reference when an estimate, measurement, simulator result, or comparison is
surprising. Start with failures that can invalidate the whole scenario, then descend to
local calibration. Do not explain a discrepancy by choosing a new efficiency factor
until identity, units, ownership, placement, and event coverage pass.

## Diagnostic Order

1. Reproduce the discrepancy from raw inputs and outputs.
2. Compare the expected and observed frozen scenarios field by field.
3. Check units, scope, numerator/denominator, and artifact lineage.
4. Reconcile logical state with physical placement and peak liveness.
5. Reconcile modeled work/events with the causal path and background capacity.
6. Check hardware mode, topology, shared-resource contention, and stage balance.
7. Check scheduler, admission, queueing, cache, and request lifecycle semantics.
8. Check calibration transfer and simulator coverage.
9. Change one assumption or measurement boundary and rerun the affected invariants.

## Symptom-to-Cause Matrix

| Symptom | Frequent wrong assumptions | Discriminating checks | Repair |
| --- | --- | --- | --- |
| OOM despite predicted fit | Aggregate bytes divided across all GPUs; replicated state omitted; allocator reserve, cache block rounding, workspace, graph pools, or liveness peak omitted; imbalanced pipeline/expert placement | Compare per-rank logical/placed/allocated/reserved/device-reported memory; sweep one admission unit; capture peak by phase | Correct component ownership and rank placement, model peak liveness and admission granularity, then regenerate capacity |
| Much less memory used than predicted | Double-counted tied weights/cache; logical maximum mistaken for admitted state; quantized storage or lazy allocation ignored; non-overlapping workspace summed | Inspect exact loaded tensors and allocator timeline; compare state ledger to placement copies and lifetimes | Remove duplicate owners, use actual representation and liveness, preserve maximum-policy limit separately |
| TTFT too optimistic | Queue, chunk boundaries, CPU/tokenization, cache lookup, communication, first decode/sampling, cold compile or transfer omitted; sequential events combined with `max` | Recalculate timing boundaries; inspect a short timeline; compare cold, warm, cached, and uncached requests | Add missing events to the causal path and report boundary-specific TTFT |
| TTFT too pessimistic | Full prompt work charged despite prefix reuse; padded worst case applied to every request; events summed that overlap safely; wrong kernel family/rate | Verify processed-token count and cache hit; inspect event dependencies and selected kernels | Use actual executed work distribution and prove overlap/resource service before applying it |
| TPOT too optimistic | Decode treated as prefill GEMM; KV read geometry wrong for GQA/MQA/MLA/windowing; sampling/collective/conversion omitted; context growth ignored | Measure TPOT versus active context and sequences; inspect KV layout and decode event trace | Derive per-step bytes/work from exact architecture and include all sequential output events |
| TPOT too pessimistic | Full historical KV charged when sliding/recurrent state limits access; cache reuse or fused kernels ignored; aggregate HBM traffic double-counted | Inspect implementation branch and memory counters over context length | Correct accessed-state geometry and event ownership, then recalibrate only within the selected kernel domain |
| Throughput exceeds physical roof | Drafted/verified tokens used as emitted tokens; replicas multiplied despite a shared bottleneck; measurement window/warmup wrong; per-device rate reported as aggregate | Recompute raw emitted tokens/wall time; check shared CPU/NIC/stage resources and scope labels | Correct numerator, time window, and limiting-resource aggregation |
| Throughput far below roof with low GPU utilization | CPU orchestration, launch gaps, queue starvation, small batches, pipeline bubbles, synchronization, sampling, or network bottleneck; offered load too low | Timeline CPU/GPU gaps; inspect scheduler batches and offered/admitted counts; stage/link utilization | Model the missing service resource or identify the load region; do not reduce GPU efficiency globally |
| Scaling is nearly linear when it should not be | Serial/replicated work or communication omitted; results accidentally multiplied by device count | Check per-rank event and state ledger; calculate shared/serial fraction and limiting link/stage | Add communication and replicated work; constrain aggregation by shared resources |
| Scaling collapses at a node or device-count boundary | Topology path changes; collective algorithm switch; NIC/PCIe contention; pipeline imbalance; smaller per-rank kernels enter a weak regime | Diff rank map and collective traces across the boundary; size-matched communication and operator benchmarks | Split the model into validity regions and calibrate the new path/kernel regime |
| Offload or prefetch looks free | Transfer removed from critical path and capacity; shared DMA/PCIe/DRAM service ignored; source already resident from warm state | Check dependency-safe overlap and bytes on each tier; measure concurrent transfer/compute and steady-state service demand | Retain transfer as background capacity, enforce every shared resource, and declare initial residency |
| Offload is much slower than predicted | Wire rate used as payload; pageable memory, NUMA, staging copy, small transfers, or synchronization ignored; bidirectional traffic conflated | Inspect path/NUMA/pinning and transfer sizes; run matched-direction payload benchmark | Model the full staged path and size-dependent payload rate |
| MTP/speculative speedup is implausibly high | Drafted or verified tokens counted as accepted; verification and rollback omitted; acceptance assumed independent of context/load; quality condition missing | Reconcile drafted/verified/accepted/emitted counters; inspect acceptance distribution and target work | Use accepted emitted tokens as numerator and include all draft/verify/recovery events |
| MTP/speculative path is slower unexpectedly | Low acceptance, verification width, draft overhead, scheduler fragmentation, cache copies, or target kernel change | Compare acceptance and work per accepted token; disable one component at a time | Model acceptance-conditioned work and kernel/scheduler regime separately |
| P95/P99 derived from average is wrong | Tail factor assumed; mixed workloads pooled; queueing arrival model wrong; warm/cold or cached/uncached cases mixed | Inspect raw distribution by class, arrival trace, and queue/service decomposition | Model or measure distributions by class and aggregate using declared weighting |
| Per-user throughput contradicts aggregate | Active-user denominator differs; idle/queued users excluded inconsistently; weighted and unweighted means mixed | Recompute per-user exposure and token counts from raw lifecycle records | Declare active-user rule and report individual distribution plus aggregate |
| “Load %” differs while request count looks similar | Different duration, request shape, admission, dropped work, or resource denominator; utilization and concurrency conflated | Recover offered/admitted/completed counts, tokens, duration, and named-resource busy time | Replace bare load percent with physical counts and a resource-specific utilization |
| Simulator curve has a smooth but wrong region | Profile interpolation/clamping/extrapolation; unsupported operator fallback; kernel-family or topology switch hidden | Inspect profile grid/coverage and compare boundary points with measurements or bounds | Split validity regions, surface fallback, and keep unsupported points unknown/bounded |
| Calibrated prediction beats a physical floor | Wrong work/byte count, wrong hardware roof/unit, asynchronous timing, calibration leakage or reverse fit | Recalculate independent bound; verify synchronization and fitted data separation | Repair the source model or measurement; never retain the super-physical factor |
| Estimate matches one headline but fails nearby cases | Reverse-fitted factor, overfitting, missing causal component with compensating error | Hold out shapes/load points and test monotonic/limiting cases | Fit phase/resource-specific factors from multiple points and preserve residual uncertainty |
| Charts and report disagree with JSON/CSV | Stale generated file, manual spreadsheet edit, mismatched scenario ID, rounding copied as source | Regenerate from immutable machine-readable artifact and compare hashes/IDs | Repair generator/data lineage and replace every stale dependent artifact |

## Cross-Cutting Wrong Assumptions

### One dtype for the whole model

Weights, embeddings, norms, experts, scales, activations, accumulators, KV cache,
communication, and workspaces can use different representations. Inspect tensor and
operator classes. Quantization metadata and excluded tensors can be material at small
bit widths.

### Divide by device count

Only the dimensions explicitly partitioned by TP, PP, EP, context parallelism, or
another placement rule shrink. Replicas duplicate state. Pipeline stages own different
layers. Expert/routing imbalance and shared buffers create rank-specific peaks. Always
calculate the limiting physical rank.

### Peak equals sustained

Official compute and bandwidth peaks are optimistic roofs tied to dtype, operation
shape, sparsity, clocks, and data locality. They provide a lower bound on time. Expected
performance needs measured, phase-specific sustained rates or an explicit wide prior.

### Events overlap because streams are asynchronous

Asynchrony permits overlap; it does not prove it. Dependencies, copy-engine count,
memory controllers, PCIe switches, HBM, compute engines, NICs, CPU threads, and runtime
synchronization can serialize events or make them share capacity. Enforce the event DAG
and service demand on each shared resource.

### Average case represents the workload

Attention cost, KV state, batching, admission, and queueing are nonlinear in prompt,
decode length, active sequences, and arrival bursts. Preserve distributions or weighted
cases. Validate both typical and tail regions relevant to the decision.

### A simulator owns all semantics

A simulator may compose operator profiles but omit allocator behavior, cache management,
CPU gaps, unsupported operations, topology contention, scheduler policy, queueing,
timeouts, or quality-conditioned acceptance. Build a coverage ledger and model missing
events explicitly.

## Repair Rules

- Repair the earliest defective owner: scenario, evidence, state ledger, placement,
  event graph, topology, scheduler, calibration, then presentation.
- Preserve the original scenario and evidence for auditability; create a repaired child
  scenario with an explicit diff.
- Regenerate all derived artifacts from the corrected machine-readable source.
- Re-run independent physical, conservation, coverage, and monotonicity checks.
- Verify the repair on a case that was not used to choose the correction.
- If multiple defects compensate, fix them separately and show the effect of each.

## Stopping Conditions

Stop and report an unresolved result when:

- the exact model/runtime/hardware scenario cannot be identified,
- raw measurement boundaries or output lineage cannot be reconstructed,
- a high-sensitivity input has no defensible range,
- required profiling or production access is not authorized,
- competing hypotheses cannot be distinguished with available tools,
- the corrected model still violates a physical or conservation invariant.

An unresolved diagnosis is useful when it names the narrowest uncertain layer and the
specific evidence required next. A plausible but untestable efficiency adjustment is
not a resolution.
