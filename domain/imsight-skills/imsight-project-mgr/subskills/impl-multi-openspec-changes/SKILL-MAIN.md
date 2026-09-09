---
name: impl-multi-openspec-changes
description: Use when two or more OpenSpec changes must be implemented in dependency order and each change needs application-specific, representative-data evidence before work advances to the next change.
metadata:
  skill_invocation_notation: >
    Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
    SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
    accepted only as legacy input when SKILL-MAIN.md is absent.
    Skill and subskill entrypoints use bare object paths: `X` invokes skill X and
    `X->Y->Z` invokes subskill Z. Subcommands use parenthesized components:
    `X->cmd()` invokes a direct subcommand, `X->Y->cmd()` invokes a subcommand of
    subskill Y, and `X->parent()->child()` invokes child subcommand child exposed
    by parent subcommand parent. Intermediate subcommands act as object generators.
    Forms such as `X()` and `X->Y()` are invalid for skill or subskill entrypoints.
---

# Implement Multiple OpenSpec Changes

## Overview

Implement OpenSpec changes as an ordered sequence of independently proven increments. A change is complete only after its implementation works with representative data, its evidence is inspected, and the remaining changes are reconciled against what actually changed.

Violating the letter of the verification rules is violating their spirit.

## When to Use

- Use when the user names two or more OpenSpec changes to implement in one delivery.
- Use when changes depend on, overlap with, or can invalidate assumptions in one another.
- Use when the user requires proof from the running application rather than test results alone.
- Do not use for a single OpenSpec change, planning-only work, proposal creation, verification without implementation, or change archival.

## Workflow

When this subskill is invoked, execute the following steps in order.

1. **Resolve the change set and execution order**. Discover the authoritative OpenSpec state for every requested change, identify dependencies and overlapping contracts, and record the intended order. See **Change Set Contract**.
2. **Plan evidence and confirm tools before editing**. Classify the application, select the evidence mode from **Application-Specific Verification**, and create the evidence workspace. Reject an execution request whose required capture tools are unavailable and ask the user to provide or enable suitable tools.
3. **Establish a clean baseline**. Read repository instructions, preserve unrelated work, run proportionate baseline checks, and record pre-existing failures separately from change-caused failures.
4. **Reconcile the next change**. Before implementing it, compare its proposal, design, specs, and tasks with the code and contracts produced by all completed changes. Update stale OpenSpec artifacts through the applicable planning workflow before implementation. See **Pre-Change Reconciliation**.
5. **Apply exactly one change**. Use the repository's OpenSpec apply workflow, preferably `$openspec-apply-change` when available, and implement only the selected change until its tasks are honestly complete.
6. **Verify the change with representative data**. Run focused automated checks and the planned application-specific proof. Inspect the evidence itself, fix failures within the current change, and repeat until the acceptance criteria pass. See **Per-Change Verification Gate**.
7. **Close the current increment**. Run strict OpenSpec validation, record commands and evidence paths, and mark the change complete only after the verification gate passes.
8. **Re-plan the remaining sequence**. Revisit dependencies, scope, artifacts, verification plans, and order after every completed change, then repeat steps 4 through 7 for the next change.
9. **Run final cross-change verification**. Run the full relevant quality gates and at least one combined scenario that exercises the implemented changes together. Produce and inspect final evidence using the selected application mode.
10. **Report the delivery**. Use **Completion Report** to summarize artifact reconciliations, actual data, commands, outcomes, and proof paths. Leave archiving, commits, pushes, releases, and cleanup to explicit user requests.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the sequencing, reconciliation, evidence, and completion constraints in this subskill, then execute the plan.

## Change Set Contract

Resolve each change through OpenSpec discovery rather than assuming artifact paths or status. For every requested change, capture:

- Exact change name and current state.
- Proposal, design, specification, and task artifacts reported by the OpenSpec workflow.
- Dependencies, shared files, shared contracts, and likely ordering constraints.
- Breaking changes or user-visible effects declared by repository policy or the artifacts.
- Focused verification criteria and the planned evidence class.

Choose an order that satisfies explicit dependencies first and minimizes ambiguous overlap. If two changes conflict or the order materially changes user-visible behavior, stop and obtain the user's decision rather than choosing silently.

## Evidence Workspace

Use the user-provided temporary location when present. Otherwise, use:

```text
tmp/impl-multi-openspec-changes/<run-slug>/
├── <sequence>-<change-name>/
│   ├── inputs/
│   ├── outputs/
│   ├── logs/
│   └── evidence/
└── final/
```

Create only the subdirectories required by the application. Keep intermediate fixtures and proof artifacts out of runtime source directories, use stable descriptive filenames, and redact credentials or sensitive user data from durable evidence.

## Pre-Change Reconciliation

Before starting each change after the first:

1. Inspect the actual code diff, public contracts, dependencies, tests, and runtime behavior introduced by completed changes.
2. Re-read the pending change's authoritative OpenSpec context from the current working tree.
3. Identify assumptions that are now false, duplicated mechanisms, conflicting ownership, unnecessary dependencies, or tests that no longer describe the desired behavior.
4. Update the pending proposal, design, specs, and tasks through the appropriate OpenSpec planning or update skill when needed, and validate the revised change before applying it.
5. Record whether the change required revision and why. A finding of “no update needed” is still an explicit reconciliation result.

Reconciliation is not permission to expand scope. Preserve the user's selected capabilities and avoid applying a new abstraction to unrelated code merely because it is available.

## Application-Specific Verification

Automated tests are necessary when relevant, but they are not a substitute for operating the application with representative data.

| Application | Required proof |
| --- | --- |
| GUI | Exercise the affected workflow end to end with representative data. Capture screenshots by default, including the meaningful operation state or result for each change and a final combined state. Visually inspect every image for correctness, readability, errors, and accidental UI regressions. |
| GUI with requested recording | Before editing, verify that an available recording tool can capture the required application surface into `.mp4`. Record the observable operation sequence through its result, then verify the file is playable and inspect representative frames. If the required recording tooling is unavailable, reject the execution request and ask the user to provide or enable it; do not silently substitute screenshots. |
| Headless program | Persist the exact representative input data, command invocation, stdout/stderr logs, exit status, output data, and assertions or comparisons that establish correctness. Redact secrets without removing behaviorally relevant fields. |
| Other application | Derive the proof plan from the user's prompt and the application's observable contract. State the acceptance criteria, actual data, operation, evidence artifact, and inspection method before implementation begins. |

Generated fixtures count as representative data only when they are valid artifacts consumed through the production path. Mocked state, snapshots of static markup, and invented logs do not count as operational proof.

For a GUI task, verify screenshot tooling during evidence planning. If no supported screenshot or requested recording path is available, reject the execution request and ask the user for the necessary tool access before modifying the application.

## Per-Change Verification Gate

Do not advance until all applicable checks pass:

1. Focused unit, integration, type, lint, build, or contract checks for the changed surface.
2. A representative-data application journey that exercises the acceptance criteria.
3. Durable evidence written under the current change's workspace.
4. Human-equivalent inspection of screenshots, recording frames, logs, inputs, and outputs as applicable.
5. Confirmation that failures produce honest behavior and no unintended mutations where relevant.
6. Strict OpenSpec validation and an accurate all-tasks-complete state.

If the gate fails, keep working on the current change. Record the failure, fix it, regenerate stale evidence, and rerun the gate. Do not use a later change to conceal or compensate for an incomplete earlier change unless the OpenSpec artifacts are explicitly revised to make that dependency intentional.

## Final Cross-Change Verification

After every individual gate passes:

- Run the repository's full relevant quality gates.
- Run individual representative-data journeys together to detect state leakage and order-dependent regressions.
- Exercise at least one combined workflow when the features can interact.
- Confirm OpenSpec strict validation and completed task state for every change.
- Inspect final proof artifacts and verify that their paths are stable and reported.
- Audit the working tree so unrelated changes and temporary outputs are not accidentally delivered.

## Completion Report

Lead with whether all requested changes are implemented and verified. Include a compact per-change record with:

| Field | Content |
| --- | --- |
| Change | Exact OpenSpec change name and final task count/state |
| Reconciliation | Artifact updates made before implementation, or an explicit no-update-needed result |
| Verification | Exact commands and observable application journey |
| Actual data | Representative inputs used |
| Evidence | Stable screenshot, `.mp4`, log, input, and output paths as applicable |
| Result | Pass, unresolved failure, or blocker |

Also report final cross-change checks, pre-existing warnings, intentionally untouched work, and any action not taken because it lacked explicit authorization.

## Rationalization Table

| Rationalization | Correction |
| --- | --- |
| “All changes are small, so I can implement them together.” | Separate increments make failures attributable and expose invalidated assumptions before they spread. |
| “The tests pass, so actual-data verification is redundant.” | Tests do not prove that the running application and its production path exhibit the intended behavior. |
| “The next proposal probably still applies.” | Completed changes alter the evidence; reconcile the pending artifacts against the current tree every time. |
| “I can collect screenshots or logs at the end.” | Evidence is the gate for the current change and must exist before advancing. |
| “A startup screen proves the GUI works.” | Proof must show the affected operation or meaningful result with representative data. |
| “The recorder is unavailable, but screenshots are close enough.” | A requested recording is a distinct evidence contract; reject and request tooling rather than substituting it. |
| “An exit code is enough for a headless program.” | Headless proof includes logs plus the actual input and output data needed to evaluate behavior. |
| “I can mark the tasks complete and return to verification later.” | Task completion must reflect evidence already obtained, not intended future work. |

## Red Flags

- “We will verify everything after all changes are implemented.”
- “The previous implementation cannot affect this proposal.”
- “CI or mocked tests are sufficient proof.”
- “The evidence can be reconstructed from memory.”
- “Any screenshot is acceptable.”
- “A different evidence mode is fine without asking.”
- “The next change will fix the current failure.”

When a red flag appears, stop progression, return to the current change's reconciliation or verification gate, and produce the missing evidence before continuing.

## Guardrails

- DO NOT implement more than one OpenSpec change before the current change passes its verification gate.
- DO NOT apply a pending change from stale artifacts after an earlier change modifies shared behavior or contracts.
- DO NOT treat mocked data or automated checks as the sole operational evidence.
- DO NOT claim GUI success without inspected screenshots or the explicitly requested `.mp4` recording.
- DO NOT substitute screenshots for a requested recording when recording tools are unavailable.
- DO NOT fabricate, infer, or retroactively describe evidence that was not captured.
- DO NOT mark quality-gate tasks complete before the corresponding commands and application proof pass.
- DO NOT archive changes, commit, push, release, or remove evidence unless the user explicitly requests that action.
- DO NOT modify or deliver unrelated working-tree changes.
