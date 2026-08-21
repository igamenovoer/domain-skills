---
name: imsight-paper-reading
description: Use when explicitly invoking imsight-paper-reading, routing from another Imsight skill, or using Imsight context to read an academic paper and produce a structured, citation-grounded reading note, optionally cross-referencing explicitly provided or repository-resident reference source code.
---

# Imsight Paper Reading

## Overview

Use this skill to turn an academic paper into a structured, deeply technical reading note grounded in direct citations from the paper. The note captures the problem, contributions, method, architecture, experiments, and reproducibility posture in a fixed section template, with Mermaid diagrams, shape-annotated pseudocode, and optional references to a companion source-code implementation.

## When to Use

- Use when the user asks for a reading note, paper summary, paper deep-dive, or structured technical digest of a specific academic paper.
- Use when the note must quote the paper to support its claims, or must cross-reference a reference implementation the user names or that lives in the current repository.
- Do not use for a literature search, a survey across many papers, or a one-paragraph abstract-level summary that does not need the full note template.
- Do not assume any paper or code location; the paper and any reference code come from the user or from an explicit search of the current repository. See **Input Resolution**.

## Workflow

When this skill is invoked, execute the following steps in order.

1. **Resolve the paper source**. See **Input Resolution**.
2. **Resolve optional reference code**. See **Input Resolution**. Code cross-references are included only when reference code is explicitly provided or located.
3. **Select a subcommand** from **Subcommands**. If no actionable task is present, handle `help`; otherwise use `make-note`.
4. **Load the selected command detail page** and follow its workflow.

If the user's task does not map cleanly to these steps, use the native planning tool to build a bounded reading and note-writing plan from the paper, the available reference code, and the contracts in this skill, then execute the plan.

## Invocation Contract

- Preferred explicit form: `$imsight-paper-reading use make-note to read <paper>`.
- Task-only form: `$imsight-paper-reading <reading request>` means use `make-note` with the supplied paper and constraints.
- No subcommand and no actionable task means `help`.
- `help` explains the input requirements, note structure, citation posture, and public subcommands.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `make-note` | Read one paper and write the full structured reading note with figures and citations | [commands/make-note.md](commands/make-note.md) |
| `help` | Explain this paper-reading skill and its contracts | This entrypoint |

## Input Resolution

There are no predefined input locations. Resolve every input explicitly:

1. **Paper**: use the exact path or URL the user provides (PDF, LaTeX source tree, or Markdown). If the user names a paper without a location, search the current repository for matching paper files; if no candidate is found or several plausible candidates remain, ask the user to supply the location before reading.
2. **Reference code** (optional): include source-code cross-references only when the user explicitly provides a code location or asks the agent to locate the implementation. When asked to locate it, search the current repository for the implementation and state the resolved root in the note's metadata. If no reference code is provided or found, write the note from the paper alone: cite paper sections, equations, and algorithms, and derive pseudocode from the paper's own descriptions.

Record the resolved paper path and, when present, the resolved reference-code root in the note's metadata section so later readers can retrace the inputs.

## Output Contract

The note is a directory containing `main-note.md` plus a `figures/` subdirectory for extracted images. All image paths in the Markdown are relative to the note file. Resolve the note directory in this order:

1. Use the exact directory supplied by the user.
2. Otherwise, when `IMSIGHT_SKILL_OUTPUT_DIR` is set, write `<IMSIGHT_SKILL_OUTPUT_DIR>/paper-reading/<paper-name>/`.
3. Otherwise, write `<project-dir>/.imsight-arts/paper-reading/<paper-name>/`.

Here `<paper-name>` is a short kebab-case handle derived from the paper title. Read an existing note before revising it; preserve manual material that remains accurate.

## Guardrails

- DO NOT assume a default paper or reference-code location such as a fixed `paper-source/` or reference-code directory; resolve inputs from the user or a repository search.
- DO NOT include code citations or implementation references when no reference code was provided or located.
- DO NOT fabricate quotations, section names, results, or citations; every blockquote must come from the resolved paper source.
- DO NOT write note artifacts outside the resolved output directory.
