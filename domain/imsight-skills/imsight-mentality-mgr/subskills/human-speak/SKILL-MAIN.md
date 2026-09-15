---
name: human-speak
description: Use when an Imsight mentality request names Human Speak or a Human Speak flavor, or human-facing communication has effective Human Speak principles. Do not use to choose a flavor implicitly or to change the substance of work under a writing preference.
---

# Human Speak Mentality

## Overview

Make an agent's output easier for people to understand using an explicitly chosen communication flavor. Human Speak owns flavor routing and shared resources; flavors are flat subcommands with individually selectable rules.

## Workflow

1. **Resolve the request** and any explicitly named flavor. For a management invocation without one, use **Flavor Selection** before any action, including deployment or recall.
2. **Load the selected flavor command** from **Flavors**, plus its required references. For ordinary communication, use only flavors already identified by explicit project selections or this agent's remembered rules.
3. **Resolve action, selectors, and scope** through [state.md](references/state.md) and the manager's [decision tree](../../references/actions.md#enabledisable-decision-tree).
4. **Execute the requested action** through the shared manager workflow, or apply effective communication principles while drafting the human-facing output.
5. **Report actual results** with flavor-qualified identities and scope. Memory actions use shared [Memory Confirmation](../../references/runtime-injection.md#memory-confirmation); ordinary replies need no repeated activation announcement.

If the task does not map cleanly to these steps, use the native planning tool to preserve the caller's chosen flavor, scope, and task requirements. A missing flavor leads to the chooser, not a guessed default or a file change.

## When to Use

Use for Human Speak management and selected guidance on replies, status updates, summaries, reports, handoffs, and PR, issue, or commit messages. Human-facing durable prose may combine a selected flavor with Docs Writer. This mentality governs presentation, not private reasoning, implementation effort, test scope, machine-readable schemas, or instructions intended for agent execution.

## Flavors

This table is the chooser inventory. Show the flavor name, origin, and short rule summary without loading every flavor's full catalog.

| Flavor | Origin | Rule Summary | Detail |
| --- | --- | --- | --- |
| `mark-life-style` | Mark-Life's `agent-to-human` skill; [bundled source](references/sources/mark-life-style/index.md). | Lead with the answer; retain useful detail; state evidence accurately; use plain language, focused sentences, named actors, readable structure, and precise references. | [Mark-Life Style](commands/mark-life-style.md) |
| `han-style` | Test Double's Han readability guidance; [bundled source](references/sources/han-style/index.md). | Account for the reader's context, make the answer clear, connect ideas, explain technical meaning, and preserve precision; leave prose structure to the agent. | [Han Style](commands/han-style.md) |
| `ste-style` | Dustin Yuchen Teng's `asd-ste100` skill, inspired by Simplified Technical English; [bundled source](references/sources/ste-style/index.md). | Use stable terminology, explicit relationships, and direct language; preserve claim strength and prefer clarity over brevity, without enforcing the STE standard. | [STE Style](commands/ste-style.md) |

## Flavor Selection

Every Human Speak management invocation requires an explicitly named flavor, even when only one exists. If omitted, list **Flavors** with origins and summaries, then ask which flavor the user wants. Keep the pending action, scope, selectors, and target in the conversation and resume after the user chooses. Do not deploy, enable, disable, or recall a guessed flavor; write no files or activation state while awaiting the choice.

Neither prior use, project configuration, remembered selections, a rule ID, nor the sole available flavor supplies the missing choice. An unknown flavor also returns the inventory for correction. `all` means all rules within a named flavor, never all flavors. Multiple flavors must each be named explicitly and validated before any requested mutation.

Bare `human-speak`, `enable human-speak`, and `recall human-speak` all open the chooser. A manager-wide recall may report other mentalities while showing this chooser for Human Speak; it does not silently select a flavor. This invocation rule does not interrupt ordinary application of already enabled, flavor-qualified rules on subsequent replies.

The following exchange is illustrative. Learn its intent and response shape; do not hardcode the example wording or treat it as an activation request.

> User: Enable Human Speak.
>
> Agent: Available flavors: **mark-life-style**, from Mark-Life's `agent-to-human`, emphasizes direct answers, useful detail, accurate evidence, and plain language; **han-style**, from Test Double's Han guidance, emphasizes reader context, connected explanations, technical meaning, and precision; **ste-style**, from Dustin Yuchen Teng's STE-inspired skill, emphasizes consistent terms, unambiguous relationships, direct language, and faithful claims. Which flavor would you like to use?
>
> User: mark-life-style.
>
> Agent: Enabled `human-speak/mark-life-style:h1` through `h8` in this agent's memory. [Summarize the eight meanings and their actual project-reference or inline-content retention.] No files written.

## Subcommands

All commands below are peers. Flavor commands take an optional shared action and its arguments; they introduce no further subskill or command level.

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `mark-life-style` | Choose Mark-Life's communication flavor and run an action, or recall it and show help when no action is supplied. | [Mark-Life Style](commands/mark-life-style.md) |
| `han-style` | Choose Han's communication flavor and run an action, or recall it and show help when no action is supplied. | [Han Style](commands/han-style.md) |
| `ste-style` | Choose the STE-inspired communication flavor and run an action, or recall it and show help when no action is supplied. | [STE Style](commands/ste-style.md) |
| `deploy` | Publish the explicitly named flavor's complete catalog and sources without activation. | [Shared Deploy](../../references/actions.md#deploy) |
| `enable-project` | Ensure deployment and add selected rules of the named flavor to project requirements. | [Shared Enable Project](../../references/actions.md#enable-project) |
| `disable-project` | Ensure deployment and remove selected rules of the named flavor from project requirements. | [Shared Disable Project](../../references/actions.md#disable-project) |
| `enable-memory` | Remember enabled overrides for the named flavor in this agent only. | [Shared Enable Memory](../../references/actions.md#enable-memory) |
| `disable-memory` | Remember explicit disabled overrides for the named flavor in this agent only. | [Shared Disable Memory](../../references/actions.md#disable-memory) |
| `recall` | Explain the explicitly named flavor's project, memory, and effective rules. | [Shared Recall](../../references/actions.md#recall) |
| `help` | List flavors with origins and summaries; ask for a choice when omitted. | This entrypoint |

For example, `imsight-mentality-mgr->human-speak->mark-life-style()` with arguments `enable-memory h1 h4` and `imsight-mentality-mgr->human-speak->enable-memory()` with arguments `mark-life-style h1 h4` resolve to the same operation. Natural wording such as “enable human-speak mark-life-style h1 h4” uses the same contract.

## Catalog Publication

Resolve the named flavor first. Its command page declares the sections, source bundle, and flavor-specific storage key used by shared deployment. Human Speak has no combined catalog, family-wide rule set, or default-flavor flag. Publishing one flavor never publishes or enables another.

## Guardrails

- DO NOT infer a missing flavor, including from a sole available option or existing state.
- DO NOT mutate files or activation state while the flavor choice is pending.
- DO NOT treat a flavor command's bare invocation as enabling its rules.
- DO NOT mix different flavors' short rule IDs or copy overrides between agents.
- DO NOT reduce requested substance, evidence, or task work to satisfy a communication preference.
- DO NOT add another subskill level for a flavor; keep its command and resources inside Human Speak.
