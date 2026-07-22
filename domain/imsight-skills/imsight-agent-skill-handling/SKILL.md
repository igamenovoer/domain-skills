---
name: imsight-agent-skill-handling
description: Manual invocation only; Imsight-authored command skill for analyzing, deep-inspecting, designing, creating, refactor-migrating, testing, hardening, or formatting agent skills. Use only when the user explicitly invokes imsight-agent-skill-handling or asks to use this exact skill. Its subcommands are help, analyze, deep-inspect, design, create, refactor-migrate, test, harden, and format. Do not invoke implicitly for generic skill creation, skill audits, skill updates, skill-format work, routing from another skill, generic coding tasks, or ordinary use of a domain skill.
---

# Imsight Agent Skill Handling

## Overview

Use this skill as the manual entrypoint for analyzing, deep-inspecting, designing, creating, refactor-migrating, testing, hardening, and formatting agent skills. It reconstructs a skill's operational logic and durable outputs, writes analysis report sets, generates self-contained skill-process design documents for existing skills, designs new skills from user tasks before any files are created, creates new skills from user requests, migrates or refactors source skill logic into target skills with provenance, runs pressure scenarios to baseline or verify skills, hardens discipline skills against rationalization, and revises skills so their structure and descriptions conform to the bundled style guide.

## Workflow

When this skill is invoked, execute the following steps in order.

1. **Select the subcommand** from the **Subcommands** table. If no subcommand or actionable task is present, handle `help`.
2. **Resolve the target skill folder, source skill folder, or task input** when the subcommand is `analyze`, `deep-inspect`, `create`, `refactor-migrate`, `test`, `harden`, or `format`, or capture the user's task description when the subcommand is `design`. See **Target Skill Folder** for folder resolution; see `references/design.md` for intent capture and `references/refactor-migrate.md` for source-target resolution.
3. **Load the selected reference** and follow its `## Workflow`.
4. **Produce the requested result** following the selected subcommand's workflow and output contract.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the subcommands and constraints in this skill, then execute the plan.

## Invocation Contract

- Preferred explicit form: `$imsight-agent-skill-handling use <subcommand> to do <task>`.
- Task-only form: `$imsight-agent-skill-handling <task prompt>` means choose the applicable subcommand from the task.
- No subcommand and no task means `help`.
- `help` summarizes this skill and lists the subcommands below.

## Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `help` | Explain this skill and list available subcommands | This entrypoint |
| `analyze` | Default path when the user wants to understand a given skill's working logic; writes Mermaid-based Markdown reports and returns a brief ASCII workflow summary in chat | `references/analyze.md` |
| `deep-inspect` | Generate one self-contained skill-process design document for a given skill, with concepts, high-level process, skill call graph, formal process, explanation, and evidence handoffs | `references/deep-inspect.md` |
| `design` | Generate a self-contained design overview document for a proposed skill from a user task, defaulting to a multi-subcommand skill with `help`; intended for human review before `create` | `references/design.md` |
| `create` | Create a new skill from a user request; pressure testing is handled by the explicit `test` subcommand | `references/create.md` |
| `refactor-migrate` | Migrate or refactor skill logic from a source skill path into a target skill path, including in-place self-migration, while preserving source provenance and rewriting runtime instructions into Imsight style | `references/refactor-migrate.md` |
| `test` | Run pressure scenarios with subagents to baseline or verify a skill | `references/test.md` |
| `harden` | Add rationalization tables, red flags, and explicit counters to a discipline skill | `references/harden.md` |
| `format` | Revise a given skill so its structure conforms to the bundled style guide and its description is optimized for discovery | `references/format.md` |

## Target Skill Folder

Use the skill folder explicitly provided by the user. If none is provided:

1. If the prompt names a skill, search the current project and known skill homes for an exact folder or frontmatter `name` match.
2. Otherwise, use the current working directory if it contains one runtime entrypoint candidate: `SKILL.md` or `SKILL-MAIN.md`.
3. If multiple candidates remain, ask the user which skill to target.

Resolve the target entrypoint by role:

- A standalone or host-discoverable skill root uses `SKILL.md`.
- A parent-scoped skill below `subskills/<subskill-name>/` uses `SKILL-MAIN.md`; its parent must load that file explicitly. Inspection and migration may read a nested `SKILL.md` only as a legacy input, while creation and formatting normalize it to `SKILL-MAIN.md` without leaving a compatibility copy.
- A preserved upstream entrypoint below `org/src/` uses `SKILL-SOURCE.md` and is provenance, not a runtime entrypoint.
- `analyze`, `deep-inspect`, and the source side of `refactor-migrate` may read an explicitly selected `SKILL-SOURCE.md`; mutation-oriented target workflows must not treat it as the target runtime entrypoint.
- If a target folder contains both `SKILL.md` and `SKILL-MAIN.md`, stop and report the ambiguous scope contract rather than choosing one silently.

## Guardrails

- DO NOT invoke this skill unless the user explicitly names it.
- DO NOT analyze or format a parent skillset directory as a single skill unless the user explicitly asks for a suite-level operation.

## Maintenance

Keep this entrypoint as a small router. Add detailed procedures to subcommand references. Keep bundled prose style rules in `references/imsight-skill-style-guide.md` and shared Mermaid style rules in `references/mermaid-style.md` so this skill does not depend on files outside its own directory.
