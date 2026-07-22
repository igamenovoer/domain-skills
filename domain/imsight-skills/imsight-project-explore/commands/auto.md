# Auto Exploration Mode

Use `auto` as the default when the user does not explicitly request a focused mode. The agent inspects the prompt and early repo evidence, chooses the most relevant exploration type, states that routing choice, and then asks the first decision-bearing question inside the selected exploration path.

## Workflow

When `auto` mode is selected, execute the following steps in order. Detailed rules for each step are in the sections referenced below.

1. **Perform a Pre-Exploration Scan**. Spend ~2 minutes gathering evidence from the repo. See **Pre-Exploration Scan** for the ordered checklist.
2. **Run a Coverage Scan**. Mark each category as Clear / Partial / Missing. See **Coverage Scan** for the internal-map rule.
3. **Choose the exploration type**. Based on the scan, select the most relevant mode or topic and state the routing choice to the user. This routing choice does not require user confirmation.
4. **Choose the questioning mode**. Inspect the user's prompt for batch-mode phrases such as "list all at once", "batch mode", "show all options", or "let me pick which ones to change". If any such phrase is present, set `mode = batch`; otherwise set `mode = sequential`. See **Batch Mode** for batch behavior and **Sequential Questioning Loop** for sequential behavior.
5. **Generate or ask questions**. If `mode = sequential`, enter the adaptive questioning loop and generate one question at a time. If `mode = batch`, generate the full batch question set. Prepare up to 5 questions from the current coverage map. See **Question Constraints**.
6. **Present questions**. If `mode = sequential`, execute the **Sequential Questioning Loop**. If `mode = batch`, present the **Batch Mode** list.
7. **After each answer, integrate**. Update the coverage map, decide whether another question is needed, generate the next single question from the updated map if so, and pivot to a focused mode if the answer reveals one is needed. See **Integration After Each Answer**. For batch responses, see **Batch Response Integration**.
8. **When complete, produce a Completion Report**. Summarize what was explored, what remains open, and what to do next. See **Completion Report**.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan based on the constraints above and the user's specific goal, then execute the plan.

## When to Use

- The user asks a broad question such as "explore this project" or "what should we build?"
- The prompt mixes scope, terminology, and decision concerns without naming a mode.
- The prompt asks for open questions, unresolved decisions, or gaps but does not explicitly name `any-open-question`.
- You need to discover which focused mode is most relevant before committing to it.

## Pre-Exploration Scan

Before asking any user-facing question, perform a 2-minute repo scan. Load evidence in this order:

1. **Previous exploration**: `<output-dir>/domain-concepts/`, `<output-dir>/adrs/`, `<output-dir>/design-choice/`, `<output-dir>/designs/`, `<output-dir>/use-cases/`. Load any relevant prior artifacts and incorporate them into your evidence set.
2. **Project guidance**: `AGENTS.md`, `CLAUDE.md`, `.agents/`, `.cursor/`, `.github/copilot-instructions.md`
3. **Product/spec material**: `README.md`, `docs/`, `specs/`, `features/`, issue or PRD files, roadmap notes
4. **Domain memory**: `CONTEXT.md`, architecture docs, design docs
5. **Behavior surfaces**: routes, controllers, API schemas, UI pages, CLI commands, migrations, test names, fixtures

Cite file paths and line numbers when reporting evidence.

## Coverage Scan

Perform a structured scan across these categories. For each, mark status: **Clear** / **Partial** / **Missing**. Produce an internal coverage map. Do not output the raw map to the user unless no questions will be asked. If questions remain, output only the first question with its proposed option.

| Category | What to Check |
| --- | --- |
| **Request type** | Is this a new feature, refactor, bug fix, spec clarification, or terminology fix? |
| **Evidence sufficiency** | Does the repo already answer parts of the request? Which parts are missing? |
| **Primary concern** | Does the prompt lean toward scope, terminology, or existing decision review? |
| **Blockers** | What is the smallest unresolved item that prevents choosing a focused mode? |
| **Drift signals** | Are there contradictions between docs, code, tests, or the user's language? |
| **Open-question signals** | Does the request first need an inventory of unresolved questions before a focused mode can be selected? |
| **Use-case signals** | Does the prompt ask about actors, scenarios, user stories, or workflows that should be documented as use cases? |

## Question Constraints

- Ask at least 1 question after choosing the exploration type and before making any substantive project decision, writing artifacts, or producing a final proposed direction, unless the user explicitly requested a non-interactive audit, explicitly asked the agent to make reasonable assumptions, or provided all required decisions in the prompt.
- **Maximum 5 total questions** across the whole session. Generate each question one at a time; do not build a fixed queue of 5 questions in advance.
- Each question must be answerable with **either**:
  - A short multiple-choice selection (2–5 distinct, mutually exclusive options), **or**
  - A short-phrase answer. The agent's proposed answer should be concise, but the user may provide a custom answer of any length.
- Only ask questions whose answers materially impact project scope, terminology, decision status, what to explore first within the selected type, or whether the request is actionable.
- If more than 5 candidate questions remain, select the top 5 by (Impact × Uncertainty) heuristic.
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
Here are the open questions:
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

1. **Motivation** — state the question clearly and explain why the answer materially impacts the exploration (e.g., which mode to enter, what to explore first, or whether the request is actionable).
2. **Example** — give a concrete, hypothesized scenario drawn from the project context that shows how each option would play out in practice.

Then analyze all options and determine the **proposed option** based on:

- Best practices for the project type
- Common patterns in similar implementations
- Risk reduction (security, performance, maintainability)
- Alignment with any explicit project goals or constraints visible in the evidence

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

1. **Motivation** — state the question clearly and explain why the answer materially impacts the exploration.
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
- The user signals completion ("done", "good", "no more"), **or**
- You reach 5 asked questions.

Do not use "no valid questions exist" as a reason to skip the first user interaction. If the prompt appears complete, state the selected exploration type and ask the user to confirm the first substantive project assumption before proceeding, unless the user explicitly requested a non-interactive audit, explicitly asked the agent to make reasonable assumptions, or provided all required decisions in the prompt.

## Integration After Each Answer

- Maintain an in-memory exploration state plus the raw evidence set.
- After each accepted answer, update the coverage map, decide whether another question is needed, and generate the next single question from the updated map if so and fewer than 5 have been asked.
- If the answer redirects the request toward a different focused mode (`any-open-question`, `design-choice`, `domain-language`, `review-decision`, `brainstorm`, or `usecase-design`), state the pivot explicitly and hand off to that mode's page.
- Do not write to disk in `auto` unless the user explicitly requests a written result. If they do, write it to `<output-dir>/design-choice/design-<what>.md`, `<output-dir>/domain-concepts/dc-<what>.md`, `<output-dir>/designs/YYYY-MM-DD-<topic>-design.md`, or `<output-dir>/use-cases/uc-<NN>-<what>.md` depending on the dominant concern, following the output directory discovery contract. If the target directory does not yet contain a `README.md`, create one as an index.
- After writing any artifact, scan all other documents under `<output-dir>/` for references to the same concepts or decisions. Update affected documents to restore consistency.
- When working with an OpenSpec change, also scan the OpenSpec change artifacts for contradictions or extensions, and update or flag them.

## Batch Response Integration

When the user replies to a batch question set:

1. **Parse overrides**. Accept answers keyed by question number (e.g., "Q1 = B", "Q2 = short: ...") or a blanket "accept all" / "yes" / "proposed".
2. **Apply overrides in order** (Q1, Q2, ...). For unmentioned questions, use the proposed default.
3. **Re-evaluate downstream proposals**. If an early override changes a premise used by a later proposed option, flag the conflict and ask the user to confirm or revise the later option. Do not silently accept a now-invalid proposal.
4. **Update the coverage map** with all resolved answers.
5. **Decide whether follow-up questions are needed**. If an override reveals a new ambiguity, treat it as a new question (within the same 5-question cap if possible; otherwise summarize the new ambiguity in the Completion Report).
6. **Write durable artifacts** only after all batch answers have been integrated and conflicts resolved.

## Completion Report

When the exploration is complete or paused, summarize:

- **Questions asked & answered**: count.
- **Selected exploration type**: what mode or topic the agent selected, plus any user redirection.
- **Evidence inspected**: key files and sections.
- **Coverage summary**: for each category, state Resolved / Deferred / Clear / Outstanding.
- **Open questions**: only unresolved blockers.
- **Suggested next action**: spec update, decision review report, ADR update, issue breakdown, implementation plan, or handoff to another mode or Imsight skill.
