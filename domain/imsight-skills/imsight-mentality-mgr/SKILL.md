---
name: imsight-mentality-mgr
description: Use when an Imsight mentality request concerns catalogs, project or agent-memory rules, Human Speak communication flavors, Agile Experimenter evidence sufficiency, Ponytail intensity and edit scope, effective mentality recall, or explicit Brooks or Ponytail reviews, or when applicable work has resolved mentality rules. Do not use for ordinary factual memory or unrelated preferences.
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

1. **Resolve intent** using **Invocation** and **Subcommands**. For enable/disable requests, follow the shared [decision tree](references/actions.md#enabledisable-decision-tree).
2. **Select mentalities** from **Subskills**. Load only the named child's `SKILL-MAIN.md` and required resources. Human Speak requires an explicit flavor through its [chooser](subskills/human-speak/SKILL-MAIN.md#flavor-selection), including during unqualified recall.
3. **Resolve scope, selectors, and priorities** through the child's selector reference, [runtime-injection.md](references/runtime-injection.md), and [family priorities](references/priorities.md). Load child-specific configuration or review contracts when selected; validate both Ponytail axes independently before mutation.
4. **Execute the action** using its linked detail section. For ordinary applicable work, resolve effective rules and apply [composition.md](references/composition.md); an explicit review follows its own diagnostic workflow.
5. **Report the result** with canonical rule IDs, affected scope, and actual file effects. For memory actions and configuration, summarize the remembered behavior and its definition references or retained content through [Memory Confirmation](references/runtime-injection.md#memory-confirmation).

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the registered mentalities, declared actions, and scope boundaries without inventing a state change.

## Invocation

Bare invocation shows help and registered mentalities; a named child alone recalls that mentality and shows concise help, except Human Speak, which lists its flavors for selection. `recall` without a mentality reports ordinary children and presents the Human Speak chooser without inferring a flavor.

Shared actions take the mentality and selectors as arguments, such as `imsight-mentality-mgr->enable-project()` with `brooks r1 r5`. A child preselects its mentality, such as `imsight-mentality-mgr->brooks->enable-memory()` with `r1 r5`. Natural wording uses the same actions: “deploy these principles,” “enable/disable in project scope,” “remember and apply” or “enable/disable in your memory,” and “recall the effective Imsight mentality.”

Human Speak additionally requires a named flavor for every management invocation. Without one, list flavors with their origins and rule summaries, ask the user to choose, and retain the pending request without file or activation changes. Do not select the sole available flavor or reuse a prior choice implicitly. Flavor commands are flat: `imsight-mentality-mgr->human-speak->mark-life-style()` takes an action such as `enable-memory h1 h4` as arguments. Resolve the flavor before applying selector defaults; `all` never means every flavor.

For `enable <mentality>` and `disable <mentality>`, inspect project deployment and current selections first. Omitted scope means this agent's chat memory; omitted memory selectors mean all currently defined rules. Explicit selectors choose a subset. Deployed definitions are retained as project paths plus rule IDs; otherwise retain operative content. These defaults write no files and also apply when the project already enables some rules.

Explicit project enable/disable requires a rule selection, including `all` when intended, and includes deployment of missing or incomplete catalogs, catalog discovery, and the corresponding `AGENTS.md` application-block update. Follow the shared [decision tree](references/actions.md#enabledisable-decision-tree) for ordering and empty-block removal. Validate the complete request before effects. Clarify unresolved targets, invalid or ambiguous selectors, missing project selectors, or conflicting scope instructions; omitted enable/disable scope alone needs no clarification.

Review and Ponytail configuration are child-specific actions. Route “review this with Brooks/Ponytail” to that child's review, not activation; use each child's action reference for arguments and defaults.

## Subcommands

These are peer actions, not required phases. Definitions are shared here; children supply their own selectors, catalogs, and applicability. Child-specific review and configuration procedures are listed in each child's subcommand table.

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `deploy` | Publish self-contained catalogs and project discovery references without enabling rules. | [Deploy](references/actions.md#deploy) |
| `enable-project` | Ensure deployment and add selected project requirements in `AGENTS.md`. | [Enable Project](references/actions.md#enable-project) |
| `disable-project` | Ensure deployment and remove selected project requirements in `AGENTS.md`. | [Disable Project](references/actions.md#disable-project) |
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
| `human-speak` | Choose Human Speak for readable human-facing output using a named communication flavor; show its chooser when the flavor is missing. | [Human Speak](subskills/human-speak/SKILL-MAIN.md) |

An unknown mentality is an error; list registered names instead of guessing. New mentalities belong beside these children and own their principle catalogs and selector vocabularies.

## Scope Contract

- **Deployed catalogs** live at `.imsight-arts/mentality/<mentality>-principles.md`, using the selected target's declared storage key, and contain the complete definitions, examples, and judgment notes. Catalogs contain maintained rule explanations and original examples only; upstream reference tables stay in the skill. Human Speak isolates catalogs and state by flavor. A catalog or discovery reference never enables a principle.
- **Project selection** lives in a separate managed `AGENTS.md` block and changes only through an explicitly requested project action. Project actions include any necessary deployment and discovery updates; complete existing deployment is reused.
- **Agent memory** contains this agent's explicit enabled and disabled overrides and child settings. Memory actions write nothing and do not automatically assign overrides to another agent.
- **Definition retention** applies to every rule and switch: retain its identity, selected value, and source scope. If its details are deployed in the project, remember the project-bound path and ID/name/flag; otherwise remember the operative content. Resolve each item independently through [Definition Retention](references/runtime-injection.md#definition-retention).
- **Effective selection** follows agent overrides first, then project selection, then disabled by default. Applicability and conflict resolution determine which selected guidance applies to the task.
- **Family priority** is a nonnegative integer per selected mentality or Human Speak flavor in each scope. Each fresh enable receives the previous assigned priority plus one, including re-enables; higher values win same-scope conflicts. Agent scope still outranks project scope. Disabling preserves gaps without renumbering; see [priorities.md](references/priorities.md) for allocation, storage, and recall.
- **Child settings** follow the child's schema. Ponytail intensity expands into canonical rule IDs; edit scope resolves independently from agent memory, then project settings, then `new-code-only`. Neither deployment nor an edit-scope setting enables rules.
- **Review criteria** default to effective selection. Explicit review selectors replace criteria for that invocation only; they never enable rules, alter memory, or change subsequent recall. Saved review evidence is not an activation source. Child edit boundaries also constrain recommendations.

Full storage, precedence, concurrency, and context-handoff rules live in [runtime-injection.md](references/runtime-injection.md). Action workflows and output examples live in [actions.md](references/actions.md).

## Maintenance

Keep shared action and scope semantics in the parent references. [review-common.md](references/review-common.md) owns shared review selection, target discovery, coverage, and report storage. Children own canonical IDs, examples, domain judgment, and any configuration schema or additional edit boundary. Keep required runtime guidance and original teaching examples self-contained. Do not bundle third-party source files, snapshots, or copied code examples. Put optional upstream links and their rule mappings in separate `References` sections of child entrypoints or flavor command pages. Rule descriptions contain no source citations or pointers to those sections; routine application and deployment do not load upstream material.

## Guardrails

- DO NOT treat catalog deployment or skill discovery as activation.
- DO NOT write files for memory actions, recall, or help.
- DO NOT persist one agent's effective selection as project-wide rules.
- DO NOT erase a remembered disabled override by treating it as absent.
- DO NOT let one agent's memory action change another agent's overrides.
- DO NOT load every child's full catalog to handle one selected mentality.
- DO NOT infer a missing Human Speak flavor or treat `all` as a flavor choice.
- DO NOT imply that a skill invocation installs runtime hooks or guarantees memory across context loss.
- DO NOT let mentality guidance override unrelated repository instructions or higher-priority instructions.
- DO NOT require online source retrieval to apply, recall, review, or deploy bundled principles.
