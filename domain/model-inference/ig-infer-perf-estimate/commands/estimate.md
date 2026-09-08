# Full Inference Performance Estimate

## Overview

Produce an evidence-labeled estimate of inference memory, phase latency, throughput,
capacity, and SLO feasibility. The result must be a causal model of the requested
deployment, not a single efficiency factor multiplied by a hardware peak.

Keep three products separate throughout the work:

- a physical or analytical bound,
- a calibrated prediction, when transferable measurements exist,
- an observed measurement, when the target system was actually measured.

## When to Use

- Use when the user needs a complete estimate rather than one isolated memory or
  roofline calculation.
- Use when model state, operator work, topology, serving policy, and workload shape can
  all materially affect the answer.
- Use for prospective capacity planning, deployment feasibility, budget comparison,
  or an estimate that will be reviewed by another engineer.
- Do not use when the available evidence supports only a quick feasibility bound; use
  `quick-bound` instead.
- Do not use to diagnose an already surprising result without reconstructing it; use
  `audit-estimate` or `troubleshoot` instead.

## Workflow

1. **Freeze the scenario**. Load `references/scenario-contract.md`, resolve every
   required field for the requested metric, and assign an immutable scenario ID.
2. **Normalize units and evidence**. Load
   `references/units-metrics-evidence.md`; create the input and evidence ledgers before
   calculating.
3. **Account for model state and admission**. Load
   `subskills/model-memory/SKILL-MAIN.md`; derive logical state, physical placement,
   peak live memory, and feasible concurrency by rank and stage.
4. **Build phase service curves**. Load
   `subskills/latency-roofline/SKILL-MAIN.md`; model prefill, decode, and any encoder,
   verify, recurrent, conversion, or offload work as owned causal events.
5. **Add topology costs when applicable**. For more than one device, process, stage,
   replica, or host, load `subskills/distributed-topology/SKILL-MAIN.md` and map every
   collective or transfer to its actual path and contention domain.
6. **Translate service into serving behavior**. Load
   `subskills/serving-scheduling/SKILL-MAIN.md`; apply the declared batching,
   admission, queueing, prefix-cache, preemption, and load policy to produce the
   requested latency, throughput, goodput, and SLO metrics.
7. **Calibrate only from transferable measurements**. When a suitable host or trace is
   available, load `subskills/empirical-calibration/SKILL-MAIN.md`; otherwise preserve
   the analytical range and label unmeasured factors as priors.
8. **Validate independently**. Load
   `subskills/validation-reporting/SKILL-MAIN.md`; run dimensional, ownership,
   placement, conservation, monotonicity, coverage, and sensitivity checks.
9. **Write one reproducible result set**. Generate the machine-readable artifacts and
   human report from the same normalized data, preserving bounds beside calibrated
   centers and listing unresolved limitations.

If the task does not map cleanly to these steps, use the native planning tool to build
a step-by-step plan from the scenario contract, subskill handoffs, evidence rules, and
requested outputs, then execute the plan.

## Required Handoffs

Do not let one stage silently redefine another stage's inputs. Use these handoff
contracts:

| Producer | Required handoff | Consumer |
| --- | --- | --- |
| Scenario freeze | Exact revisions, dimensions, token/load distributions, topology, runtime and scheduler settings, metric definitions | Every stage |
| Model-memory | State-component ledger, physical placement, peak-live curve, admission ceiling, uncertainty | Latency, topology, serving, validation |
| Latency-roofline | Owned events, FLOPs/bytes/messages, dependency edges, resource roofs, phase service ranges | Topology, serving, validation |
| Distributed-topology | Rank/stage mapping, collective algorithms, path bandwidth/latency, contention and pipeline limits | Serving, validation |
| Serving-scheduling | Request/token service curves, queueing policy, occupancy/load curve, SLO acceptance | Calibration, validation |
| Empirical-calibration | Raw samples, environment fingerprint, synchronization method, fitted factors and transfer limits | Validation/reporting |

If a required handoff field is unknown, preserve it as an explicit interval or report it
as a blocker. Never encode an unknown as zero.

## Calculation Discipline

### Work by phase and event

At minimum, distinguish model load/warmup, prefill, steady decode, and request teardown.
Add encoder, draft, verify, recurrent-state update, cache migration, quantize/dequantize,
host offload, and collective events when the scenario contains them. For every event,
record:

- the owner and execution count,
- the causal predecessors,
- FLOPs, bytes at each memory level, and communication bytes,
- the rank, device, stage, stream, and shared resource used,
- the lower-bound service time and calibrated service range,
- whether it lies on the request critical path or consumes background capacity.

Sum events that are causally sequential. Use `max` only for events that can actually
overlap and still verify that their shared compute, HBM, DMA, PCIe, memory-controller,
or network service demand does not exceed capacity.

### Preserve scenario-dependent denominators

Calculate each requested result with its own declared denominator. Examples include
output tokens per second per replica, aggregate output tokens per second across
replicas, requests per second at a fixed prompt/output distribution, and per-user
tokens per second at a declared active-user count. Do not derive one from another until
the identity and all conditions are stated.

### Separate feasibility from performance

Memory admission proves only that state can be placed under the declared reserve and
fragmentation policy. It does not prove that a latency percentile or throughput target
is achievable. Conversely, a fast service curve is not deployable if peak live memory,
host memory, addressability, or communication buffers violate placement constraints.

## Output Contract

For a durable full estimate, write the following applicable artifacts beneath the
resolved output directory:

| Artifact | Required content |
| --- | --- |
| `scenario.json` | Frozen scenario, metric definitions, case ID, creation time, and all varied fields |
| `evidence.json` | One record per input with value/range, unit, scope, evidence class, source, revision, and freshness |
| `state-ledger.csv` | One row per logical persistent or peak-live state component, including formula and lifetime |
| `placement.csv` | Physical owner, sharding/replication rule, rank/stage/node, copies, and bytes |
| `operator-coverage.csv` | Event owner, phase, execution count, FLOPs, bytes, messages, and coverage status |
| `event-trace.csv` | Dependency-safe critical-path and background events with resource service time |
| `hardware-calibration.json` | Raw measurements, environment fingerprint, fitting method, factors, and transfer domain, when calibration exists |
| `estimate.json` | Bounds, calibrated ranges, sensitivities, metric definitions, and scenario linkage |
| `validation.json` | Invariant results, coverage totals, warnings, unresolved unknowns, and severity |
| `report.md` | Decision-focused conclusions, assumptions, ranges, bottlenecks, SLO envelope, sensitivities, and limitations |

Generate tables and charts from `estimate.json` or another declared machine-readable
source in the same result set. For a narrow estimate, return the requested metrics and
include the minimum scenario fields, equations, evidence records, and checks needed to
reproduce them.

## Completion Criteria

A full estimate is complete only when:

- the scenario and each metric denominator are frozen,
- every persistent-state component and modeled event has exactly one owner,
- logical state reconciles with physical placement and peak live memory,
- the critical path contains all required sequential work,
- shared-resource overlap and topology constraints are enforced,
- serving results respect admission and limiting-stage capacity,
- bounds remain visible beside calibration,
- high-sensitivity unknowns are surfaced rather than hidden in a center value,
- the report and machine-readable outputs agree.

## Guardrails

- DO NOT continue to a precise result when a missing high-sensitivity input cannot be bounded.
- DO NOT mix model revisions, runtime revisions, workload distributions, or scheduler policies inside one scenario.
- DO NOT treat successful memory admission as proof of latency or throughput feasibility.
- DO NOT reuse one global efficiency factor across prefill, decode, communication, conversion, and offload.
- DO NOT hide a physical lower bound after calibration or relabel a calibrated prediction as measured.
- DO NOT publish a report whose numbers cannot be regenerated from its machine-readable artifacts.
