# Propose Gates

Use this subcommand to propose verification gate candidates for a feature in chat without writing any files. Persistence happens after the user confirms or selects candidates, or explicitly delegates the selection decision to the agent; persistence always goes through the `design-gates` subcommand.

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the feature design directory** and read `README.md`, `feature-requirement.md`, relevant `usecases/uc-*.md`, `design/` docs, and any existing `gates/*.md` files.
2. **Check predecessor artifacts**. `feature-requirement.md` must exist with substantive content. If it is missing or still a scaffold placeholder, refuse to propose and tell the user to run `define-feature` first.
3. **Gather feature context** following the context-gathering rules in `commands/design-gates.md`: the request, prior conversation, referenced files, nearby feature docs, existing gates, design docs, and host-project evidence.
4. **Determine the proposal count**. Use the count the user stated, such as "propose 3 gates". When no count is given, propose one candidate per uncovered coverage-scan category or state the count you chose and why.
5. **Run the coverage scan** defined in `commands/design-gates.md` to find uncovered risk categories and gaps in the existing ladder. Keep the raw scan internal unless it identifies a blocker that needs user input.
6. **Draft the candidates** following **Candidate Drafting**. Apply the matching rule from `commands/design-gates.md` so candidates do not duplicate existing gates.
7. **Present the proposal summary** in chat following **Proposal Summary Format**, then pause. Write no files and change no indexes before the user confirms or delegates the decision.
8. **Hand off after confirmation or delegation**. When the user confirms all candidates, picks a subset, or explicitly delegates the selection decision, run `design-gates` in create mode for the selected candidates, carrying over the drafted content. See **Confirmation And Handoff**.

If the task does not map cleanly to these steps, build a concise step-by-step plan from this procedure and execute only the next appropriate proposal stage.

## Candidate Drafting

- Give each candidate a working title in `<kebab-title>` form without assigning a ladder number or gate ID; numbering and IDs are assigned at persistence time.
- Ground every candidate in the feature requirement, an uncovered coverage-scan category, or host-project evidence. Reject candidates that restate existing gates with new wording.
- Keep candidates distinct from each other: different risk categories, verdicts, or cadence tiers.
- State where each candidate sits in the cheap-to-expensive ladder relative to existing gates and other candidates.
- Draft enough substance for the user to judge each candidate: purpose, the risk it stops, expected outcome as observable pass-condition sketches, proposed cadence, and ladder position. Do not draft the full gate format; that is the persistence stage's job.
- Flag terminology conflicts and assumptions inline next to the affected candidate.

## Proposal Summary Format

Present the candidates as one numbered list the user can select from by number, ordered by ladder position:

```markdown
## Proposed Gates

1. **<Working title>** — <one-sentence purpose>. <Two to four sentences: the risk it stops, expected outcome sketch, proposed cadence, ladder position, and the coverage gap or requirement it addresses.>
2. ...
```

After the list, state the assumptions made, the candidates' relationship to existing gates, and the selection instruction: reply with the numbers to persist, `all`, or revisions to apply first. Do not write files at this point unless the user has delegated the decision.

## Confirmation And Handoff

- Waiting for confirmation is the default, not a mandate. Treat an explicit confirmation, a numbered selection, or `all` as the approval signal. Treat questions, tentative suggestions, and unrelated conversation as no decision; keep waiting.
- When the user explicitly delegates the decision, with wording such as "decide on your own", "use your judgment", or "just persist them", skip the pause: select the candidates yourself, defaulting to all proposed candidates, state the selection you made and why, then hand off directly.
- For the approved candidates, invoke `design-gates` in create mode with the drafted content as context, so it assigns ladder numbers and gate IDs, writes `gates/NN-<kebab-title>.md`, updates the feature `README.md` gate index, and runs its self-review.
- When the user asks for revisions before persisting, revise the affected candidates in chat and present the updated summary again before any handoff.

## Completion Report

When paused or complete, summarize:

- Candidates proposed, with working titles and ladder positions.
- Coverage gaps or requirements that motivated each candidate.
- Assumptions made and terminology conflicts flagged.
- The approval signal received: confirmation, selection, or delegation; or that the proposal is waiting for selection.
- Candidates handed off to `design-gates`, with their persisted gate IDs once written.

## Guardrails

- DO NOT create, update, or delete any file in the feature design directory before the user confirms or selects candidates, or explicitly delegates the selection decision to the agent.
- DO NOT update the feature `README.md` gate index or any other index during the proposal stage.
- DO NOT persist candidates directly; persistence always goes through `design-gates` so numbering, gate IDs, format, and self-review stay in one place.
- DO NOT propose candidates that duplicate the title, risk category, or expected results of an existing gate; refine the existing one instead.
- DO NOT treat activation, questions, or tentative suggestions as approval or delegation.
