# Brainstorm Ideas Into System Design

Adapted from [obra/superpowers/skills/brainstorming](https://github.com/obra/superpowers/tree/main/skills/brainstorming).

## Overview

Use `brainstorm` when the user has a vague idea, product concept, or feature direction and needs help turning it into a concrete system design. This subskill explores intent, constraints, and alternatives through collaborative dialogue, then produces an approved design document before any implementation work begins.

## Workflow

When `brainstorm` is selected, execute the following steps in order:

1. **Perform a Pre-Exploration Scan**. See **Pre-Exploration Scan**.
2. **Run a Coverage Scan**. See **Coverage Scan**.
3. **Enter the adaptive questioning loop**. Prepare to ask up to 5 clarification questions, generating each one from the current coverage map. See **Question Constraints**.
4. **Execute the Sequential Questioning Loop**. See **Sequential Questioning Loop**.
5. **Propose 2–3 approaches**. See **Proposing Approaches**.
6. **Present the design in sections**. See **Presenting the Design**.
7. **Write the design document**. See **Writing the Design Document**.
8. **Run a Spec Self-Review**. See **Spec Self-Review**.
9. **Gate on user review of the written spec**. See **User Review Gate**.
10. **Produce a Completion Report**. See **Completion Report**.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan based on the constraints above and the user's specific goal, then execute the plan.

## When to Use

- The user describes an idea in broad terms (e.g., "build a dashboard", "add notifications", "rethink the workflow").
- The request mixes product intent, UX concerns, architecture, and scope without a clear design.
- The user explicitly asks to brainstorm, explore possibilities, or design a system.
- `design-choice` feels too narrow because the central challenge is deciding what the system should be, not just choosing a known design option.

## Hard Gate

Do **not** start implementation, invoke an implementation skill, write code, scaffold a project, or take any implementation action until the user has approved the written design document. This applies regardless of perceived simplicity; even a "simple" idea can hide unstated assumptions.

## Pre-Exploration Scan

Before asking any user-facing question, inspect the repo for:

- **Previous exploration**: `<output-dir>/designs/`, `<output-dir>/domain-concepts/`, `<output-dir>/adrs/`, `<output-dir>/design-choice/`. Load any relevant prior artifacts and incorporate them into your evidence set. Do not duplicate or contradict prior exploration without explicitly noting the conflict.
- **Project guidance**: `AGENTS.md`, `CLAUDE.md`, `.agents/`, `.cursor/`, `.github/copilot-instructions.md`.
- **Product/spec material**: `README.md`, `docs/`, `specs/`, `features/`, issue or PRD files, roadmap notes.
- **Domain memory**: `CONTEXT.md`, architecture docs, design docs.
- **Behavior surfaces**: routes, controllers, API schemas, UI pages, CLI commands, migrations, test names, fixtures.
- **Similar existing systems**: How are comparable capabilities built, named, tested, and deployed? What patterns should the new design follow or deliberately depart from?

Cite file paths and line numbers when reporting evidence.

## Coverage Scan

Perform a structured ambiguity & coverage scan across this taxonomy. For each category, mark status: **Clear** / **Partial** / **Missing**. Produce an internal coverage map (do not output the raw map unless no questions will be asked).

| Category | What to Check |
| --- | --- |
| **Purpose & Success Criteria** | Why build this? What user or system outcome must improve? How would we know it succeeded? |
| **Actors & Entry Points** | Who interacts with the system? Through what interfaces (UI, API, CLI, event, batch)? |
| **Functional Scope** | Core capabilities; explicit non-goals; features deferred to later phases |
| **Domain & Data Model** | Key entities, relationships, lifecycle states, identity/uniqueness rules |
| **Architecture & Components** | Major components, boundaries, interfaces, and deployment topology |
| **Data Flow & Interaction** | How data moves between components and actors; synchronous vs. async patterns |
| **Non-Functional Qualities** | Performance, reliability, observability, security, privacy, scalability targets |
| **Integration & Dependencies** | External services, protocols, file formats, failure modes, versioning |
| **Edge Cases & Failure Handling** | Negative paths, retries, conflicts, partial failures, error surfaces |
| **Constraints & Trade-offs** | Technical, organizational, or compliance constraints; rejected alternatives worth remembering |
| **Terminology & Consistency** | Canonical terms; conflicts with existing glossary; overloaded or ambiguous language |
| **Completion Signals** | How to validate the design is correct and complete enough to implement |

For each category with **Partial** or **Missing** status, add a candidate question opportunity unless clarification would not materially change the design or is better deferred to planning.

## Question Constraints

- Ask at least 1 question before proposing approaches, writing the design document, or producing a final proposed direction, unless the user explicitly requested a non-interactive audit, explicitly asked the agent to make reasonable assumptions, or provided all required decisions in the prompt.
- **Maximum 5 total questions** across the whole session. Generate each question one at a time; do not build a fixed queue of 5 questions in advance.
- Each question must be answerable with **either**:
  - A short multiple-choice selection (2–5 distinct, mutually exclusive options), **or**
  - A short-phrase answer. The agent's proposed answer should be concise, but the user may provide a custom answer of any length.
- Only ask questions whose answers materially impact architecture, component boundaries, data modeling, integration choices, UX behavior, operational readiness, or compliance validation.
- Ensure category coverage balance: attempt to cover the highest-impact unresolved categories first.
- Exclude questions already answered by repo evidence, trivial stylistic preferences, or plan-level execution details (unless blocking correctness).
- Do not reveal future questions in advance. Because each question is generated after the previous answer is integrated, there is no fixed queue to reveal.

## Sequential Questioning Loop

Present **exactly one question at a time**.

### For Multiple-Choice Questions

Before presenting the options, provide:

1. **Motivation** — state the question clearly and explain why the answer materially impacts architecture, component boundaries, data modeling, integration choices, UX behavior, operational readiness, or compliance validation.
2. **Example** — give a concrete, hypothesized scenario drawn from the project context that shows how each option would play out in practice.

Then analyze all options and determine the **proposed option** based on:

- Best practices for the project type
- Common patterns in similar implementations
- Risk reduction (security, performance, maintainability)
- Alignment with any explicit project goals or constraints visible in the evidence

Present your **proposed option** prominently at the top with:
- The proposal itself.
- **Why it is proposed** (1–2 sentences).
- **Implication** — what happens downstream if this option is chosen (e.g., which components change, which assumptions hold, which risks are accepted).

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

1. **Motivation** — state the question clearly and explain why the answer materially impacts architecture, component boundaries, data modeling, integration choices, UX behavior, operational readiness, or compliance validation.
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

## Proposing Approaches

After critical ambiguities are resolved, present 2–3 distinct design approaches. Each approach should include:

- **Name** — a short label.
- **Description** — how the system would be structured under this approach.
- **Pros** — what this approach wins on.
- **Cons** — what it costs or risks.
- **Best fit when** — the conditions that make this approach attractive.

Lead with your **recommended approach** and explain why. Tie the recommendation back to repo evidence, project constraints, and the user's stated goals.

If all approaches are essentially equivalent, present 2 approaches that differ on a meaningful dimension (e.g., scope, coupling, operational complexity) rather than inventing artificial distinctions.

## Presenting the Design

Once the user selects or confirms an approach, present the design in sections scaled to complexity:

- **Overview** — what the system does and why.
- **Actors & Entry Points** — who uses it and how.
- **Components & Responsibilities** — major units, each with one clear purpose.
- **Data Model** — key entities and relationships.
- **Data Flow** — how requests, events, or data move through the system.
- **Error Handling & Edge Cases** — failure modes and recovery.
- **Testing Strategy** — what must be validated.
- **Open Questions** — anything still unresolved.

Ask the user to approve each section before moving to the next, or ask for approval of the whole design if it is short. Be ready to return to clarifying questions if a section reveals new ambiguity.

## Writing the Design Document

After the user approves the design, write it to:

```
<output-dir>/designs/YYYY-MM-DD-<topic>-design.md
```

Use `<output-dir>` resolved by the parent skill's **Output Directory Discovery** rules. If the `designs/` directory does not yet contain a `README.md`, create one as an index.

The design document should be a durable, self-contained spec that covers the same sections presented to the user. Use concrete terms, avoid placeholders, and cite relevant repo evidence where it informed the design.

If the user explicitly requests tracked project docs, write to `docs/design/` instead and update `<output-dir>/designs/README.md` to point there.

## Spec Self-Review

After writing the design document, review it with fresh eyes:

1. **Placeholder scan** — fix any "TBD", "TODO", incomplete sections, or vague requirements.
2. **Internal consistency** — ensure architecture matches feature descriptions and no sections contradict each other.
3. **Scope check** — confirm the design is focused enough for a single implementation plan.
4. **Ambiguity check** — rewrite any requirement that could be interpreted two ways.

Fix issues inline. No need to re-review; just fix and move on.

## User Review Gate

After the self-review passes, ask the user to review the written spec before proceeding:

> "Design written to `<path>`. Please review it and let me know if you want any changes before we move to implementation planning."

Wait for the user's response. If they request changes, make them and re-run the spec self-review. Only proceed once the user approves.

Do not transition to implementation until the user explicitly approves the written design.

## Integration After Each Answer

- Maintain an in-memory representation of the exploration state plus the raw evidence set.
- After each accepted answer, apply the clarification to the most appropriate category in the coverage map.
- If the answer resolves a hard-to-reverse decision, involves a real trade-off, or would surprise a future reader, write an ADR immediately to `<output-dir>/adrs/<index>-<what>.md`. Load `references/ADR-FORMAT.md` before creating it. Do not batch ADRs; create them as decisions are made.
- If the answer reveals that `design-choice`, `domain-language`, or `review-decision` is a better fit, state the pivot explicitly and hand off to that mode's page.
- After writing or updating any artifact, scan all other documents under `<output-dir>/` for references to the same concepts, decisions, or terms. Update affected documents to restore consistency.
- When working with an OpenSpec change, also scan the OpenSpec change artifacts (`proposal.md`, `design.md`, `tasks.md`, and specs under `specs/`) for references to the same topics. Update the relevant OpenSpec documents or flag the inconsistency to the user.

## Completion Report

When brainstorming is complete or paused, summarize:

- **Questions asked & answered**: count.
- **Selected approach**: the chosen design direction and why.
- **Design artifact**: path to the written design document.
- **Resolved decisions**: concrete architecture, component, and scope decisions.
- **Open questions**: only unresolved blockers.
- **Evidence**: most important docs/code references.
- **Suggested next action**: implementation planning, additional exploration in another mode, ADR updates, or handoff to another Imsight skill.

Do not start implementation unless the user explicitly asks to switch from exploration to implementation.
