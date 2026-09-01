# Design Gates

Use this subcommand to design verification gates for a feature as an ordered gate ladder under `<feature-dir>/gates/`.

Gates are an optional part of a feature design directory. Create or update them only when the user asks; `scaffold` does not create `gates/`.

When the user asks to propose, brainstorm, or list candidate gates without committing to files, route to `propose-gates` first and return here only after the user confirms which candidates to persist or delegates the decision.

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the feature design directory** and read `README.md`, `feature-requirement.md`, relevant `usecases/uc-*.md`, `design/` docs, any existing `feature-milestones.md`, and any existing `gates/*.md` files. When the feature design directory is inside an OpenSpec change, treat the change's `proposal.md`, `design.md`, `tasks.md`, and `specs/` as the equivalent baseline and read them as well; `feature-requirement.md` may not exist there.
2. **Check predecessor artifacts**. A substantive requirements baseline must exist: `feature-requirement.md`, or, inside an OpenSpec change, the change's own artifacts (`proposal.md`, `design.md`, `tasks.md`, `specs/`). If no substantive baseline exists or it is still a scaffold placeholder, refuse to design gates and tell the user to run `define-feature` first.
3. **Gather feature context**. Incorporate the request, relevant prior conversation, referenced files, nearby feature docs, existing use cases, design docs, and host-project evidence. Flag terminology conflicts before writing.
4. **Select mode**. Use **Create Mode** when drafting new gates. Use **Clarify And Refine Mode** when updating matched gates or when the user asks to review, refine, or improve the gate set.
5. **Run a coverage scan** using **Gate Coverage Scan**. Keep the raw scan internal unless it identifies a blocker that needs user input.
6. **Execute the selected mode**. See **Create Mode** or **Clarify And Refine Mode**.
7. **Write gate artifacts** under `<feature-dir>/gates/` and update the feature `README.md` gate index. Use the naming convention `NN-<kebab-title>.md`.
8. **Run a self-review**. See **Gate Self-Review**.
9. **Produce a completion report** with mode, questions, paths, assumptions, open questions, and the suggested next subcommand.

If the task does not map cleanly to these steps, build a concise step-by-step plan from this procedure and execute only the next appropriate gate design stage.

## Mode Selection

Select `create` when the user asks to create, draft, or write gates and no existing gate clearly matches the topic. Default to drafting the complete ordered ladder in one invocation; split into multiple invocations only when the user asks or the ladder is still undecided.

Select `clarify-and-refine` when the user asks to review, refine, clarify, or improve gates, when existing gates match the topic, or when the task is to align gates with the feature requirement, use cases, design docs, or domain language.

If the mode is unclear, prefer `create` when no gates exist and `clarify-and-refine` when gates already exist.

## Context Gathering

Before drafting or refining, collect and synthesize:

- Feature goal, non-goals, functional requirements, and operational constraints.
- User instruction and relevant prior conversation.
- Referenced files and nearby feature docs.
- Existing use cases, design docs, and milestone plans under the feature design directory.
- Host-project evidence such as `README.md`, `docs/`, `context/`, tests, schemas, CI or quality commands, benchmarks, and operational runbooks.
- Domain language from existing feature docs, code identifiers, test names, and docs.

Cite file paths and line numbers when reporting evidence or contradictions. Do not invent verification infrastructure the host project does not have; surface a proposed interpretation and ask only if it materially changes a gate.

## Gate Coverage Scan

Check these categories before writing or refining. Mark each internally as **Clear**, **Partial**, or **Missing**. Not every feature needs every category; record why a category is skipped.

| Category | What to Check |
| --- | --- |
| Provenance & Capability | Whether identities of code, build, hardware, model, data, and configuration must be pinned before results are meaningful, and which profiles are supported versus rejected. |
| Invariants | Storage, lifecycle, ownership, accounting, or state invariants that cheap tests can check without the full system. |
| Differential & Parity | Whether the feature must match a reference implementation, oracle, or prior behavior, at what tolerance, and at which operation level. |
| End-to-End Canary | The smallest real end-to-end path that proves wiring, admission, execution, and cleanup together. |
| Lifecycle & Recovery | Failure, abort, retry, cleanup, and reuse behavior under realistic disturbance. |
| Compatibility Envelope | The declared supported matrix and the negative cases that must fail closed. |
| Release Qualification | Expensive boundary, capacity, quality, or performance evidence required before release. |
| Open Questions / Gaps | Missing information affecting gate scope, verdicts, cadence, or evidence. |

## Create Mode

Use `create` to produce an initial gate ladder without blocking on clarifying questions. Make reasonable assumptions from feature context and document them inline as assumptions or open questions.

1. Gather context and run the coverage scan.
2. Match the topic against existing gates. If a match exists, switch to `clarify-and-refine`.
3. Order the ladder from cheap, fast checks to expensive, release-only checks. A later gate may assume every earlier gate has passed for the same identified inputs.
4. Choose zero-padded identifiers: filenames `NN-<kebab-title>.md` and gate IDs `<FEATURE_PREFIX>-GATE-NN`, deriving `<FEATURE_PREFIX>` from established feature language.
5. Draft each gate using **Gate Format**. Use the template at `assets/templates/feature/gates/gate.md` for new files.
6. Write the artifacts automatically. Add or update a gate index section in the feature `README.md` listing the gates in ladder order.
7. Run gate self-review and produce the completion report.

## Clarify And Refine Mode

Use `clarify-and-refine` to update existing gates with targeted questions.

1. Load the matched gates and related feature docs.
2. Inspect feature context and run the coverage scan.
3. Ask up to five clarification questions, one at a time, only when the answer materially impacts gate scope, verdicts, tolerances, cadence, evidence requirements, or ladder ordering.
4. For each question, provide motivation, a feature-grounded example, a proposed answer or option, and downstream implication.
5. After each answer, integrate the decision into the coverage map and drafts.
6. Present revised draft summaries for review before final writing unless the user explicitly requested non-interactive assumptions.
7. Write the updated artifacts, update the feature `README.md` gate index, run gate self-review, and produce the completion report.

## Gate Set Principles

- Each gate is independently runnable and produces a clear pass or fail verdict.
- Order gates so each one is cheaper or narrower than the next; release-only gates run last.
- Every gate declares its cadence: when it runs, such as every commit, every pull request, or release candidate only.
- Keep each gate focused on one risk category from the coverage scan; do not merge unrelated checks into one gate.
- Write verdicts as observable conditions with concrete tolerances, identities, or counts, not vague expectations.
- Specify the evidence contract per gate: what each run must leave, where, and what must stay out of version control.

## Gate Format

Each gate must include:

- **Title** as `# Gate <N>: <Title>` in the H1, matching the filename.
- **Gate ID** as `<FEATURE_PREFIX>-GATE-NN`.
- **Status** as `Planned`. Execution updates the status later; this subcommand never writes verdicts, run identifiers, or evidence links.
- **Cadence** stating when the gate runs and its cost profile.
- **Context and Rationale** explaining why the gate exists, what defect or risk it stops, and why cheaper gates cannot cover it.
- **Evaluation Data** listing the inputs, fixtures, resources, and identities the gate needs.
- **Expected Result** listing the observable pass conditions.
- **Functionality Checked** listing the behaviors or mechanisms the gate exercises.
- **Audit Evidence** specifying what each run shall leave and where, which compact summaries may be committed, and which large artifacts stay out of version control.

## Planning-Stage Boundary

Gates written by this subcommand are planning artifacts. DO NOT write execution-stage content into them:

- No run results, verdicts, timings, or observed values.
- No run identifiers, execution dates, or hardware-observed status lines.
- No links to produced evidence files; the gate names the evidence contract, execution produces the evidence.

Execution workflows update the gate status and add evidence references when a gate actually runs.

## Matching Rule

Do not create a new gate file when the topic is already represented. Prefer updating an existing file if its title, slug, risk category, or expected results overlap the request.

## Gate Self-Review

After writing or updating artifacts, fix issues inline:

1. Placeholder scan: remove `TBD`, `TODO`, incomplete sections, and vague verdicts.
2. Internal consistency: align gate IDs, titles, terminology, and cross-gate assumptions across the ladder and feature docs.
3. Domain language check: confirm terms match established feature vocabulary or document an explicit assumption.
4. Ordering check: confirm the ladder runs cheap to expensive and each gate only assumes earlier gates have passed.
5. Verdict check: verify every expected result is observable and concrete.
6. Planning-stage check: confirm no gate contains run results, verdict records, or evidence links.
7. Index check: ensure the feature `README.md` gate index links to every gate file in ladder order.

## Completion Report

When complete or paused, summarize:

- Mode used: `create` or `clarify-and-refine`.
- Questions asked and answered.
- Created or updated gate identifiers and titles.
- Artifact paths.
- Resolved scope, verdict, cadence, or evidence decisions.
- Assumptions made.
- Open questions.
- Evidence that shaped the gates.
- Suggested next action, usually `plan-feature`, another `design-gates`, or `design-agent-task`.

Do not start implementation or execute any gate unless the user explicitly asks to switch from design to execution.
