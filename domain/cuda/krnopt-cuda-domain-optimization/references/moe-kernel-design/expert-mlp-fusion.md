# Expert MLP Fusion

Use this when GEMM1, activation, and GEMM2 boundaries write too much
intermediate data or launch too many kernels.

## Sources

- Paper: "FusedXpert: GPU Kernel for Fine-Grained Mixture of Experts"
- Related paper: "Axe: A Simple Unified Layout Abstraction for Machine Learning
  Compilers"
- KB paths:
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/fusedxpert-paper.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/axe-layout-paper.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/hpc-ops-fused-moe-design.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/sonicmoe-kernel-design.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/concepts/glu-activation-fusion.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/concepts/moe-fusion-beyond-baseline.md`

## Method Card

- Target case: GEMM1, `SiLU(gate) * up`, re-quantization, and GEMM2 boundaries write too much intermediate data or launch too many kernels.
- Rationale: Hopper FP8 MoE pipelines expose activation/multiply/quantization as a boundary between two grouped GEMMs; SonicMoE motivates reducing activation IO for fine-grained MoE.
- Applicable regime: FP8 forward paths, large intermediate dimensions, fine-grained experts, or staged pipelines where activation traffic is visible after GEMM optimization.
- Pros: removes or shortens `[routed_tokens, intermediate_dim]` intermediates, can prepare GEMM2 input scale/layout earlier, and targets SwiGLU-specific MoE cost.
- Cons / guardrails: raises register, shared-memory, and scheduler pressure; full GEMM1 -> activation -> GEMM2 fusion needs explicit tile dependencies and a fallback split.
- Primary anchors: HPC-Ops for the staged FP8 forward pipeline, SonicMoE for IO-aware MoE fusion, and FusedXpert/Axe for fusion and tile-pipelining lineage.

## Pattern

- Compute gate and up projections together or in adjacent tiled phases.
- Keep gate/up tiles in registers, shared memory, or architecture-specific
  accumulator storage when feasible.
- Apply `SiLU(gate) * up` before global writeback.
- Optionally re-quantize activation output in the epilogue before GEMM2.
- For deeper fusion, start GEMM2 tiles after their dependent GEMM1/activation
  tiles complete instead of waiting for the whole intermediate tensor.

## Pros

- Removes large `[routed_tokens, intermediate_dim]` intermediate buffers.
- Directly targets SwiGLU MoE layers.
- Gains grow with sequence length and intermediate dimension.
- Tile-level GEMM1-to-GEMM2 pipelining can reduce full-layer materialization
  even when a one-kernel full MLP is too large.

## Cons

- Raises register, shared-memory, and scheduler pressure.
- FusedXpert leaves scale-and-accumulate unfused because sparse output
  reduction is difficult.
- Full GEMM1 -> activation -> GEMM2 fusion needs a clear tile dependency
  schedule and fallback split point.
- More sensitive to dtype, scale layout, and architecture than dispatch-only
  techniques.

## Implementation Notes

- First estimate intermediate traffic saved versus occupancy lost.
- Keep a fallback split after GEMM1+activation if GEMM2 fusion spills or lowers
  tensor-core utilization.
- For top-k combine, separate "scale output" from "reduce multiple expert
  contributions to one token" in the design.
