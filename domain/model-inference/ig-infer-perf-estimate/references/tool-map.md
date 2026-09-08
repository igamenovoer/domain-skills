# Tool Map

Choose tools by the unknown they can resolve. A tool's output is evidence only for the
state it actually observes; a simulator, profiler, runtime counter, or vendor table does
not validate assumptions outside its coverage.

The skill must remain usable when optional tools are absent. Detect availability, use
the least invasive applicable method, and return a bounded estimate plus a measurement
plan when the environment cannot collect stronger evidence.

## Selection Workflow

1. Name the unresolved field or competing hypotheses.
2. Identify the cheapest tool whose observable differs between those hypotheses.
3. Check its availability, version, permission, perturbation, and output boundary.
4. Capture raw output together with the frozen scenario and environment fingerprint.
5. Convert the observation into one evidence record; do not extend it beyond the tool's
   declared coverage.
6. Re-run the relevant independent invariant after updating the estimate.

## Tool Selection Matrix

| Unknown | First choice | Escalation | What it establishes | What it does not establish |
| --- | --- | --- | --- | --- |
| Model architecture and dimensions | Exact config/source inspection with `rg` and a structured parser | Runtime introspection on the loaded model | Declared fields and implementation branches | Actual tensor dtype, selected kernel, or performance |
| Tensor inventory, shape, and storage dtype | Checkpoint index/header inspection without materializing tensors | Load metadata through the exact runtime | Stored tensor records and file sharding | Resident copies, quantization expansion, runtime workspace |
| Loaded dtype and kernel choice | Exact runtime logs/introspection | Targeted operator trace | Selected runtime state for observed shapes | Behavior for unsampled shapes or revisions |
| Logical/placed memory | Bundled deterministic calculator and placement ledger | Runtime allocator and device memory snapshots | Expected components and observed allocation boundaries | Causal latency or SLO feasibility |
| Peak liveness/OOM | Runtime allocator history or memory snapshot around phase boundaries | Allocation timeline or controlled admission sweep | Allocation size/lifetime and failure threshold | User-visible latency distribution |
| Per-event duration and ordering | Explicit application timestamps or GPU event timing | Nsight Systems or equivalent timeline | Causal ordering, gaps, overlap, CPU/GPU and transfer timing | Detailed instruction/memory bottleneck without counters |
| Kernel work/bottleneck | Source/work accounting plus operator microbenchmark | Nsight Compute or equivalent counters | Sampled kernel resource behavior | End-to-end queueing or unsampled operators |
| Device specifications | Exact-revision official product documentation | Runtime-reported SKU/capacity/clocks and measured microbenchmarks | Contractual capacity and marketing roofs | Sustained application rate |
| GPU/node topology | Runtime rank map plus `nvidia-smi topo -m` or platform inventory | Fabric/NIC/PCIe tools and collective microbenchmark | Physical paths and process placement | Concurrent application payload rate without measurement |
| Collective performance | Size-matched collective microbenchmark on the target path | Timeline/counters under application contention | Sampled collective service curve | Different algorithms, message sizes, or contention domains |
| HBM/compute sustained rate | Shape- and dtype-matched operator microbenchmark | Kernel counters on the application | Transferable phase-specific service rate when matched | Queueing, launch gaps, CPU orchestration, other phases |
| Serving load/latency distribution | Application load generator with raw request/token timestamps | Engine scheduler trace plus system timeline | Offered/admitted/completed work and observed percentiles | Counterfactual policies without a model/simulator |
| Scheduler behavior | Exact engine config and logs | Instrumented scheduler trace | Admission, batching, preemption, cache, and queue decisions | Hardware capacity not exercised by the trace |
| Simulator coverage | Inspect profile tables, source/config, supported operations, and interpolation logic | Reproduce sampled points against target measurements | Which events and domains the simulator composes | Correctness of missing inputs or extrapolated regions |

## Bundled Deterministic Arithmetic

Resolve `<skill-dir>` to this skill's folder. Use
`<skill-dir>/scripts/infer_perf_calc.py` for repeatable arithmetic that the script
actually exposes. Inspect `--help` before invocation and retain its input and output
files with the scenario.

The calculator accepts already-derived decimal-byte state inputs and SI per-second
rates. It does not convert arbitrary human-entered units or infer bytes from tensor
shapes. Normalize units and derive tensor/state geometry before populating its input.
Its supported arithmetic is:

- aggregate generic fixed and per-request state components through explicit
  component-to-device placement rows,
- calculate per-device memory budgets, limiting-device admission, replica capacity,
  and requested/admitted headroom,
- calculate compute, HBM, optional conversion, and fixed-time operator roofs using
  supplied peaks and efficiencies,
- compose operator or fixed-duration events through an acyclic dependency graph and
  return the critical path,
- enforce declared background-service demand and parallel-lane floors beside the
  foreground path,
- derive admitted per-user and aggregate emitted-output-token throughput,
- validate its built-in throughput identity, requested-user fit, nonnegative event
  durations, scenario warnings, and input/schema constraints,
- compare common numeric output fields from two independently evaluated scenarios.

The exact unit declaration is mandatory:

```json
{
  "units": {
    "bytes": "decimal",
    "rates": "per_second",
    "time": "milliseconds"
  }
}
```

`estimate` returns `bounded-by-input-assumptions`; it does not certify those assumptions.
`validate` is a calculator-level check, not the full validation-reporting workflow.
`compare` emits numeric deltas plus a normalization warning; it does not prove the two
scenario contracts are controlled. Run the applicable evidence, coverage, placement,
topology, and serving checks outside the script.

### CLI examples

Use the bundled template first as an interface smoke test. It contains synthetic values
and `placeholder-do-not-publish` evidence, so its output must never be presented as a
real estimate.

```text
python "<skill-dir>/scripts/infer_perf_calc.py" estimate "<skill-dir>/assets/scenario-template.json" --pretty
python "<skill-dir>/scripts/infer_perf_calc.py" validate "<skill-dir>/assets/scenario-template.json" --pretty
python "<skill-dir>/scripts/infer_perf_calc.py" compare "<skill-dir>/assets/scenario-template.json" "<skill-dir>/assets/scenario-template.json" --pretty
python "<skill-dir>/scripts/infer_perf_calc.py" self-test --pretty
```

Expected smoke-test behavior:

- `estimate` succeeds and warns that the template contains illustrative placeholder
  evidence.
- `validate` returns a nonzero exit status because warnings make the template invalid
  for publication; this is expected until all placeholder evidence is replaced.
- comparing the template with itself succeeds and produces zero deltas for common
  numeric fields; this checks the command path only and is not a meaningful comparison.
- `self-test` uses its internal fixture and checks limiting-device admission, replica
  capacity, DAG critical path, throughput identity, memory monotonicity, fixed-state OOM,
  and dependency-cycle rejection.

For real work, copy `assets/scenario-template.json` into the resolved output directory,
give it a specific scenario ID, replace every synthetic number, and replace the
placeholder evidence with sourced records. Then run:

```text
python "<skill-dir>/scripts/infer_perf_calc.py" estimate "<output-dir>/scenario.json" --output "<output-dir>/estimate.json" --pretty
python "<skill-dir>/scripts/infer_perf_calc.py" validate "<output-dir>/scenario.json" --output "<output-dir>/validation.calc.json" --pretty
python "<skill-dir>/scripts/infer_perf_calc.py" compare "<output-dir>/scenario-a.json" "<output-dir>/scenario-b.json" --output "<output-dir>/comparison.calc.json" --pretty
```

Treat exit status `0` as command success, `1` from `validate` as a completed validation
with a failed check or warning, and `2` as an invalid scenario, dependency-cycle error,
or self-test assertion failure. Review JSON output rather than relying on exit status
alone.

The bundled calculator is not a unit converter, tensor-shape calculator, hardware
database, model registry, profiler, full serving simulator, or evidence source for its
inputs. Feed it cited scenario values and preserve the formulas and script revision
used. If the requested calculation is not implemented, perform the transparent equation
in the report or extend the calculator only under a separate authorized
skill-maintenance task.

## Specialized Estimation and Simulation Tools

Treat these tools as layers in a pipeline, not interchangeable oracles:

| Tool | Best role | Required custom inputs | Does not supply |
| --- | --- | --- | --- |
| GenZ-LLM-Analyzer | Operator-level compute, HBM, and communication rooflines for a declared model/device mapping | Unsupported model operators and dimensions, device roofs, topology, precision, parallelism, and defensible efficiency inputs | Target kernel efficiency, framework gaps, custom offload events, cache quality, or a production scheduler |
| LLMServingSim | Compose layer or phase profiles into a serving and parallel-execution simulation | Shape-covered execution profiles, model graph and partition, hardware topology, workload trace, and scheduler policy | Trustworthy latency profiles for an unknown model, device, or operator |
| InferSim | Explore supported inference schedules when its benchmark database matches the target | Matching model, hardware, parallelism, kernel/profile data, and extensions for unsupported events | Automatic validity for a new architecture, sparse-cache algorithm, offload path, or unprofiled hardware |
| ASTRA-Sim | Detailed collective/network timing and contention when a distributed trace warrants it | Workload communication trace, system/network configuration, rank mapping, collective algorithms, and link parameters | GPU kernel time, cache placement, serving policy, or evidence that a network configuration matches the target |

GenZ and LLMServingSim can form a pipeline: use a grounded operator model or target
measurements to create shape-indexed profiles, then let the serving simulator compose
them. They can also answer different questions independently. If only profile lookup
or partitioning helpers are called, describe that exact use; do not call it a full
simulator run. Reject silent profile clamping or extrapolation, especially when MTP
multiplies the effective verification batch beyond the sampled grid.

A simulator result inherits every unsupported input as an assumption. Maintain an
operator-coverage ledger around the tool boundary so native attention, sparse-index
selection, cache reconstruction, H2D fetch, dequantization, recurrent state,
collectives, and scheduler gaps are each charged exactly once.

## Source and Metadata Inspection

Prefer exact local artifacts over remembered architecture defaults:

- Use `rg`/`rg --files` to locate configs, manifests, rank maps, engine options, and
  code branches without loading large data files.
- For source-only Git inspection, set `GIT_LFS_SKIP_SMUDGE=1`, use a shallow clone when
  history is unnecessary, and record the exact commit. Do not mistake absent LFS
  payloads for a complete checkpoint inventory.
- Read structured checkpoint indexes and tensor headers rather than loading weight
  payloads solely to count shapes or dtypes.
- Record file hashes or immutable revisions for inputs that lack a source-control ID.
- Compare requested configuration with runtime logs to detect fallbacks and ignored
  settings.
- Treat generated configuration, wrapper defaults, and environment overrides as part of
  the runtime contract.

Do not scan unrelated user directories or secrets. Limit inspection to the model,
runtime, artifact, and environment scope the user placed in the task.

## Measurements and Microbenchmarks

Design a measurement to resolve one model parameter or hypothesis:

- match dtype, tensor shape, batch/sequence regime, kernel family, topology, and
  communication size to the target region,
- record hardware clocks/power, driver/runtime revisions, process mapping, and
  co-tenancy,
- warm up compilation, allocation, caches, and graph capture separately from the
  measured steady-state window,
- synchronize the measured boundary explicitly,
- retain raw samples instead of only the mean,
- report median and relevant tails with sample/window count,
- measure profiler perturbation by comparing profiled and unprofiled control runs when
  the trace informs a quantitative result.

A microbenchmark is transferable evidence only inside its declared domain. A square
GEMM peak does not calibrate all decode GEMVs; an isolated collective does not include
application contention; an HBM copy benchmark does not prove cache/offload service
rates.

## Timeline and Counter Profilers

Use a timeline profiler to answer ordering, overlap, launch-gap, CPU-orchestration,
transfer, and collective questions. Use a kernel counter profiler only after the target
kernel/event has been localized and the required metrics are known.

Before collecting:

- minimize the capture to representative iterations or ranges,
- confirm output size and storage location,
- avoid production load unless explicitly authorized,
- avoid replay modes that change memory state or execute unsafe side effects,
- record profiler version and collection options,
- keep the unprofiled baseline.

Profiler labels and percentages are not automatically workload accounting. Reconcile
sampled events to execution counts and the scenario's complete operator coverage.

## Serving Load Generators and Traces

The load driver must record, at minimum:

- offered arrival time and request ID,
- admitted/started time where observable,
- first-token and every emitted-token timestamp or sufficient aggregates,
- completion/cancellation/rejection/timeout status,
- actual input and accepted output token counts,
- cache/reuse classification where available,
- exact request distribution and load-generation mode,
- measurement window and warmup exclusions.

Closed-loop concurrency tests and open-loop arrival tests answer different questions.
Do not relabel a fixed-concurrency saturation run as an arrival-rate latency curve.

## Simulators and Spreadsheets

Before using a simulator or spreadsheet, audit:

- model/runtime revision and all input profiles,
- supported architecture/operator list,
- state and event ownership,
- interpolation, clamping, and extrapolation behavior,
- kernel/profile shape domain,
- topology and collective model,
- batching, queueing, admission, prefix-cache, and preemption semantics,
- generated-output lineage and versioning.

Use simulators to compose explicit inputs consistently and explore variants. Do not use
the simulator's existence as evidence that a peak-efficiency, cache-hit, acceptance,
overlap, or scheduling assumption is true.

## External Documentation and Freshness

Hardware specifications, runtime behavior, pricing, model revisions, and simulator APIs
change. When current facts matter:

- prefer official vendor/model/runtime documentation tied to an exact version,
- use installed tool `--help` or version-matched docs before relying on command syntax,
- record retrieval date and immutable document/release revision when possible,
- preserve quoted numeric facts in the evidence ledger with unit/scope,
- treat search summaries and remembered figures as discovery hints only.

If authoritative current documentation is unavailable, keep the field assumed or
unknown and bound its influence.

## Tool Guardrails

- DO NOT treat a calculator or simulator as evidence for values supplied to it.
- DO NOT run broad or invasive profiling when a metadata check or controlled microbenchmark can distinguish the hypotheses.
- DO NOT collect privileged, production-impacting, or high-volume traces without applicable authorization.
- DO NOT extrapolate a microbenchmark across dtype, shape, kernel family, topology, or load regime without a transfer argument and wider uncertainty.
- DO NOT discard raw samples, tool versions, launch configuration, or environment fingerprints after extracting a headline.
- DO NOT trust a generated chart or spreadsheet cell whose upstream data and formula cannot be traced.
