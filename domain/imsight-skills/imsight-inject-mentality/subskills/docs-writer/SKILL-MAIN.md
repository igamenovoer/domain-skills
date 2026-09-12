---
name: docs-writer
description: Use when an Imsight mentality request targets Docs Writer, or when writing or revising durable documents arrives with Docs Writer enabled. Do not use for ordinary chat replies, code-only tasks, or document linting unrelated to a mentality.
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

# Docs Writer Mentality

## Overview

Docs Writer is a preventive documentation mentality: write and revise durable documents so the main text reads as a single-pass current-state description, with revision history confined to sections explicitly designed to track previous records. It optimizes what a first-time reader sees, not the convenience of the editor.

Selected rules apply while drafting, restructuring, and polishing. Treating them as a final cosmetic checklist violates their purpose.

## When to Use

Use this subskill when the user selects the Docs Writer mentality, changes its enabled state or rule selection, persists it to project rules or conversation context, or asks for documentation work while resolved state says Docs Writer is enabled.

Do not use it for chat replies, commit messages, code-only tasks, or document review reports. Those are outside the mentality's applicability, not tasks it shapes.

## Workflow

1. Determine whether the request is a control operation from **Subcommands** or an applicable documentation task with Docs Writer already enabled.
2. Resolve Docs Writer state according to [references/state.md](references/state.md); never invent persistence.
3. For a control operation, load and execute only the linked command page.
4. For an applicable documentation task, read [references/principles.md](references/principles.md) and render only the selected rules.
5. Apply the selected rules while drafting, restructuring, and polishing the document.
6. For every state-changing control operation, follow the application order in [../../references/runtime-injection.md](../../references/runtime-injection.md); a managed `AGENTS.md` directive and `.imsight-arts/mentality/docs-writer-rules.md` are the default project representation.
7. Report the task result normally; mention Docs Writer only when its guidance caused a material tradeoff or the user requested status.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the selected Docs Writer rules, current task, and repository constraints, then execute it without turning the mentality into an editing report.

## Invocation Contract

- Invoke `imsight-inject-mentality->docs-writer` without a command to show Docs Writer status and concise help. It does not enable Docs Writer implicitly.
- Invoke `imsight-inject-mentality->docs-writer->enable()` or `imsight-inject-mentality->docs-writer->disable()` to change whether the retained selection is applied.
- Invoke `imsight-inject-mentality->docs-writer->enable-all()` or `imsight-inject-mentality->docs-writer->disable-all()` to add or remove every Docs Writer rule without changing whether Docs Writer is enabled.
- Invoke `imsight-inject-mentality->docs-writer->status()` to inspect effective state.
- Invoke `imsight-inject-mentality->docs-writer->list()` to inspect the rule catalog and selection; `imsight-inject-mentality->docs-writer->ls()` is an accepted alias.
- Invoke `imsight-inject-mentality->docs-writer->edit()` to atomically modify the rule selection.
- Natural invocation may use `$imsight-inject-mentality docs-writer edit remove d1`.

## Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `enable` | Apply Docs Writer using its retained selection or the built-in default selection. | `commands/enable.md` |
| `disable` | Stop applying Docs Writer without losing its retained rule selection. | `commands/disable.md` |
| `enable-all` | Add all canonical Docs Writer rules to the selection without changing enabled state. | `commands/enable-all.md` |
| `disable-all` | Remove all Docs Writer rules from the selection without changing enabled state. | `commands/disable-all.md` |
| `edit` | Atomically add, remove, set, or reset selected Docs Writer rules. | `commands/edit.md` |
| `list` | Show available, selected, and effective rules; accepts `ls` as an alias. | `commands/list.md` |
| `status` | Show enabled state, selected rules, effective rules, and persistence scope. | `commands/status.md` |
| `help` | Explain this mentality and list its public commands. | This entrypoint |

## Applying the Mentality

When Docs Writer is enabled and the task writes or revises a durable document:

1. Load the selected rule definitions from [references/principles.md](references/principles.md).
2. Draft the current state directly; relocate or delete past-version references instead of annotating them.
3. Treat each rule's examples and judgment notes as prompts for judgment, never automatic verdicts.
4. Before finishing, re-read the final text as a first-time reader and remove anything that requires knowing an earlier version.

For injection, render each selected rule as its compact constructive reminder. Do not inject unselected rules or editing-report language.

## Rule Catalog

Docs Writer canonical IDs, compact reminders, examples, and judgment notes live at `references/principles.md` relative to this subskill. Default project-rule persistence writes the selected compact reminders to `.imsight-arts/mentality/docs-writer-rules.md`, then names the entrance skill `imsight-inject-mentality`, the selected canonical IDs, and that artifact in `AGENTS.md`; after loading, the entrance skill owns routing to this entrypoint and catalog. Wrap the `AGENTS.md` section in the runtime contract's invisible `imsight-skill:imsight-inject-mentality/docs-writer` managed fence so later control operations replace the same source-owned block.

## Rationalization Table

| Rationalization | Counter |
| --- | --- |
| "The reader needs to know what changed." | Revision provenance belongs to version control and designed tracking sections; the main text serves the current reader. |
| "This history note is only temporary." | A temporary mention still makes the main text depend on a version the reader cannot see; move it or delete it. |
| "One small reference costs nothing." | Each past-version reference forces the reader to reconstruct a document they cannot see; the cost compounds. |
| "The point is clearer with before/after framing." | Before/after framing is a record; put it in a designed tracking section or rewrite it as a current-state statement. |

## Red Flags

- Main-text sentences opening with "Previously", "Until now", "This section used to", or "We changed".
- Inline edit annotations such as "(new)", "(removed)", or "(updated)" scattered through prose.
- A changelog paragraph embedded mid-section instead of a designed tracking section.
- Obsolete paragraphs kept with strike-through or "no longer applies" notes when deletion would do.

## Guardrails

- DO NOT mention a document's previous versions in its main text outside explicitly designed tracking sections.
- DO NOT apply a rule that the current Docs Writer state has not selected.
- DO NOT strip a designed changelog, records, or migration section in the name of the mentality.
- DO NOT let Docs Writer override explicit task requirements or repository instructions.
- DO NOT claim conversation state survives context loss or a new conversation without host support.
- DO NOT copy rule text into a project instruction file unless the user explicitly requests the inline-copy variant.
- DO NOT persist Docs Writer to a project without synchronizing `.imsight-arts/mentality/docs-writer-rules.md` and its `AGENTS.md` reference.
