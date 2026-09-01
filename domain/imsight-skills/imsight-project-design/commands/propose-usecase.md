# Propose Use Case

Use this subcommand to propose new use case candidates for a feature in chat without writing any files. Persistence happens after the user confirms or selects candidates, or explicitly delegates the selection decision to the agent; persistence always goes through the `design-usecase` subcommand.

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the feature design directory** and read `README.md`, `feature-requirement.md`, `usecases/README.md`, existing `usecases/uc-*.md` files, and relevant `design/` docs. When the feature design directory is inside an OpenSpec change, treat the change's `proposal.md`, `design.md`, `tasks.md`, and `specs/` as the equivalent baseline and read them as well; `feature-requirement.md` may not exist there.
2. **Check predecessor artifacts**. A substantive requirements baseline must exist: `feature-requirement.md`, or, inside an OpenSpec change, the change's own artifacts (`proposal.md`, `design.md`, `tasks.md`, `specs/`). If no substantive baseline exists or it is still a scaffold placeholder, refuse to propose and tell the user to run `define-feature` first.
3. **Gather feature context** following the context-gathering rules in `commands/design-usecase.md`: the request, prior conversation, referenced files, nearby feature docs, existing use cases, design docs, and host-project evidence.
4. **Determine the proposal count**. Use the count the user stated, such as "propose 3 new usecases". When no count is given, propose 3 candidates or state the count you chose and why.
5. **Run the coverage scan** defined in `commands/design-usecase.md` to find uncovered actors, workflows, and exception flows. Keep the raw scan internal unless it identifies a blocker that needs user input.
6. **Draft the candidates** following **Candidate Drafting**. Apply the matching rule from `commands/design-usecase.md` so candidates do not duplicate existing use cases.
7. **Present the proposal summary** in chat following **Proposal Summary Format**, then pause. Write no files and change no indexes before the user confirms or delegates the decision.
8. **Hand off after confirmation or delegation**. When the user confirms all candidates, picks a subset, or explicitly delegates the selection decision, run `design-usecase` in create mode for each selected candidate, carrying over the drafted content. See **Confirmation And Handoff**.

If the task does not map cleanly to these steps, build a concise step-by-step plan from this procedure and execute only the next appropriate proposal stage.

## Candidate Drafting

- Give each candidate a working title in `uc-<kebab-title>` form without assigning a number; numbering happens at persistence time.
- Ground every candidate in the feature requirement, uncovered coverage-scan categories, or host-project evidence. Reject candidates that restate existing use cases with new wording.
- Keep candidates distinct from each other: different actors, goals, triggers, or durable outputs.
- Draft enough substance for the user to judge each candidate: actor goal, situation summary, main flow sketch, and durable outputs. Do not draft the full use case format; that is the persistence stage's job.
- Flag terminology conflicts and assumptions inline next to the affected candidate.

## Proposal Summary Format

Present the candidates as one numbered list the user can select from by number:

```markdown
## Proposed Use Cases

1. **<Working title>** — <one-sentence actor goal>. <Two to four sentences: situation, main flow sketch, durable outputs, and the coverage gap or requirement it addresses.>
2. ...
```

After the list, state the assumptions made, the candidates' relationship to existing use cases, and the selection instruction: reply with the numbers to persist, `all`, or revisions to apply first. Do not write files at this point unless the user has delegated the decision.

## Confirmation And Handoff

- Waiting for confirmation is the default, not a mandate. Treat an explicit confirmation, a numbered selection, or `all` as the approval signal. Treat questions, tentative suggestions, and unrelated conversation as no decision; keep waiting.
- When the user explicitly delegates the decision, with wording such as "decide on your own", "use your judgment", or "just persist them", skip the pause: select the candidates yourself, defaulting to all proposed candidates, state the selection you made and why, then hand off directly.
- For each approved candidate, invoke `design-usecase` in create mode with the drafted content as context, so it assigns the identifier, writes `usecases/uc-<NN>-<kebab-title>.md`, updates `usecases/README.md`, and runs its self-review.
- When the user asks for revisions before persisting, revise the affected candidates in chat and present the updated summary again before any handoff.

## Completion Report

When paused or complete, summarize:

- Candidates proposed, with working titles.
- Coverage gaps or requirements that motivated each candidate.
- Assumptions made and terminology conflicts flagged.
- The approval signal received: confirmation, selection, or delegation; or that the proposal is waiting for selection.
- Candidates handed off to `design-usecase`, with their persisted identifiers once written.

## Guardrails

- DO NOT create, update, or delete any file in the feature design directory before the user confirms or selects candidates, or explicitly delegates the selection decision to the agent.
- DO NOT update `usecases/README.md`, the feature `README.md`, or any other index during the proposal stage.
- DO NOT persist candidates directly; persistence always goes through `design-usecase` so numbering, format, and self-review stay in one place.
- DO NOT propose candidates that duplicate the title, slug, actor goal, or summary of an existing use case; refine the existing one instead.
- DO NOT treat activation, questions, or tentative suggestions as approval or delegation.
