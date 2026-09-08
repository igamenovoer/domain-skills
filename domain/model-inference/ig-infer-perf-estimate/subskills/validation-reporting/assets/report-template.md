# Inference Performance Estimate: <title>

Status: <validated | validated-with-caveats | bounded-but-under-specified | contradicted | unreproducible | blocked>

Validation depth: <shape-only | arithmetic | model | empirical | audit>

Source revision: <scenario and artifact revision>

## Decision

<State the decision the estimate supports in two or three sentences. Say whether the
result is feasibility, an analytical lower bound, a calibrated prediction, an
observation, or a comparison. Include the most important limitation.>

## Metric and Scope Contract

| Field | Definition |
| --- | --- |
| Question | <decision question> |
| Metric | <exact metric and unit> |
| Clock boundary | <start event through end event> |
| Numerator and denominator | <tokens, requests, devices, interval, acceptance rules> |
| Scope | <per rank, stage, replica, node, cluster, request, or user> |
| Workload | <prompt, cached-prefix, output, context, batch, concurrency, arrivals> |
| Acceptance or SLO | <latency, quality, rejection, timeout, or goodput rules> |

## Scenario Fingerprint

| Dimension | Value | Evidence |
| --- | --- | --- |
| Model and tokenizer revision | <value> | <evidence ID> |
| Runtime and kernel revision | <value> | <evidence ID> |
| Weight, KV, and compute formats | <value> | <evidence ID> |
| Hardware and count | <value> | <evidence ID> |
| Topology and placement | <value> | <evidence ID> |
| Parallelism and replicas | <value> | <evidence ID> |
| Scheduler, cache, offload, speculation | <value> | <evidence ID> |
| Calibration fingerprint | <value or none> | <evidence ID or not-applicable> |

## Result

| Metric | Low | Central | High | Unit and scope | Evidence class |
| --- | ---: | ---: | ---: | --- | --- |
| <headline metric> | <value> | <value or not-supported> | <value> | <unit and scope> | <class> |

<Explain the limiting resource, scenario boundaries, and whether the central value is
calibrated. Do not repeat table values without interpretation.>

## Memory and Admission

| Component | Logical | Physical peak | Unit and scope | Placement or owner |
| --- | ---: | ---: | --- | --- |
| Weights and metadata | <value> | <value> | <unit> | <owner> |
| KV or recurrent state | <value> | <value> | <unit> | <owner> |
| Activations and workspace | <value> | <value> | <unit> | <owner> |
| Runtime, graph, communication, reserve | <value> | <value> | <unit> | <owner> |
| Headroom | <value> | <value> | <unit> | <limiting worker> |

Admission result: <memory-admissible capacity and limiting worker>

## Latency and Critical Path

| Phase or event | Low | Central | High | Unit | Evidence or formula |
| --- | ---: | ---: | ---: | --- | --- |
| Queue and admission | <value> | <value> | <value> | <unit> | <ID> |
| Prefill | <value> | <value> | <value> | <unit> | <ID> |
| First target step | <value> | <value> | <value> | <unit> | <ID> |
| Decode or recurrent steps | <value> | <value> | <value> | <unit> | <ID> |
| Communication and transfer | <value> | <value> | <value> | <unit> | <ID> |
| Finalization | <value> | <value> | <value> | <unit> | <ID> |

Overlap statement: <which events overlap, dependency reason, and shared-resource check>

## Throughput, Queueing, and SLO

| Metric | Low | Central | High | Definition |
| --- | ---: | ---: | ---: | --- |
| Request throughput | <value> | <value> | <value> | <definition> |
| Output-token throughput | <value> | <value> | <value> | <definition> |
| Per-user output rate | <value> | <value> | <value> | <definition> |
| Goodput | <value> | <value> | <value> | <acceptance rule> |
| Stable concurrency or load | <value> | <value> | <value> | <definition> |

Scheduler model: <identity, bound, trace replay, queue approximation, or simulation>

## Distributed and Topology Effects

| Item | Value or range | Scope | Evidence |
| --- | --- | --- | --- |
| Limiting stage or path | <value> | <scope> | <ID> |
| Collective or transfer contribution | <value> | <scope> | <ID> |
| Pipeline bubble or imbalance | <value> | <scope> | <ID> |
| Contention and overlap | <value> | <scope> | <ID> |

## Calibration

Analytical floor: <value and formula>

Calibration grade: <exact | in-domain | proxy | incompatible | none>

Measured terms: <named terms>

Uncalibrated terms: <named terms>

Holdout residual: <summary>

## Uncertainty and Sensitivity

| Rank | Input or assumption | Variation | Output effect | Decision impact |
| ---: | --- | --- | --- | --- |
| 1 | <driver> | <range or scenario> | <effect> | <impact> |

<State which ranges are measurement variability, fitted uncertainty, scenario
sensitivity, transfer uncertainty, or structural model error.>

## Validation

| Check | Status | Severity | Finding | Repair owner |
| --- | --- | --- | --- | --- |
| <check ID> | <status> | <severity> | <finding> | <owner> |

Validation verdict: <verdict and concise reason>

## Audit

<Include only for an audited external claim. Record the original claim, reconstructed
method, independent result, material deltas, difference taxonomy, and verdict.>

## Visualization Contract

<Include only when plots or an interactive report are produced. Generate every view
from the same validated dataset. Compare alternatives at common absolute user counts;
case-relative percentages of separate OOM ceilings are a second capacity view, not an
apples-to-apples throughput comparison. Keep no-MTP and MTP cases on separate plots
when scale compression would hide the base case. For whole-layer cache residency, plot
the exact implementable layer ratio and label interpolated intermediate requests.
Define every abbreviation such as `mb`, and format paired output-rate tooltips as
`<aggregate>/<per-user> tok/s`. Validate JavaScript parsing, data/label alignment, and
KaTeX rendering before publication.>

## Limitations and Next Evidence

- <Unsupported behavior or missing input>
- <Boundary outside the modeled or calibrated domain>
- <Highest-value measurement or source needed next>

## Reproduction

| Artifact | Path or identifier | Revision or checksum |
| --- | --- | --- |
| Scenario | <scenario.json> | <revision> |
| Evidence ledger | <evidence.json> | <revision> |
| State and placement ledgers | <paths or not-applicable> | <revision> |
| Calibration | <hardware-calibration.json or not-applicable> | <revision> |
| Estimate | <estimate.json> | <revision> |
| Validation | <validation.json> | <revision> |

Command or procedure: <exact reproducible invocation without credentials>
