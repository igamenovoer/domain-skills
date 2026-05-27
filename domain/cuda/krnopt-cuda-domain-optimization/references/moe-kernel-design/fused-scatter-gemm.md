# Fused Scatter-GEMM

Use this when explicit token permutation, unpermutation, or dispatch/combine
buffers dominate memory traffic.

## Sources

- Paper: "Scattered Mixture-of-Experts Implementation"
- Related paper: "FusedXpert: GPU Kernel for Fine-Grained Mixture of Experts"
- KB paths:
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/scattermoe-paper.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/scattermoe-source-code.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/fusedxpert-paper.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/concepts/fused-scatter-gemm.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/concepts/moe-implementation-kernel-techniques.md`

## Method Card

- Target case: explicit token permutation, unpermutation, dispatch buffers, or combine buffers dominate memory traffic.
- Rationale: ScatterMoE avoids padding and excessive copies by gathering token rows through indices during GEMM tile load and scattering during tile store, padding only cheap index arrays.
- Applicable regime: dispatch-heavy single-GPU inference/training, many experts with irregular token order, or custom GEMM paths that can absorb indirection.
- Pros: removes one or more HBM round trips, keeps the input tensor in canonical order, and composes with grouped GEMM or activation fusion.
- Cons / guardrails: indexed loads can hurt coalescing and complicate TMA; fixed tile M can still waste skewed tiny groups; top-k combine and output ownership remain separate design problems.
- Primary anchors: ScatterMoE paper/source for tile-load/store indirection and FusedXpert for deeper expert-MLP fusion variants.

## Pattern

- Keep input tokens in original HBM order.
- Sort or group route indices cheaply.
- Gather token rows through indices during GEMM tile load.
- Scatter rows through indices during GEMM tile store.
- Pad index arrays rather than full activation matrices.
- Support mode combinations such as scattered-to-grouped,
  grouped-to-scattered, scattered-to-scattered, and grouped-to-grouped when the
  operator needs them.

## Pros

- Eliminates large dispatch/unpermute buffers and one or more HBM round trips.
- Keeps token data in one canonical order.
- Composes with grouped GEMM, activation fusion, and padding-free residual
  handling.
- Particularly attractive when padding an integer index array is much cheaper
  than padding dense token activations.

## Cons

- Indexed loads can reduce coalescing and complicate TMA use.
- Fixed `BLOCK_M` still wastes work for very small or highly skewed expert
  groups.
- Top-k combine is not automatically solved; output ownership and reduction
  semantics must be designed.
- Harder to debug than explicit dispatch buffers because correctness is tied to
  tile-load and tile-store indexing.

## Implementation Notes

- Prefer this before a standalone sparse-dispatch rewrite if GEMM is already
  custom.
- Keep route metadata cache-friendly; irregular indices can erase the traffic
  win.
- For top-k > 1, define whether the GEMM2 store writes partial expert outputs
  or performs token-local accumulation.
