---
name: docs-writer
description: Use when an Imsight mentality request names Docs Writer, or durable document writing and revision has effective Docs Writer principles. Do not use for ordinary chat replies, commit messages, code-only tasks, or unrelated document linting.
---

# Docs Writer Mentality

## Overview

Docs Writer provides principles for durable prose that reads as a clear current-state document. Its initial principle, `d1` (`single-pass-revision`), keeps incidental self-revision history out of the main text while preserving sections designed to track records.

## Workflow

1. **Resolve intent** using **Subcommands**, or recognize an applicable task with effective Docs Writer principles.
2. **Validate selectors** using [state.md](references/state.md), which owns this mentality's canonical IDs and groups.
3. **Execute the resolved action** through its shared detail section.
4. **For substantive work**, resolve scope through [runtime-injection.md](../../references/runtime-injection.md), then apply the selected definitions under **Applying the Mentality**.
5. **Report actual effects** following the shared action contract; during ordinary work mention the mentality only for material tradeoffs or requested status.

If the task does not map cleanly to these steps, use the native planning tool to build a bounded plan from the declared actions, scope precedence, principles, and user intent without assuming activation.

## When to Use

Use for Docs Writer catalog deployment, explicit project or agent-memory selection, recall, or durable documentation work with effective Docs Writer principles. Ordinary chat replies, commit messages, code-only changes, and document review reports are outside its application scope.

## Subcommands

These actions inherit the shared workflows unchanged with `docs-writer` as the selected mentality. The parent owns action and scope semantics; this child owns selectors, definitions, and applicability.

For example, `$imsight-mentality-mgr docs-writer enable-memory d1` remembers the single-pass-revision principle for this agent.

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

1. Resolve effective principles and their scope through the shared runtime contract, then check applicability to the durable document being written.
2. Read and retain each applicable principle's reminder, examples, and judgment notes through shared [Definition Retention](../../references/runtime-injection.md#definition-retention).
3. Draft and revise the current state directly, moving incidental self-revision history into designed tracking sections or deleting it.
4. Preserve legitimate changelogs, migration guides, decision records, and references to external documents.
5. Re-read the final text as a first-time reader and remove dependence on unseen previous versions.

Apply guidance while drafting, restructuring, and polishing, including small edits. Render only effective, applicable reminders with their source scope.

## Catalog Publication

The canonical source is [principles.md](references/principles.md). Publish `.imsight-arts/mentality/docs-writer-principles.md` using the shared deployment contract. Include the complete `Writing Rules` and `Applicability` sections and every nested example and judgment note, with a title, canonical rule index, entrance skill name, and availability-only statement. Exclude the source workflow and skill-control guardrails; the artifact documents principles, not activation or agent state.

Publishing or refreshing the catalog does not change either scope. Project actions change only `AGENTS.md`; memory actions change only the current agent's explicit overrides. Apply the shared precedence rather than a mentality-wide enabled flag.

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
- DO NOT strip a designed changelog, records, or migration section in the name of the mentality.
- DO NOT apply a principle suppressed by this agent's explicit memory override.
- DO NOT treat catalog deployment as project or agent activation.
- DO NOT copy this agent's remembered selection into shared project instructions.
- DO NOT let mentality guidance override unrelated repository instructions or explicit task requirements.
