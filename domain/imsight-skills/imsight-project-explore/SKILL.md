---
name: imsight-project-explore
description: Use when explicitly invoking imsight-project-explore, routing from another Imsight skill, or handling an Imsight-scoped request to explore a project before implementation, clarify specs, behavior, scope, acceptance criteria, ambiguities, terminology, plan risks, or contradictions between docs and code. Do not use for implementation-only tasks unless exploration is requested first.
---

# Imsight Project Explore

## Overview

Use this skill to explore a development project before planning or building. Treat the user's proposal, issue, feature idea, or spec as a hypothesis to test against the repository's existing docs, code, tests, terminology, and product boundaries.

Exploration is interactive by default. In `auto` mode, the agent may inspect repository evidence and choose the exploration type itself, such as `any-open-question`, `design-choice`, `domain-language`, or `review-decision`. After that routing choice, the agent must ask the user at least one decision-bearing question before choosing a durable project direction, writing artifacts, or producing a final proposed direction. Use zero questions only when the user explicitly requests a non-interactive audit, explicitly asks the agent to make reasonable assumptions, or provides all required decisions in the prompt.

## When to Use

- Use for explicit or routed `imsight-project-explore` requests.
- Use for Imsight-scoped pre-implementation exploration, ambiguity resolution, terminology, use cases, design choices, decision review, or brainstorming.
- Use zero questions only under the explicit exceptions in **Overview**.
- Do not use for implementation-only tasks unless exploration is requested first.

## Workflow

When this skill is invoked, execute the following steps in order. Detailed rules for each step are in the sections referenced below.

1. **Determine the project directory**. See **Project Directory**.
2. **Resolve `<output-dir>`**. See **Output Directory Discovery**.
3. **Load previous exploration artifacts**. Check `<output-dir>/` for existing `domain-concepts/`, `adrs/`, `design-choice/`, `designs/`, and `use-cases/` files. Load any relevant prior artifacts and incorporate them into your evidence set. See Core Principles §1.
4. **Prepare domain language baseline**. See **First Step: Prepare Domain Language**. If accepting or changing domain language requires a project decision, ask the user before treating it as established.
5. **Select exploration mode**. Inspect the user's prompt and early repository evidence against the **Subcommands** table:
   - If the prompt explicitly names a mode (`any-open-question`, `design-choice`, `domain-language`, `review-decision`, `brainstorm`, `usecase-design`) or clearly asks for that kind of work, use that mode.
   - Otherwise, default to `auto`.
   - If the prompt spans multiple modes naturally, combine them sequentially.
6. **Execute the selected mode's workflow**. Load the mode's page from **Subcommands** and follow its **Workflow** section step by step.
7. **Route documentation-specific writing needs**. If the artifact needs a particular document style, Markdown structure, polished prose, Mermaid diagrams, or other writing-specific conventions, use `imsight-doc-writing` for those rules before writing the artifact. See **Documentation Writing Route**.
8. **Capture durable knowledge**. Follow the **Capturing Knowledge** rules when writing or updating artifacts.
9. **Do not start implementation** unless the user explicitly asks to switch from exploration to implementation.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan based on the available modes, constraints above, and the user's specific goal, then execute the plan.

## Invocation Contract

- Preferred explicit form: `$imsight-project-explore <task prompt>`.
- Task-only form uses `auto` exploration by default.
- Outside `auto`, select `any-open-question`, `design-choice`, `domain-language`, `review-decision`, `brainstorm`, or `usecase-design` only when the user's prompt explicitly names that mode or clearly asks for that kind of focused exploration. Inside `auto`, the agent may choose the focused exploration type after inspecting the prompt and repository evidence.
- **Batch question mode**: When the user explicitly asks to see all questions at once with recommended options — using phrases such as "list all at once", "batch mode", "show all options", or "let me pick which ones to change" — the agent may list every material question (up to the mode's maximum) in one message, each with a **Proposed** option and short **Pros/Cons**. Batch mode is opt-in; the default remains sequential questioning.
- No actionable task means `help`.

## Project Directory

Use the project directory explicitly provided by the user. If none is provided, use the current working directory. Before creating or updating files, confirm the current directory looks like the intended project root unless the user already made that explicit.

## Output Directory Discovery

When this skill writes artifacts, resolve `<output-dir>` in this priority:

1. An output location explicitly provided by the user.
2. If the user is targeting an OpenSpec change, use `<openspec-change-dir>/explore` (e.g., `openspec/changes/<change-name>/explore`). [OpenSpec](https://github.com/Fission-AI/OpenSpec) is a structured, artifact-driven spec workflow; when the prompt names a change directory or references a change-specific artifact, treat that change as the exploration scope.
3. The directory named in the `IMSIGHT_SKILL_OUTPUT_DIR` environment variable (relative or absolute).
4. `<project-dir>/.imsight-arts/project-explore/` by default.

Only write to `docs/design/` if the user explicitly requests tracked project docs.

## Documentation Writing Route

Use `imsight-doc-writing` whenever exploration produces or revises documentation that needs writing-specific guidance: domain concept notes, ADRs, design-choice records, design docs, use cases, review summaries, Markdown structure, prose style, or Mermaid diagrams. Treat `imsight-project-explore` as responsible for project evidence, decisions, artifact paths, consent, and consistency; treat `imsight-doc-writing` as responsible for how the document should be written in the requested or established style.

Do not duplicate detailed writing-style rules in this skill. When the user asks for a particular documentation style or the artifact type has a specialized writing convention, load `imsight-doc-writing`, follow its applicable subskill, then return here to apply the **Capturing Knowledge** and consistency rules.

## First Step: Prepare Domain Language

Before entering any exploration mode, scan the project for domain language that may affect the exploration. This scan informs mode selection and question quality; it does not authorize the agent to make terminology decisions without user consent.

1. Check `<output-dir>/domain-concepts/` for previously established domain language. If it exists, load it and treat it as the starting baseline instead of building from scratch.
2. Inspect the codebase for project-specific terms: identifiers in code, schema fields, UI labels, test names, documentation headings, and any existing glossary (such as `CONTEXT.md`).
3. Build a candidate vocabulary of canonical terms and their definitions, extending or correcting the previous baseline if one exists.
4. If the vocabulary affects the selected exploration type, artifact content, naming, or downstream implementation, ask the user to confirm, correct, or extend the candidate terms before treating them as established.
5. Write established domain language following the artifact rules in **Capturing Knowledge** below only after user consent.

If the project already has an established domain language document that the user accepts as authoritative, skip this step and load it instead.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `help` | Explain this exploration skill and list its modes | This entrypoint |
| `auto` | Let the agent choose the exploration type from the prompt, repo evidence, and highest-risk uncertainty | [commands/auto.md](commands/auto.md) |
| `any-open-question` | Identify unresolved questions in given material, classify them by type, and route each material question to the matching non-brainstorm exploration mode | [commands/any-open-question.md](commands/any-open-question.md) |
| `design-choice` | Clarify a design decision: features, scopes, protocols, conventions, patterns, interfaces, acceptance criteria, and tradeoffs | [commands/design-choice.md](commands/design-choice.md) |
| `domain-language` | Resolve project-specific terms and terminology conflicts | [commands/domain-language.md](commands/domain-language.md) |
| `review-decision` | Review existing decisions for consistency, drift, stale assumptions, and missing trade-offs | [commands/review-decision.md](commands/review-decision.md) |
| `brainstorm` | Turn a vague idea or product concept into an approved system design before implementation | [commands/brainstorm.md](commands/brainstorm.md) |
| `usecase-design` | Create use cases from project context, or clarify and refine existing use cases against system design and domain language | [commands/usecase-design.md](commands/usecase-design.md) |

Use `auto` as the default exploration mode. In `auto`, inspect the prompt and early repo evidence, choose the most relevant exploration type, state that routing choice, and proceed into that mode's questioning loop. The routing choice itself does not require user confirmation. Any substantive product, terminology, scope, ADR, artifact, or implementation-impacting decision after routing requires user consent. Choose another mode from the user's prompt, explicit mode names, requests to find any open or unresolved questions, direct requests about feature scope, terminology, decision review, system design brainstorming, or use-case design, wording that clearly maps to one focused mode, or the agent's evidence-based routing judgment in `auto`. Combine modes only when the request naturally spans them.

## Core Principles

### 1. Read the project context first

If a question can be answered by exploring the codebase, inspect the codebase instead of asking the user.

Do not treat repository evidence as a substitute for product intent, priority, risk tolerance, domain terminology ownership, or acceptance criteria. When evidence suggests a direction but user intent is not explicit, present it as a proposal inside a question and wait for confirmation.

Look for coding agent context files (such as `AGENTS.md` or `.cursor/`), project documentation, domain memory (such as `CONTEXT.md`, architecture docs, or ADRs), and behavior surfaces (routes, schemas, tests, migrations, UI labels, CLI commands). Also look for similar existing features that imply naming, permissions, lifecycle states, error handling, or acceptance criteria.

Before creating any new artifact, check `<output-dir>/` for previous exploration results. Load existing `domain-concepts/`, `adrs/`, `design-choice/`, `designs/`, and `use-cases/` files and incorporate them into your evidence set. Do not duplicate or contradict prior exploration without explicitly noting the conflict.

Use targeted search and file reads before broad exploration. Cite file paths and line numbers when reporting evidence or contradictions.

### 2. Pay attention to domain language

Watch for discrepancies between the user's terms and the terms used in the codebase. Challenge the user when:

- Their term conflicts with the existing glossary (such as `CONTEXT.md`) or the dominant usage in code.
- The same concept has multiple names across docs, tests, and code.
- A term is overloaded or ambiguous in a way that affects implementation or tests.

Only change domain language terms with explicit user consent. Write them following the artifact rules in **Capturing Knowledge** below; only update `CONTEXT.md` if the user explicitly says that is their project's glossary. Surface the conflict, give the evidence, propose a resolution, and ask for the smallest needed decision.

## Capturing Knowledge

Update durable project artifacts inline when the session resolves durable knowledge. All paths below are relative to `<output-dir>`, resolved by the **Output Directory Discovery** rules above.

| Artifact | Path | Reference |
| --- | --- | --- |
| Domain concepts | `domain-concepts/dc-<what>.md` | `references/DOMAIN-CONCEPTS-FORMAT.md` |
| ADRs | `adrs/<index>-<what>.md` | `references/ADR-FORMAT.md` |
| Design choice | `design-choice/design-<what>.md` | — |
| Design | `designs/YYYY-MM-DD-<topic>-design.md` | `commands/brainstorm.md` |
| Use cases | `use-cases/uc-<NN>-<what>.md` | `commands/usecase-design.md` |

When creating the first file in `domain-concepts/`, `design-choice/`, `designs/`, or `use-cases/`, also create a `README.md` index in that directory. ADRs are durable project content; whether they are version-controlled depends on whether `<output-dir>` itself is tracked. Only write to `docs/design/` if the user explicitly requests tracked project docs.

### Consistency discipline

After writing or updating any artifact, scan all other documents under `<output-dir>/` for references to the same concepts, decisions, or terms. If the new content invalidates, contradicts, or extends an existing document, update the affected document to restore consistency. Do not leave stale definitions or outdated decisions across artifacts.

### OpenSpec synchronization

When `<output-dir>` is inside an OpenSpec change (i.e., `<openspec-change-dir>/explore`), also scan the OpenSpec change artifacts themselves — `proposal.md`, `design.md`, `tasks.md`, and specs under `specs/` — for references to the same topics. If a new decision or domain concept contradicts or extends the OpenSpec artifacts, update the relevant OpenSpec documents or flag the inconsistency to the user before proceeding.

- Use an existing spec, issue, PRD, or design doc when the exploration resolves feature behavior, acceptance criteria, scope, or non-goals.
- In `review-decision`, review existing ADRs, decision sections, architecture notes, and code behavior before proposing any new decision. Report inconsistencies first; update durable artifacts only after the inconsistency has a resolved answer.

Do not start implementation unless the user explicitly asks to switch from exploration to implementation.

## Guardrails

- DO NOT ask the user for facts that repository inspection can answer.
- DO NOT treat repository evidence as product intent or acceptance criteria.
- DO NOT establish or change domain language without user consent.
- DO NOT ignore previous exploration artifacts.
- DO NOT start implementation before the user explicitly switches from exploration to implementation.
