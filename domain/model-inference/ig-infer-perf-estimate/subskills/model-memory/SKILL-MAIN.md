---
name: model-memory
description: Use when an inference estimate needs model/runtime fact extraction, KV or recurrent-state geometry, quantized storage accounting, physical cache placement, HBM or host-memory admission, or diagnosis of implausible concurrency. Do not use when only kernel latency or queueing behavior is unknown.
metadata:
  skill_invocation_notation: >
    Skill and subskill entrypoints use bare object paths. Subcommands use
    parenthesized components after the owning skill or subskill.
---

# Model and Memory Accounting

## Overview

Derive persistent and peak inference memory from the tensors the selected runtime
actually retains, then map each component onto ranks, stages, nodes, and replicas.
Keep logical per-sequence state, physical duplication, allocator capacity, and OOM
admission as distinct quantities.

## Workflow

1. **Freeze the model/runtime contract.** Record exact model, checkpoint, serving-code
   revision, maximum live context including generated tokens, weight/KV/activation
   formats, and every parallelism degree.
2. **Load the accounting method.** Read `references/memory-accounting.md` completely
   before deriving a tensor size or applying a parallelism divisor.
3. **Build the state ledger.** Inspect official configuration, checkpoint indexes,
   model code, and the intended runtime cache implementation. Enumerate every growing,
   fixed, auxiliary, transient, and shared allocation with shape, dtype, lifetime,
   source, and evidence class.
4. **Calculate logical state first.** Produce one-copy per-sequence totals before PP,
   TP, DCP, EP, DP, or replica placement. Cross-check at one hand-computable context.
5. **Apply physical ownership component by component.** Mark each ledger row replicated,
   sharded, stage-owned, shared, or communicated on every relevant rank. Route to
   `ig-infer-perf-estimate->distributed-topology` when the placement or fabric is the
   primary uncertainty.
6. **Compute peak rank memory and admission.** Include packed weights, runtime reserve,
   workspaces, fragmentation policy, static state, and per-request state. Identify the
   limiting stage/rank and verify that the next whole request fails.
7. **Return auditable artifacts.** Report logical state, per-rank state, aggregate
   physical state, host state, headroom, memory-only admission, and unresolved runtime
   alternatives separately.

If the request does not map cleanly to this workflow, use the native planning tool to
build a step-by-step plan from this subskill, its reference, and the user's constraints,
then execute that plan.

## When to Use

- Use for KV-cache, MLA latent-cache, sparse-index, sliding-window, SSM/KDA/recurrent,
  prefix-cache, quantization-metadata, weight-placement, runtime-reserve, or OOM work.
- Use when TP/PP/DCP or replicas appear to change per-user memory unexpectedly.
- Use when a model fits by checkpoint bytes but fails at serving startup or at a long
  context.
- Use when only source and metadata are available; return bounded alternatives where
  the runtime implementation is unknown.
- Do not use as the sole route for kernel execution time, interconnect latency, arrival
  queues, or quality effects. Hand those questions to the owning subskill.

## Subcommands

| Subcommand | Use For | Terminal Result |
| --- | --- | --- |
| `inventory()` | Extract cache, side-state, dtype, and checkpoint facts | Evidence-labeled tensor ledger |
| `logical-state()` | Calculate intrinsic one-copy context and fixed state | Logical bytes by component and context |
| `physical-state()` | Apply a declared rank/stage/node placement | Per-rank and aggregate physical bytes |
| `admission()` | Calculate HBM/host headroom and whole-request ceilings | Limiting rank, accepted maximum, next-request failure |
| `audit-memory()` | Diagnose an existing memory or concurrency result | Reconciled formula and discrepancy list |
| `help()` | Explain these routes and required inputs | Concise command summary |

Invoke them as, for example,
`ig-infer-perf-estimate->model-memory->logical-state()`.

## Troubleshooting Guide

- Concurrency is much higher than a hand calculation.
  - If the estimate is unexpectedly generous, then check the layer multiplier, MLA
    replication under pure TP, fixed-format indexes, recurrent state, and GB/GiB units
    before changing any reserve.
- Per-GPU memory was derived by dividing aggregate bytes by total GPUs.
  - If ownership was not proven tensor by tensor, then discard the divisor and rebuild
    the rank/stage placement ledger.
- Configuration and runtime source imply different cache shapes.
  - If the runtime may expand or transform the cache, then model each implementation as
    a separate scenario and do not average them.
- `nvidia-smi` does not rise as the sequence grows.
  - If the engine preallocates a cache pool, then compare consumed blocks and admission
    capacity rather than incremental process memory.
- Native compressed serving admits more users than an offload overlay.
  - If the byte decomposition confirms this, then report it as a legitimate result;
    an overlay can exceed a checkpoint's already compressed native representation.

## Guardrails

- DO NOT infer the live cache representation from the model family name or config alone.
- DO NOT add a K/V factor of two to an MLA latent unless the selected runtime stores two tensors.
- DO NOT divide every cache or side-state tensor by TP, PP, or world size.
- DO NOT apply one advertised quantization bit width to exclusions, scales, indexes, or recurrent state.
- DO NOT equate sparse attention's accessed-token count with its retained historical state.
- DO NOT omit output growth, allocator blocks, workspaces, fragmentation, graphs, or runtime reserve from admission.
- DO NOT treat an average weight-per-GPU value as exact stage packing without labeling the approximation.
- DO NOT call memory admission an SLO-safe concurrency limit.
