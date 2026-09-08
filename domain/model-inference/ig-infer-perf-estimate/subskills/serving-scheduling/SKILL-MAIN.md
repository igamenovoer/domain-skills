---
name: serving-scheduling
description: Use when an inference estimate must turn phase service curves and memory admission into request latency, offline throughput, online queueing, goodput, concurrency, or SLO feasibility under batching, caching, speculation, preemption, or scheduler policy. Do not use to derive model memory or operator-level compute and communication costs.
metadata:
  skill_invocation_notation: >
    Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
    SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
    accepted only as legacy input when SKILL-MAIN.md is absent.
    Skill and subskill entrypoints use bare object paths: X invokes skill X and
    X->Y->Z invokes subskill Z. Subcommands use parenthesized components:
    X->cmd() invokes a direct subcommand, X->Y->cmd() invokes a subcommand of
    subskill Y, and X->parent()->child() invokes child subcommand child exposed
    by parent subcommand parent. Intermediate subcommands act as object generators.
    Forms such as X() and X->Y() are invalid for skill or subskill entrypoints.
---

# Serving and Scheduling Estimation

## Overview

Convert physical admission limits and phase-level service curves into workload-facing
metrics without confusing device service, scheduler delay, queueing delay, or user
experience. Treat scheduler policy and arrival shape as first-class model inputs.

## Workflow

1. Select the narrowest operation from **Subcommands** and load
   references/scheduling-metrics.md.
2. Freeze the metric denominator, latency clock boundaries, workload distribution,
   arrival model, scheduler policy, cache policy, and SLO acceptance rules.
3. Verify the upstream handoff: memory admission by physical worker and service curves
   for prefill, decode, communication, transfer, and fixed overhead.
4. Build the serving model at the scheduler's actual decision granularity, separating
   admission, queue, prefill, decode, preemption, eviction, and completion events.
5. Calculate single-request, offline, or online results as requested; use simulation
   only when the policy cannot be represented by a transparent closed-form bound.
6. Check capacity, conservation, percentile ordering, throughput identities, warmup,
   and observation-window sufficiency.
7. Return ranges, sensitivities, unsupported scheduler semantics, and the exact inputs
   required by validation-reporting.

If the task does not map cleanly to these steps, use the native planning tool to build
a step-by-step plan from the subcommands, scheduling model, evidence rules, and user
request, then execute the plan.

## When to Use

- Use when estimating TTFT, TPOT or inter-token latency, request completion latency,
  offline throughput, online throughput, per-user rate, goodput, concurrency, or an
  SLO-qualified operating envelope.
- Use when continuous or static batching, chunked prefill, priority, preemption,
  prefix caching, KV eviction, speculative decoding, MTP, offload, or admission
  policy changes the workload-facing result.
- Use when a latency or throughput estimate is surprising even though the underlying
  phase service times look plausible.
- Do not use to derive tensor residency, FLOP or byte counts, collective algorithms,
  or empirical efficiency factors; consume those artifacts from the owning subskill.
- Do not use queueing approximations as a replacement for measured production arrival
  and service distributions when a production SLO decision requires them.

## Invocation Contract

- Invoke this subskill as ig-infer-perf-estimate->serving-scheduling.
- Invoke a command as
  ig-infer-perf-estimate->serving-scheduling-><subcommand>().
- With no command, summarize the required handoff and select the narrowest command.

## Subcommands

| Subcommand | Use For |
| --- | --- |
| single-request | Estimate TTFT, token cadence, and completion latency without queueing |
| offline-throughput | Estimate saturated batch throughput and latency-throughput tradeoffs |
| online-slo | Estimate queueing, percentiles, goodput, rejection, and SLO envelopes |
| capacity-envelope | Find feasible concurrency and load ranges under memory and service limits |
| audit-scheduling | Reconstruct a scheduler-sensitive claim and find denominator or policy errors |
| help | Explain the serving inputs, commands, and supported output metrics |

All analytic commands use references/scheduling-metrics.md. A command may calculate
missing upstream primitives only when their formulas and evidence are already present;
otherwise it must return a named predecessor requirement rather than inventing them.

## Required Handoff

Record these inputs or mark them unknown:

- exact model, runtime, hardware, topology, and parallelism scenario identifiers
- physical sequence and KV-block admission by replica or pipeline
- prefill service curves indexed by uncached tokens and scheduled chunk or batch shape
- decode service curves indexed by active sequences, context buckets, and tokens stepped
- communication, host-transfer, fixed launch, scheduler, and detokenization overheads
- request distributions for prompt, cached-prefix, output, priority, and arrival time
- scheduler rules for batching, chunking, preemption, fairness, eviction, and rejection
- explicit definitions for every latency, throughput, goodput, and SLO metric

Use ranges when a non-critical field is uncertain. Refuse a precise online tail claim
when arrivals, scheduling semantics, or observation volume are materially unknown.

## Output Contract

Return a namespaced serving result suitable for estimate.json with:

- scenario and policy identifiers
- metric definition and denominator
- memory-admissible, scheduler-configured, and service-stable capacities
- TTFT, TPOT or ITL, completion latency, and their requested percentiles
- output-token throughput, request throughput, per-user rate, and goodput as applicable
- queue, prefill, decode, transfer, and fixed-overhead decomposition
- rejection, timeout, preemption, eviction, and cache-hit statistics when modeled
- low, central, and high cases with dominant sensitivity drivers
- model type: identity, bound, trace replay, queue approximation, or discrete-event
- unsupported semantics and evidence class for every calibrated input

Keep service-time bounds distinct from queueing predictions and measured observations.

## Troubleshooting Guide

- Throughput is high but user latency is implausibly low
  - If aggregate output rate was reused as each user's token rate, then reconstruct
    request timelines and calculate per-user cadence separately.
- Tail latency is smooth or nearly identical to the mean
  - If the model used only average arrivals or average service, then add distributions,
    batching boundaries, head-of-line blocking, and a sufficiently long observation.
- More concurrency reduces both queueing and service time without a mechanism
  - If batching gains were applied without saturation or contention, then cap the gain
    with measured service curves and shared-resource capacity.
- Prefix caching or speculation gives impossible speedup
  - If saved target work was counted without lookup, draft, verification, rejection,
    or cache-maintenance cost, then restore those events and use hit or acceptance
    distributions rather than a constant multiplier.
- The model admits requests that the runtime rejects
  - If physical KV capacity was used as scheduler capacity, then also apply configured
    sequence, block-reserve, preemption, and fragmentation limits.
- Offline and online results disagree by orders of magnitude
  - If they use different token denominators, prompt amortization, warmup, or completion
    windows, then normalize definitions before comparing scheduler effects.

## Guardrails

- DO NOT derive tail-latency SLOs from average service time or memory admission alone.
- DO NOT treat aggregate tokens per second as every user's tokens per second.
- DO NOT claim cached or speculative tokens are free when lookup, draft, verification, rejection, or maintenance work exists.
- DO NOT allow a simulator to invent unsupported scheduler semantics or missing service curves.
- DO NOT report a stable online operating point when offered load reaches or exceeds modeled service capacity.
- DO NOT combine results that use different arrival, token, completion-window, or rejection denominators.

## Resource Ownership

This subskill owns serving metric definitions, scheduler-event composition, queue and
goodput reasoning, workload-facing capacity, and scheduler-sensitive audits. Model
state, operator work, communication costs, empirical factors, and final publication
remain owned by their sibling subskills.
