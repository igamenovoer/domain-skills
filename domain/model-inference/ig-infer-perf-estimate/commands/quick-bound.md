# Quick Inference Feasibility Bound

## Overview

Produce a transparent first-pass bound when detailed calibration, operator profiles, or
serving simulation are unavailable. A quick bound should answer whether a scenario is
clearly feasible, clearly infeasible, or unresolved; it is not permission to invent a
realistic-looking point estimate.

## When to Use

- Use for early hardware sizing, memory fit, order-of-magnitude latency or throughput,
  and deciding which measurement would be most valuable next.
- Use when only model configuration, workload shape, topology, and official hardware
  ceilings are available.
- Use when the user explicitly wants a fast, auditable calculation with wide bounds.
- Do not use to predict queueing percentiles, scheduler-specific goodput, or a narrow
  SLO envelope without measured or otherwise defensible service distributions.
- Do not use when a detailed existing result is under dispute; use `audit-estimate`.

## Workflow

1. **Define the question**. Load `references/scenario-contract.md`; freeze the target
   metric, scenario scope, exact denominators, and the minimum fields needed for it.
2. **Label all inputs**. Load `references/units-metrics-evidence.md`; normalize units,
   distinguish peak from sustained quantities, and turn unknown high-impact inputs into
   explicit intervals.
3. **Bound memory and admission**. Account for fixed state, per-request state, transient
   workspace, allocator reserve, fragmentation, replication, and per-rank placement.
4. **Bound event service**. For each required phase event, derive compute, memory, and
   communication floors and compose them using causal dependencies.
5. **Bound aggregate capacity**. Apply the limiting rank, stage, link, memory tier, and
   replica resource; keep request rate, aggregate token rate, and per-user rate on their
   declared denominators.
6. **Run cheap independent checks**. Verify dimensions, physical capacity, work and
   byte conservation, monotonicity, and at least one independent anchor.
7. **Report the decision interval**. State what is proven, what remains unresolved, the
   dominant sensitivity, and the next measurement that would shrink uncertainty most.

If the task does not map cleanly to these steps, use the native planning tool to build
a step-by-step bounding plan from the available evidence, physical ceilings, metric
definitions, and requested decision, then execute the plan.

## Bounding Rules

### Memory

For each physical rank or stage, start with:

```text
peak resident bytes
  = fixed resident state
  + admitted per-request state
  + phase-transient state at peak liveness
  + communication and runtime workspaces
  + allocator reserve and fragmentation allowance
```

Do not divide total logical bytes by the number of devices. Place each tensor, cache,
buffer, expert, stage, and replica according to its actual sharding and replication
rule. A conservative admission ceiling for identical requests is:

```text
floor((usable capacity - fixed bytes - peak shared/transient bytes)
      / peak incremental bytes per admitted request)
```

Apply it per limiting rank, then apply runtime admission granularity, cache block
rounding, and policy limits. If allocation lifetimes overlap ambiguously, publish both
the proven lower and conservative upper peak.

### Event service time

For one event with no demonstrated intra-event overlap, use a physical lower bound:

```text
event time >= max(
  event FLOPs / applicable compute rate,
  bytes at memory tier / applicable bandwidth,
  communication payload / applicable path payload rate,
  launch or fixed latency floor
)
```

Use rates for the exact dtype, operation class, sparsity contract, direction, device,
and path. Marketing peak yields an optimistic floor. A sustained-rate interval yields
a prediction interval only when its provenance and transfer scope are stated.

For a request path:

```text
critical-path time >= sum(sequential event lower bounds)
```

Replace a sum with a maximum only where dependency and resource checks prove overlap.
Background work that is not on the immediate critical path must still consume capacity
and can reduce steady-state throughput.

### Capacity and throughput

Use the bottleneck service resource, not average device utilization:

```text
replica output-token capacity <= 1 / limiting steady-state service time per output token
aggregate capacity <= sum(replica capacities constrained by shared resources)
```

For pipeline parallelism, throughput is limited by the slowest steady-state stage while
single-request latency includes all causal stages and bubbles applicable to that
request. For speculative or multi-token prediction, use accepted emitted tokens—not
drafted or verified candidates—as the default output-throughput numerator.

### Serving claims

A quick bound may prove that offered load exceeds a hard capacity ceiling or that an
SLO is impossible below a physical latency floor. It cannot establish attainable P95
or P99 latency from mean service time alone. Mark the middle region between a proven
floor and conservative ceiling as unresolved.

## Decision Classes

Classify the result without false precision:

| Class | Meaning |
| --- | --- |
| Clearly feasible under stated conservative assumptions | Even the conservative resource model satisfies the target with declared margin |
| Clearly infeasible under stated optimistic assumptions | A physical lower bound or capacity ceiling already violates the target |
| Conditionally feasible | Feasibility depends on an explicit assumption or bounded unknown |
| Unresolved | Available evidence cannot separate feasible from infeasible |

## Output Contract

Return or write a compact bound record containing:

- scenario ID and exact metric definitions,
- an input/evidence table with ranges and units,
- equations with substituted values,
- per-rank memory feasibility and margin,
- phase/event latency floors and capacity ceilings applicable to the request,
- optimistic and conservative results without an unlabeled midpoint,
- decision class and acceptance margin,
- dominant uncertainty drivers in ranked order,
- one or more measurements that would most reduce the decision interval.

When writing durable artifacts, use `scenario.json`, `evidence.json`, `estimate.json`,
`validation.json`, and `report.md`; omit full ledgers only when the compact calculation
shows all ownership and placement decisions directly.

## Guardrails

- DO NOT call a marketing peak, wire rate, or analytical floor an expected application result.
- DO NOT produce queueing percentiles from a mean service time or capacity ceiling.
- DO NOT divide aggregate state or work uniformly across devices without placement evidence.
- DO NOT use `max` to combine sequential events or to hide contention on a shared resource.
- DO NOT manufacture a center value when evidence supports only a range or one-sided bound.
