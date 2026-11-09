# Write a Weekly Report

## Workflow

When this subcommand is invoked, execute the following steps in order.

1. **Resolve the reporting period**. Identify the week and its inclusive start and end dates. See **Period Boundary**.
2. **Load the project report contract**. Resolve naming, title form, body language, sections, and style from the project's own reporting instructions, or record that none exists. See [Project Report Contract](../references/project-report-contract.md).
3. **Collect period evidence**. Read the period's own daily reports first, then Git, project records, build output, and validation results for work they missed. See **Period Evidence**.
4. **Build a period outcome ledger**. Record each candidate outcome with its evidence, delivery state, verification, and uncertainty, merging items that support one outcome.
5. **Reconcile**. Keep the newest supported conclusion, retain a superseded measurement only with its conditions, and drop repeated background.
6. **Synthesize by outcome**. Apply the shape the contract selects, or the compact form when it selects none, and group by the period's outcomes rather than by day. See **Synthesis**.
7. **Draft and validate**. Follow the parent skill's claim rules, then check that no section reproduces the daily sequence and that every number carries a condition.
8. **Deliver**. Follow the parent skill's **Output Contract**, then state the written path and any material evidence gap.

If the requested period, evidence sources, or audience do not map cleanly to these steps, use the native planning tool to build a bounded reporting plan from this workflow and the user's scope, then execute the plan.

## Period Boundary

Default to an ISO week, Monday through Sunday, and name the range explicitly in the report. A project contract overrides the boundary convention, including when the reported span is shorter than the calendar week.

Derive the range from the newest existing period artifact whenever one exists: advance to the next boundary of the project's convention rather than to the calendar day after the last reported day. For a Monday-to-Friday reporting week, that is the following Monday, not the intervening Saturday. Consecutive reports must neither overlap nor leave an unreported gap inside the convention.

Prefer the project's own week indexing over a calendar library's week number, because months, quarters, and release cycles do not follow ISO weeks.

## Period Evidence

Use the period's own reports as primary evidence and everything else as a gap check:

1. Daily reports inside the period, including ones the user did not mention.
2. Git history, staged and unstaged changes, and untracked work inside the boundary.
3. Project records that establish delivery or validation: run records, test results, build output, approvals, and archived decisions.
4. The previous period's report, to avoid restating settled context as new work.

A daily report proves that work was reported, not that it was verified. Confirm each claim against the stronger record where one exists.

## Synthesis

- Group by the period's outcomes. One outcome may span several days and several artifacts; split one day's work across outcomes when it did.
- Write one background section for the period. Do not repeat each day's motivation.
- Keep the period's most decision-relevant conclusions in the summary, and keep the body able to support every one of them.
- Report a conclusion that changed during the period at its latest supported state, and keep the earlier value only when the change itself matters.
- Preserve failures, blocked attempts, and unresolved differences when they change what the reader should decide.
- Leave single-day detail out unless it carries the evidence for a period-level conclusion.

## Output

Follow the contract's filename and title patterns. Without a contract, write `<project-dir>/tmp/daylog/<YYYY>-W<ww>.md` using the ISO week of the period's start, and keep the title as a plain date range.

## Completion Check

- The period's start and end dates appear in the title and match the resolved boundary.
- Every daily report in the period was read or explicitly excluded with a reason.
- No section reproduces the daily reports' order or repeats their background.
- Every number keeps its baseline, unit, conditions, and uncertainty.
- Superseded conclusions are either removed or retained with their conditions.
- All future work sits in the closing section.

## Guardrails

- DO NOT build the report by concatenating the period's daily reports.
- DO NOT present a daily conclusion as a period conclusion without checking later evidence.
