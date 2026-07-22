---
name: imsight-doc-writing
description: Use when explicitly invoking imsight-doc-writing, routing from another Imsight skill, or handling an Imsight-scoped request to draft, revise, structure, review, or polish technical Markdown, project notes, design or usage docs, architecture explanations, or Mermaid diagrams.
---

# Imsight Doc Writing

## Overview

Use this skill as the Imsight entrypoint for documentation work. Keep this file small: route specialized writing and diagramming work to subskills, keep durable style rules in those subskills, and edit the user's requested documentation directly when the target file is clear.

## When to Use

- Use for an explicit `imsight-doc-writing` invocation or route from another Imsight skill.
- Use for Imsight-scoped documentation writing, structure, Markdown deliverables, review, Mermaid graphing, or Mermaid formatting.
- Use the general documentation pass when no specialized command fits.

## Workflow

When this skill is invoked, execute the following steps in order.

1. **Identify the documentation task**. Determine whether the user wants a new document, a revision, a review, a structure proposal, a diagram, or a mixed documentation pass.
2. **Select the subskill** from the **Subcommands** table. If no subskill fits, use the **General Documentation Pass** rules.
3. **Resolve the target artifact**. Use the file, directory, or output location provided by the user; otherwise ask only when writing to the wrong place would be risky.
4. **Read existing context before writing**. Inspect nearby docs, project terminology, linked specs, and existing diagrams before choosing headings, terms, or diagram shapes.
5. **Execute the selected subskill's workflow**. Load the linked subskill and follow its `## Workflow` section step by step.
6. **Return a concise handoff**. Summarize changed files, important writing choices, and any validation or preview limitations.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the available subskills, constraints, and requested deliverable, then execute the plan.

## Invocation Contract

- Preferred explicit form: `$imsight-doc-writing use <subskill> to do <task>`.
- Task-only form: `$imsight-doc-writing <task prompt>` means choose the applicable subskill or documentation sequence from the request.
- No subskill and no actionable task means `help`.
- `help` summarizes this skill and lists the subskills below.

## Subcommands

| Subskill | Use For | Load |
| --- | --- | --- |
| `help` | Explain this documentation-writing skill and list available subskills | This entrypoint |
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
