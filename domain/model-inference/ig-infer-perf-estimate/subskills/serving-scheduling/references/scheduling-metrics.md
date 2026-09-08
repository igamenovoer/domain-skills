# Scheduling and Serving Metrics

## Purpose

Use this reference to translate upstream physical and phase estimates into transparent
serving metrics. It contains definitions and modeling rules, not hardware constants or
project-specific runtime behavior.

## 1. Freeze the Metric Contract

Define every clock and denominator before calculating.

| Metric | Required definition |
| --- | --- |
| TTFT | request admission or arrival timestamp through first user-visible output token |
| ITL | distribution of intervals between consecutive user-visible output tokens |
| TPOT | for more than one output token, time after first token divided by remaining output tokens; otherwise undefined |
| completion latency | arrival or admission through final accepted output |
| request throughput | completed, accepted, or admitted requests divided by the named interval |
| output-token throughput | accepted output tokens divided by the named interval |
| total-token throughput | named prompt plus output tokens divided by the named interval |
| per-user output rate | output tokens for one request divided by that request's named active or end-to-end interval |
| goodput | work satisfying all named acceptance and SLO rules divided by the observation interval |

State whether the clock begins at client arrival, gateway arrival, engine admission, or
device dispatch. State whether rejected, cancelled, cached, speculative, draft, hidden,
and partial outputs enter the numerator or denominator.

## 2. Required Upstream Primitives

Serving calculations consume, rather than recreate:

- physical memory admission and KV block capacity per replica, stage, rank, and tier
- prefill service time or work/rate curves by uncached tokens and scheduled shape
- decode step service curves by active sequences, context bucket, and tokens advanced
- communication and transfer events with overlap constraints
- fixed per-request, per-batch, and per-step costs
- calibrated ranges when available, plus the original analytical lower bounds

If only a point service time is available, restrict the workload domain to that sampled
shape or widen the result. Do not silently interpolate over sequence length, batch
composition, or topology.

## 3. Causal Request Timeline

Represent each request with explicit events:

1. arrival and queue entry
2. admission and optional prefix lookup
3. one or more prefill chunks
4. first target-token production
5. repeated decode, draft, verification, or recurrent steps
6. optional preemption, KV eviction, reload, or recomputation
7. final output processing and completion

Device service and scheduler delay are different quantities. For request r:

TTFT_r = queue_r + admission_r + prefix_r + prefill_r + first_step_r + visible_overhead_r

Completion_r = TTFT_r + sum(inter_token_intervals_r) + finalization_r

Only omit a term when the scenario explicitly places it outside the requested clock.

## 4. Scheduler Granularity

Model decisions at the runtime's actual granularity:

- Static batching fixes membership for a batch and often exposes padding or
  longest-sequence effects.
- Continuous batching changes membership at iteration boundaries; step cost depends on
  active sequence count and context distribution, not only maximum batch size.
- Chunked prefill competes with decode for scheduled tokens and device service. Record
  chunk size, priority, and any decode budget.
- Priority and fairness policies can improve one class while worsening another. Keep
  per-class results and starvation rules.
- Preemption can swap, evict, or recompute state. Each mode has different memory,
  transfer, and service consequences.
- A configured maximum is not usable capacity unless physical memory and stable service
  also permit it.

When implementation details are unavailable, model at least two explicit policies that
bound plausible behavior and label the policy uncertainty.

## 5. Capacity and Stability

Keep three capacity concepts separate:

1. Memory-admissible capacity: requests or token blocks that physically fit after all
   reserves and fragmentation assumptions.
2. Scheduler capacity: configured sequences, batch tokens, blocks, priority pools, and
   admission limits.
3. Service-stable capacity: offered load below the long-run completion capacity of the
   limiting resource and policy.

The feasible capacity is bounded by the minimum of all applicable limits, but those
limits need not share one unit. Convert them through an explicit workload mix.

Little's Law, L = lambda times W, is a consistency check for a stable, consistently
defined observation window. It is not a tail-latency predictor and does not prove that a
system near saturation is stable.

For a simple single-class approximation, utilization may be written as offered work
divided by effective service capacity. If utilization approaches one, queueing becomes
highly sensitive to variability and approximation error. Do not extrapolate a smooth
finite p99 through or beyond the stability boundary.

## 6. Offline Throughput

For a closed or saturated workload:

- separate warmup, steady measurement, and drain
- define whether the interval includes prompt preprocessing and finalization
- report requests, prompt tokens, accepted output tokens, and total tokens separately
- reconstruct per-request timelines when latency is also requested
- sweep scheduled shape rather than assuming maximum batch is optimal

Offline throughput is not an online SLO result. It is useful as an upper envelope for a
specific workload mix and scheduler policy.

## 7. Online Queueing and Simulation

Use a closed-form queue approximation only when its assumptions are named and plausible.
Otherwise use a discrete-event or trace-replay model whose event policy is auditable.

Minimum online scenario fields:

- arrival timestamps or a declared stochastic process
- request-class proportions
- prompt, cached-prefix, and output distributions with correlations when material
- cancellation, timeout, rejection, and retry behavior
- policy for batching, chunking, priority, preemption, and KV management
- warmup and observation windows
- random seed and independent replication count for stochastic simulation

Validate the simulator using deterministic small traces that can be hand-calculated.
Report effective completed samples at each requested percentile. A percentile from too
few tail observations is an unstable sample statistic, not a dependable SLO estimate.

## 8. Prefix Caching

For each request class, record:

- cache lookup cost
- hit probability and distribution of matched tokens
- cache capacity, placement, sharing, and eviction policy
- invalidation or model-revision boundary
- saved prefill work and any remaining attention or state materialization

Apply caching to the specific events it removes. A hit does not automatically remove
decode, selection, transfer, or scheduler work.

## 9. Speculative Decoding and MTP

Model target-visible progress and internal work separately:

- draft or auxiliary-model steps
- proposal count
- verification work
- accepted-token distribution
- rejection and rollback behavior
- target KV and auxiliary-state updates
- scheduler interaction and batch-shape changes

Effective visible tokens per target iteration comes from the acceptance distribution,
not from the maximum proposal length. Preserve a baseline path so speedup can be
reconciled as saved target steps minus added draft and verification work.

## 10. Offload and Shared Resources

Overlapped transfer still consumes a finite shared service resource. Enforce capacity
for PCIe, interconnect, host memory, storage, copy engines, and decompression or
conversion paths. When several requests overlap, aggregate issued bytes and service
time over the same interval rather than treating each request's hidden transfer as free.

## 11. Output Ranges

Produce at least:

- a physical or service lower bound
- a central case only when its priors or calibration are explicit
- a conservative case that varies the dominant uncertain inputs together when they
  are correlated

Report sensitivity to arrival burstiness, prompt/output mix, active sequences, cache
hit rate, speculation acceptance, service rates, and scheduler limits as applicable.
Do not call scenario percentiles or sensitivity bands confidence intervals.

## 12. Validation Checklist

- Latency components are non-negative and use one clock boundary.
- TTFT is not greater than completion latency for completed requests.
- Percentiles are ordered and based on enough completed samples.
- Completed plus rejected plus cancelled plus timed-out requests reconcile with arrivals,
  allowing explicitly in-flight requests at the boundary.
- Visible output tokens reconcile with accepted target progress.
- Goodput never exceeds the correspondingly defined raw throughput.
- Stable online completions do not exceed modeled limiting-resource service capacity.
- Memory-admitted active state does not exceed the physical worker limit.
- Aggregate and per-user token metrics are not compared without a shared denominator.
- Cached, speculative, preempted, and offloaded work has one event owner.

Hand the resulting artifacts to validation-reporting before publication.
