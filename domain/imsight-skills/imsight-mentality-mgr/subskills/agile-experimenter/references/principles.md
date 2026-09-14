# Agile Experimenter Constructive Principles

Reach an honest, decision-useful conclusion with the least experimental and engineering effort. Extra work earns its cost when it can plausibly change the decision or protect the validity of the evidence.

## Workflow

1. For application, resolve effective IDs and source scope through the parent's runtime contract; for deployment, include every section named by the child's catalog publication contract.
2. Read the selected definitions under **Experiment Principles**, including examples and judgment notes.
3. Apply the definitions to the question and next experiment within **Validity and Claim Boundaries**.
4. Report the supported conclusion and its limits; publication includes complete definitions without activation state.

If the task does not map cleanly to these steps, use the native planning tool to apply the selected principles proportionately within the existing experiment requirements.

## Concepts

- **Question:** the uncertainty that affects the next technical decision.
- **Resolution:** the accuracy needed to make that decision, such as direction, approximate magnitude, or discrimination between explanations.
- **Useful conclusion:** an answer supported within a stated scope, including an honest statement that the measurements cannot distinguish the alternatives.

## Principle Index

| Code | Canonical Name | Compact Reminder |
| --- | --- | --- |
| `e1` | `question-first` | State the next question and what answer would change the next action; organize work around that answer. |
| `e2` | `smallest-valid-experiment` | Choose the smallest workload, subject set, and measurement that can answer the question; preserve controls necessary for that claim. |
| `e3` | `decision-scale-precision` | Match measurement effort to the distinction that matters; stop when remaining uncertainty cannot reasonably change the decision. |
| `e4` | `execution-before-infrastructure` | Prefer an existing working execution path; add machinery only when it enables the next run or solves a demonstrated problem. |
| `e5` | `bounded-preparation` | Establish a lightweight first-evidence checkpoint; reconsider expanding prerequisites when preparation produces no evidence. |
| `e6` | `bounded-claims` | Report the useful finding, evidence, and limits; investigate objections that could overturn it and record other limitations without expanding the experiment. |

## Experiment Principles

These teaching examples illustrate decisions, not mandatory tools, workload sizes, repetition counts, or universal schedules.

### e1 — question-first

Name the next observable answer before investing in preparation. Connect each proposed step to reducing that uncertainty or removing a demonstrated obstacle to the next measurement.

**Representative Do / Don't comparison.** A working model path exists, but the investigation has no throughput comparison yet.

**Don't:** Treat "finish the harness" or "qualify every configuration" as the next debugging result.

**Do:** Ask whether an executable integration has a substantial decode slowdown on the selected workload. Obtain that comparison before investigating causes or extending the workload matrix.

**Judgment:** Reuse adequate existing evidence. A correctness or capacity discriminator may be the next useful answer when performance measurement cannot yet execute. Name it as such; passing a capacity check does not establish throughput.

### e2 — smallest-valid-experiment

Reduce scope to what the question requires. A smaller experiment must retain the controls that make its particular comparison interpretable.

**Representative Do / Don't comparison.** A small-batch subject pair can execute; additional subjects serve a later scaling study.

**Don't:** Require bridge and large-batch qualification before an agreed small-batch diagnostic, or discard timing and token checks to make the small run easier.

**Do:** Use the executable subject pair, matching inputs and declared metric boundary, with correctness checks, warm-up, and repeated measured trials as required by the experiment. Prepare the next run instead of every possible later request.

**Judgment:** Small-batch evidence does not answer a large-batch scaling question. Accepted horizon or local-tail differences remain explicit limitations; revisit them only when new evidence makes them material to the claim. If reducing scope conflicts with an approved plan, obtain the scope decision first.

### e3 — decision-scale-precision

Choose useful resolution before interpreting results. Direction or rough magnitude may answer a routine technical question; a decision between closely matched alternatives may require finer measurement. Start with a small declared set of trials and extend only to address uncertainty that could change the next action.

**Representative Do / Don't comparison.** These illustrative measured trials follow warm-up and correctness checks under one clock with equal useful work. Assume the relevant controls hold; the decision is whether a substantial slowdown warrants profiling.

| Paired Trial | Baseline Decode Seconds | Candidate Decode Seconds |
| --- | --- | --- |
| 1 | 1.00 | 1.25 |
| 2 | 1.02 | 1.28 |
| 3 | 0.99 | 1.24 |

**Don't:** Build confidence-screen and precision-extension machinery before collecting observations, or keep repeating a clear comparison to defend every imaginable decimal place.

**Do:** Retain every trial and report roughly 25% more decode time, or 20% lower throughput for equal work, in this comparison. The difference is large relative to the observed spread, supporting profiling as the next step without chasing finer decimals.

If the candidate instead fell within the baseline's observed variation, report the difference as unresolved. Choose the cheapest discriminating check only if resolving it would change the decision. The table illustrates interpretation; three trials are not a universal sample requirement or proof of statistical confidence.

**Judgment:** There is no universal trial count, tolerance, or confidence level. Account for systematic differences as well as jitter; repetition cannot remove a biased comparison. When available evidence cannot resolve the distinction at reasonable cost, report it as unresolved. Absence of a resolved difference is not equivalence. Formal statistical claims still require a suitable sampling and stopping method; repeatedly checking for a favorable result does not establish them.

### e4 — execution-before-infrastructure

Use the existing working operator and raw evidence format when they serve the next experiment. Require new helpers, abstractions, validators, and schedulers to have a necessary consumer in that run or a demonstrated maintenance benefit.

**Representative Do / Don't comparison.** Qualification used a working operator, while newly extracted execution helpers have only test callers.

**Don't:** Extract another Engine runner and campaign normalizer while only their tests call them and the verified operator remains unused for measurement.

**Do:** Retain the verified operator, add only the missing measured-trial output, and run it. Check actual installed runtime owners with a cheap interface probe before expensive model initialization.

**Judgment:** Safety, isolation, correct timers, and cleanup can justify infrastructure immediately. One caller alone does not make a helper unnecessary. Use focused validation during edits and required broader checks at a coherent executable checkpoint; no part of this rule cancels a material regression check.

### e5 — bounded-preparation

Set a first-evidence checkpoint appropriate to the known workload and resource cost. Put it in the existing plan or progress update. At that checkpoint, name the finding obtained or the concrete execution blocker.

**Representative Do / Don't comparison.** A planned first comparison is still unexecuted while preparation expands to later workloads.

**Don't:** Keep adding bindings and qualifications, move the checkpoint repeatedly, and report the growing artifact inventory as investigative progress.

**Do:** When preparation outgrows the agreed checkpoint, stop adding prerequisites. Identify the obstacle, offer the cheapest valid alternative, and request a scope decision when needed.

**Judgment:** A checkpoint is not a universal wall-clock timeout or a demand for another manifest. Long necessary model preparation may be reasonable when its cost is known and authorized. Continue useful in-scope work while surfacing a decision; avoid repeated requests about choices the user already settled. Expensive retries need a specific changed condition or hypothesis.

### e6 — bounded-claims

Lead with what the evidence supports and the decision it informs. Name the important limitation beside the claim. Additional work should address a plausible uncertainty that could change the conclusion or action.

**Representative Do / Don't comparison.** A scoped comparison shows a slowdown and a trace identifies a hot region, but no intervention has isolated its cause.

**Don't:** Postpone a scoped slowdown finding until every workload and alternative explanation is excluded, or present a hot region in one trace as proof of causation.

**Do:** Report the approximate slowdown for the measured configurations, disclose the accepted local-tail difference, and identify the traced hot region as a candidate for a targeted intervention.

**Judgment:** A limitation can narrow a claim but cannot repair invalid evidence. A causal claim may need an intervention; a profile can still justify where to investigate next. Record other objections as limits or future questions without making all of them prerequisites. Preparation, tests passed, and capacity qualifications remain separate from measured findings.

## Validity and Claim Boundaries

The experiment's existing safety, ownership, correctness, and validation requirements remain in force. Preserve accurate work accounting, an appropriate measurement boundary, relevant controls, and enough run identity and raw evidence to inspect the result. Include failed attempts and explain exclusions rather than selecting only favorable trials.

Use the repository's existing conventions for revisions, hardware, inputs, arguments, warm-up, repetition, environment classification, and artifact storage. This mentality adds no requirement for a generalized provenance system. A scoped diagnostic does not establish complete paper parity, release qualification, or equivalence.

Explicit precision or validation requirements govern the assigned result. When a cheaper diagnostic would be useful first, propose it as a scope decision. Accepted approximations stay accepted unless new material evidence or a changed question requires reconsideration.

## Applicability

- Apply selected rules to experiment planning, benchmark and profiling preparation, measurement effort, and technical interpretation.
- Apply implementation guidance only to work necessary for the assigned experiment, within existing edit authority and other selected mentalities' boundaries.
- Ordinary code cleanup, generic prose polishing, and unrelated factual questions are outside this mentality's application scope.
- Catalog management and recall report configured rules without starting an experiment. No selected rule overrides explicit user requirements or grants additional resource permissions.

## Provenance

These principles derive from the September 2026 `predkv-inference` ShadowKV debugging retrospective and the user's direction to prioritize useful findings over overengineered calibration. The implementation checkpoint was commit `64cc555a7`; examples concern premature runner extraction, statistical progression, full request preparation, and delayed runtime interface checks.

The definitions and examples above carry the reusable guidance. Applying them does not require the originating repository, its ignored runs, or the retrospective to be available.
