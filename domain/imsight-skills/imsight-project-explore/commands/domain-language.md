# Domain Language Exploration Mode

Use `domain-language` when the user's prompt involves terminology, naming, or when you detect conflicts between the user's words and the codebase's words. Resolve project-specific terms and write durable definitions to `<output-dir>/domain-concepts/dc-<what>.md`, following the output directory discovery contract. Only update `CONTEXT.md` if the user explicitly says that is their project's glossary. Ask 1-5 highly targeted clarification questions unless the user explicitly requested a non-interactive audit, explicitly asked the agent to make reasonable assumptions, or provided all required decisions in the prompt.

## Workflow

When `domain-language` mode is selected, execute the following steps in order. Detailed rules for each step are in the sections referenced below.

1. **Perform a Pre-Exploration Scan**. Gather repo evidence about existing glossaries, code identifiers, API schemas, UI labels, and test/docs terminology. See **Pre-Exploration Scan**.
2. **Run a Coverage Scan**. Mark each category as Clear / Partial / Missing. See **Coverage Scan**.
3. **Enter the adaptive questioning loop**. Prepare to ask up to 5 questions, generating each one from the current coverage map. See **Question Constraints**.
4. **Execute the Sequential Questioning Loop**. Present exactly one question at a time. See **Sequential Questioning Loop** for question formats and handling rules.
5. **After each answer, integrate**. Update the terminology state and write domain-concepts docs immediately. See **Integration After Each Answer**.
6. **When complete, produce a Completion Report**. Summarize resolved terms, open questions, and next actions. See **Completion Report**.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan based on the constraints above and the user's specific goal, then execute the plan.

## When to Use

- The user uses a term that does not appear in the codebase or appears with a different meaning.
- The prompt asks to "clarify terminology", "define domain language", or "update the glossary".
- You find the same concept named differently in code, tests, docs, and user-facing copy.

## Pre-Exploration Scan

Before asking any user-facing question, inspect the repo for:

- **Previous exploration**: `<output-dir>/domain-concepts/` and `<output-dir>/adrs/`. Load any relevant prior artifacts and incorporate them into your evidence set. Do not duplicate or contradict prior exploration without explicitly noting the conflict.
- **Existing glossary** (such as `CONTEXT.md`): canonical terms and avoided synonyms.
- **Code identifiers**: class names, function names, variable names, database tables/columns.
- **API schemas**: field names, type names, enum values.
- **UI labels**: user-facing copy, button text, headings.
- **Tests and docs**: fixture names, test descriptions, documentation headings.

Use `rg` to map every occurrence of candidate terms. Cite file paths and line numbers when reporting evidence.

## Coverage Scan

Perform a structured ambiguity & coverage scan across this taxonomy. For each category, mark status: **Clear** / **Partial** / **Missing**. Produce an internal coverage map (do not output the raw map unless no questions will be asked).

| Category | What to Check |
| --- | --- |
| **Term inventory** | Which terms in the prompt are project-specific domain words (not generic programming words)? |
| **Usage mapping** | Where does each term appear in code, tests, schemas, UI, and docs? |
| **Synonym detection** | Is one concept named with multiple words (e.g., "customer" vs "account" vs "user")? |
| **Glossary alignment** | Does the user's term conflict with an existing canonical term or _Avoid_ entry (in `CONTEXT.md` or `<output-dir>/domain-concepts/`)? |
| **Code consistency** | Does the codebase use one term inconsistently (e.g., column `status` mapped to enum `State`)? |
| **Expert language** | Which term do domain experts (not programmers) use for this concept? |
| **Definition precision** | Can the term be defined in 1–2 sentences as what the thing is, not every operation on it? |
| **Relationships** | What hierarchical, compositional, or state-transition relationships does this term participate in? |
| **Update scope** | Should this update the glossary, or is it a transient implementation naming concern? |
| **Deprecation** | Are there synonyms that should be explicitly avoided going forward? |

For each category with **Partial** or **Missing** status, add a candidate question opportunity unless:
- The term is generic programming vocabulary (service, controller, handler, manager)
- The conflict is purely implementation-level and better resolved during coding

## Question Constraints

- Ask at least 1 question before finalizing canonical terminology, writing artifacts, or producing a final proposed direction, unless the user explicitly requested a non-interactive audit, explicitly asked the agent to make reasonable assumptions, or provided all required decisions in the prompt.
- **Maximum 5 total questions** across the whole session. Generate each question one at a time; do not build a fixed queue of 5 questions in advance.
- Each question must be answerable with **either**:
  - A short multiple-choice selection (2–5 distinct, mutually exclusive options), **or**
  - A short-phrase answer. The agent's proposed answer should be concise, but the user may provide a custom answer of any length.
- Only include questions whose answers materially impact how the team communicates about the domain, how new code should be named, or whether the glossary needs an update.
- Ensure category coverage balance: attempt to cover the highest impact unresolved categories first.
- Exclude questions already answered by repo evidence or trivial stylistic preferences.
- Favor clarifications that prevent recurring naming conflicts in code reviews.
- If more than 5 categories remain unresolved, select the top 5 by (Impact × Uncertainty) heuristic.
- Do not reveal future questions in advance. Because each question is generated after the previous answer is integrated, there is no fixed queue to reveal.

## Sequential Questioning Loop

Present **exactly one question at a time**.

### For Multiple-Choice Questions

Before presenting the options, provide:

1. **Motivation** — state the question clearly and explain why the answer materially impacts how the team communicates about the domain, how new code should be named, or whether the glossary needs an update.
2. **Example** — give a concrete, hypothesized scenario drawn from the project context that shows how each option would play out in practice (e.g., a code review comment, a user-facing error message, or a schema field name).

Then analyze all options and determine the **proposed option** based on:

- Domain expert usage over implementation jargon
- Consistency with existing glossary entries
- Prevalence in the current codebase
- Clarity and lack of overload (same word meaning multiple things)

Present your **proposed option** prominently at the top with:
- The proposal itself.
- **Why it is proposed** (1–2 sentences).
- **Implication** — what happens downstream if this option is chosen (e.g., which files need renaming, which glossary entries change, which synonyms become avoided).

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

1. **Motivation** — state the question clearly and explain why the answer materially impacts how the team communicates about the domain, how new code should be named, or whether the glossary needs an update.
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

Do not use "no valid questions exist" as a reason to skip the first user interaction. If the prompt appears complete, ask the user to confirm the proposed terminology baseline and proceed only after the answer, unless the user explicitly requested a non-interactive audit, explicitly asked the agent to make reasonable assumptions, or provided all required decisions in the prompt.

## Integration After Each Answer

- Maintain an in-memory representation of the terminology state plus the raw evidence set.
- Load `references/DOMAIN-CONCEPTS-FORMAT.md` before creating or editing domain concepts docs.
- After each accepted answer, apply the clarification:
  - If the answer selects or defines a canonical term, write it to `<output-dir>/domain-concepts/dc-<what>.md` immediately (atomic overwrite), following the output directory discovery contract. If the `domain-concepts/` directory does not yet contain a `README.md`, create one as an index. Only update `CONTEXT.md` if the user explicitly says that is their project's glossary. Include definition, _Avoid_ synonyms, and relationships.
  - If the answer resolves a naming conflict, normalize the term across any in-memory notes; retain the original only once with `(formerly referred to as "X")` if necessary.
  - If the term is not durable or project-specific, record it in a design-choice doc instead.
- After writing or updating any domain-concepts file, scan all other documents under `<output-dir>/` for references to the same terms. Update affected ADRs or design-choice docs to restore consistency.
- When working with an OpenSpec change, also scan the OpenSpec change artifacts (`proposal.md`, `design.md`, `tasks.md`, and specs under `specs/`) for references to the same terms. Update the relevant OpenSpec documents or flag the inconsistency to the user.
- Do not batch inferred terms; update immediately.
- Do not use domain concepts docs as a spec, implementation plan, issue list, or scratchpad.

## Completion Report

When the exploration is complete or paused, summarize:

- **Questions asked & answered**: count.
- **Resolved terms**: canonical term, definition, and avoided synonyms.
- **Open questions**: only unresolved terminology blockers.
- **Evidence**: most important docs/code references.
- **Coverage summary**: for each taxonomy category, state Resolved / Deferred / Clear / Outstanding.
- **Suggested next action**: update `<output-dir>/domain-concepts/dc-<what>.md` (only update `CONTEXT.md` if the user explicitly says that is their glossary), propose code renames, handoff to [design-choice](design-choice.md), or proceed to implementation planning.
