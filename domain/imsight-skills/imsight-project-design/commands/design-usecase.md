# Design Use Case

Use this subcommand to design one feature use case as an actor-system or system-system workflow under `<feature-dir>/usecases/`.

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the feature design directory** and read `README.md`, `feature-requirement.md`, `design/README.md`, relevant `design/*.md`, `usecases/README.md`, and existing `usecases/uc-*.md` files.
2. **Gather feature context**. Incorporate the request, relevant prior conversation, referenced files, nearby feature docs, existing use cases, design docs, and host-project evidence. Flag terminology conflicts before writing.
3. **Select mode**. Use **Create Mode** when drafting a new use case. Use **Clarify And Refine Mode** when updating a matched use case or when the user asks to review, refine, or improve use cases.
4. **Run a coverage scan** using **Use Case Coverage Scan**. Keep the raw scan internal unless it identifies a blocker that needs user input.
5. **Execute the selected mode**. See **Create Mode** or **Clarify And Refine Mode**.
6. **Write use case artifacts** under `<feature-dir>/usecases/` and update `usecases/README.md`. Use the naming convention `uc-<NN>-<kebab-title>.md`.
7. **Run a self-review**. See **Use Case Self-Review**.
8. **Produce a completion report** with mode, questions, paths, assumptions, open questions, and the suggested next subcommand.

If the task does not map cleanly to these steps, build a concise step-by-step plan from this procedure and execute only the next appropriate use case design stage.

## Mode Selection

Select `create` when the user asks to create, draft, or write a use case and no existing use case clearly matches the topic. Default to one new use case per invocation unless the user explicitly asks for a batch.

Select `clarify-and-refine` when the user asks to review, refine, clarify, or improve use cases, when an existing use case matches the topic, or when the task is to align use cases with the feature requirement, design docs, or domain language.

If the mode is unclear, prefer `create` when no use cases exist and `clarify-and-refine` when use cases already exist.

## Context Gathering

Before drafting or refining, collect and synthesize:

- Feature goal and feature requirement.
- User instruction and relevant prior conversation.
- Referenced files and nearby feature docs.
- Existing use cases and design docs under the feature design directory.
- Host-project evidence such as `README.md`, `docs/`, `context/`, tests, schemas, CLIs, routes, contracts, service code, scripts, or configuration.
- Domain language from existing feature docs, code identifiers, schema fields, test names, and docs.

Cite file paths and line numbers when reporting evidence or contradictions. Do not treat host-project evidence as feature intent when acceptance criteria, priority, or actor boundaries are unclear; surface a proposed interpretation and ask only if it materially changes the use case.

## Use Case Coverage Scan

Check these categories before writing or refining. Mark each internally as **Clear**, **Partial**, or **Missing**.

| Category | What to Check |
| --- | --- |
| Primary Actors | Human roles, external systems, services, tools, or automation roles that initiate or participate in the use case. |
| Goals & Success Criteria | What each actor wants and how success is observed. |
| Trigger & Preconditions | What starts the use case and what must already be true. |
| Main Success Flow | The happy-path actor-system or system-system interaction sequence. |
| Alternative & Exception Flows | Branches, errors, cancellations, retries, or edge cases. |
| Durable Outputs & Postconditions | Artifacts, records, decisions, state changes, retained outputs, or observable side effects. |
| System Boundaries | What is inside the planned system, outside it, and which external services or interfaces are touched. |
| Terminology & Consistency | Whether actor, entity, and action names match established feature language. |
| Relationship to Existing Work | How the use case relates to prior use cases, requirements, design docs, decisions, or implementation surfaces. |
| Agent Skill Examples | For agent-skill designs, whether the use case includes at least one example user prompt and the expected example AI response shape. |
| Open Questions / Gaps | Missing information affecting scope, acceptance criteria, diagrams, or durable outputs. |

## Create Mode

Use `create` to produce an initial use case without blocking on clarifying questions. Make reasonable assumptions from feature context and document them inline as assumptions or open questions.

1. Gather context and run the coverage scan.
2. Match the topic against existing use cases. If a match exists, switch to `clarify-and-refine`.
3. Choose the next available zero-padded identifier: `uc-<NN>-<kebab-title>`.
4. Draft the use case using **Use Case Format**.
5. Write the artifact automatically and update `usecases/README.md`.
6. Run use case self-review and produce the completion report.

## Clarify And Refine Mode

Use `clarify-and-refine` to update existing use cases with targeted questions.

1. Load the matched use case and related feature docs.
2. Inspect feature context and run the coverage scan.
3. Ask up to five clarification questions, one at a time, only when the answer materially impacts actor boundaries, use case scope, success criteria, durable outputs, terminology, or acceptance criteria.
4. For each question, provide motivation, a feature-grounded example, a proposed answer or option, and downstream implication.
5. After each answer, integrate the decision into the coverage map and draft.
6. Present revised draft summaries for review before final writing unless the user explicitly requested non-interactive assumptions.
7. Write the updated artifact, update `usecases/README.md`, run use case self-review, and produce the completion report.

## Use Case Format

Each use case must include:

- **Identifier and title** in the filename and H1.
- **Actor Goal** in a short actor-goal-benefit sentence when it fits.
- **Use Case** as a short paragraph describing the situation and the system's role.
- **Supported Actions** with H3 action titles and the `context`, `intent`, `action`, and `result` structure below.
- **Main Flow** as numbered actor-system or system-system interactions.
- **Alternative And Exception Flows** when relevant.
- **Mermaid Flow Diagram** showing actors, system boundary, and key interactions when useful.
- **Mermaid Sequence Diagram** with `sequenceDiagram` and `autonumber` when interaction ordering matters.
- **Durable Outputs** listing artifacts, records, decisions, state changes, retained outputs, or side effects.
- **Example Prompt And Expected AI Response** when the planned feature is an agent skill, AI assistant skill, or agent-facing instruction workflow.
- **Assumptions And Open Questions** when relevant.

Supported actions must use this shape:

```markdown
### <Action Title>

<Briefly describe what this action is.>

- context
  - Actor **has** <actor-side precondition or material at hand>.
  - System **has** <system-side precondition or capability already available>.
- intent
  - Actor **wants** <desired outcome>.
  - Actor **wonders** "<concrete question in the actor's mind, using an example when helpful>"
- action
  - Actor then **asks** the system to <perform the action>.
- result
  - Actor **gets** <observable output, decision, artifact, status, or next-step guidance>.
```

## Matching Rule

Do not create a new use case file when the topic is already represented. Prefer updating an existing file if its title, slug, actor goal, prompt phrase, generated artifact, supported action, or summary overlaps the request.

## Agent Skill Use Cases

When the feature being designed is an agent skill, AI assistant skill, or agent-facing instruction workflow, each use case should include an `## Example Prompt And Expected AI Response` section. This section grounds the workflow in the actual conversational contract the skill must satisfy.

Include:

- **Example Prompt**: one realistic user invocation or request that triggers the use case.
- **Expected AI Response**: the observable response shape, decisions, files, commands, diagnostics, or next-step guidance the agent should produce.
- **Notes**: any constraints on tone, refusal, validation, mutation, or follow-up questions that make the response acceptable.

Format examples as compact event records:

```markdown
### Event 001 - <Short Scenario Title>

> Time: `<example-or-placeholder-time>` · Session: `<example-session-or-context>`

User Prompt:

> <realistic user invocation>

AI:
> <expected response shape or illustrative response>
```

Use `User Action:` instead of `User Prompt:` when the triggering input is a slash command, skill activation, button, or other non-freeform user action. Keep examples concrete enough to guide implementation and review, but avoid turning them into brittle full transcripts. The AI block should describe the response contract and may include a short illustrative snippet when wording matters.

## Use Case Self-Review

After writing or updating artifacts, fix issues inline:

1. Placeholder scan: remove `TBD`, `TODO`, incomplete sections, and vague requirements.
2. Internal consistency: align actor names, entity names, and flow steps across use cases and feature docs.
3. Domain language check: confirm terms match established feature vocabulary or document an explicit assumption.
4. Scope check: ensure the use case describes observable workflow behavior, not low-level implementation tasks.
5. Supported action check: verify each action includes context, intent, action, and result.
6. Diagram accuracy: ensure Mermaid diagrams reflect the main flow and durable outputs.
7. Index check: ensure `usecases/README.md` links to the created or updated file.
8. Agent skill example check: when the planned feature is an agent skill, confirm the use case includes an example prompt and expected example AI response.

## Completion Report

When complete or paused, summarize:

- Mode used: `create` or `clarify-and-refine`.
- Questions asked and answered.
- Created or updated use case identifier and title.
- Artifact paths.
- Resolved actor, scope, terminology, or boundary decisions.
- Assumptions made.
- Open questions.
- Evidence that shaped the use case.
- Suggested next action, usually `design-interface` or another `design-usecase`.

Do not start implementation unless the user explicitly asks to switch from design to implementation.
