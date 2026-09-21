---
name: rigor-control
description: Use when an Imsight mentality request names Rigor Control or a rigor flavor, or engineering, robustness, and verification effort should follow an already selected assurance target. Do not use to infer a rigor level, weaken explicit requirements, or excuse known failures inside the selected use-case envelope.
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

# Rigor Control Mentality

Match engineering and verification rigor to an explicitly chosen assurance target. Flavors are flat commands with independent rules and state, not a ladder that the agent may choose implicitly.

## Workflow

1. For management, resolve an explicit flavor through **Flavor Selection** before any action.
2. Load only that flavor's command and needed [state](references/state.md) or principle sections.
3. Execute the shared action, or apply already effective rigor rules while planning, implementing, and verifying work.
4. Report action effects with flavor-qualified identity; ordinary work mentions the flavor only when its boundary materially affects a decision or claim.

For other requests, use the native planning tool while preserving the selected assurance target, task authority, and explicit acceptance requirements.

## When to Use

Apply an effective flavor when deciding how robust an implementation must be, which failure cases belong in scope, what verification is sufficient, and when further hardening no longer serves the intended use. Rigor Control calibrates effort and readiness claims; it does not replace explicit safety, security, compliance, performance, or acceptance requirements.

## Flavors

Use this inventory for the chooser without reading every catalog.

| Flavor / command | Assurance target | Main guidance | Detail |
| --- | --- | --- | --- |
| `product-showcase` | A short hands-on event demonstration for ordinary users. | Protect the core experience, support presented numbers with claim-relevant evidence, and defer industrial rigor. | [Command](commands/product-showcase.md) |

## Flavor Selection

Every management invocation, including deploy and recall, requires an explicitly named flavor. If it is missing or unknown, list available names, assurance targets, and summaries, then ask for a choice. Retain the pending action, scope, selectors, and target; mutate nothing until resolved. Prior use, existing state, rule IDs, or a sole available option never supplies the choice.

`all` means all rules of one named flavor, never all Rigor Control flavors. Validate every named flavor before a multi-family mutation. Bare Rigor Control and unqualified recall open the chooser; manager-wide recall may report ordinary children alongside it. Ordinary application of already selected flavor-qualified rules needs no new choice.

Example: “Enable Rigor Control” returns this inventory and a choice question. “product-showcase” then resumes the pending enable using normal scope defaults and reports meanings, priority, retention, and actual effects.

## Subcommands

Flavor commands accept a shared action and arguments; with no action, recall that flavor and show help. They add no review, release, certification, or code-edit action.

| Shared action | Detail |
| --- | --- |
| `deploy` | [Publish named flavor](../../references/actions.md#deploy) |
| `enable-project` | [Add project rules](../../references/actions.md#enable-project) |
| `disable-project` | [Remove project rules](../../references/actions.md#disable-project) |
| `enable-memory` | [Remember enabled overrides](../../references/actions.md#enable-memory) |
| `disable-memory` | [Remember disabled overrides](../../references/actions.md#disable-memory) |
| `recall` | [Report named flavor](../../references/actions.md#recall) |
| `help` | Show this inventory. |

`imsight-mentality-mgr->rigor-control->product-showcase()` with `enable-memory all` equals `imsight-mentality-mgr->rigor-control->enable-memory()` with `product-showcase all`. Actions are arguments to flavor commands, not deeper subcommands.

## Catalog Publication

Use the selected command's declared sections and flavor binding. Rigor Control has no combined catalog or default-flavor flag. Publishing one flavor never selects or publishes another.

## Guardrails

- DO NOT infer a missing flavor, mutate while its choice is pending, or enable a flavor through bare invocation.
- DO NOT use a rigor flavor to weaken explicit acceptance, safety, security, compliance, data-integrity, or authorization requirements.
- DO NOT treat out-of-scope hardening as permission to leave a known failure in the selected use-case envelope.
- DO NOT combine different flavors into one state entry or copy overrides between agents.
- DO NOT introduce another subskill level for flavors.
