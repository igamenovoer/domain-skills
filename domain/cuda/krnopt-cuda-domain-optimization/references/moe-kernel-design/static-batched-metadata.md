# Static-Batched Metadata

Use this when explicit token reordering is expensive but a fully dynamic
device-side grouped-GEMM scheduler is too heavy.

## Sources

- Paper: "Static Batching of Irregular Workloads on GPUs: Framework and
  Application to Efficient MoE Model Inference"
- Implementation reference: DashInfer source provenance
- KB paths:
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/static-batching-irregular-workloads-moe.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/concepts/static-batching.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/concepts/hopper-optimization-guides/moe-grouped-gemm.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/concepts/moe-fusion-beyond-baseline.md`

## Method Card

- Target case: H20/H800/H100 MoE inference where explicit token copies are expensive but a fully dynamic persistent queue or whole-operator fusion is too much.
- Rationale: static batching represents irregular expert work as compact virtual-CTA metadata and per-expert row-index arrays, then gathers A rows by index inside the WGMMA expert GEMM.
- Applicable regime: device-known per-expert M, irregular local expert loads, and paths where dispatch/unpermute traffic is more important than pure GEMM tile shape.
- Pros: avoids duplicate contiguous token buffers, keeps Hopper WGMMA grouped GEMM viable, and gives predictable metadata instead of an all-dynamic queue.
- Cons / guardrails: row-index loads may reduce coalescing; metadata and prefix decoding can become the bottleneck; worst-case skew and empty experts need dedicated tests.
- Primary anchors: Static Batching / DashInfer source digest for H20/H800 mechanics and Hopper MoE Grouped GEMM for the broader grouped-GEMM context.

## Pattern

- Store compact per-expert row-index arrays.
- Store virtual CTA or tile-to-task metadata for expert tile ownership.
- Decode `blockIdx -> (expert, tile)` using compact prefix metadata.
- Load A rows through row indices instead of copying full token tensors.
- Keep expert weights in grouped or static-batched layouts.
- Bucket tile shapes or paths by expert load when useful.

## Pros

- Reduces dispatch/unpermute traffic without requiring a full fused operator.
- Keeps WGMMA grouped expert GEMMs viable on Hopper-style paths.
- Avoids duplicate token copies while preserving explicit task metadata.
- More predictable than an all-dynamic queue for some irregular workloads.

## Cons

- Row-index loads may be less coalesced than contiguous expert batches.
- Metadata must stay cache-friendly; large metadata can become the bottleneck.
- Virtual CTA barriers, readiness flags, or prefix decoding add correctness
  burden.
- Less flexible than a fully dynamic persistent queue under extreme skew.

## Implementation Notes

- Use this when per-expert M is known on device and dispatch copies dominate.
- Keep metadata formats small enough to fit hot paths in cache.
- Validate empty experts and very small experts; static metadata often breaks
  first on edge buckets.
