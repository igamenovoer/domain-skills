---
name: imsight-mentality-mgr
description: Use when an Imsight mentality request concerns catalogs, project or agent-memory rules, Agile Experimenter evidence sufficiency, Ponytail intensity and edit scope, effective mentality recall, or explicit Brooks or Ponytail reviews, or when applicable work has resolved mentality rules. Do not use for ordinary factual memory or unrelated preferences.
metadata:
  skill_invocation_notation: >
    Invoke skills and subskills as bare paths (`X`, `X->Y`). Append `()` to
    every subcommand component (`X->cmd()`, `X->Y->cmd()`,
    `X->parent()->child()`). Intermediate commands establish their declared
    child context; arguments follow the invocation path. This convention
    applies throughout this skill and its subskills.
---

# Imsight Mentality Manager

## Overview

Manage named mentalities, their principle catalogs, project-wide selections, and agent-local overrides. Shared catalogs document what each principle means; project instructions select shared defaults; each agent remembers its own overrides. Multiple agents can use the same catalogs and `AGENTS.md` while applying different principles. Brooks and Ponytail provide explicit reviews; Ponytail also separates simplification intensity from permission to revise existing task-related infrastructure.

## Workflow

1. **Resolve intent** using **Invocation** and **Subcommands**.
2. **Select mentalities** from **Subskills**. Load only the named child's `SKILL-MAIN.md` and required resources; unqualified recall covers all registered mentalities.
3. **Resolve scope and selectors** through the child's selector reference and [runtime-injection.md](references/runtime-injection.md). Load child-specific configuration or review contracts when selected; validate both Ponytail axes independently before mutation.
4. **Execute the action** using its linked detail section. For ordinary applicable work, resolve effective rules and apply [composition.md](references/composition.md); an explicit review follows its own diagnostic workflow.
5. **Report the result** with canonical rule IDs, affected scope, and actual file effects. Identify project paths when they are relevant to the requested result.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the registered mentalities, declared actions, and scope boundaries without inventing a state change.

## Invocation

Bare invocation shows help and registered mentalities; a named child alone recalls that mentality and shows concise help. `recall` without a mentality covers all registered children.

Shared actions take the mentality and selectors as arguments, such as `imsight-mentality-mgr->enable-project()` with `brooks r1 r5`. A child preselects its mentality, such as `imsight-mentality-mgr->brooks->enable-memory()` with `r1 r5`. Natural wording uses the same actions: “deploy these principles,” “enable/disable in project scope,” “remember and apply” or “enable/disable in your memory,” and “recall the effective Imsight mentality.”

Enable/disable requires a named mentality, explicit selectors, and a clear project or memory scope. Use `all` explicitly; omitted selectors never mean all rules. Validate the complete request before changing state. If scope is ambiguous, clarify it without mutation; prior actions or an existing `AGENTS.md` do not choose the scope.

Review and Ponytail configuration are child-specific actions. Route “review this with Brooks/Ponytail” to that child's review, not activation; use each child's action reference for arguments and defaults.

## Subcommands

These are peer actions, not required phases. Definitions are shared here; children supply their own selectors, catalogs, and applicability. Child-specific review and configuration procedures are listed in each child's subcommand table.

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `deploy` | Publish complete catalogs, declared offline sources, and project discovery references without enabling rules. | [Deploy](references/actions.md#deploy) |
| `enable-project` | Add selected principles to project-wide requirements in `AGENTS.md`. | [Enable Project](references/actions.md#enable-project) |
| `disable-project` | Remove selected principles from project-wide requirements. | [Disable Project](references/actions.md#disable-project) |
| `enable-memory` | Remember explicit enabled overrides for this agent's chat session. | [Enable Memory](references/actions.md#enable-memory) |
| `disable-memory` | Remember explicit disabled overrides, including for project-enabled principles. | [Disable Memory](references/actions.md#disable-memory) |
| `recall` | Report project selections, remembered overrides, and effective principles. | [Recall](references/actions.md#recall) |
| `help` | Explain mentalities, actions, selectors, and scope precedence without changing state. | This entrypoint |

## Subskills

| Mentality | When to Route Here | Load |
| --- | --- | --- |
| `brooks` | Choose Brooks for maintainable production-code decisions and test design, or to explicitly review existing code through those principles. | [Brooks](subskills/brooks/SKILL-MAIN.md) |
| `ponytail` | Choose Ponytail to simplify implementations through reuse and removal, with explicit intensity and boundaries for changing existing infrastructure, or to review those opportunities. | [Ponytail](subskills/ponytail/SKILL-MAIN.md) |
| `docs-writer` | Choose Docs Writer principles for durable prose whose main text should describe its current state without incidental revision history. | [Docs Writer](subskills/docs-writer/SKILL-MAIN.md) |
| `agile-experimenter` | Choose Agile Experimenter for experiment scope, evidence sufficiency, and stopping decisions. | [Agile Experimenter](subskills/agile-experimenter/SKILL-MAIN.md) |

An unknown mentality is an error; list registered names instead of guessing. New mentalities belong beside these children and own their principle catalogs and selector vocabularies.

## Scope Contract

- **Deployed catalogs** live at `.imsight-arts/mentality/<mentality>-principles.md` and contain the complete definitions, examples, and judgment notes. Declared source bundles are copied into project-local `sources/` directories and linked from the catalogs for offline use. A catalog, source file, or discovery reference never enables a principle.
- **Project selection** lives in a separate managed `AGENTS.md` block and changes only through an explicitly requested project action.
- **Agent memory** contains this agent's explicit enabled and disabled overrides. Neither kind of override is written to shared files or automatically assigned to another agent.
- **Effective selection** follows agent overrides first, then project selection, then disabled by default. Applicability and conflict resolution determine which selected guidance applies to the task.
- **Child settings** follow the child's schema. Ponytail intensity expands into canonical rule IDs; edit scope resolves independently from agent memory, then project settings, then `new-code-only`. Neither deployment nor an edit-scope setting enables rules.
- **Review criteria** default to effective selection. Explicit review selectors replace criteria for that invocation only; they never enable rules, alter memory, or change subsequent recall. Saved review evidence is not an activation source. Child edit boundaries also constrain recommendations.

Full storage, precedence, concurrency, and context-handoff rules live in [runtime-injection.md](references/runtime-injection.md). Action workflows and output examples live in [actions.md](references/actions.md).

## Maintenance

Keep shared action and scope semantics in the parent references. [review-common.md](references/review-common.md) owns shared review selection, target discovery, coverage, and report storage. Children own canonical IDs, examples, domain judgment, and any configuration schema or additional edit boundary. Bundle runtime resources and relevant source material inside this skill. Link maintained guidance to local source records; keep origin URLs inside those records. Preserve original archives under `org/` and declare the source files needed for offline catalog deployment.

## Guardrails

- DO NOT treat catalog deployment or skill discovery as activation.
- DO NOT write files for memory actions, recall, or help.
- DO NOT persist one agent's effective selection as project-wide rules.
- DO NOT erase a remembered disabled override by treating it as absent.
- DO NOT let one agent's memory action change another agent's overrides.
- DO NOT load every child's full catalog to handle one selected mentality.
- DO NOT imply that a skill invocation installs runtime hooks or guarantees memory across context loss.
- DO NOT let mentality guidance override unrelated repository instructions or higher-priority instructions.
- DO NOT require online source retrieval to apply, recall, review, or deploy bundled principles.
