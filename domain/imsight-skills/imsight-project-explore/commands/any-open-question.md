# Any Open Question Exploration Mode

Use `any-open-question` when the user asks whether given material has unresolved questions, open design decisions, missing decisions, ambiguity, TODO-style planning gaps, or anything that must be clarified before planning or implementation. This mode inventories open questions, classifies each material question by type, then routes to the matching non-brainstorm exploration mode instead of resolving every question locally.

## Workflow

When `any-open-question` mode is selected, execute the following steps in order. Detailed rules for each step are in the sections referenced below.

1. **Collect the material to inspect**. Use the user's prompt, named files, current OpenSpec change artifacts, prior exploration artifacts, and nearby repository evidence. See **Input Material**.
2. **Find candidate open questions**. Scan for explicit questions, TODOs, placeholders, contradictions, missing acceptance criteria, undefined terms, and unstated choices. See **Open Question Scan**.
3. **Classify and prioritize**. Assign each material question a route type and priority. See **Route Classification**.
4. **Choose the output mode**. Inspect the user's prompt for batch-mode phrases such as "list all at once", "batch mode", "show all options", or "let me pick which ones to change". If any such phrase is present, set `mode = batch`; otherwise set `mode = sequential`. See **Batch Mode** for batch behavior and **Routing Rules** for sequential behavior.
5. **Report or expand questions**. If `mode = sequential`, report the open-question map. If `mode = batch`, expand every material question into a batch item. See **Reporting Format** and **Batch Mode**.
6. **Route or integrate**. If `mode = sequential`, route to the next mode. If `mode = batch`, integrate the batch response. See **Routing Rules** and **Batch Response Integration**.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan based on the constraints above and the user's specific goal, then execute the plan.

## When to Use

- The user asks "any open questions?", "any open design decisions?", "what is unresolved?", or "what questions remain?"
- The user provides a proposal, roadmap, OpenSpec change, design note, issue, PRD, or README and asks for gaps.
- The user says "resolve open questions" without naming a specific question type.
- The material may contain several question types and the correct focused mode is not obvious until after inspection.

## Input Material

Inspect the material explicitly named by the user first. If none is named, inspect the current prompt, active OpenSpec change if one is obvious, `<output-dir>/` exploration artifacts, roadmap notes, specs, design docs, and behavior surfaces relevant to the request. Cite file paths and line numbers when reporting evidence.

Do not broaden the scan into unrelated repository areas after the material is sufficient to identify the material open questions. If a broader scan is needed, state why before continuing.

## Open Question Scan

Treat an item as an open question when a reasonable implementer would need an answer before making a durable plan, changing code, or writing a binding spec. Look for:

- Explicit unanswered questions or "open questions" sections.
- TODO, TBD, placeholder, or "to decide" language in planning material.
- Contradictions between docs, code, tests, roadmaps, ADRs, and OpenSpec artifacts.
- Undefined or overloaded domain terms.
- Missing scope, non-goals, acceptance criteria, lifecycle states, ownership, security posture, error behavior, integration contracts, or validation strategy.
- Broad product ideas that need system design before any implementation plan is trustworthy.

Exclude minor copy edits, stylistic preferences, implementation chores, or questions already answered by the material unless the answer conflicts with another source.

## Route Classification

Classify each material open question with exactly one primary route:

| Route | Use When the Open Question Is About |
| --- | --- |
| `domain-language` | Canonical terms, definitions, naming conflicts, overloaded vocabulary, or glossary ownership |
| `design-choice` | Feature scope, behavior, acceptance criteria, data shape, protocol, interface, convention, architecture, UX flow, quality attributes, or validation strategy |
| `review-decision` | Whether an existing decision, ADR, design note, spec, or implementation still holds; drift, contradiction, stale assumptions, or missing trade-offs |
| `auto` | Mixed, ambiguous, broad product, or system-design questions where no single focused non-brainstorm route is reliable after inspection |

Prioritize by impact, uncertainty, reversibility, and whether the answer blocks other questions. Mark each question as **Blocker**, **Important**, or **Deferred**.

## Reporting Format

Before routing, report a compact open-question map:

| Priority | Open Question | Evidence | Recommended Route |
| --- | --- | --- | --- |
| Blocker | ... | `path:line` | `design-choice` |

This map is for visibility only. Do not present it as a list of questions for the user to answer in this message. After the map, either route automatically to the highest-priority mode or ask exactly one routing question.

**Incorrect follow-up**:

```
Please answer these questions:
1. Should the feature be Project-scope or Topic-scope?
2. What validation rules apply?
3. ...
```

**Correct follow-up**:

```
The highest-priority blocker is a scope decision, so I will enter `design-choice` mode to resolve it. (Or, if the route is unclear: "Should we resolve the scope question first, or the terminology conflict?")
```

If no material open questions are found, say so, list the evidence inspected, and stop with a suggested next action. Do not invent questions to force a route.

## Routing Rules

The open-question map is a routing aid, not a questionnaire. Never ask the user to answer all listed questions at once.

If the user explicitly requested a non-interactive audit only, do not enter another mode. Stop after the open-question map and recommended routes.

Otherwise, route automatically when the open question type maps clearly to one focused mode. State the route and why, then load that mode's page and follow its workflow from its **Pre-Exploration Scan** or equivalent first step.

If several open questions exist, route to the highest-priority **Blocker** first. If several blockers tie, prefer the route that unlocks the others in this order: `domain-language`, `review-decision`, `design-choice`, `auto`.

Ask the user one routing question only when:

- Two or more routes are equally plausible and the choice changes what evidence will be inspected or which artifact may be updated.

### Routing Question Format

When a routing question is required, present **exactly one question** using the same enforced format as the other exploration modes.

#### For Multiple-Choice Routing Questions

Before presenting the options, provide:

1. **Motivation** — state the question clearly and explain why the chosen route materially impacts which evidence will be inspected and which artifact may be updated.
2. **Example** — give a concrete, hypothesized scenario drawn from the project context that shows how each route would play out in practice.

Then analyze the routes and determine the **proposed option** based on:

- Which route unlocks the most blockers
- Which route best matches the user's explicit focus
- Which route reduces the risk of redundant or contradictory exploration

Present your **proposed option** prominently at the top with:
- The proposal itself.
- **Why it is proposed** (1–2 sentences).
- **Implication** — what happens downstream if this route is chosen (e.g., which mode's workflow will be followed, which artifacts may be updated).

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

#### For Short-Answer Routing Questions

Before presenting the proposed answer, provide:

1. **Motivation** — state the question clearly and explain why the chosen route materially impacts which evidence will be inspected and which artifact may be updated.
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
- If ambiguous, ask for a quick disambiguation before routing.

Once routed, do not continue resolving the remaining open-question list inside `any-open-question`. Let the selected mode ask its own 1-5 material questions, write any durable artifacts, and hand back if a later answer reveals a different mode is needed.

## Batch Mode

Use **Batch Mode** when the user explicitly asks to see all open questions at once with recommended options and routes, instead of routing into one focused mode immediately. Batch mode is opt-in; if the user does not use a batch-mode phrase, follow **Routing Rules** instead.

### Generating the Batch Question Set

1. Use the same classified and prioritized open-question map produced in step 3.
2. Select up to 5 questions using the same prioritization heuristic (Impact × Uncertainty), preferring **Blocker** items first.
3. For each selected question, prepare:
   - The original open question and its evidence.
   - A **Recommended Route** (`domain-language`, `design-choice`, `review-decision`, or `auto`).
   - A **Proposed** option for resolving the question.
   - A short **Pros/Cons** table with 2–5 mutually exclusive options.
4. Number each question (Q1, Q2, ...) so the user can refer to them when overriding.

### Batch Response Format

Present all selected open questions in one message. Keep each question self-contained. After the last question, add an instruction such as:

```
Reply with the numbers you want to override (e.g., "Q1 = B, Q3 = D"), or say
"accept all" / "yes" to accept every proposed option. If an earlier override
changes a downstream proposal, I will flag it and ask for confirmation.
```

### Batch Mode Example

```
Q1 — Scope decision (route: design-choice)
Evidence: feature-requirement.md:42
**Proposed:** Option A — Project-scope default with optional topic override.
**Implication:** Simplifies the happy path but requires explicit narrowing for per-topic behavior.
| Option | Description | Pros/Cons |
| --- | --- | --- |
| A | Project-scope default, topic override | Pros: simpler common case. Cons: topic users must remember to narrow. |
| B | Topic-scope default | Pros: safer for multi-topic projects. Cons: more verbose for project-wide behavior. |
| Short | Provide a different answer | — |

Q2 — Terminology conflict (route: domain-language)
...
```

## Batch Response Integration

When the user replies to a batch open-question set:

1. **Parse overrides**. Accept answers keyed by question number (e.g., "Q1 = B", "Q2 = short: ...") or a blanket "accept all" / "yes" / "proposed".
2. **Apply overrides in order** (Q1, Q2, ...). For unmentioned questions, use the proposed default.
3. **Re-evaluate downstream proposals**. If an early override changes a premise used by a later proposed option, flag the conflict and ask the user to confirm or revise the later option. Do not silently accept a now-invalid proposal.
4. **Route resolved questions** to their recommended modes. A question may be resolved by the batch answer, or it may still need exploration in its recommended mode.
5. **Update durable artifacts** only after all batch answers have been integrated and conflicts resolved.

## Completion Report

When this mode completes or hands off, summarize:

- **Open questions found**: count by priority.
- **Primary route**: selected mode and why.
- **Deferred questions**: only items not handled by the selected route.
- **Evidence**: most important docs/code references.
- **Suggested next action**: continue in the selected mode, run another route for deferred questions, update artifacts, or move to implementation planning after questions are resolved.

Do not start implementation unless the user explicitly asks to switch from exploration to implementation.
