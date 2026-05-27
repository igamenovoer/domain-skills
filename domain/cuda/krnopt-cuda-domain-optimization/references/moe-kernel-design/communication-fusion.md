# Communication Fusion

Use this when experts are sharded across GPUs and expert-parallel communication
dominates dispatch, compute, or combine.

## Sources

- Papers:
  - "NCCL EP: Towards a Unified Expert Parallel Communication API for NCCL"
  - "Flux: Fast Software-based Communication Overlap on GPUs through Kernel
    Fusion"
  - "COMET: Fine-grained Computation-Communication Overlapping for
    Mixture-of-Experts"
  - "Harnessing Inter-GPU Shared Memory for Seamless MoE
    Communication-Computation Fusion"
- KB paths:
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/nccl-ep-paper.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/flux-paper.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/flux-source-code.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/comet-paper.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/ccfuser-paper.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/concepts/expert-parallelism.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/concepts/moe-fusion-beyond-baseline.md`

## Method Card

- Target case: experts are sharded across GPUs and expert-parallel communication dominates local dispatch, compute, or combine.
- Rationale: Flux/COMET, NCCL EP, and related systems attack all-to-all/all-gather/reduce-scatter boundaries by fusing communication with scatter, grouped GEMM, gather, or reduce stages.
- Applicable regime: distributed expert-parallel inference/training; for single-GPU local experts, use only the readiness and producer/consumer scheduling ideas.
- Pros: reduces idle time behind collective barriers and can overlap communication with expert compute at sub-layer granularity.
- Cons / guardrails: topology, framework integration, completion semantics, and payload size decide the outcome; importing distributed complexity into a single-GPU kernel is usually a mistake.
- Primary anchors: Expert Parallelism concept for scope, Flux/COMET source for fused AG/scatter/GEMM and GEMM/gather/RS splits, and NCCL EP for library-mode selection.

## Pattern

- Replace bulk-synchronous all-to-all boundaries with staged dispatch/combine
  primitives or fused communication+GEMM kernels.
- Use low-latency modes for decode-sized payloads and high-throughput modes for
  prefill/training payloads when the library supports both.
- Fuse all-gather with scatter/grouped-GEMM prologues or GEMM/reduce-scatter
  with epilogues.
- Use readiness signals, remote writes, or one-sided shared-memory/RDMA
  semantics when the platform exposes them.
- Overlap communication and computation at tile, token, or sub-token
  granularity depending on synchronization overhead.

## Pros

- Attacks the dominant cost in expert-parallel distributed MoE.
- Can reduce idle GPU time caused by slow peers and collective barriers.
- Provides queueing and producer/consumer patterns that transfer to
  single-GPU persistent kernels.
- Library-style APIs such as NCCL EP can hide topology details while preserving
  stream-based async execution.

## Cons

- Mostly irrelevant for a single-GPU local-expert kernel except as scheduling
  inspiration.
- Communication progress, memory ordering, and completion semantics are harder
  than local HBM scheduling.
- Small payload decode and large payload prefill usually need different
  algorithms.
- End-to-end gains depend heavily on topology, framework integration, and
  routing distribution.

## Implementation Notes

- Do not import distributed complexity into a single-GPU kernel unless the same
  queueing or readiness pattern removes a local boundary.
- For multi-GPU work, choose the communication mode from measured token count
  regime, not just from peak bandwidth claims.
- Keep explicit completion and lifetime rules for any remote or shared-memory
  buffer.
