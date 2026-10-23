---
name: imsight-project-subagents
description: Use when the user explicitly invokes imsight-project-subagents or another loaded skill routes the creation, teaching, or standardization of project-level coding-agent subagent definitions (custom reviewer, coder, or task-specific sub-agents) for a specific agent runtime, including model-agnostic definitions and a user-owned model-binding handoff. Do not invoke implicitly for generic coding or delegation tasks.
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

# Imsight Project Subagents

## Overview

Use this skill as the manually invoked or internally routed entrypoint for teaching an agent how to equip a project with custom subagent definitions: named, purpose-scoped sub-agents (for example a default coder, an escalation coder for repeatedly failing problems, a planner, or a deep reviewer) that the main agent delegates to. Each supported agent runtime has its own definition format and discovery locations, and its own place where the user binds models, so the runtime-specific procedure and handoff live in a bundled subskill.

## When to Use

- Use only when the user explicitly invokes `imsight-project-subagents` or another loaded skill explicitly routes a subagent-authoring operation here.
- Use to create a project's subagent roster from scratch, to add one new subagent definition to an existing roster, or to port a proven roster from one project into another.
- Use to standardize project subagent definitions and hand off model binding to the user's runtime instruction file.
- Do not activate implicitly for generic coding, delegation, or review tasks that merely happen to involve subagents at runtime.

## Workflow

When this skill is invoked, execute the following steps in order.

1. **Confirm invocation eligibility**. Continue only when the user explicitly invoked `imsight-project-subagents` or another loaded skill explicitly routed the operation here. See **Invocation Contract**.
2. **Identify the target agent runtime** (for example Kimi Code CLI) and the target project root. Use the user-provided project directory, or the current repository root when the task clearly targets it.
3. **Select the matching subskill** from **Subskills**. If no subskill covers the runtime, stop and report the gap rather than inventing a format.
4. **Load only the selected subskill's `SKILL-MAIN.md`** and the local resources it explicitly requires, then follow its workflow step by step.
5. **Report the result** using the subskill's output contract: definitions written, the suggested model-binding handoff, and the validation result.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the subskills and constraints in this skill, then execute the plan.

## Invocation Contract

- Preferred explicit form: `$imsight-project-subagents <task prompt>` means choose the applicable subskill from the task.
- Direct subskill form: invoke skill `imsight-project-subagents->kimi-code-subagents` with the target project and the requested subagent roster.
- Routed form: another loaded skill may explicitly route a subagent-authoring operation to `imsight-project-subagents` with the target runtime, project root, and request body.
- No actionable task means `help`, which summarizes this skill and lists the subskills below.

## Subskills

| Subskill | When to Route Here | Entrypoint |
| --- | --- | --- |
| `kimi-code-subagents` | Route here when the target runtime is Kimi Code CLI and the deliverable is model-agnostic Markdown agent definition files, including a ready-to-adapt default-coder, expert-coder, planner, and reviewer roster, and a suggested model-binding handoff for the user's Kimi `AGENTS.md`. | `subskills/kimi-code-subagents/SKILL-MAIN.md` |

Load only the selected subskill's `SKILL-MAIN.md` and the local resources it explicitly requires.

## Guardrails

- DO NOT activate this skill for a task that did not name it or was not routed from another skill.
- DO NOT author subagent definitions for a runtime without loading that runtime's subskill; formats and model-binding handoff locations differ per runtime.
- DO NOT choose or write model bindings for the user's subagents; the runtime subskill only suggests where the user can bind them.
- DO NOT treat bundled agent templates as drop-in finals; each subskill defines the adaptation step for the target project.

## Maintenance

Keep this entrypoint as a compact router. Add one bundled subskill per supported agent runtime, each owning its private templates and reference material under `subskills/<runtime>-subagents/`.
