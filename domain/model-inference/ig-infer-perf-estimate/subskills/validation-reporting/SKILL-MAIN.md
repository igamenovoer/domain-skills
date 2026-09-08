---
name: validation-reporting
description: Use when an inference estimate, comparison, simulator result, chart, or external performance claim needs invariant checks, independent reconstruction, sensitivity analysis, reproducibility grading, audit verdicts, or a human-facing report. Do not use to invent missing model, hardware, topology, calibration, or scheduler inputs.
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

# Validation and Reporting

## Overview

Validate the source model before polishing its outputs. Make every conclusion traceable
from a frozen scenario and evidence ledger through formulas, event ownership,
calibration, checks, and a report generated from the same machine-readable results.

## Workflow

1. Select an operation from **Subcommands** and load
   references/validation-audit.md.
2. Freeze the scenario, source artifacts, claim wording, metric scope, and acceptance
   criteria so validation cannot silently move the target.
3. Check structural completeness, evidence provenance, units, scopes, formula
   dependencies, state placement, and event ownership before checking headline values.
4. Recompute deterministic identities and independent anchors, then run physical,
   causal, cross-domain, monotonic, and empirical-residual checks.
5. Run sensitivity or controlled scenario comparisons where uncertainty could change
   the decision; separate scenario bands from statistical confidence.
6. Classify every finding, grade reproducibility, and assign an explicit validation or
   audit verdict with blockers and repair ownership.
7. Render the report from the validated machine-readable dataset using
   assets/report-template.md, preserving unsupported claims and limitations.

If the task does not map cleanly to these steps, use the native planning tool to build
a step-by-step plan from the subcommands, validation layers, audit rubric, available
artifacts, and user request, then execute the plan.

## When to Use

- Use before publishing a memory, latency, throughput, scaling, capacity, goodput, or
  SLO estimate.
- Use when reviewing an existing spreadsheet, report, simulator result, plot, or verbal
  claim whose inputs or derivation may be incomplete.
- Use when comparing scenarios, ranking sensitivity drivers, reconciling prediction
  with measurement, or identifying the owner of a discrepancy.
- Use when a corrected source model must regenerate multiple tables or charts
  consistently.
- Do not use as a substitute for the model-memory, latency-roofline,
  distributed-topology, serving-scheduling, or empirical-calibration calculations.
- Do not upgrade an under-specified claim to validated merely because its headline is
  numerically plausible.

## Invocation Contract

- Invoke this subskill as ig-infer-perf-estimate->validation-reporting.
- Invoke a command as
  ig-infer-perf-estimate->validation-reporting-><subcommand>().
- With no command, identify the available artifacts, validation depth, and narrowest
  useful command.

## Subcommands

| Subcommand | Use For |
| --- | --- |
| validate-estimate | Run structural, dimensional, physical, causal, and cross-domain checks |
| audit-claim | Reconstruct an external estimate and issue a traceable audit verdict |
| analyze-sensitivity | Rank decision-driving assumptions and scenario uncertainty |
| compare-scenarios | Verify controlled deltas and common denominators across alternatives |
| render-report | Produce a human-facing report from validated machine-readable results |
| help | Explain validation depth, verdicts, and required artifacts |

All commands use references/validation-audit.md. render-report also uses
assets/report-template.md. Rendering must not repair, suppress, or reinterpret a failed
validation result.

## Validation Depth

Choose and report one depth:

- shape-only: required fields, provenance, schema, units, and scope
- arithmetic: shape-only plus formulas, identities, aggregation, and tolerances
- model: arithmetic plus coverage, placement, causal critical path, and physical bounds
- empirical: model plus calibrated-domain and prediction-versus-observation checks
- audit: independent reconstruction of the original claim and all applicable checks

A lower depth is not a failure when source artifacts do not support a higher one, but
the report must not imply stronger assurance.

## Verdict Contract

Use these verdicts:

- validated: all required checks for the declared depth pass
- validated-with-caveats: checks pass for the decision, with bounded non-blocking gaps
- bounded-but-under-specified: a defensible range exists but the original precision or
  scope is unsupported
- contradicted: independent evidence or reconstruction conflicts materially
- unreproducible: required inputs, formulas, versions, or source artifacts are missing
- blocked: validation cannot proceed safely without a named predecessor artifact

Attach severity, evidence, affected outputs, and repair owner to every non-pass finding.

## Output Contract

Return or write:

- validation.json with check identifiers, status, severity, evidence, tolerance,
  affected paths, and repair owner
- report.md generated from the same scenario, evidence, estimate, calibration, and
  validation artifacts
- audit.md for an external-claim audit, including original claim, reconstruction,
  deltas, verdict, and correction
- corrected machine-readable source artifacts when repair was authorized

Keep obsolete generated outputs visibly stale or regenerate them from the corrected
source. Never hand-edit one presentation artifact while leaving its source inconsistent.

## Troubleshooting Guide

- A headline passes while component checks fail
  - If cancellation or double counting makes the total look plausible, then block the
    headline and repair component ownership before reporting.
- Two scenarios cannot be compared cleanly
  - If model revision, metric denominator, workload mix, evidence class, or topology
    changed unintentionally, then normalize the common contract or report separate
    cases instead of a delta.
- A measured value violates the analytical lower bound
  - If clock boundaries, work counts, precision, overlap, aggregation, or units differ,
    then reconcile definitions before declaring either artifact wrong.
- Sensitivity rankings change with perturbation size
  - If the system crosses a memory, scheduling, algorithm, or topology boundary, then
    use piecewise scenarios and report the discontinuity rather than one local slope.
- The report and JSON disagree
  - If the report was manually edited or generated from stale data, then regenerate it
    from the validated source and record the artifact revision.
- An audit cannot reproduce the original number
  - If key inputs or formulas are absent, then issue unreproducible or
    bounded-but-under-specified rather than reverse-fitting assumptions.

## Guardrails

- DO NOT validate a headline while its component ownership, units, or source graph fails.
- DO NOT repair generated prose, tables, or charts without repairing and regenerating their machine-readable source.
- DO NOT compare scenarios whose metric, model, workload, topology, or evidence denominator changed silently.
- DO NOT call a sensitivity band, sample percentile, or scenario range a confidence interval.
- DO NOT reverse-engineer hidden assumptions merely to reproduce an audited claim.
- DO NOT omit failed, skipped, blocked, or not-applicable checks from the validation record.
- DO NOT present a performance validation as evidence of model-quality preservation.

## Resource Ownership

This subskill owns validation layers, invariant and metamorphic checks, sensitivity
reporting, audit reconstruction and verdicts, reproducibility grading, and
human-facing report shape. It consumes but does not redefine the analytical and
empirical models owned by sibling subskills.
