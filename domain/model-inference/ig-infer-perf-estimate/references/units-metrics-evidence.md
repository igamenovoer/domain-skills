# Units, Metrics, and Evidence

Use one canonical unit system and one evidence vocabulary across source inspection,
calculation, calibration, validation, and reporting. Most large estimation errors are
scope or denominator errors that survive because the final number still looks
plausible.

## Canonical Units

Store arithmetic in base units and attach display units only at presentation time.

| Quantity | Canonical storage | Display examples | Required qualifier |
| --- | --- | --- | --- |
| Time | seconds (`s`) | ms, us | service/queue/end-to-end and start/end events |
| Bytes | bytes (`B`) | GB (`10^9 B`), GiB (`2^30 B`) | logical/allocated/reserved/resident and scope |
| Bit rate | bits/s | Gbit/s | wire or payload, direction, link aggregation |
| Byte bandwidth | bytes/s | GB/s, GiB/s | memory tier or path, read/write/duplex convention |
| Compute | FLOP | GFLOP/s, TFLOP/s | operation convention, dtype, dense/sparse |
| Tokens | integer token events | input, processed, drafted, verified, accepted, emitted | tokenizer/revision and numerator type |
| Requests | integer lifecycle events | offered, admitted, completed, SLO-met | lifecycle boundary |
| Energy | joules (`J`) | Wh, kWh | device/node/deployment and included components |
| Cost | declared currency | currency/hour, currency/request, currency/Mtoken | pricing date and utilization rule |

### Mandatory conversions

- `1 byte = 8 bits`.
- `1 GB = 1,000,000,000 bytes`; `1 GiB = 1,073,741,824 bytes`.
- A value advertised in Gbit/s is not a GB/s payload rate; divide by eight and then
  account for encoding/protocol/collective overhead.
- State the FLOP convention. Unless a source defines otherwise, count one multiply-add
  as two FLOPs and keep non-FMA operations separate when material.
- Do not mix total bidirectional link rate with simultaneous usable rate in one
  direction.

Every table column and serialized numeric field must include or inherit an unambiguous
unit. Avoid labels such as `memory`, `speed`, or `load` with bare numbers.

## Scope Vocabulary

Attach a scope to every value:

- model, request, sequence, token, batch, iteration, or measurement window;
- rank, pipeline stage, device, node, replica, or deployment;
- logical state, physical resident allocation, allocator allocated, allocator reserved,
  or device-reported usage;
- instantaneous, peak, average, percentile, total, or steady-state.

An aggregate value may be divided only when the ownership and denominator make the
operation valid. For example, replicated weights do not become smaller per GPU because
the deployment has more GPUs, and aggregate token throughput is not per-user throughput
without active-user exposure.

## Token and Request Events

Keep these counters separate:

| Counter | Meaning |
| --- | --- |
| Input tokens | Tokens entering the target model after the declared cache reuse |
| Processed/prefill tokens | Tokens for which prefill work was actually executed |
| Drafted tokens | Candidate tokens proposed by a draft or MTP path |
| Verified tokens | Candidate tokens evaluated by the target verification path |
| Accepted tokens | Verified tokens retained in the final sequence |
| Emitted output tokens | Accepted output tokens delivered at the measured boundary |
| Offered requests | Requests arriving at the service boundary |
| Admitted requests | Requests allowed into executable or resident state |
| Completed requests | Requests satisfying the declared completion rule |
| SLO-met requests | Completed requests meeting every declared SLO condition |

Default output throughput uses emitted accepted output tokens. Drafted and verified
tokens describe internal work and must not inflate user-visible throughput.

## Metric Definitions and Identities

### Latency

For request `i` with acceptance time `a_i`, first-token time `f_i`, successive emitted
token times `t_i,j`, and completion time `c_i`:

```text
TTFT_i = f_i - a_i
TPOT_i,j = t_i,j - t_i,j-1        for post-first-token intervals
E2E_i = c_i - a_i
queue_i = service_start_i - a_i
```

State whether tokenization, network ingress/egress, queueing, detokenization, streaming
buffering, and cold start are inside the measured boundary. Do not derive tail
percentiles by applying a factor to a mean. Compute percentiles from the declared sample
population or a distribution-aware serving model.

### Throughput

For a wall-time window of duration `T`:

```text
output token throughput = sum(emitted accepted output tokens) / T
processed token throughput = sum(all model-processed tokens) / T
request throughput = completed requests / T
goodput = SLO-met accepted work / T
```

Define whether goodput's work unit is requests or emitted output tokens. Report offered,
admitted, completed, and SLO-met counts beside online throughput so drops and timeouts
cannot masquerade as efficiency.

For user `u`:

```text
user output rate_u = emitted output tokens attributed to u / active exposure time_u
```

`aggregate throughput / active users` equals an average per-user rate only when the
same users and exposure interval are represented and the desired aggregation is that
specific mean. It is not an individual-user guarantee.

### Load, utilization, and concurrency

Keep these distinct:

- offered load: request or token arrivals per unit time,
- concurrency: requests/sequences admitted or active at an instant,
- batch size: sequences or tokens executed together in one scheduler iteration,
- utilization: busy service demand divided by available capacity for a named resource,
- occupancy: hardware residency or scheduler population, not utilization,
- load percentage: invalid unless its numerator, denominator, resource, and window are
  explicitly defined.

The queueing identity `rho = lambda * E[S]` applies directly only to a compatible
single-service-resource model with consistent request units. Multi-stage, batched,
state-dependent inference needs a service-network or simulation model; do not use this
identity as a universal deployment utilization formula.

### Memory

Use these non-interchangeable metrics:

- logical bytes: content implied by tensor/state geometry,
- placed bytes: logical bytes after sharding, replication, padding, and copies,
- live bytes: placed allocations whose lifetimes overlap at an instant,
- allocator allocated bytes: live allocations known to the runtime allocator,
- allocator reserved bytes: memory held by its pool, including reusable slack,
- device-reported bytes: broader process/device usage, potentially including contexts
  and allocations outside the inspected allocator,
- usable capacity: physical capacity minus explicit system/runtime reserve.

Reconcile boundaries rather than expecting equality.

### Capacity and SLO margin

State the sign convention once. A useful convention is:

```text
latency margin = SLO limit - predicted latency
throughput margin = predicted goodput - required goodput
memory margin = usable bytes - predicted peak resident bytes
```

Positive margin passes. Report absolute and relative margin and the uncertainty range.

## Evidence Classes

Use exactly one primary class per numeric input or result:

| Class | Meaning | Typical use |
| --- | --- | --- |
| `measured` | Observed on the exact frozen target scenario with retained raw evidence | Direct result or target calibration |
| `runtime-declared` | Reported by the exact loaded runtime/build for the scenario | Selected kernel, allocator state, loaded dtype, rank map |
| `official-metadata` | Vendor/model-author specification tied to an exact revision | Device capacity/peak, model config, checkpoint index |
| `paper-measured` | Measurement published with enough scenario detail to assess transfer | External anchor or proxy calibration |
| `proxy-measured` | Measurement from a materially different scenario with explicit transfer argument | Wide calibration prior |
| `literature-prior` | General empirical range without target-specific verification | Sensitivity interval only |
| `derived` | Deterministic result from cited input records and an explicit formula | State bytes, work, bound, conversion |
| `assumed` | Chosen scenario value or unverified hypothesis | Conditional branch or sensitivity input |
| `unknown` | Required value unavailable and not safely bounded | Blocker or unresolved dimension |

These classes describe provenance, not truth ranking. A runtime-declared field can still
be stale or misunderstood; a measurement can still use the wrong timing boundary.

## Evidence Record

Each `evidence.json` item should contain:

- stable field or claim ID,
- value or range and canonical unit,
- scope and aggregation,
- evidence class,
- source location, command/run ID, URL, or artifact path,
- model/runtime/hardware revision and retrieval/measurement time,
- extraction method and any transformation,
- applicability and transfer limits,
- uncertainty or alternatives,
- freshness decision,
- downstream fields that consume it.

For a derived value, cite the formula version and every input record ID. For an assumed
value, state who or what selected it and how the conclusion changes across its range.

## Evidence Precedence and Conflicts

Do not silently choose whichever source supports the preferred result. When sources
conflict:

1. confirm they refer to the same field, unit, scope, revision, and operating mode,
2. prefer exact runtime inspection for selected runtime state and exact target
   measurement for target behavior,
3. prefer exact-revision official metadata for static contracts,
4. retain conflicting records and explain the adjudication,
5. widen the range or block the claim when conflict remains decision-relevant.

Marketing summaries, unsourced tables, search snippets, and remembered values are
discovery hints, not final evidence.

## Bounds, Predictions, and Confidence

Label outputs by product:

- **Physical/analytical bound**: a one-sided or interval constraint derived from work,
  bytes, capacity, and causality.
- **Calibrated prediction**: a range produced by applying transferable measured factors
  to a compatible model.
- **Measurement**: an observed distribution from the frozen target scenario.

Do not call a min/max sensitivity envelope a statistical confidence interval. Describe
how the interval was produced: parameter range, discrete scenario branches, fit residual,
bootstrap, repeated runs, or another explicit method.

Report enough significant digits for the input quality. Preserve unrounded values in
machine-readable outputs and round only at presentation. More digits do not increase
confidence.

## Independent Validation Identities

Use at least the applicable checks:

- parameter/tensor sum equals the logical-weight ledger within explained exclusions,
- logical state becomes placed state through explicit copy/shard/padding factors,
- peak-live bytes do not exceed usable capacity,
- every operator/event and state component has exactly one owner,
- total emitted tokens do not exceed accepted tokens or completed output work,
- aggregate throughput reconciles with raw counts and wall time,
- per-stage steady-state throughput does not exceed the limiting stage,
- calibrated time does not beat a valid physical floor,
- comparison deltas reproduce from their absolute scenario results.

When an identity fails, repair the source record or model and regenerate dependents;
never insert a balancing constant without an evidence record.
