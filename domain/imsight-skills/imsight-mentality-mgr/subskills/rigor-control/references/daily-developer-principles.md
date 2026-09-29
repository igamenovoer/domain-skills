# Rigor Control: Daily Developer Principles

## Workflow

1. For application, resolve the flavor's effective rules and source scope; for deployment, include all sections declared by the [flavor command](../commands/daily-developer.md#catalog-publication).
2. Read the selected definitions, comparisons, and judgment notes under **Daily Developer Principles**.
3. Apply them to the current design, implementation, and verification decision within **Applicability**.
4. Report scoped readiness, material limits, and any explicit requirement that demands stronger assurance; catalog publication includes definitions without activation state.

If the task does not map cleanly to these steps, use the native planning tool to match effort to the selected daily-developer rigor level without weakening explicit requirements, then execute the plan.

## Purpose

Make everyday development and internal experiments rigorous enough that the developer can trust the results and act on them. Producing something useful outranks producing something publishable: stamp evidence with code version at run time, judge from code logic whether a change can materially affect a claim, keep failed attempts cheap to retry, and defer rigor whose purpose is external review or publication.

## Principle Index

| Code | Canonical Name | Compact Reminder |
| --- | --- | --- |
| `rc1` | `useful-outcome-first` | Calibrate rigor to a result the developer can act on, not an artifact for reviewers. |
| `rc2` | `logic-scoped-evidence-refresh` | Stamp evidence with code version; re-run only what a change can materially affect, judged from code logic. |
| `rc3` | `cheap-iteration-failure` | Treat failed attempts as cheap recorded iterations; fix and rerun without ceremony. |
| `rc4` | `decision-grade-verification` | Verify what the pending decision or daily use depends on, not exhaustive coverage. |
| `rc5` | `defer-publication-rigor` | Defer journal-grade protocol until the audience actually becomes external. |

## Daily Developer Principles

The comparisons below are original teaching examples. They illustrate judgment rather than mandatory features, test counts, or implementation layouts; learn their intent and semantics rather than hardcoding the example content.

### rc1 — useful-outcome-first

Calibrate rigor to producing a result the developer can act on.

**Underdone:** The work is too sloppy to trust its own output, so the result cannot support the decision it was produced for.

**Overdone:** Verification, documentation, or packaging effort is aimed at anonymous reviewers while the developer's own decision waits.

**Preferred rigor:** Make the result reliable enough for the developer's own repeated use and next decision; stop when additional effort primarily serves an external audience.

> **Example.** A developer compares two attention-kernel configurations on their own workload to pick one for this week's experiments.
>
> **Don't (underdone):** Run each configuration once, one with a warm cache and one cold, and keep whichever number looks better.
>
> **Don't (overdone):** Require significance tests across thirty seeds, confidence intervals, and a written methodology section before daring to pick a configuration.
>
> **Do:** Warm up both configurations, repeat a few measured trials, confirm the difference is stable and larger than run-to-run noise, record the configuration and numbers, and pick one.

**Judgment:** Useful means the developer can defend the result to themselves next week, not to a program committee. The decision the work supports defines how much rigor is enough. Explicit task requirements remain authoritative.

### rc2 — logic-scoped-evidence-refresh

Calibrate evidence refresh to changes that can materially affect each claim, judged from code logic.

**Underdone:** Old numbers keep being cited after the measured path changed, with no re-run and no record that anything changed.

**Overdone:** Any artifact change invalidates all evidence, even when the change cannot affect the claim; a harness refuses to run because a comment or a log line altered a source hash.

**Preferred rigor:** Stamp each result with the code version or hash at run time. When code changes, reason from the diff about which claims it can materially affect, re-run the affected evidence, reuse the unaffected evidence, and disclose the evaluated scope.

> **Example.** An internal experiment harness runs latency requests against an inference scheduler. The team must decide how request identity and code version interact.
>
> **Don't (underdone):** After editing the scheduler's batching logic, keep quoting last week's latency table as if nothing changed.
>
> **Don't (overdone):** Hash every source file into each request's definition and refuse to run when any hash moves, so changing one print statement invalidates every recorded request and forces a full re-run of the experiment series.
>
> **Do:** Keep requests as data independent of code version, stamp each run's results with the code version, and judge from the code change itself what it can affect. A print-only change does not affect latency, so prior numbers stand; a batching-logic change does, so the latency runs are repeated.

**Judgment:** A version stamp identifies what was measured; it is not an automatic invalidation policy. Performance numbers usually depend on the executed code path, workload, configuration, and hardware. Comments, log lines, and unrelated files affect none of these, and reading the diff is sufficient to tell the difference for daily work.

### rc3 — cheap-iteration-failure

Calibrate failure handling during bring-up to cheap, recorded iteration.

**Underdone:** Failures leave no record, so the same bug is rediscovered or nobody can tell which run produced which number.

**Overdone:** Each failed attempt consumes a scarce allowance and requires an approval ceremony before the same attempt may be retried, even during ordinary bring-up.

**Preferred rigor:** Record each failed attempt briefly — what ran, its code stamp, and why it failed — then fix and rerun the same request or test data freely. Reserve strict retry accounting for final reported measurements.

> **Example.** A developer brings up a new inference execution path. The first full-model request crashes in cleanup code after a successful prefill.
>
> **Don't (underdone):** Retry in a loop with logs overwritten each time, so three days later nobody remembers whether the crash happened before or after the fix.
>
> **Don't (overdone):** Treat the crashed request as permanently consumed, regenerate every request definition against the repaired code, and require an explicit budget amendment before one retry is permitted.
>
> **Do:** Keep the failure record with its code stamp, fix the bug, rerun the same request data, and note the failed attempt in the results.

**Judgment:** During iteration, a failure is information, not expenditure. Retry accounting and frozen-revision enforcement protect the comparability of final reported numbers; applying them to everyday debugging makes progress wait on ceremony. Escalate to strict accounting when the measurement itself becomes the deliverable.

### rc4 — decision-grade-verification

Calibrate verification depth to what the pending decision or daily use depends on.

**Underdone:** “It ran once” is accepted when a wrong result would mislead the decision or break daily use.

**Overdone:** Exhaustive test matrices, full-coverage gates, or formal verification are required for internal tooling and exploratory code.

**Preferred rigor:** Test the cases whose failure would change the decision or break daily use, cover the boundaries that actually occur, and skip coverage that only a reviewer would demand.

> **Example.** A developer refactors the aggregation script that summarizes benchmark trials into the table the team reads.
>
> **Don't (underdone):** Eyeball one output row while the aggregation silently drops failed trials from the averages.
>
> **Don't (overdone):** Require property-based tests over the full input space and complete branch coverage for a personal analysis script.
>
> **Do:** Check the aggregation on a small case with known answers, run it on the real dataset, and sanity-check the headline numbers against expectation.

**Judgment:** The decision at stake sets the verification bar. Code whose output feeds a result people quote deserves checks on exactly the logic that could corrupt that output; scaffolding around it does not. Revisit the bar when the audience or the stakes change.

### rc5 — defer-publication-rigor

Stop at daily-useful assurance instead of importing journal-grade protocol.

**Underdone:** “It is just internal” is used to skip the evidence, iteration records, or verification that the developer's own decisions depend on.

**Overdone:** Pre-registered hypotheses, frozen-protocol approval loops, reviewer-style writeups, or re-run-everything invalidation gates become defaults for everyday comparisons.

**Preferred rigor:** Satisfy the daily-developer rules for the internal audience, and adopt stronger protocol when results will be published, released, or audited. Say so when a daily-grade conclusion is used where stronger assurance is due.

> **Example.** A team shares benchmark notes in its chat channel; months later one comparison is considered for a paper figure.
>
> **Don't (underdone):** Skip recording which model revision produced the speedup that the team now quotes from memory.
>
> **Don't (overdone):** Require a frozen, hash-bound experiment protocol with amendment approvals before anyone may compare two branches on a Tuesday afternoon.
>
> **Do:** Keep decision-grade notes with code stamps for internal comparisons, and re-run the specific comparison under a strict protocol when it becomes a paper claim or a release gate.

**Judgment:** This rule excludes extra rigor for a different assurance target; it does not override explicit task requirements. Work needed for useful outcomes, logic-scoped evidence, cheap iteration, or decision-grade verification remains governed by `rc1`–`rc4`.

## Applicability

Apply selected rules when deciding implementation robustness, verification depth, evidence validity, retry policy, and completion criteria for everyday development and internal experiments. They define a bounded rigor level and do not grant authority to change the requested work or ignore higher-priority requirements. When publication, release, compliance, or audit review applies, that stronger target governs instead.
