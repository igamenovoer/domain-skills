---
name: imsight-doc-writing
description: Use when explicitly invoking imsight-doc-writing, routing from another Imsight skill, or handling an Imsight-scoped request to draft, revise, structure, review, or polish technical Markdown, project notes, design or usage docs, architecture explanations, annotated source-code explainer webpages, or Mermaid diagrams.
metadata:
  skill_invocation_notation: >
    Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
    SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
    accepted only as legacy input when SKILL-MAIN.md is absent.
    Skill and subskill entrypoints use bare object paths: `X` invokes skill X and
    `X->Y->Z` invokes subskill Z. Subcommands use parenthesized components:
    `X->cmd()` invokes a direct subcommand, `X->Y->cmd()` invokes a subcommand of
    subskill Y, and `X->parent()->child()` invokes child subcommand child exposed
    by parent subcommand parent. Intermediate subcommands act as object generators.
    Forms such as `X()` and `X->Y()` are invalid for skill or subskill entrypoints.
---

# Imsight Doc Writing

## Overview

Use this skill as the Imsight entrypoint for documentation work. Keep this file small: route specialized writing, code explanation, and diagramming work to the owning subskill or subcommand, keep durable guidance with its resource owner, and edit the user's requested documentation directly when the target file is clear.

## When to Use

- Use for an explicit `imsight-doc-writing` invocation or route from another Imsight skill.
- Use for Imsight-scoped documentation writing, structure, Markdown deliverables, review, Mermaid graphing, or Mermaid formatting.
- Use for annotated implementation webpages that align explanations, equations, data shapes, and exact ranges from a source file.
- Use the general documentation pass when no specialized route fits.

## Workflow

When this skill is invoked, execute the following steps in order.

1. **Identify the documentation task**. Determine whether the user wants a new document, a revision, a review, a structure proposal, an annotated source walkthrough, a diagram, or a mixed documentation pass.
2. **Select the narrowest route** from **Subskills** or **Subcommands**. If no specialized route fits, use the **General Documentation Pass** rules.
3. **Resolve the target artifact**. Use the file, directory, or output location provided by the user; otherwise ask only when writing to the wrong place would be risky.
4. **Read existing context before writing**. Inspect nearby docs, project terminology, linked specs, and existing diagrams before choosing headings, terms, or diagram shapes.
5. **Execute the selected capability's workflow**. Load only the selected subskill's `SKILL-MAIN.md` or subcommand page and the local resources it requires, then follow its `## Workflow` section step by step.
6. **Return a concise handoff**. Summarize changed files, important writing choices, and any validation or preview limitations.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the available subskills, constraints, and requested deliverable, then execute the plan.

## Invocation Contract

- Invoke `imsight-doc-writing` with a task prompt to select the applicable route; with no actionable task, summarize its documentation capabilities.
- Invoke a subskill with a bare object path, such as `imsight-doc-writing->code-explainer`.
- Invoke a parent-owned command with a parenthesized component, such as `imsight-doc-writing->mermaid-graphing()`.
- Invoke `imsight-doc-writing->help()` to list the routes below.

## Subskills

| Subskill | When to Route Here | Load |
| --- | --- | --- |
| `code-explainer` | Route here when the requested document is an implementation walkthrough that must keep commentary, equations, or data shapes aligned with exact source ranges in a webpage. | [subskills/code-explainer/SKILL-MAIN.md](subskills/code-explainer/SKILL-MAIN.md) |

## Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `help` | Explain this documentation-writing skill and list available subskills and subcommands | This entrypoint |
| `mermaid-graphing` | Create, revise, troubleshoot, or style Mermaid diagrams in Markdown, including flowcharts, sequence diagrams, state diagrams, class diagrams, ER diagrams, timelines, and Gantt charts | [commands/mermaid-graphing.md](commands/mermaid-graphing.md) |
| `format-mermaid` | Reformat existing Mermaid diagrams in one or more Markdown documents to match the `mermaid-graphing` portable style | [commands/format-mermaid.md](commands/format-mermaid.md) |
| `mermaid-syntax-check` | Check Mermaid source text or an `.mmd` file with the `mermaid` package without rendering an image or launching a browser | [commands/mermaid-syntax-check.md](commands/mermaid-syntax-check.md) |

## General Documentation Pass

Use these rules when the task is documentation writing but no specialized subskill exists yet.

1. Establish the reader, purpose, and artifact type: README, design doc, ADR, onboarding note, runbook, user guide, API note, changelog, or review comment.
2. Match the existing document style before inventing a new structure.
3. Prefer concrete headings, short paragraphs, and scannable lists over long narrative blocks.
4. Preserve project terminology unless the user explicitly asks for a terminology rewrite.
5. When editing Markdown in this repository, keep each prose paragraph on a single line unless a list, table, code block, or semantic line break requires otherwise.
6. Avoid adding process notes, meta-explanations, or unused auxiliary docs unless the requested artifact genuinely needs them.

## Output Contract

When the user names a file, edit that file in place. When the user asks for a new tracked document, place it in the location they request or in the project docs area that existing conventions imply. When the task needs skill-owned drafts or scratch artifacts and no location is specified, resolve `<output-dir>` in this order:

1. Use the output location explicitly provided by the user.
2. Otherwise, use `IMSIGHT_SKILL_OUTPUT_DIR` when set; relative values resolve from the current project directory and absolute values are used as-is.
3. Otherwise, use `<project-dir>/.imsight-arts/doc-writing/`.

## Quality Bar

- The result must be useful as documentation, not just a transcript of reasoning.
- Any Mermaid diagram must render as a fenced `mermaid` block and fit the target document without horizontal scrolling.
- Any durable document should have enough context for a future reader who did not watch the conversation.
- State assumptions and unresolved questions only when they affect the document's correctness or next action.

## Guardrails

- DO NOT write before reading nearby documentation and project terminology.
- DO NOT invent a new document structure when the target already has a consistent style.
- DO NOT treat a documentation result as a transcript of reasoning.
- DO NOT add unused process notes or auxiliary documents.
- DO NOT produce Mermaid that does not render or requires horizontal scrolling.
- DO NOT use the general documentation pass when the code-explainer subskill is the specific route.
