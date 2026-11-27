# Write Weekly Report

## Workflow

When this subcommand is invoked, execute the following steps in order.

1. **Resolve the reporting period**. Fix the inclusive date range and timezone, honoring the project contract's week convention or defaulting to the ISO Monday–Sunday week. See **Period Boundary**.
2. **Load the project report contract**. Re-read the project's reporting instructions for filename, title, language, section order, and terminology. See [Project Report Contract](../references/project-report-contract.md).
3. **Gather period evidence**. Read all daily reports in the period, check Git and authoritative run/validation records for gaps or newer commits (including relevant external checkouts), and check the previous period's report to avoid restating settled background. See **Period Evidence**.
4. **Rank by project goal and align focus**. When the period covers many features or substantial upstream/dependency changes, rank what was added and what was verified live by importance to this project's core goal and offer the ranked list for the user to pick the focus—unless the user already chose the topics or asked for a direct draft. See **Goal-Ranked Focus Selection**.
5. **Apply the reporting mentality and write**. Remember the nine principles in [Reporting Principles](../references/reporting-principles.md) (`r1`–`r9`), reconcile superseded daily conclusions to their latest supported state, and synthesize directly by outcome rather than by day.
6. **Deliver or save**. Follow the parent skill's **Output Contract** and state the written path when saved.

If the period spans unusual milestones, cross-repo workstreams, or stakeholder constraints, use the native planning tool to plan evidence reconciliation and focus selection within these principles, then execute the plan.

## Period Boundary

Default to an ISO week (Monday through Sunday) and state the exact covered dates (and cutoff date if the week is still in progress). When an existing weekly series establishes a convention, advance cleanly from the previous period without gaps or overlaps, and use the project's own week numbering when declared.

## Period Evidence

Treat daily reports as a starting map, not final proof:

1. Read every daily report inside the period.
2. Inspect Git history, uncommitted/untracked changes, and relevant external or nested checkouts for work after the last daily report (confirming external checkouts are synced through the cutoff when authorized).
3. Verify major claims against stronger records—live qualification reports, benchmark measurements, release tags, and archived decisions—when available.
4. Skim the previous weekly report so already-settled context is not presented as new progress.

## Goal-Ranked Focus Selection

A busy week often mixes breakthroughs directly advancing this project's goal with routine dependency updates or internal cleanups. Before writing a broad weekly report where priorities are not yet fixed:

- Separate **what was added** from **what was verified live** (distinguishing real end-to-end runs from mock checks and unrun drafts).
- Rank candidates by how directly they advance **this project's stated goal**, not by commit count or chronological recency.
- Present the ranked list concisely when the user is open to scoping, so they can pick the exact themes to spotlight and which background items to compress or drop. Skip this pause when the user asks to draft directly.

## Guardrails

- DO NOT build a weekly report by concatenating or lightly paraphrasing the period's daily reports.
- DO NOT carry forward an earlier daily conclusion that was fixed, replaced, or overturned later in the week without reconciling it to the latest supported state.
- DO NOT give routine upstream maintenance the same prominence as work directly advancing the project's goal.
