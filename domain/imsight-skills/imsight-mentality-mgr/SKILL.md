---
name: imsight-mentality-mgr
description: Use when an Imsight mentality request concerns principle deployment, project-wide rules, agent-local remembered rules, or effective mentality recall, or when an applicable task arrives with resolved mentality rules. Do not use for ordinary factual memory or unrelated preferences.
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
  invocation_contract: |
    - Invoke `imsight-mentality-mgr` without an action or named child to show help and registered mentalities.
    - Invoke a named child, such as `imsight-mentality-mgr->brooks`, to recall that mentality and show concise help.
    - Invoke a shared action with mentality and selectors as arguments, such as `imsight-mentality-mgr->enable-project()` with `brooks r1 r5`.
    - A child exposes the same actions with its mentality already selected, such as `imsight-mentality-mgr->brooks->enable-memory()` with `r1 r5`.
    - Invoke `imsight-mentality-mgr->recall()` without a mentality to report all registered mentalities. A named child or mentality argument filters recall.
    - Natural wording uses the same actions: `$imsight-mentality-mgr brooks deploy`, `$imsight-mentality-mgr brooks enable-project r1 r5`, or `$imsight-mentality-mgr brooks disable-memory r5`.
    - “Deploy these principles” selects `deploy`; “enable/disable in project scope” selects the corresponding project action; “remember and apply” or “enable/disable in your memory” selects the corresponding memory action; “recall the effective Imsight mentality” selects `recall`.
    - Require a named mentality and explicit rule selectors for enable/disable actions; accept `all` only within a named mentality. For several named mentalities, validate every selection before changing anything. Never interpret omitted selectors as all rules.
    - When an enable/disable request leaves its scope materially ambiguous, ask for scope without mutating state. Do not infer project scope from a prior project action or the existence of `AGENTS.md`.
---

# Imsight Mentality Manager

## Overview

Manage named mentalities, their principle catalogs, project-wide selections, and agent-local overrides. Shared catalogs document what each principle means; project instructions select shared defaults; each agent remembers its own overrides. Multiple agents can use the same catalogs and `AGENTS.md` while applying different principles.

## Workflow

1. **Resolve intent** using **Subcommands** and the frontmatter `metadata.invocation_contract`.
2. **Select mentalities** from **Subskills**. Load only the named child's `SKILL-MAIN.md` and required resources; unqualified recall covers all registered mentalities.
3. **Resolve scope and selectors** through the child's selector reference and [runtime-injection.md](references/runtime-injection.md). Validate the entire request before mutation.
4. **Execute the action** using its linked detail section. For applicable work, resolve effective rules and apply [composition.md](references/composition.md).
5. **Report the result** with canonical rule IDs, affected scope, and actual file effects. Identify project paths when they are relevant to the requested result.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the registered mentalities, declared actions, and scope boundaries without inventing a state change.

## Subcommands

These are peer actions, not required phases. Definitions are shared here; children supply their own selectors, catalogs, and applicability.

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `deploy` | Publish complete principle catalogs and their project discovery references without enabling rules. | [Deploy](references/actions.md#deploy) |
| `enable-project` | Add selected principles to project-wide requirements in `AGENTS.md`. | [Enable Project](references/actions.md#enable-project) |
| `disable-project` | Remove selected principles from project-wide requirements. | [Disable Project](references/actions.md#disable-project) |
| `enable-memory` | Remember explicit enabled overrides for this agent's chat session. | [Enable Memory](references/actions.md#enable-memory) |
| `disable-memory` | Remember explicit disabled overrides, including for project-enabled principles. | [Disable Memory](references/actions.md#disable-memory) |
| `recall` | Report project selections, remembered overrides, and effective principles. | [Recall](references/actions.md#recall) |
| `help` | Explain mentalities, actions, selectors, and scope precedence without changing state. | This entrypoint |

## Subskills

| Mentality | When to Route Here | Load |
| --- | --- | --- |
| `brooks` | Choose Brooks principles for production-code decisions and test design that should resist structural decay. | [Brooks](subskills/brooks/SKILL-MAIN.md) |
| `docs-writer` | Choose Docs Writer principles for durable prose whose main text should describe its current state without incidental revision history. | [Docs Writer](subskills/docs-writer/SKILL-MAIN.md) |

An unknown mentality is an error; list registered names instead of guessing. New mentalities belong beside these children and own their principle catalogs and selector vocabularies.

## Scope Contract

- **Deployed catalogs** live at `.imsight-arts/mentality/<mentality>-principles.md` and contain the complete definitions, examples, and judgment notes. A catalog or discovery reference never enables a principle.
- **Project selection** lives in a separate managed `AGENTS.md` block and changes only through an explicitly requested project action.
- **Agent memory** contains this agent's explicit enabled and disabled overrides. Neither kind of override is written to shared files or automatically assigned to another agent.
- **Effective selection** follows agent overrides first, then project selection, then disabled by default. Applicability and conflict resolution determine which selected guidance applies to the task.

Full storage, precedence, concurrency, and context-handoff rules live in [runtime-injection.md](references/runtime-injection.md). Action workflows and output examples live in [actions.md](references/actions.md).

## Maintenance

Keep shared action and scope semantics in the parent references. Child entrypoints link to these definitions instead of duplicating command files. Keep canonical IDs, examples, and domain judgment with each child.

## Guardrails

- DO NOT treat catalog deployment or skill discovery as activation.
- DO NOT write files for memory actions, recall, or help.
- DO NOT persist one agent's effective selection as project-wide rules.
- DO NOT erase a remembered disabled override by treating it as absent.
- DO NOT let one agent's memory action change another agent's overrides.
- DO NOT load every child's full catalog to handle one selected mentality.
- DO NOT imply that a skill invocation installs runtime hooks or guarantees memory across context loss.
- DO NOT let mentality guidance override unrelated repository instructions or higher-priority instructions.
