# Calibration Protocol

## Purpose

Use this protocol to replace unsupported efficiency guesses with reproducible,
scope-limited measurements. It is vendor-neutral and project-independent. Adapt the
commands to available tools, but preserve the fingerprint, raw data, and validation
contract.

## 1. State the Calibration Question

Name the uncertain term before selecting a benchmark. Examples:

- sustained compute rate for a precision and operator family
- sustained HBM or host-transfer rate for a traffic pattern
- launch, dispatch, graph, or scheduler fixed overhead
- collective startup and payload rate on a specified rank placement
- prefill or decode service curve across scheduled shapes
- KV offload or prefix-cache service cost
- end-to-end residual not explained by modeled components

Do not begin with “measure performance.” A benchmark that combines several unknown
terms may validate a prediction while being unable to calibrate any one term.

## 2. Calibration Fingerprint

Record enough state to decide whether a result transfers:

- accelerator make, exact model, count, memory size, partitioning, and firmware
- node, socket, NUMA, PCIe, accelerator-link, NIC, rail, and rank placement
- power limit, application and memory clocks when observable, temperature, and
  competing load
- operating system, driver, accelerator runtime, communication library, and compiler
- serving framework and revision, backend, kernel library, graph or eager mode, and
  relevant runtime flags
- model and tokenizer revision, architecture, weight/KV/activation precision,
  quantization scheme, sparsity, and custom kernels
- TP, PP, DP, EP, replicas, microbatch, scheduler, cache, offload, speculation, and MTP
  settings
- prompt, cached-prefix, output, context, batch, concurrency, and arrival distributions
- benchmark command, environment overrides, seed, timing method, warmup, repetitions,
  run order, and timestamps

Hash or otherwise identify immutable inputs when possible. Never put credentials or
private request content in the calibration artifact.

## 3. Choose a Measurement Layer

| Layer | Best use | Main limitation |
| --- | --- | --- |
| Inventory | Verify capacity, clocks, placement, and configuration | Does not reveal sustained application rates |
| Microbenchmark | Isolate compute, memory, copy, or network ceilings | May not reproduce application access patterns |
| Operator | Calibrate a kernel family and shape regime | Omits orchestration and scheduler costs |
| Phase | Calibrate prefill, decode, collective, or transfer service curves | Combines several operators |
| End-to-end | Validate user-facing prediction and residual | Weak causal identifiability |

Measure from low to high only as far as the decision requires. If a phase benchmark is
already sufficient and reproducible, a large serving run may add cost without
identifying a new parameter.

## 4. Design an Identifiable Matrix

Vary inputs that separate model terms:

- include small and large work sizes to distinguish fixed cost from sustained rate
- cross suspected saturation boundaries rather than sampling only one batch
- cover relevant context and active-sequence buckets for decode
- vary uncached prompt tokens and chunk sizes for prefill
- vary collective payload, rank count, algorithm, placement, and concurrent traffic
- include cache-hit, miss, acceptance, or offload regimes when those policies matter
- include at least one target-like case and withheld interpolation or extrapolation cases

Change one explanatory dimension at a time where practical, then include a small number
of representative interactions. Randomize or balance run order when drift can be
confounded with shape.

## 5. Measurement Hygiene

Before collection:

1. inspect any host-local operating or network notes before installing or downloading
2. create a project-local isolated environment, preferably with Pixi when available;
   use a data disk or local NVMe cache and do not modify the host's system runtime
3. restrict the process with `CUDA_VISIBLE_DEVICES` or the platform equivalent, then
   verify logical-to-physical device identity and that no unrequested accelerator is used
4. verify correctness and output equivalence for the benchmark path
5. record idle memory, utilization, clocks, power, temperature, and neighboring work
6. separate compilation, graph capture, weight loading, cache priming, and steady state
7. choose device-event timing for isolated device work and host wall time for requested
   end-to-end clocks
8. synchronize at benchmark boundaries without adding synchronization to every event
9. predeclare warmup, stopping, timeout, and failure rules

For host-to-device calibration, allocate pinned host buffers, bind or record the NUMA
node, sweep payload sizes, and measure one copy, simultaneous endpoint copies, shared
PCIe/root groups, and node-wide traffic separately. For P2P or network calibration,
record the actual peer path and direction. Use multiple rotating buffers or a working
set larger than the relevant cache when the estimate assumes streaming traffic; a hot
single buffer can overstate sustained bandwidth.

During collection:

- retain every raw sample in execution order
- retain failures, retries, timeouts, and exclusion reasons
- capture telemetry with enough cadence to detect throttling or contention
- avoid concurrent profiling during official timing unless instrumentation overhead is
  itself part of the scenario
- repeat until central tendency and relevant tails are stable enough for the requested
  decision, not until an arbitrary round number is reached

After collection:

- compare early and late samples
- inspect multimodality before summarizing
- report robust summaries and raw sample count
- keep cold, warm, compile, capture, and steady-state populations separate
- report at least median, p10, and p90 for repeated performance samples when sample
  count permits, together with the exact percentile convention

Model weights are not required to calibrate raw HBM streaming, pinned H2D, concurrent
H2D, P2P, collective primitives, dequantization throughput, or representative synthetic
GEMM shapes. The actual runtime and weights, or a faithful operator substitute, are
needed for claims about end-to-end fusion, real MoE routing, framework gaps, model
quality, and checkpoint-specific fallback behavior.

## 6. Derive Rates Without Losing Units

For a compatible work definition:

rate = modeled_work / measured_service_time

efficiency = sustained_rate / matching_physical_peak

Efficiency is meaningful only when work count, precision, sparsity convention, boost
state, device scope, and peak definition match. A value above one is a diagnostic for
definition mismatch before it is a reason to clamp the result.

For traffic:

effective_bandwidth = payload_or_modeled_bytes / measured_service_time

Name whether bytes are requested, transferred on the wire, read plus written, per
direction, aggregate, or per device. Protocol and collective traffic may exceed logical
payload.

## 7. Preferred Model Families

Use the simplest model supported by residual evidence.

### Fixed plus proportional

For one stable regime:

time(work) = alpha + work / sustained_rate

Use multiple work sizes to identify alpha and the rate. A single point cannot separate
them.

### Compute and traffic roof

For a phase with justified overlap:

time = fixed + max(FLOPs / compute_rate, bytes / memory_rate)

Use a sum or explicit event graph when compute and traffic are sequential. Do not use
max merely to make the prediction smaller.

### Collective or transfer

For a fixed algorithm and path:

time = startup(shape, ranks) + wire_bytes(shape, ranks) / effective_path_rate

Model hop, phase, or contention terms when residuals depend systematically on
placement. Do not reuse one alpha-beta pair across algorithms or paths without a test.

### Service surfaces

For prefill, decode, or scheduler service, use a table or piecewise surface over the
few dimensions that explain observed regime changes. Interpolate only inside covered
ranges. Outside them, use a physical bound plus widened uncertainty or collect data.

## 8. Fitting Discipline

- Fit times or rates with their units attached.
- Weight observations only for a stated noise or decision model.
- Preserve parameter covariance when terms trade off.
- Prefer robust fitting or explicit exclusion over deleting inconvenient samples.
- Inspect residuals against every varied dimension and run order.
- Use piecewise regimes only when a known algorithm, saturation, padding, cache, or
  topology transition supports them.
- Report both in-sample and withheld error.
- Preserve the analytical floor and reject fitted predictions below it unless the
  underlying work or ceiling definition is repaired.

Do not select a model solely by minimum training error. Prefer the smallest causal model
that meets the decision tolerance on withheld data.

## 9. Uncertainty

Separate:

- measurement variability
- fitted-parameter uncertainty
- scenario-input uncertainty
- transfer uncertainty
- structural model error

Repeated-sample quantiles describe observed samples. Bootstrap or fitted intervals
describe sampling uncertainty only under their assumptions. Scenario sweeps describe
sensitivity, not statistical confidence. Label each range correctly and combine
correlated uncertainties through explicit scenarios rather than independent extremes.

## 10. Holdout Validation

Withhold cases that exercise:

- an interior interpolation point
- a boundary near saturation or algorithm change
- a target-like composite phase or trace
- a changed batch, context, rank count, or placement relevant to expected use

For every holdout, report signed and absolute residuals, the prediction range, and
whether the observation is inside the declared domain. A good average error does not
excuse a systematic tail or boundary miss.

## 11. Transferability Grades

| Grade | Meaning | Use |
| --- | --- | --- |
| exact | Fingerprint and workload domain match the target | Apply with measured and fit uncertainty |
| in-domain | Differences are covered by the fitted dimensions and holdouts | Apply within declared interpolation range |
| proxy | Material differences exist but the measurement constrains a related term | Use as a prior or wider bound |
| incompatible | Mechanism, scope, or evidence cannot support the target term | Do not apply |

Compare at least hardware, precision/kernel path, runtime revision, topology,
parallelism, model architecture, workload regime, scheduler, and power/clock state.
Record every difference and its expected direction even when the grade remains
in-domain.

## 12. Applying Calibration

1. Copy the analytical estimate rather than overwriting it.
2. Map each fitted parameter to named formula terms.
3. Apply only inside the validity domain.
4. Propagate parameter and scenario ranges.
5. Recompute all dependent artifacts from the same calibrated dataset.
6. Validate against withheld data and physical floors.
7. Label the result calibrated-predicted, not measured.

An end-to-end correction factor may be reported as a diagnostic, but it must not hide
which component terms remain wrong.

## 13. Artifact Shape

The calibration artifact should include:

- schema version and scenario identifier
- fingerprint and source revision
- benchmark definitions and commands
- raw sample references and checksums when available
- work-count and traffic definitions
- fit model and parameter values with units
- validity dimensions and covered ranges
- uncertainty components and residual summaries
- holdout cases and pass criteria
- transfer target, differences, grade, and rationale
- excluded or uncalibrated terms

The artifact must be sufficient for another agent to reproduce the fit without access
to the originating project.

## 14. Stop Conditions

Stop and return a plan or blocker when:

- the execution scope or cost is unauthorized
- correctness cannot be verified
- required clocks, placement, or revision cannot be identified
- the benchmark does not isolate the requested term
- observed drift or contention dominates the required precision
- the target lies outside all defensible transfer domains

Do not hide a stop condition by substituting a generic efficiency prior.
