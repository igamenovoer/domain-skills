---
name: ig-infer-perf-estimate
description: Use when an agent must estimate, calibrate, compare, validate, troubleshoot, or audit LLM inference memory, latency, throughput, scaling, capacity, or SLO feasibility from model, workload, hardware, topology, and serving assumptions. Do not use for training estimates or for implementing kernel optimizations.
metadata:
  skill_invocation_notation: >
    Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
    SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
    accepted only as legacy input when SKILL-MAIN.md is absent.
    Skill and subskill entrypoints use bare object paths: `X` invokes skill X and
    `X->Y->Z` invokes subskill Z. Subcommands use parenthesized components:
    `X->cmd()` invokes a direct subcommand, `X->Y->cmd()` invokes a subcommand of
    subskill Y, and `X->parent()->child()` invokes child subcommand child exposed
    by parent subcommand parent. Intermediate subcommands act as object generators.
    Forms such as `X()` and `X->Y()` are invalid for skill or subskill entrypoints.
---

# Inference Performance Estimation

## Overview

Build inference estimates from an explicit scenario, evidence ledger, physical-state
placement, causal event model, and serving policy. Preserve analytical lower bounds,
calibrated predictions, and measurements as different products.

Violating the letter of the evidence and accounting rules is violating their spirit.

## When to Use

- Use for prospective or retrospective estimates of VRAM/RAM capacity, TTFT, TPOT or
  inter-token latency, latency percentiles, output throughput, per-user throughput,
  goodput, concurrency, and SLO envelopes.
- Use for dense, GQA/MQA, MLA, sparse, sliding-window, recurrent/linear-attention, MoE,
  quantized, speculative/MTP, cache-offloaded, or multi-node inference.
- Use when an existing number, graph, simulator output, or hardware extrapolation looks
  contradictory and needs a source-to-result audit.
- Use when only source/config metadata or a partially available test host exists; the
  workflow can return bounded estimates instead of pretending a benchmark exists.
- Do not use for training performance, quality evaluation, or implementing/profiling a
  kernel whose bottleneck has not already been translated into estimation inputs.

## Workflow

1. **Select the route** from **Subcommands** or **Subskills**. If no actionable task is
   present, handle `help`.
2. **Freeze the scenario contract** before calculating. Load
   `references/scenario-contract.md` and define metric, model/runtime revision,
   workload, precision, topology, scheduler, cache policy, and acceptance/rejection
   semantics.
3. **Build the evidence ledger**. Load `references/units-metrics-evidence.md`; give every
   numeric input a unit, scope, evidence class, source/revision, range, and freshness.
4. **Execute the selected command**. Load only its page and the subskills/resources it
   calls. A full estimate normally visits model-memory, latency-roofline,
   distributed-topology, serving-scheduling, optional empirical-calibration, then
   validation-reporting.
5. **Run independent checks before reporting**. Reconcile logical versus physical
   memory, event ownership, critical-path composition, simulator coverage, admission,
   and throughput identities.
6. **Deliver ranges and limitations** using the output contract. Preserve the
   uncalibrated bound beside any calibrated center and identify the dominant sensitivity
   drivers.

If the task does not map cleanly to these steps, use the native planning tool to build
a step-by-step plan from the available commands, subskills, evidence rules, and user
request, then execute the plan.

## Invocation Contract

- Invoke `ig-infer-perf-estimate` with an actionable task to let the parent choose the
  narrowest command or subskill route.
- Invoke a parent command as `ig-infer-perf-estimate->estimate()`,
  `ig-infer-perf-estimate->quick-bound()`,
  `ig-infer-perf-estimate->audit-estimate()`,
  `ig-infer-perf-estimate->compare-scenarios()`, or
  `ig-infer-perf-estimate->troubleshoot()`.
- Invoke a targeted subskill with a bare path such as
  `ig-infer-perf-estimate->model-memory`.
- Invoke `ig-infer-perf-estimate->help()` to summarize all public routes.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `estimate` | Produce a full evidence-labeled performance and capacity estimate | `commands/estimate.md` |
| `quick-bound` | Produce transparent feasibility and roofline bounds when calibration or serving simulation is unavailable | `commands/quick-bound.md` |
| `audit-estimate` | Reconstruct and independently check an existing estimate, graph, or simulator result | `commands/audit-estimate.md` |
| `compare-scenarios` | Compare controlled deployment or algorithm alternatives on common denominators | `commands/compare-scenarios.md` |
| `troubleshoot` | Diagnose a surprising OOM, latency, throughput, scaling, offload, or MTP result | `commands/troubleshoot.md` |
| `help` | Explain this skill and list commands and subskill routes | This entrypoint |

The operational commands are peer entrypoints; the table order is not a required
lifecycle.

## Subskills

| Subskill | When to Route Here | Load |
| --- | --- | --- |
| `model-memory` | Route here when model/runtime facts, persistent-state geometry, quantization metadata, physical placement, or OOM admission is the primary unknown. | `subskills/model-memory/SKILL-MAIN.md` |
| `latency-roofline` | Route here when prefill/decode work, operator roofs, cache access, conversion, offload, overlap, or the causal critical path needs to be derived. | `subskills/latency-roofline/SKILL-MAIN.md` |
| `distributed-topology` | Route here when TP/PP/DP/EP/DCP, replicas, collectives, NUMA/PCIe/NVLink/IB paths, contention, or pipeline imbalance controls the result. | `subskills/distributed-topology/SKILL-MAIN.md` |
| `serving-scheduling` | Route here when service curves must become single-user latency, offline throughput, online queueing, goodput, concurrency, or an SLO envelope. | `subskills/serving-scheduling/SKILL-MAIN.md` |
| `empirical-calibration` | Route here when a host is available to measure sustained rates, fit phase-specific factors, or decide whether proxy data transfers to the target. | `subskills/empirical-calibration/SKILL-MAIN.md` |
| `validation-reporting` | Route here when an estimate needs invariant checks, sensitivity analysis, claim grading, reproducible artifacts, or a human-facing report. | `subskills/validation-reporting/SKILL-MAIN.md` |

Load only the selected child's `SKILL-MAIN.md` and the local resources it explicitly
requires. Full-estimate commands may load several children in their declared order.

## Output Contract

For a durable estimate, resolve `<output-dir>` in this order:

1. Use the user's explicit location.
2. Otherwise use `INFER_PERF_ESTIMATE_OUTPUT_DIR`, resolving a relative value from the
   project directory.
3. Otherwise use `<project-dir>/.inference-estimates/<scenario-id>/`.

Create only artifacts justified by the request. A full run normally produces:

```text
scenario.json              normalized inputs and metric definitions
evidence.json              provenance and assumption ledger
state-ledger.csv           logical state components
placement.csv              physical rank/stage/node ownership
operator-coverage.csv      one owner for every modeled event
hardware-calibration.json  optional measured samples and fitted rates
event-trace.csv             causal and background service work
estimate.json              machine-readable results and ranges
validation.json            invariants, warnings, and coverage
report.md                  human-readable conclusions
audit.md                   only for an audit run
```

For a narrow question, return the requested answer plus enough of the scenario,
equations, evidence labels, and limitations to reproduce it; do not force the full
bundle.

## Evidence Discipline

- Every operator and persistent-state component has exactly one owner. Missing ownership
  is an omission; duplicate ownership is double counting.
- Every reported value is labeled `measured`, `runtime-declared`, `official-metadata`,
  `paper-measured`, `proxy-measured`, `literature-prior`, `derived`, `assumed`, or
  `unknown`.
- A simulator is a composition tool, not evidence for inputs it does not contain.
- Quality preservation for quantization, sparsification, prediction, or offload is a
  separate conditional assumption unless validated on the target model and workload.

See `references/tool-map.md` before choosing simulators or profilers and
`references/failure-modes.md` when a result is surprising.

## Rationalization Table

| Rationalization | Correction |
| --- | --- |
| “A balanced efficiency guess is good enough for one headline.” | Preserve the physical bound, show a range, and label the center as a prior until calibrated. |
| “TP8 means divide everything by eight.” | Classify each tensor and event as sharded, replicated, communicated, or stage-owned. |
| “The simulator produced it, so it is grounded.” | Audit its profile inputs, unsupported operators, interpolation domain, and scheduling semantics. |
| “Prefetch is hidden, so transfer is free.” | Enforce shared DMA, PCIe, DRAM, and network service-rate constraints even when latency overlaps. |
| “The quantized checkpoint says FP8, so every byte is FP8.” | Inspect tensor-level exclusions, scales, side caches, compute dtype, and conversion site. |
| “The graph looks smooth, so the model is plausible.” | Check units, identities, monotonic properties, limiting-stage capacity, and independent anchors. |
| “One corrected output table is enough.” | Fix the source model, regenerate every derived artifact, and verify source/output consistency. |

## Red Flags

- A result has no exact model/runtime revision or scenario definition.
- A per-GPU value was obtained by dividing an aggregate value by total GPUs.
- Sequential events are combined with `max` without a causal overlap argument.
- Effective bandwidth or compute efficiency appears without measurement or provenance.
- “Load percent” is compared across cases without the corresponding request counts.
- Aggregate and per-user token rates do not share an explicit denominator.
- A simulator profile silently clamps or extrapolates beyond its sampled domain.
- A sensitivity percentile is described as a statistical confidence interval.
- Full HBM residency removes attention, selection, or recurrent work without an
  algorithmic reason.

When a red flag appears, stop publication, run `troubleshoot` or `audit-estimate`, and
repair the upstream ledger or event model before regenerating results.

## Guardrails

- DO NOT invent a missing critical input to produce a precise point estimate.
- DO NOT present marketing peaks, link rates, analytical floors, simulator rows, and
  measured application performance as interchangeable evidence.
- DO NOT apply one parallelism divisor, one dtype, or one efficiency factor to every
  tensor or operator.
- DO NOT claim overlap without a dependency-safe event graph and shared-resource
  service check.
- DO NOT infer latency SLOs from memory admission or average service time alone.
- DO NOT reverse-fit an efficiency factor solely to reproduce a desired answer.
- DO NOT publish generated tables or charts that cannot be reproduced from the same
  machine-readable dataset as the documented methodology.
- DO NOT claim accuracy or quality preservation from a performance-only model.

## Maintenance

Keep this entrypoint as a router and shared contract. Put domain formulas in their
owning subskill, cross-domain failure signatures in `references/failure-modes.md`, and
deterministic arithmetic in `scripts/infer_perf_calc.py`.
