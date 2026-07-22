# Design Choice Exploration Mode

Use `design-choice` when the user's prompt is about a design decision: a feature, user story, behavior change, protocol, convention, architectural pattern, interface contract, or any other choice in a design space. Clarify what is being decided, who it is for, what the chosen direction does, what it explicitly does not do, and how to know the decision is sound. Ask 1-5 highly targeted clarification questions unless the user explicitly requested a non-interactive audit, explicitly asked the agent to make reasonable assumptions, or provided all required decisions in the prompt.

## Workflow

When `design-choice` mode is selected, execute the following steps in order. Detailed rules for each step are in the sections referenced below.

1. **Perform a Pre-Exploration Scan**. Gather repo evidence about similar design decisions, behavior surfaces, product material, and domain memory. See **Pre-Exploration Scan**.
2. **Run a Coverage Scan**. Mark each category as Clear / Partial / Missing. See **Coverage Scan** for the internal-map rule.
3. **Choose the questioning mode**. Inspect the user's prompt for batch-mode phrases such as "list all at once", "batch mode", "show all options", or "let me pick which ones to change". If any such phrase is present, set `mode = batch`; otherwise set `mode = sequential`. See **Batch Mode** for batch behavior and **Sequential Questioning Loop** for sequential behavior.
4. **Generate or ask questions**. If `mode = sequential`, enter the adaptive questioning loop and generate one question at a time. If `mode = batch`, generate the full batch question set. Prepare up to 5 questions from the current coverage map. See **Question Constraints**.
5. **Present questions**. If `mode = sequential`, execute the **Sequential Questioning Loop**. If `mode = batch`, present the **Batch Mode** list. See **Sequential Questioning Loop** and **Batch Mode** for response formats.
6. **After each answer, integrate**. Update choice notes, write ADRs for hard decisions, and update the design-choice doc. See **Integration After Each Answer**. For batch responses, see **Batch Response Integration**.
7. **When complete, produce a Completion Report**. Summarize the decision, resolved behavior, open questions, and next actions. See **Completion Report**.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan based on the constraints above and the user's specific goal, then execute the plan.

## When to Use

- The user describes a new feature, enhancement, or change in behavior.
- The prompt asks for a choice between protocols, formats, conventions, patterns, or interfaces.
- The prompt includes phrases like "support X", "handle Y", "integrate Z", "add a way to...", "should we use A or B", or "what protocol/format/convention should...".
- There is no clear decision criteria, boundary, or acceptance criteria stated.
- The central question is a design-space decision rather than terminology clarification or review of an existing decision.

## Pre-Exploration Scan

Before asking any user-facing question, inspect the repo for:

- **Previous exploration**: `<output-dir>/design-choice/`, `<output-dir>/domain-concepts/`, `<output-dir>/adrs/`. Load any relevant prior artifacts and incorporate them into your evidence set. Do not duplicate or contradict prior exploration without explicitly noting the conflict.
- **Similar existing decisions**: How are comparable features, protocols, conventions, or patterns named, tested, and scoped? What permissions and error patterns do they use?
- **Behavior surfaces**: Routes, controllers, API schemas, UI pages, CLI commands, migrations, test names, fixtures.
- **Product material**: `README.md`, `docs/`, `specs/`, `features/`, issue or PRD files.
- **Domain memory**: `CONTEXT.md`, architecture docs that constrain the decision.

Cite file paths and line numbers when reporting evidence.

## Coverage Scan

Perform a structured ambiguity & coverage scan across this taxonomy. For each category, mark status: **Clear** / **Partial** / **Missing**. Produce an internal coverage map. Do not output the raw map to the user unless no questions will be asked. If questions remain, output only the first question with its proposed option.

| Category | What to Check |
| --- | --- |
| **Decision Type & Design Space** | What kind of choice is being made (feature, protocol, convention, pattern, interface, format)? What are the known alternatives? |
| **Functional Scope & Behavior** | Core user goals & success criteria; explicit out-of-scope declarations; user roles / personas differentiation |
| **Domain & Data Model** | Entities, attributes, relationships; identity & uniqueness rules; lifecycle/state transitions; data volume / scale assumptions |
| **Protocol & Interface Choices** | Wire protocols, API styles, serialization formats, event schemas, version contracts, compatibility guarantees |
| **Conventions & Standards** | Naming, formatting, linting, project conventions, team standards, regulatory or compliance standards that apply |
| **Architecture & Pattern Choices** | Structural patterns, component boundaries, responsibility allocation, coupling/decoupling decisions |
| **Interaction & UX Flow** | Critical user journeys / sequences; error/empty/loading states; accessibility or localization notes |
| **Non-Functional Quality Attributes** | Performance targets; reliability & availability; observability signals; security & privacy posture |
| **Integration & External Dependencies** | External services/APIs and failure modes; data import/export formats; protocol/versioning assumptions |
| **Edge Cases & Failure Handling** | Negative scenarios; rate limiting / throttling; conflict resolution (e.g., concurrent edits) |
| **Constraints & Tradeoffs** | Technical constraints; explicit tradeoffs or rejected alternatives visible in code or docs |
| **Terminology & Consistency** | Canonical glossary terms; avoided synonyms / deprecated terms; conflicts with the existing glossary |
| **Completion Signals** | Acceptance criteria testability; measurable Definition of Done style indicators |
| **Misc / Placeholders** | TODO markers / unresolved decisions; ambiguous adjectives ("robust", "intuitive") lacking quantification |

For each category with **Partial** or **Missing** status, add a candidate question opportunity unless:
- Clarification would not materially change implementation or validation strategy
- Information is better deferred to the planning phase (note internally)

## Question Constraints

- Ask at least 1 question before finalizing the design choice, writing artifacts, or producing a final proposed direction, unless the user explicitly requested a non-interactive audit, explicitly asked the agent to make reasonable assumptions, or provided all required decisions in the prompt.
- **Maximum 5 total questions** across the whole session. Generate each question one at a time; do not build a fixed queue of 5 questions in advance.
- Each question must be answerable with **either**:
  - A short multiple-choice selection (2–5 distinct, mutually exclusive options), **or**
  - A short-phrase answer. The agent's proposed answer should be concise, but the user may provide a custom answer of any length.
- Only include questions whose answers materially impact architecture, data modeling, task decomposition, test design, UX behavior, operational readiness, compliance validation, or choice of protocol/convention/pattern.
- Ensure category coverage balance: attempt to cover the highest impact unresolved categories first; avoid asking two low-impact questions when a single high-impact area (e.g., security posture or protocol choice) is unresolved.
- Exclude questions already answered by repo evidence, trivial stylistic preferences, or plan-level execution details (unless blocking correctness).
- Favor clarifications that reduce downstream rework risk or prevent misaligned acceptance tests.
- If more than 5 categories remain unresolved, select the top 5 by (Impact × Uncertainty) heuristic.
- Do not reveal future questions in advance. Because each question is generated after the previous answer is integrated, there is no fixed queue to reveal.

## Batch Mode

Use **Batch Mode** when the user explicitly asks to see all questions at once with recommended options. Batch mode is opt-in; if the user does not use a batch-mode phrase, use the **Sequential Questioning Loop** instead.

### Generating the Batch Question Set

1. Run the same coverage scan and question selection logic used for sequential mode.
2. Select up to 5 questions using the same (Impact × Uncertainty) heuristic.
3. For each selected question, prepare:
   - A concise **Motivation**.
   - A concrete **Example** scenario.
   - A **Proposed** option.
   - A short **Pros/Cons** table with 2–5 mutually exclusive options.
4. Number each question (Q1, Q2, ...) so the user can refer to them when overriding.

### Batch Response Format

Present all selected questions in one message. Keep each question self-contained. After the last question, add an instruction such as:

```
Reply with the numbers you want to override (e.g., "Q1 = B, Q3 = D"), or say
"accept all" / "yes" to accept every proposed option. If an earlier override
changes a downstream proposal, I will flag it and ask for confirmation.
```

### Batch Mode Example

```
Q1 — Scope default
**Proposed:** Option A — Project-scope default with optional topic override.
**Implication:** Simplifies the happy path but requires explicit narrowing for per-topic behavior.
| Option | Description | Pros/Cons |
| --- | --- | --- |
| A | Project-scope default, topic override | Pros: simpler common case. Cons: topic users must remember to narrow. |
| B | Topic-scope default | Pros: safer for multi-topic projects. Cons: more verbose for project-wide behavior. |
| Short | Provide a different answer | — |

Q2 — Validation source
...
```

## Sequential Questioning Loop

Present **exactly one question at a time**.

### Correct and Incorrect Response Shapes

**Incorrect** — listing all questions at once:

```
Here are the open design questions:
1. Should the feature be Project-scope or Topic-scope?
2. What validation rules apply?
3. Should we store state in the manifest or a separate file?
4. ...
```

This is wrong because it forces the user to answer everything at once, ignores dependencies between answers, and provides no proposed option or trade-offs.

**Correct** — one question with a proposed option:

```
**Proposed:** Option A — Project-scope default with optional topic override.

**Implication:** If we choose this, the skill can assume Project scope unless the user passes `--topic`, which simplifies the happy path but requires explicit narrowing for per-topic behavior.

| Option | Description | Pros/Cons |
| --- | --- | --- |
| A | Project-scope default, topic override | Pros: simpler common case. Cons: topic users must remember to narrow. |
| B | Topic-scope default | Pros: safer for multi-topic projects. Cons: more verbose for project-wide behavior. |
| Short | Provide a different answer | — |

You can reply with the option letter (e.g., "A"), accept the proposal by saying "yes" or "proposed", or provide your own answer.
```

### For Multiple-Choice Questions

Before presenting the options, provide:

1. **Motivation** — state the question clearly and explain why the answer materially impacts architecture, data modeling, task decomposition, test design, UX behavior, operational readiness, compliance validation, or choice of protocol/convention/pattern.
2. **Example** — give a concrete, hypothesized scenario drawn from the project context that shows how each option would play out in practice.

Then analyze all options and determine the **proposed option** based on:

- Best practices for the project type
- Common patterns in similar implementations
- Risk reduction (security, performance, maintainability)
- Alignment with any explicit project goals or constraints visible in the spec

Present your **proposed option** prominently at the top with:
- The proposal itself.
- **Why it is proposed** (1–2 sentences).
- **Implication** — what happens downstream if this option is chosen (e.g., which files change, which assumptions hold, which risks are accepted).

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

1. **Motivation** — state the question clearly and explain why the answer materially impacts architecture, data modeling, task decomposition, test design, UX behavior, operational readiness, compliance validation, or choice of protocol/convention/pattern.
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

Do not use "no valid questions exist" as a reason to skip the first user interaction. If the prompt appears complete, ask the user to confirm the proposed design choice and proceed only after the answer, unless the user explicitly requested a non-interactive audit, explicitly asked the agent to make reasonable assumptions, or provided all required decisions in the prompt.

## Integration After Each Answer

- Maintain an in-memory representation of the exploration state plus the raw evidence set.
- After each accepted answer, apply the clarification to the most appropriate category in the coverage map:
  - Functional ambiguity → Update scope / behavior notes
  - User interaction / actor distinction → Update user roles or entry points
  - Data shape / entities → Update data model notes
  - Protocol / convention / pattern choice → Update design-choice notes and record the selected alternative
  - Non-functional constraint → Add measurable criteria
  - Edge case / negative flow → Add error-handling notes
  - Terminology conflict → Normalize term across notes; if the conflict is durable, also update `<output-dir>/domain-concepts/dc-<what>.md`
- If the clarification invalidates an earlier ambiguous statement, replace that statement instead of duplicating; leave no obsolete contradictory text.
- If an existing spec, issue, PRD, or design doc is the target artifact, update it incrementally after each answer (atomic overwrite). Preserve formatting and heading hierarchy.
- If the answer resolves a decision that is hard to reverse, surprising without context, or involves a real trade-off, write an ADR immediately to `<output-dir>/adrs/<index>-<what>.md`. Load `references/ADR-FORMAT.md` before creating it. Do not batch ADRs; create them as decisions are made.
- If the user asked for a written result or the session is pausing, write the accumulated choice notes to `<output-dir>/design-choice/design-<what>.md`. If the `design-choice/` directory does not yet contain a `README.md`, create one as an index.
- After writing or updating any artifact, scan all other documents under `<output-dir>/` for references to the same concepts, decisions, or terms. Update affected documents to restore consistency.
- When working with an OpenSpec change, also scan the OpenSpec change artifacts (`proposal.md`, `design.md`, `tasks.md`, and specs under `specs/`) for references to the same topics. Update the relevant OpenSpec documents or flag the inconsistency to the user.

## Batch Response Integration

When the user replies to a batch question set:

1. **Parse overrides**. Accept answers keyed by question number (e.g., "Q1 = B", "Q2 = short: ...") or a blanket "accept all" / "yes" / "proposed".
2. **Apply overrides in order** (Q1, Q2, ...). For unmentioned questions, use the proposed default.
3. **Re-evaluate downstream proposals**. If an early override changes a premise used by a later proposed option, flag the conflict and ask the user to confirm or revise the later option. Do not silently accept a now-invalid proposal.
4. **Update the coverage map** with all resolved answers.
5. **Decide whether follow-up questions are needed**. If an override reveals a new ambiguity, treat it as a new question (within the same 5-question cap if possible; otherwise summarize the new ambiguity in the Completion Report).
6. **Write durable artifacts** only after all batch answers have been integrated and conflicts resolved. Write ADRs immediately for hard decisions as they are resolved.

## Completion Report

When the exploration is complete or paused, summarize:

- **Questions asked & answered**: count.
- **Design choice decision**: what was chosen, what is in and out, and what alternatives were rejected.
- **Resolved behavior**: concrete feature/spec/protocol/convention/pattern decisions.
- **Open questions**: only unresolved blockers.
- **Evidence**: most important docs/code references.
- **Coverage summary**: for each taxonomy category, state Resolved / Deferred / Clear / Outstanding.
- **Suggested next action**: spec update, decision review report, ADR update, issue breakdown, implementation plan, or handoff to another Imsight skill.

Prefer a narrow end-to-end slice over broad partial infrastructure. Name the slice in terms of user-visible behavior or the concrete design decision made.
