# Validation and Audit Reference

## Purpose

Use this reference to decide whether an inference estimate is structurally complete,
dimensionally sound, physically possible, causally consistent, empirically supported,
and reproducible. Validation checks the current source model; an audit also reconstructs
an existing external claim independently.

## 1. Freeze the Subject

Before checking anything, preserve:

- original claim, units, significant digits, qualifiers, chart axes, and stated scope
- scenario and evidence artifacts as received
- model/runtime/hardware revisions and timestamps
- formulas, scripts, simulator versions, commands, seeds, and raw data references
- requested decision and materiality threshold

Hash or copy immutable source artifacts when appropriate. Do not silently correct a
claim before recording what was actually asserted.

## 2. Build the Dependency Graph

Trace every reported value through:

result
  to aggregation or percentile
  to calibrated or analytical component
  to formula and event owner
  to scenario input
  to evidence record and source

Each persistent state component and modeled event must have one owner. Zero owners
means omitted work; multiple owners mean possible double counting. A presentation-only
number without a machine-readable source is a reproducibility finding.

## 3. Validation Layers

Run inexpensive gates before interpretive checks.

### Structural completeness

- required artifacts exist for the declared depth
- scenario and metric identifiers agree across artifacts
- every numeric value has a unit and scope
- every derived value names a formula or deterministic source
- evidence identifiers resolve and include class, source, revision, and range
- unknown and not-applicable are distinct from zero

### Dimensional and scope checks

- bytes, bits, seconds, tokens, requests, devices, ranks, and nodes are not mixed
- decimal and binary capacity conversions are explicit
- per-rank, per-stage, per-replica, per-node, and aggregate scopes reconcile
- one-way, bidirectional, payload, and wire bandwidth are distinguished
- prompt, output, total, accepted, draft, and cached tokens use named denominators
- latency clocks share explicit start and end events

### Arithmetic and formula checks

- recompute totals from source line items rather than formatted tables
- evaluate formula units before numeric substitution
- use enough internal precision and round only for presentation
- check independent identities rather than repeating the same code path
- apply absolute and relative tolerances suitable for the value scale

### Coverage and ownership

- logical state maps to physical ranks, stages, replicas, and memory tiers
- every operation or transfer appears exactly once on a causal or background path
- unsupported operators and simulator gaps remain explicit
- overlap claims have dependency-safe event relationships
- shared resources enforce aggregate service, even for hidden events

### Physical and causal checks

- predictions do not cross compatible compute, memory, link, or capacity ceilings
- calibrated prediction is not below its compatible analytical floor
- sequential events are summed along the critical path
- max is used only for work that can overlap in the declared model
- pipeline, scheduler, cache, speculation, and offload events respect causality

### Empirical checks

- observation and prediction use the same clock, scope, workload, and revision
- the target lies inside the calibration validity domain or has an explicit proxy grade
- residuals are reported by shape and regime, not only as one mean
- held-out observations remain independent of fitting inputs
- measurement variability and structural model error are distinguished

## 4. Domain Invariants

### Memory

- logical bytes reconcile with physical placed bytes plus named replication,
  padding, metadata, allocator, workspace, graph, and communication overhead
- peak memory uses simultaneous lifetimes rather than summing unrelated phase peaks
- usable capacity subtracts named reserves and fragmentation assumptions
- KV bytes grow monotonically with stored tokens within a fixed policy
- admission never exceeds the limiting physical worker
- the limiting worker fits exactly `Cmax` whole requests and fails at `Cmax + 1`
- PP stage components sum to the full logical model before physical replication
- a shared MLA/index history remains full-sized per pure-TP rank unless an explicit
  DCP/context-sharding mechanism and its communication are modeled
- MoE active parameters and resident parameters are not interchanged

### Latency and roofline

- phase time is non-negative
- predicted time does not beat compatible compute, traffic, communication, or fixed
  overhead floors
- prefill and decode use their own work models
- context-sensitive decode work uses the correct context definition
- conversion, selection, launch, transfer, and synchronization work is not silently
  removed by full residency
- a native/no-offload control has no overlay-only selection, reconstruction, or host
  transfer events, while a full-residency overlay has zero host bytes but retains its
  algorithmically required selection and attention
- every model layer is charged exactly once as native, overlaid, recurrent, or another
  named execution class
- end-to-end latency follows the declared causal graph

### Distributed topology

- sharded, replicated, stage-owned, and expert-owned state reconcile independently
- collective logical payload and wire traffic are not confused
- ranks follow the declared physical path and contention domain
- aggregate throughput respects the limiting stage or replica
- pipeline bubble and imbalance assumptions are visible
- overlap does not exceed both dependency and shared-resource limits

### Serving

- arrivals reconcile with completed, rejected, cancelled, timed-out, and in-flight
  requests over the same window
- TTFT does not exceed completion latency for a completed request
- percentile ordering is nondecreasing
- goodput does not exceed its correspondingly defined raw throughput
- output progress reconciles with accepted target tokens
- aggregate homogeneous-round throughput equals active admitted users times the
  correspondingly defined mean per-user throughput
- per-user token cadence does not improve merely because unrelated users were added;
  any batching benefit requires a measured or explicitly modeled service curve
- a stable online point stays below limiting service capacity
- memory, configured, and service-stable concurrency are distinct
- speculative/MTP execution is rejected for an unsupported runtime/checkpoint and
  cannot accept beyond its actual draft horizon

### Calibration

- work, time, rate, and peak definitions are compatible
- source and target fingerprints are recorded
- factors map to named formula terms
- validity and transfer domains are enforced
- raw samples, exclusions, residuals, and holdouts are retained
- a fitted factor above a nominal ceiling triggers definition review rather than silent
  clamping
- generated simulator profiles round-trip at sampled points and cover the largest
  scheduled microbatch, including MTP-expanded verification positions, without silent
  clamp or extrapolation

## 5. Metamorphic Checks

Use controlled changes to expose wrong dependencies. Expected directions apply only
while the stated regime remains fixed.

| Controlled change | Expected check |
| --- | --- |
| Increase stored tokens with fixed cache geometry | KV memory must not decrease |
| Add a replicated tensor | Per-replica resident memory must not decrease |
| Reduce an effective service rate | The directly dependent lower-bound time must not improve |
| Add a sequential event | Critical-path time must not decrease |
| Increase offered load below a fixed service policy | Queueing should not systematically improve without batching or policy effects |
| Reduce cache hit or speculation acceptance | Saved target work must not increase |
| Add a slower pipeline stage | Pipeline capacity must not improve |
| Increase a physical capacity only | Feasibility may improve, but modeled work must not vanish |

Do not impose a monotonic rule across a known algorithm switch, padding boundary,
batching gain, cache regime, placement change, or admission-policy transition. Split
the scenarios at the boundary instead.

## 6. Independent Anchors

At least one independent check should not reuse the primary derivation:

- parameter-file or tensor-metadata sum versus architecture-derived memory
- hand-computed small case versus calculator output
- physical roof versus simulator prediction
- trace totals versus per-event aggregation
- limiting-stage capacity versus aggregate pipeline output
- Little's Law consistency versus reported stable online window
- measured phase sum versus end-to-end residual

Agreement is evidence only to the independence level of the two paths.

## 7. Sensitivity Analysis

Start with parameters that are both uncertain and decision-relevant:

- sustained compute, HBM, link, copy, or storage rates
- activation, workspace, allocator, and fragmentation reserves
- context, output, concurrency, and workload mix
- cache-hit and speculation-acceptance distributions
- scheduler limits, arrival burstiness, and preemption
- communication overlap and topology contention
- calibration transfer error

Use:

- finite differences inside one smooth regime
- explicit low, central, and high scenario corners
- piecewise cases at discrete boundaries
- correlated scenarios when inputs move together

Report the input change, output change, direction, local validity range, and whether the
decision or rank ordering changes. A sensitivity percentile is not a statistical
confidence interval.

## 8. Controlled Scenario Comparison

Before taking a delta, require common:

- model and runtime revision unless the revision is the named treatment
- workload samples or distribution
- token and latency denominator
- hardware and placement unless they are the named treatment
- evidence class and calibration depth
- warmup, observation, rejection, and completion rules

Create a difference manifest containing only intended changes. Recalculate both cases
from source. Do not subtract rounded report values or compare one measured case with
one uncalibrated estimate without labeling that asymmetry.

## 9. Audit Procedure

1. Record the original claim exactly.
2. Parse value, unit, scope, clock, workload, revision, precision, topology, scheduler,
   evidence class, and uncertainty.
3. Mark absent fields unknown rather than inferring favorable defaults.
4. Reconstruct the claimed method when formulas and sources permit.
5. Build an independent scenario and rederive the result from primary line items.
6. Compare claim, reconstructed method, independent result, and relevant observation.
7. Localize differences to inputs, units, coverage, placement, causality, calibration,
   aggregation, or presentation.
8. Issue a verdict and smallest upstream repair that resolves all derived artifacts.

Do not choose hidden assumptions solely because they reproduce the claim. When several
plausible assumptions yield a range, the correct finding is under-specification.

## 10. Difference Taxonomy

| Class | Examples |
| --- | --- |
| contract | different metric, clock, token denominator, or scenario |
| unit/scope | bits versus bytes, binary versus decimal, per-rank versus aggregate |
| evidence | stale, proxy, circular, missing, or unsupported source |
| coverage | omitted or duplicate state, operator, transfer, or scheduler event |
| placement | wrong sharding, replication, stage, rank, memory tier, or topology path |
| causality | invalid overlap, missing serialization, incorrect event ordering |
| calibration | wrong factor, validity domain, fingerprint, or transfer grade |
| arithmetic | formula, aggregation, indexing, rounding, or percentile error |
| presentation | stale table, mislabeled axis, copied value, or inconsistent prose |

Assign the earliest causal class that explains downstream symptoms; do not list every
derived mismatch as a separate root cause.

## 11. Severity and Verdicts

Suggested severity:

- blocker: result cannot support the stated decision
- major: likely changes feasibility, conclusion, rank, or SLO
- moderate: changes precision or a secondary conclusion
- minor: presentation or reproducibility defect that does not alter the decision

Verdicts:

- validated
- validated-with-caveats
- bounded-but-under-specified
- contradicted
- unreproducible
- blocked

A numerically close result may still be unreproducible. A numerically different claim
may be bounded-but-under-specified when its missing inputs admit the independent range.

## 12. Tolerances

For each check, state:

- exact or approximate nature
- absolute and relative tolerance
- rounding stage
- expected measurement or simulation variability
- decision materiality

Use exact checks for identifiers, ownership counts, enum values, and deterministic
integer byte accounting where possible. Use explicit tolerances for floating arithmetic
and measurement comparisons. Never widen a tolerance after seeing a failure without
recording and justifying the change.

## 13. Validation Artifact

Each validation.json check should contain:

- check identifier and validation layer
- status: pass, fail, warning, blocked, skipped, or not-applicable
- severity
- subject artifact and field
- expected condition and tolerance
- observed value
- evidence identifiers
- explanation
- affected outputs
- repair owner and next action

The artifact summary includes validation depth, verdict, counts by status and severity,
source revision, timestamp, and tool version.

## 14. Reporting Rules

Generate report.md from the same artifacts that passed validation:

- lead with the decision and scope
- distinguish feasibility, lower bound, calibrated prediction, and observation
- show low, central, and high cases without false precision
- expose evidence quality and top sensitivity drivers
- include a compact decomposition and limiting resource
- show failed and blocked checks that affect interpretation
- state what is unsupported and what measurement would reduce uncertainty most
- provide exact reproduction artifacts and commands

Use assets/report-template.md. Omit inapplicable sections rather than filling them with
invented values. Preserve unresolved contradictions visibly.

## 15. Completion Gate

Publication is ready only when:

- the scenario and metric contract are frozen
- every headline traces to validated source data
- all blocker and major findings are resolved or prominently accepted as limitations
- comparisons use controlled deltas
- report and machine-readable artifacts share a source revision
- another agent can reproduce the result without the originating project

Otherwise return the current verdict, findings, and named repair action.
