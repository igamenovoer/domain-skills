---
name: docs-writer
description: Use when an Imsight mentality request names Docs Writer, or durable document writing and revision has effective Docs Writer principles. Do not use for ordinary chat replies, commit messages, code-only tasks, or unrelated document linting.
---

# Docs Writer Mentality

Write durable prose as a clear current-state document. `d1` (`single-pass-revision`) removes incidental self-revision history while preserving designed tracking sections.

## Workflow

1. Resolve intent and [selectors](references/state.md).
2. Execute a shared management action below, or resolve effective rules for relevant work.
3. Retain selected meanings through [Definition Retention](../../references/runtime-injection.md#definition-retention), then apply them within the task.
4. Report management effects or substantive findings and limits.

For other requests, use the native planning tool without inferring activation or new authority.

## Subcommands

Shared actions inherit the parent contract.

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `deploy` | Publish the complete catalog without enabling principles. | [Shared definition](../../references/actions.md#deploy) |
| `enable-project` | Add selected principles to project-wide requirements. | [Shared definition](../../references/actions.md#enable-project) |
| `disable-project` | Remove selected principles from project-wide requirements. | [Shared definition](../../references/actions.md#disable-project) |
| `enable-memory` | Remember enabled overrides for this agent only. | [Shared definition](../../references/actions.md#enable-memory) |
| `disable-memory` | Remember disabled overrides for this agent only. | [Shared definition](../../references/actions.md#disable-memory) |
| `recall` | Explain project selection, memory overrides, and effective principles. | [Shared definition](../../references/actions.md#recall) |
| `help` | Explain Docs Writer principles, selectors, and actions without changing state. | This entrypoint |

## Applying the Mentality

Apply selected [definitions and examples](references/principles.md) while drafting or revising durable documents. Rewrite current meaning directly; move incidental revision history to tracking sections or remove it. Preserve legitimate changelogs, migration guides, decision records, and external references. Check that a first-time reader needs no unseen earlier version. Ordinary chat, commit messages, code-only work, and document review reports are outside this mentality.

## Catalog Publication

Publish `.imsight-arts/mentality/docs-writer-principles.md` through the shared [catalog contract](../../references/runtime-injection.md#catalog-artifact). Copy complete `Writing Rules` and `Applicability` sections from [principles.md](references/principles.md), including all examples and judgment notes. Exclude workflow, activation state, and control instructions.

## Guardrails

- DO NOT leave incidental previous-version commentary in the main text.
- DO NOT remove designed changelogs, migration records, or legitimate external references.
