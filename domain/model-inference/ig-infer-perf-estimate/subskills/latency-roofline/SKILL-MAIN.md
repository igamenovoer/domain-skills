---
name: latency-roofline
description: Use when an inference estimate needs prefill or decode work decomposition, arithmetic-intensity bounds, effective compute or bandwidth, quantization conversion, attention or cache-offload latency, overlap, prefetch, MTP, or critical-path diagnosis. Do not use for queueing-only or memory-only questions.
metadata:
  skill_invocation_notation: >
    Skill and subskill entrypoints use bare object paths. Subcommands use
    parenthesized components after the owning skill or subskill.
---

# Latency Roofline and Critical Path

## Overview

Turn model operations into explicit FLOP, byte, conversion, launch, and communication
work, then compose them according to dependencies and shared resources. A roofline is
a latency lower bound or calibrated center for one kernel; it is not automatically an
end-to-end prediction.

## Workflow

1. **Define the phase and metric.** Separate prefill, one decode round, speculative
   drafting, target verification, and queue delay. Record batch/microbatch, context,
   emitted tokens, precision, and whether the requested result is a bound or prediction.
2. **Load the method.** Read `references/roofline-critical-path.md` completely before
   applying an efficiency factor, adding dequantization, or claiming overlap.
3. **Build the operator-coverage ledger.** Give exactly one owner to projections,
   attention/indexing, experts, recurrent state, LM head, quantization conversion,
   cache selection/reconstruction/fetch, collectives, and framework overhead.
4. **Derive work and effective resource rates.** Compute FLOPs/MACs, stored and moved
   bytes, converted values, messages, and launches from source-grounded shapes. Keep
   nameplate bounds, measured rates, proxy rates, and priors separate.
5. **Evaluate per-event roofs.** Use a `max` only inside a proven fused kernel; use a
   sum for sequential kernels. Retain which resource controls every result.
6. **Construct the causal/resource graph.** Add predecessors, device/stage/node,
   execution stream, resource demand, and legal overlap. Calculate the longest causal
   path and enforce steady-state HBM, DMA, PCIe, DRAM, and network service limits.
7. **Model alternatives and uncertainty.** Evaluate fused/unfused conversion,
   resident/offloaded cache, fetch-at-decode/prefetch, balanced/skewed MoE, MTP
   acceptance, and evidence-based efficiency ranges without changing the central
   scheduler implicitly.
8. **Return a component trace.** Report phase latency, latency-bound direction,
   bottleneck, aggregate resource demand, sensitivity drivers, omitted work, and the
   calibration needed to promote the result to a prediction.

If the request does not map cleanly to this workflow, use the native planning tool to
build a step-by-step plan from this subskill, its reference, and the user's constraints,
then execute that plan.

## When to Use

- Use for TTFT compute, TPOT/inter-token latency, arithmetic intensity, model-core
  floors, attention scans, sparse selection, host-cache transfer, FP8/INT4 unpacking,
  prefetch overlap, recurrent state, or MTP verification.
- Use when a simulator needs missing per-layer or per-batch service-time profiles.
- Use when an estimate relies on an unexplained “effective bandwidth,” MFU, MBU, or
  hardware-utilization guess.
- Use to diagnose a speedup that exceeds a physical roof or disappears after adding
  an allegedly hidden event.
- Do not use alone for request arrival queues, replica assignment, HBM admission, or
  quality/accuracy validation.

## Subcommands

| Subcommand | Use For | Terminal Result |
| --- | --- | --- |
| `inventory-operators()` | Establish complete event ownership | Operator-coverage ledger |
| `roofline()` | Derive compute, memory, conversion, and launch roofs | Per-event lower bounds and calibrated centers |
| `critical-path()` | Compose dependencies and legal overlap | Event DAG, critical path, and bottleneck |
| `offload-prefetch()` | Model selection, transfer, reuse, prediction, and residency | Critical and background cache-service trace |
| `mtp()` | Model drafting, target verification, acceptance, and emitted tokens | MTP TPOT/throughput overlay and no-MTP control |
| `audit-latency()` | Diagnose an existing latency or throughput core | Reconciled work, units, roofs, and missing events |
| `help()` | Explain these routes and required inputs | Concise command summary |

Invoke them as, for example,
`ig-infer-perf-estimate->latency-roofline->critical-path()`.

## Troubleshooting Guide

- Predicted latency is below a physical resource floor.
  - If any event violates peak compute, bandwidth, conversion, or link time, then
    correct MAC/FLOP factors, byte units, efficiency basis, and event coverage before
    applying empirical calibration.
- Prefetch produces an implausibly large speedup.
  - If background work vanished from latency, then restore false-positive traffic,
    JIT misses, selection verification, and the aggregate DMA/DRAM service constraint.
- FP8 nearly multiplies end-to-end throughput by the storage ratio.
  - If BF16 compute, reconstruction, conversion, fixed-format side state, or model-core
    work remains, then expose those terms and recompute the controlling roof.
- Full cache residency removes nearly all latency.
  - If the algorithm still performs indexing, selection, sparse attention, or recurrent
    updates, then restore those events; residency normally removes only fetch and
    reconstruction.
- A simulator curve flattens or jumps at its largest batch.
  - If lookup exceeds the sampled profile domain, then extend measured/generated rows
    through the largest MTP-expanded microbatch and reject silent clamping.

## Guardrails

- DO NOT use a marketing peak or a literature utilization prior as an unlabeled prediction center.
- DO NOT combine sequential events with `max` or overlapping events with `sum` without the dependency graph.
- DO NOT substitute GEMM MBU for sparse gather, attention, dequantization, or collective efficiency.
- DO NOT charge a quantized value conversion twice or omit it from the actual consumption site.
- DO NOT make prefetched work disappear from steady-state resource demand.
- DO NOT skip current-token selection unless an explicitly authoritative predictor supplies the exact set.
- DO NOT infer an end-to-end model latency from a simulator whose operator profiles are missing or fabricated.
- DO NOT report a latency floor as measured performance or invert it into guaranteed throughput.
