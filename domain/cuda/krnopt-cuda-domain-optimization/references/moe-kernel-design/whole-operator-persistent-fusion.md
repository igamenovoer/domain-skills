# Whole-Operator Persistent Fusion

Use this when the operator is bespoke and launch, dispatch, compute, and
combine boundaries dominate enough to justify one persistent kernel.

## Sources

- Paper: "FlashMoE: Fast Distributed MoE in a Single Kernel"
- KB paths:
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/flashdmoe-paper.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/flashmoe-source-code.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/summaries/sonicmoe-kernel-design.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/concepts/moe-fusion-beyond-baseline.md`
  - `kbs/cuda-kernel-optimization-kb/wiki/concepts/moe-kernel-design-compendium.md`

## Method Card

- Target case: a bespoke MoE operator has dominant launch, dispatch, compute, and combine boundaries and simpler staged fusion has already been exhausted.
- Rationale: FlashMoE shows a persistent task-queue model where dispatch, GEMM tasks, and combine progress through readiness signals and counters instead of bulk-synchronous kernel boundaries.
- Applicable regime: highly tuned single-GPU experiments borrowing scheduler ideas, or distributed MoE where communication and compute must overlap at tile granularity.
- Pros: maximum opportunity to overlap dispatch, compute, combine, and communication; handles irregular expert timing through queueing when the scheduler is robust.
- Cons / guardrails: hardest option to debug; deadlock/starvation risk is real; scheduler state can dominate small problems; keep a staged baseline for differential tests.
- Primary anchors: FlashMoE paper/source for task queues and persistent-kernel scaffolding, SonicMoE for IO-aware algorithmic fusion context.

## Pattern

- Keep dispatch, compute, and combine inside one persistent kernel.
- Use tile queues or per-expert task queues.
- Use readiness flags, counters, or stage state between producer and consumer
  roles.
- Dedicate a small scheduler role, often one warp or CTA.
- Let compute CTAs pull ready tiles instead of relying on global barriers.
- For distributed MoE, use device-initiated communication or completion
  signals when available.

## Pros

- Eliminates launch boundaries.
- Can overlap dispatch, compute, combine, and communication at tile granularity.
- Handles irregular expert timing naturally when the queue design is robust.
- Provides a clean conceptual model for persistent single-GPU MoE even when
  communication is absent.

## Cons

- Much harder to debug and validate than a staged multi-kernel pipeline.
- Scheduler state can dominate small problems.
- Deadlock and starvation are real risks.
- Often overfits one model geometry, expert count, dtype, and routing regime.
- Hard to preserve a simple fallback path if all boundaries disappear at once.

## Implementation Notes

- Start with a staged graph: dispatch tasks, GEMM tasks, combine tasks, and
  completion semantics.
- Define ownership of every buffer and every token contribution before coding.
- Keep a multi-kernel baseline for differential testing and for bisecting
  scheduler bugs.
