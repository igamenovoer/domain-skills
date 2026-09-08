# Compare Inference Scenarios

## Overview

Compare deployment, precision, parallelism, algorithm, caching, or serving alternatives
on common definitions and evidence quality. A valid comparison changes declared fields
while freezing all intended controls; it does not place unrelated benchmark headlines
side by side.

## When to Use

- Use to compare hardware SKUs, device counts, TP/PP/EP mappings, cache formats,
  quantization schemes, batching policies, offload paths, speculative/MTP policies, or
  other inference alternatives.
- Use to find crossover points, sensitivity drivers, and conditions under which one
  scenario dominates another.
- Use when a user wants both absolute feasibility and relative improvement.
- Do not use when only one scenario needs estimation; use `estimate` or `quick-bound`.
- Do not use to claim model-quality equivalence; performance comparison treats quality
  acceptance as a separately supplied condition.

## Workflow

1. **Define the decision**. State the alternatives, selection metric, hard constraints,
   acceptance rule, and whether the comparison is prospective or measured.
2. **Freeze the common scenario**. Load `references/scenario-contract.md`; separate
   controlled fields from intentionally varied fields and assign one scenario ID per
   variant.
3. **Normalize evidence and metrics**. Load
   `references/units-metrics-evidence.md`; use identical units, scopes, token/request
   distributions, percentile definitions, and evidence classes wherever possible.
4. **Estimate each variant symmetrically**. Apply the same accounting coverage,
   placement rigor, topology treatment, serving model, calibration policy, and
   validation level to every alternative.
5. **Reconcile absolute results first**. Check each scenario independently for memory,
   physical latency floors, limiting resource, admission, and SLO feasibility before
   calculating deltas.
6. **Compute controlled deltas and crossovers**. Compare absolute values, ratios,
   margins, bottleneck migrations, and sensitivity ranges without canceling uncertainty
   that is not genuinely shared.
7. **Validate the ranking**. Test whether the conclusion survives plausible values of
   high-sensitivity unknowns, changes in load or sequence distribution, and calibration
   error.
8. **Report a conditional decision**. State the winner only inside the region where it
   is supported; expose ties, unresolved regions, and the next evidence needed.

If the task does not map cleanly to these steps, use the native planning tool to build
a step-by-step comparison from the alternatives, controlled variables, decision
criteria, and shared evidence rules, then execute the plan.

## Comparison Contract

Create a scenario matrix before calculating:

| Field | Baseline | Variant A | Variant B | Control or reason for change |
| --- | --- | --- | --- | --- |
| Model/checkpoint revision |  |  |  |  |
| Runtime/kernel revision |  |  |  |  |
| Precision by tensor/operator/cache |  |  |  |  |
| Prompt/output/load distribution |  |  |  |  |
| Device and topology |  |  |  |  |
| Parallelism and rank placement |  |  |  |  |
| Scheduler/admission/cache policy |  |  |  |  |
| Calibration source and domain |  |  |  |  |
| Quality acceptance condition |  |  |  |  |

Blank or `same` cells are not evidence. Resolve them to explicit values or mark them
unknown. If a field changes unintentionally, either restore the control or describe the
comparison as a compound change.

## Common-Denominator Rules

- Compare TTFT at the same prompt-length distribution, cache state, and timing
  boundaries.
- Compare TPOT or inter-token latency at the same active-sequence and context regime;
  report how it changes over decode length when relevant.
- Compare output throughput using accepted emitted output tokens over the same wall-time
  window. Report total processed tokens separately.
- Compare request throughput at the same prompt/output distribution and completion rule.
- Compare per-user throughput only at the same active-user definition and concurrency.
- Compare memory at the same accounting boundary: logical state, resident allocation,
  allocator reserved, or peak device-reported usage.
- Compare cost only after currency/time, device count, utilization, reservation model,
  and failed/SLO-missed work are aligned.

## Handling Different Evidence Classes

Prefer comparisons whose alternatives share one evidence class and calibration domain.
When they do not:

1. preserve the bound, calibrated prediction, and measurement columns separately,
2. avoid subtracting or ratioing an optimistic analytical floor against a measured
   application result as if they were peers,
3. widen uncertainty for proxy or out-of-domain calibration,
4. label a ranking conditional when evidence asymmetry could reverse it.

Shared uncertain inputs may be varied together only when they are truly correlated.
Independent uncertainties must not be canceled merely because the same symbol appears
in both calculations.

## Crossover and Sensitivity Analysis

Evaluate the decision over the axes that can change the limiting resource, such as:

- prompt length and generated length,
- active sequences, batch tokens, and offered load,
- prefix-cache hit rate and reuse length,
- accepted draft length or prediction acceptance,
- HBM residency versus offload fraction,
- tensor/pipeline/expert parallel degree and node boundary,
- sustained compute, HBM, DMA, and network efficiency,
- allocator reserve and cache-block utilization.

Report a crossover only when both sides use valid models in that region. A simulator
boundary, memory cliff, kernel-family switch, topology change, or scheduler-policy
change creates a new region rather than a smooth continuation.

## Output Contract

Return or write:

- the decision statement and acceptance constraints,
- the filled scenario matrix with controlled and changed fields,
- absolute results and uncertainty for every scenario,
- deltas, ratios, margins, and bottleneck changes on common denominators,
- feasibility/SLO status per scenario,
- sensitivity or crossover table with validity regions,
- evidence asymmetries and quality assumptions,
- conditional recommendation, tie, or unresolved decision,
- the single next measurement most likely to change or confirm the ranking.

For durable work, store each variant's normalized scenario and estimate under its own
scenario ID and generate the comparison table/report from those machine-readable
records. Do not hand-copy headline values into a separate untraceable chart.

## Guardrails

- DO NOT compare scenarios with hidden changes in workload, model/runtime revision, metric boundaries, or scheduler policy.
- DO NOT report only relative speedup when one or more variants are infeasible or violate the SLO.
- DO NOT compare analytical, proxy-calibrated, and measured values as equivalent evidence.
- DO NOT cancel uncertainty unless the uncertain quantity and its correlation are shared by construction.
- DO NOT treat a performance win as proof that quantization, sparsity, prediction, or offload preserves quality.
