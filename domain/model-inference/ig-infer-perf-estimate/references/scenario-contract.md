# Scenario Contract

An estimate is meaningful only for a frozen combination of model, workload, hardware,
topology, runtime, scheduler, cache policy, and metric semantics. Use this contract as
the single source of truth for every command and subskill. Do not let individual stages
silently fill or reinterpret fields.

## Use This Reference

1. Copy the applicable fields into `scenario.json` or an equivalent in-memory record.
2. Resolve every field required by the requested metric from user input, inspected
   metadata, or a cited source.
3. Record unknowns explicitly and decide whether to bound, measure, or block on them.
4. Freeze the record, derive a scenario ID, and create a new variant rather than editing
   it when a material input changes.

## Scenario Identity

Record:

- `scenario_id`: a stable, human-readable slug plus a content hash or revision.
- `created_at`: timestamp and timezone.
- `purpose`: the decision this estimate informs.
- `estimate_mode`: full estimate, quick bound, audit, comparison, or troubleshooting.
- `target_metrics`: names and exact definitions, including aggregation and scope.
- `acceptance`: threshold, direction, percentile, evaluation window, and rejection rule.
- `project_revision`: source or artifact revision when project files are inputs.
- `parent_scenario_id`: required for a derived comparison or repaired scenario.
- `changed_fields`: exact material differences from the parent.

The scenario ID must identify the content, not only a friendly experiment name. A
changed model revision, workload distribution, topology, scheduler policy, cache state,
or metric definition creates a new scenario.

## Model and Checkpoint

### Required identity

- model family and exact checkpoint/config revision,
- architecture implementation and trust-remote-code/custom-code revision when used,
- tokenizer revision and special-token behavior when token counts depend on it,
- runtime-loaded model identifier rather than only the requested identifier,
- parameter source: inspected tensors, official metadata, runtime declaration, or
  derived formula.

### Required geometry

Record all applicable dimensions rather than assuming a dense decoder-only transformer:

- layer count; hidden/intermediate sizes; vocabulary; embedding tying;
- attention heads, KV heads, query groups, head dimension, rotary fraction;
- MLA or latent-attention dimensions and absorbed/non-absorbed implementation choice;
- local/sliding/global attention pattern and window length by layer;
- recurrent, convolutional, or state-space state dimensions and update cadence;
- encoder/decoder and cross-attention dimensions;
- MoE expert count, routed/shared experts, top-k, capacity or padding policy, expert
  placement, and routing balance assumption;
- draft/target/MTP head count, verification width, and acceptance semantics;
- logits/sampling scope, vocabulary partition, and output-head behavior.

### Precision and representation

Record precision per state or operator class:

- checkpoint storage dtype,
- resident weight dtype and packing,
- scale, zero-point, codebook, group, block, and alignment overhead,
- tensors excluded from quantization,
- compute input, accumulation, and output dtypes,
- KV/cache or recurrent-state dtype and metadata,
- activation and communication dtype,
- conversion/dequantization site and whether converted buffers persist,
- sparse encoding metadata and whether hardware peak assumes structured sparsity.

A checkpoint label such as `FP8`, `INT4`, or `AWQ` is not a complete representation
contract.

## Workload

### Request shape

Record a distribution or explicit cases for:

- input/prompt tokens after actual tokenization,
- generated/accepted output tokens,
- encoder input length or modality dimensions,
- active context length during decode,
- stop reason and maximum output length,
- batch sequences and batch tokens,
- beam count, samples per prompt, or parallel candidates,
- structured-output, logits, or log-probability requirements.

Use quantiles, histograms, or weighted cases when the workload is heterogeneous. A mean
sequence length generally cannot reproduce attention cost, KV memory, or tail latency.

### Arrival and duration

Record:

- closed-loop users or open-loop arrival process,
- request rate and units,
- concurrency cap and admission limit,
- burst distribution or trace,
- run duration and measurement window,
- warmup and cool-down exclusion,
- retry, cancellation, timeout, rejection, and failure treatment.

### Reuse and cache state

Record:

- cold, warm, or mixed model/runtime state,
- prefix-cache hit rate and reused-token distribution,
- cache lookup/materialization cost,
- session reuse and KV retention policy,
- cache eviction and block-allocation policy,
- speculative or MTP draft/acceptance distribution,
- offload residency and migration state at request arrival.

## Hardware and Physical Topology

### Accelerator inventory

For each distinct device class, record:

- exact SKU and count,
- usable memory capacity and configured reserve,
- applicable dense/sparse compute peaks by dtype and operation class,
- HBM bandwidth and source,
- cache capacities when the model uses them explicitly,
- clock/power mode, partitioning/MIG state, and co-tenancy,
- driver, firmware, and relevant library versions for measured scenarios.

### Host and offload tiers

Record CPU model/count, NUMA placement, host DRAM capacity/bandwidth, pinned/pageable
memory policy, storage path when used, and every DMA path between tiers. Include shared
PCIe switches, root complexes, copy engines, and host-memory contention where relevant.

### Fabric

Record link type, generation, count, direction, topology graph, payload-rate evidence,
latency, collective implementation, NIC/GPU affinity, rail mapping, and competing
traffic. Keep wire signaling rate distinct from usable payload rate.

## Parallelism and Placement

Record independently:

- tensor parallel degree and sharded dimensions,
- pipeline stages, layer assignment, virtual stages, and microbatch policy,
- data-parallel replicas and whether weights/cache are duplicated,
- expert parallel degree, expert placement, routing exchange, and imbalance,
- context/sequence parallel or decode-context parallel degree,
- draft/target or disaggregated prefill/decode placement,
- rank-to-device, rank-to-node, stage-to-rank, and replica-to-rank maps,
- process and thread placement, CPU/NUMA affinity, and shared service processes.

For every state component and event, one placement rule must say whether it is sharded,
replicated, stage-owned, expert-owned, request-owned, shared, or transient. Never infer
placement from the total device count.

## Runtime and Kernel Contract

Record:

- framework, inference engine, backend, and exact revisions,
- selected kernel/algorithm families where known,
- eager, compiled, graph-captured, or mixed execution,
- attention, GEMM, MoE, collective, sampling, and cache implementations,
- shape buckets, padding/alignment, graph or workspace pools, and fallbacks,
- allocator and memory pool policy,
- CPU orchestration, tokenizer, detokenizer, and sampling placement,
- environment variables and launch options that change performance semantics.

If the runtime selects kernels dynamically, record the selection domain or measured
shape cases. Do not pretend one profile applies across a kernel-family switch.

## Scheduler, Admission, and Cache Policy

Record:

- maximum sequences, batch tokens, and model length,
- continuous/static batching and iteration cadence,
- prefill/decode mixing and chunked-prefill limits,
- queue discipline, priority, fairness, and preemption,
- admission rule and reserved memory margin,
- KV block/page size, allocation granularity, and eviction,
- prefix caching, deduplication, and reuse accounting,
- replica routing and load balancing,
- timeout, cancellation, rejection, retry, and failure behavior,
- disaggregated stage handoff and backpressure,
- speculative/MTP scheduling, draft width, verification, and acceptance policy.

A serving estimate without these fields is at most a service-capacity bound.

## Metric Contract

Define each requested metric by events and scope. Recommended defaults are below, but
the scenario must preserve the user's or system's actual contract.

| Metric | Start | End/numerator | Required scope |
| --- | --- | --- | --- |
| TTFT | Request accepted by the measured boundary | First output token available at that same boundary | Queue included/excluded, cache state, percentile aggregation |
| Prefill service time | Prefill work becomes runnable | Request becomes decode-ready | Input-token distribution, chunking and batch context |
| TPOT / inter-token latency | One accepted token event | Next accepted token event | First-token exclusion, per-request versus globally pooled intervals |
| End-to-end latency | Request accepted | Completion under the declared stop rule | Queue, tokenize/detokenize, streaming, cancellation treatment |
| Output throughput | Measurement-window start | Accepted emitted output tokens / elapsed wall time | Replica/deployment scope and failed work treatment |
| Request throughput | Measurement-window start | Completed accepted requests / elapsed wall time | Prompt/output distribution and completion rule |
| Per-user throughput | Same window | Accepted output tokens attributed to users / active-user exposure time | Active-user definition and weighting |
| Goodput | Same window | Accepted work meeting every declared SLO / elapsed wall time | SLO set, rejected/failed/timed-out work treatment |
| Memory | Declared lifecycle point | Logical, allocated, reserved, or device-reported bytes | Per rank/stage/node/deployment and peak interval |

Do not use the labels `latency`, `throughput`, `memory`, or `load` without the fields in
the rightmost column.

## Calibration and Measurement Contract

For measured or calibrated values, record:

- environment fingerprint and scenario ID,
- raw samples or immutable trace location,
- warmup, synchronization, timing boundary, and sample/window count,
- clock/power state and co-tenancy,
- profilers or instrumentation and estimated perturbation,
- fitted quantity and fitting method,
- residual error and validation split,
- exact transfer domain: phases, shapes, dtypes, kernel families, devices, topology,
  scheduler, and load region where the factor is accepted.

Calibration outside that domain becomes proxy evidence and must widen uncertainty.

## Unknowns and Ranges

Represent an unknown as a typed record, not a guessed number:

- field and unit,
- why it is unknown,
- feasible interval or discrete alternatives when available,
- impact direction and sensitivity,
- evidence needed to resolve it,
- whether it blocks the decision.

Use separate variants when discrete assumptions change algorithms or placement. Use an
interval only when the model remains valid continuously across the range.

## Freeze and Change Rules

- Write `scenario.json` before derived result artifacts.
- Store derived values outside the input fields or label them explicitly as derived.
- Hash or otherwise version the normalized scenario content.
- Link every output artifact to the scenario ID and generator revision.
- When a material input changes, copy the scenario to a new ID and list changed fields.
- When an audit repairs a scenario, preserve the original and link the repaired child.
- When comparing scenarios, keep a common base plus explicit per-variant overrides.

## Minimum Field Sets

### Memory fit only

Model/checkpoint geometry and representation, physical placement, device/host capacity,
runtime copies/workspaces, workload state geometry, allocator/admission policy, and the
memory metric boundary.

### Single-request latency bound

Memory-fit fields plus phase work/bytes, exact prompt/output cases, compute/memory/link
roofs, causal events, topology, and whether queueing or cold start is included.

### Offline throughput

Latency-bound fields plus batch policy, steady-state stage service, concurrency,
replicas, run window, warmup, and accepted-token/request numerator.

### Online latency or goodput

Offline fields plus arrival process/trace, burstiness, scheduler/admission, queueing,
timeouts/rejections, workload distributions, and percentile/SLO aggregation.

If a required minimum field cannot be resolved or bounded, narrow the claim instead of
silently upgrading an incomplete scenario.
