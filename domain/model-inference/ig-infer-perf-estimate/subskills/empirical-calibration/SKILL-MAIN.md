---
name: empirical-calibration
description: Use when an inference estimate needs measured sustained rates, fixed overheads, communication parameters, service curves, uncertainty, or a decision about whether proxy measurements transfer to the target scenario. Do not use when the task is only analytical bounding or when running benchmarks would exceed the authorized host and workload scope.
metadata:
  skill_invocation_notation: >
    Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
    SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
    accepted only as legacy input when SKILL-MAIN.md is absent.
    Skill and subskill entrypoints use bare object paths: X invokes skill X and
    X->Y->Z invokes subskill Z. Subcommands use parenthesized components:
    X->cmd() invokes a direct subcommand, X->Y->cmd() invokes a subcommand of
    subskill Y, and X->parent()->child() invokes child subcommand child exposed
    by parent subcommand parent. Intermediate subcommands act as object generators.
    Forms such as X() and X->Y() are invalid for skill or subskill entrypoints.
---

# Empirical Calibration

## Overview

Measure the rates and overheads that an analytical inference model cannot know from
peak specifications alone. Preserve raw observations, analytical floors, fitted
predictions, and transfer assumptions as distinct evidence layers.

## Workflow

1. Select an operation from **Subcommands** and load
   references/calibration-protocol.md.
2. Freeze the target scenario, calibration question, required precision, host scope,
   runtime budget, and benchmark side-effect boundary.
3. Build the calibration fingerprint and choose the lowest measurement layer that can
   identify the uncertain model terms.
4. Prepare a benchmark matrix that varies the dimensions needed to distinguish fixed
   overhead, work-proportional cost, saturation, topology, and scheduler effects.
5. Collect synchronized raw samples with warmup, environment telemetry, exact commands,
   failures, and run-order metadata.
6. Fit the narrowest physically interpretable model, retain uncertainty and residuals,
   and test it on withheld shapes or traces.
7. Grade transferability to the target, apply only supported factors, and preserve the
   original analytical lower bound and any uncalibrated terms.
8. Return the calibration artifact, exclusions, validity domain, and validation inputs.

If the task does not map cleanly to these steps, use the native planning tool to build
a step-by-step plan from the subcommands, benchmark protocol, evidence constraints,
available tools, and user request, then execute the plan.

## When to Use

- Use when vendor peaks or generic efficiency priors are too weak for a requested
  latency, throughput, communication, offload, or SLO estimate.
- Use when a target or proxy host is available for microbenchmarks, operator tests,
  phase tests, trace replay, or end-to-end measurement.
- Use when fitted rates look physically impossible, calibration changes across shapes,
  or a prior measurement must be transferred across hardware, software, model, or
  workload changes.
- Use when measurements exist but lack sufficient metadata to decide what they
  calibrate.
- Do not use to redefine FLOP, byte, state-placement, event-ownership, or serving
  semantics; those remain owned by the analytical subskills.
- Do not run disruptive, unbounded, production, billable, or multi-tenant benchmarks
  unless that exact execution scope is authorized.

## Invocation Contract

- Invoke this subskill as ig-infer-perf-estimate->empirical-calibration.
- Invoke a command as
  ig-infer-perf-estimate->empirical-calibration-><subcommand>().
- With no command, identify which unknown terms need calibration and propose the
  smallest sufficient measurement plan.

## Subcommands

| Subcommand | Use For |
| --- | --- |
| plan-measurements | Design a bounded matrix that identifies selected model terms |
| collect-calibration | Execute or specify reproducible measurements and preserve raw samples |
| fit-calibration | Fit sustained rates, overheads, service surfaces, and uncertainty |
| check-transferability | Grade whether source measurements apply to a target scenario |
| apply-calibration | Apply supported factors while retaining analytical bounds |
| audit-calibration | Diagnose implausible, unstable, circular, or under-documented factors |
| help | Explain measurement layers, artifacts, and transfer grades |

All commands use references/calibration-protocol.md. A plan is a valid output when no
authorized or compatible host is available; do not convert the absence of measurement
into fabricated calibration.

## Calibration Contract

A calibration result must identify:

- the exact analytical terms it calibrates
- the model/runtime/hardware/workload fingerprint
- raw sample locations and timing method
- work and traffic counters or the formulas used to derive them
- fitted parameters with units, ranges, residuals, and validity domain
- withheld validation cases
- source-to-target differences and transfer grade
- analytical values left unchanged

Use separate parameters for terms with different causal mechanisms. Prefer a bound or
prior range over a single global efficiency multiplier.

## Evidence Ladder

Use the lowest layer that isolates the uncertainty, then verify against at least one
higher layer when practical:

1. inventory and environmental telemetry
2. compute, memory, copy, and collective microbenchmarks
3. operator or kernel-family measurements
4. prefill, decode, transfer, and communication phase measurements
5. scheduler trace replay or end-to-end serving observations

Higher layers improve realism but combine more causes. They do not automatically
identify which lower-level parameter is wrong.

## Output Contract

Write or return a hardware-calibration artifact containing:

- fingerprint and provenance
- benchmark matrix and exact execution contract
- raw samples, excluded samples, and exclusion reasons
- derived work and traffic values
- fitted parameter sets by phase, shape region, and topology when needed
- uncertainty and parameter correlations
- holdout predictions and residuals
- transfer grade and target deltas
- applicability and stop conditions

Calibration output augments estimate.json; it never replaces the scenario, evidence
ledger, analytical bound, or final validation.

## Troubleshooting Guide

- A fitted efficiency exceeds the selected physical ceiling
  - If the work count, precision, boost state, aggregation scope, or peak convention is
    mismatched, then repair those definitions before constraining the factor.
- Repeated samples drift with run order
  - If clocks, power, temperature, cache state, compilation, or neighboring load drift,
    then stabilize or randomize the run order and retain telemetry with every sample.
- One factor fits a sampled shape but fails nearby shapes
  - If fixed cost, saturation, algorithm switches, padding, or memory regime changes
    were collapsed into one multiplier, then fit a piecewise or causal model and add
    boundary samples.
- Proxy measurements produce an unexplained target miss
  - If any transfer fingerprint dimension changed, then downgrade the transfer grade
    and calibrate the changed term or widen the result.
- Profiling and timing disagree
  - If instrumentation, synchronization, replay, or capture mode changes execution,
    then use profiling for attribution and a minimally instrumented run for timing.
- Calibration exactly reproduces the values it was meant to audit
  - If parameters were solved from the claimed outputs without independent samples,
    then label the fit circular and restore an independent benchmark or prior.

## Guardrails

- DO NOT replace an analytical lower bound with a fitted prediction or observation.
- DO NOT fit one efficiency factor across phases, precisions, algorithms, or topology regimes without evidence of invariance.
- DO NOT discard raw samples, failed runs, environment telemetry, or exclusion reasons.
- DO NOT transfer a calibration while hiding source-to-target fingerprint differences.
- DO NOT tune parameters against the same claim or trace used as independent validation.
- DO NOT run benchmarks outside the authorized host, workload, duration, cost, or disruption boundary.

## Resource Ownership

This subskill owns benchmark design, sample provenance, physically interpretable model
fitting, uncertainty, holdout testing, and transfer grades. It does not own the
analytical work model, state ledger, distributed event model, scheduler semantics, or
final report verdict.
