# Review Decision Exploration Mode

Use `review-decision` when the user's prompt asks to review, validate, or audit existing project decisions. Check for logical consistency, conflicts with current code/docs/tests, stale assumptions, missing trade-offs, and implementation drift. Ask 1-5 highly targeted clarification questions unless the user explicitly requested a non-interactive audit, explicitly asked the agent to make reasonable assumptions, or provided all required decisions in the prompt.

## Workflow

When `review-decision` mode is selected, execute the following steps in order. Detailed rules for each step are in the sections referenced below.

1. **Perform a Pre-Exploration Scan**. Gather existing decision artifacts and current evidence from the repo. See **Pre-Exploration Scan**.
2. **Run a Coverage Scan**. Mark each category as Clear / Partial / Missing. See **Coverage Scan**.
3. **Enter the adaptive questioning loop**. Prepare to ask up to 5 questions, generating each one from the current coverage map. See **Question Constraints**.
4. **Execute the Sequential Questioning Loop**. Present exactly one question at a time. See **Sequential Questioning Loop** for question formats and handling rules.
5. **After each answer, integrate**. Note drift resolution, update ADRs, and maintain consistency across documents. See **Integration After Each Answer**.
6. **When complete, produce a Completion Report**. Summarize consistent decisions, drift detected, stale assumptions, and next actions. See **Completion Report**.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan based on the constraints above and the user's specific goal, then execute the plan.

## When to Use

- The prompt asks to "review ADRs", "audit decisions", "check for drift", or "validate architecture".
- The user suspects a documented decision no longer matches the codebase.
- A planned change may conflict with an existing architectural boundary or constraint.

## Pre-Exploration Scan

Before asking any user-facing question, inspect the repo for:

- **Decision artifacts**: `<output-dir>/adrs/`, `<output-dir>/domain-concepts/`, `<output-dir>/design-choice/`, architecture docs, design docs, decision sections in specs, inline code comments recording intent.
- **Current evidence**: code, tests, schemas, configs, routes, UI behavior, deployment manifests.
- **Product constraints**: `README.md`, `AGENTS.md`, compliance or partner contract references.

Cite file paths and line numbers when reporting evidence.

## Coverage Scan

Perform a structured ambiguity & coverage scan across this taxonomy. For each category, mark status: **Clear** / **Partial** / **Missing**. Produce an internal coverage map (do not output the raw map unless no questions will be asked).

| Category | What to Check |
| --- | --- |
| **Decision inventory** | What ADRs, architecture notes, and spec decision sections exist? Are any missing that should exist? |
| **Logical consistency** | Does each decision still make sense given current project goals? |
| **Cross-decision conflicts** | Do any two decisions contradict each other? |
| **Code drift** | Does the decision conflict with current code behavior? |
| **Test drift** | Do tests enforce behavior that violates the decision? |
| **Documentation drift** | Do README or API docs describe behavior the decision forbids? |
| **Stale assumptions** | Are the dependencies, scale, team size, or compliance assumptions still true? |
| **Missing trade-offs** | Were genuine alternatives evaluated? Are there new trade-offs not captured? |
| **Reversal cost** | Is the cost of reversing the decision meaningful? If not, did it need an ADR? |
| **Impact of change** | What code, tests, or docs would need to change if the decision is updated? |

For each category with **Partial** or **Missing** status, add a candidate question opportunity unless:
- The ambiguity is low-impact and does not affect correctness or maintainability
- The issue is purely cosmetic (formatting, wording) rather than substance

## Question Constraints

- Ask at least 1 question before updating, deprecating, reaffirming, or producing a final proposed direction about a decision, unless the user explicitly requested a non-interactive audit, explicitly asked the agent to make reasonable assumptions, or provided all required decisions in the prompt.
- **Maximum 5 total questions** across the whole session. Generate each question one at a time; do not build a fixed queue of 5 questions in advance.
- Each question must be answerable with **either**:
  - A short multiple-choice selection (2–5 distinct, mutually exclusive options), **or**
  - A short-phrase answer. The agent's proposed answer should be concise, but the user may provide a custom answer of any length.
- Only include questions whose answers materially impact whether a decision should be updated, deprecated, or re-affirmed, or what code/docs changes are required.
- Ensure category coverage balance: attempt to cover the highest impact unresolved categories first; avoid asking two low-impact questions when a single high-impact area (e.g., a security or data-ownership decision) is unresolved.
- Exclude questions already answered by repo evidence or plan-level execution details (unless blocking correctness).
- Favor clarifications that reduce risk of building on top of a stale or contradictory decision.
- If more than 5 categories remain unresolved, select the top 5 by (Impact × Uncertainty) heuristic.
- Do not reveal future questions in advance. Because each question is generated after the previous answer is integrated, there is no fixed queue to reveal.

## Sequential Questioning Loop

Present **exactly one question at a time**.

### For Multiple-Choice Questions

Before presenting the options, provide:

1. **Motivation** — state the question clearly and explain why the answer materially impacts whether a decision should be updated, deprecated, or re-affirmed, or what code/docs changes are required.
2. **Example** — give a concrete, hypothesized scenario drawn from the project context that shows how each option would play out in practice (e.g., a future PR that violates the current ADR, or a test that enforces drifted behavior).

Then analyze all options and determine the **proposed option** based on:

- Best practices for the project type
- Current codebase evidence (what the code actually does)
- Risk reduction (security, performance, maintainability)
- Alignment with any explicit project goals or constraints

Present your **proposed option** prominently at the top with:
- The proposal itself.
- **Why it is proposed** (1–2 sentences).
- **Implication** — what happens downstream if this option is chosen (e.g., which ADRs to update, which code to amend, which tests to change).

Format as:

```
**Proposed:** Option [X] - <why proposed>

**Implication:** <downstream consequence>
```

Then render all options as a Markdown table that includes a **Pros/Cons** column:

| Option | Description | Pros/Cons |
| --- | --- | --- |
| A | ... | Pros: ... Cons: ... |
| B | ... | Pros: ... Cons: ... |
| C | ... | Pros: ... Cons: ... |
| Short | Provide a different answer (any length) | — |

After the table, add:

```
You can reply with the option letter (e.g., "A"), accept the proposal by saying "yes" or "proposed", or provide your own answer.
```

### For Short-Answer Questions

Before presenting the proposed answer, provide:

1. **Motivation** — state the question clearly and explain why the answer materially impacts whether a decision should be updated, deprecated, or re-affirmed, or what code/docs changes are required.
2. **Example** — give a concrete, hypothesized scenario drawn from the project context that shows why the answer matters.

Then provide your **proposed answer** with:
- The proposal itself.
- **Brief reasoning**.
- **Implication** — what happens downstream if this answer is chosen.

Format as:

```
**Proposed:** <your proposed answer> - <brief reasoning>

**Implication:** <downstream consequence>
```

Then output:

```
Format: Short answer. You can accept the proposal by saying "yes" or "proposed", or provide your own answer.
```

### After the User Answers

- If the user replies with "yes", "recommended", "suggested", or "proposed", use your previously stated proposal as the answer.
- Otherwise, validate the answer maps to one option or is a valid custom answer.
- If ambiguous, ask for a quick disambiguation (this still counts as the same question; do not advance the counter).
- Once satisfactory, record it in working memory, update the exploration state and coverage map, and decide whether another question is needed.
- If another question is needed and fewer than 5 have been asked, generate the next single question from the updated coverage map.

**Stop asking** when:
- No further material ambiguity remains that is worth asking about, **or**
- The user signals completion ("done", "good", "no more", "stop", "proceed"), **or**
- You reach 5 asked questions.

Do not use "no valid questions exist" as a reason to skip the first user interaction. If the prompt appears complete, ask the user to confirm the proposed decision-review outcome and proceed only after the answer, unless the user explicitly requested a non-interactive audit, explicitly asked the agent to make reasonable assumptions, or provided all required decisions in the prompt.

## Integration After Each Answer

- Maintain an in-memory representation of the decision review state plus the raw evidence set.
- Load `references/ADR-FORMAT.md` before creating or updating any ADR.
- After each accepted answer, apply the clarification:
  - If the answer resolves a drift, note whether to update the ADR, amend code to match, deprecate the decision, or document the drift as accepted.
  - If the answer invalidates an earlier ambiguous statement, replace that statement instead of duplicating; leave no obsolete contradictory text.
  - Update durable artifacts only after the inconsistency has a resolved answer. After updating an ADR, scan all other documents under `<output-dir>/` for references to the same decision. Update affected domain-concepts and design-choice docs to restore consistency.
  - When working with an OpenSpec change, also scan the OpenSpec change artifacts (`proposal.md`, `design.md`, `tasks.md`, and specs under `specs/`) for references to the same decisions. Update the relevant OpenSpec documents or flag the inconsistency to the user.
- Do not write new ADRs during review unless the user explicitly requests one and the decision meets the three criteria from `ADR-FORMAT.md`.

## Completion Report

When the exploration is complete or paused, summarize:

- **Questions asked & answered**: count.
- **Consistent decisions**: decisions that remain valid.
- **Drift detected**: decisions that conflict with code, tests, or docs; include file references.
- **Stale assumptions**: assumptions no longer true.
- **Open questions**: only unresolved blockers.
- **Evidence**: most important docs/code references.
- **Coverage summary**: for each taxonomy category, state Resolved / Deferred / Clear / Outstanding.
- **Suggested next action**: update ADRs, amend code, create deprecation notes, handoff to [design-choice](design-choice.md), or proceed to implementation planning.
