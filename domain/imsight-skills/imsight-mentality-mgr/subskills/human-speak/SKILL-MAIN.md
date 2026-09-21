---
name: human-speak
description: Use when an Imsight mentality request names Human Speak or a Human Speak flavor, or human-facing communication has effective Human Speak principles. Do not use to choose a flavor implicitly or to change the substance of work under a writing preference.
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

# Human Speak Mentality

Improve human-facing communication through an explicitly chosen flavor. Flavors are flat commands with independent rules and state, not nested subskills.

## Workflow

1. For management, resolve an explicit flavor through **Flavor Selection** before any action.
2. Load only that flavor's command and needed [state](references/state.md) or principle sections.
3. Execute the shared action, or apply already effective communication rules while writing.
4. Report action effects with flavor-qualified identity; ordinary replies need no activation announcement.

For other requests, use the native planning tool while preserving flavor choice, scope, and task requirements.

## When to Use

Applies to human-facing replies, updates, summaries, reports, handoffs, and PR/issue/commit text. Durable prose may also use Docs Writer. It does not govern private reasoning, implementation/test effort, machine-readable schemas, or instructions for agent execution.

## Flavors

Use this inventory for the chooser without reading every catalog.

| Flavor / command | Origin | Main guidance | Detail |
| --- | --- | --- | --- |
| `mark-life-style` | Mark-Life's `agent-to-human`. | Direct answers, useful detail, accurate evidence, plain language, focused sentences, named actors, readable structure, precise references. | [Command](commands/mark-life-style.md) |
| `han-style` | Test Double's Han readability guidance. | Reader context, clear answers, connected explanations, technical meaning, precision; agent-chosen structure. | [Command](commands/han-style.md) |
| `ste-style` | Dustin Yuchen Teng's `asd-ste100` skill. | Stable terms, explicit relationships, direct language, faithful claims, sufficient clarity; no STE compliance requirement. | [Command](commands/ste-style.md) |

## Flavor Selection

Every management invocation, including deploy and recall, requires an explicitly named flavor. If missing or unknown, list names, origins, and summaries, then ask for a choice. Retain the pending action/scope/selectors/target; mutate nothing until resolved. Prior use, existing state, rule IDs, or a sole option never supply the choice.

`all` means all rules of a named flavor, never all flavors. Validate every named flavor before a multi-family mutation. Bare Human Speak and unqualified recall open the chooser; manager-wide recall may report ordinary children alongside it. Ordinary application of already selected flavors needs no new choice.

Example: “Enable Human Speak” returns this inventory and a choice question. “han-style” then resumes the pending enable using normal scope defaults and reports meanings, priority, retention, and actual effects.

## Subcommands

Flavor commands accept a shared action and arguments; with no action, recall that flavor and show help. They add no review, configuration, intensity, or code-edit action.

| Shared action | Detail |
| --- | --- |
| `deploy` | [Publish named flavor](../../references/actions.md#deploy) |
| `enable-project` | [Add project rules](../../references/actions.md#enable-project) |
| `disable-project` | [Remove project rules](../../references/actions.md#disable-project) |
| `enable-memory` | [Remember enabled overrides](../../references/actions.md#enable-memory) |
| `disable-memory` | [Remember disabled overrides](../../references/actions.md#disable-memory) |
| `recall` | [Report named flavor](../../references/actions.md#recall) |
| `help` | Show this inventory. |

`imsight-mentality-mgr->human-speak->han-style()` with `enable-memory h1 h5` equals `imsight-mentality-mgr->human-speak->enable-memory()` with `han-style h1 h5`. Actions are arguments to flavor commands, not deeper subcommands.

## Catalog Publication

Use the selected command's declared sections and flavor binding. Human Speak has no combined catalog or default-flavor flag. Publishing one flavor never selects or publishes another; References remain outside deployed catalogs.

## Guardrails

- DO NOT infer a missing flavor, mutate while its choice is pending, or enable it through bare invocation.
- DO NOT mix different flavors' short IDs or copy overrides between agents.
- DO NOT reduce requested work, substance, or evidence to satisfy a writing preference.
- DO NOT introduce another subskill level for flavors.
