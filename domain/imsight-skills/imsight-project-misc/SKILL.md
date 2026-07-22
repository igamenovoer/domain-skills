---
name: imsight-project-misc
description: Use when explicitly invoking imsight-project-misc, routing from another Imsight skill, or using Imsight context for miscellaneous project infrastructure, development utilities, project-local Docker services, Compose service folders, or support work without a more specific Imsight owner. Do not use for generic project or Docker tasks without Imsight context.
---

# Imsight Project Misc

## Overview

Use this skill as a router for miscellaneous generic development project tasks. Keep `SKILL.md` as a first-level subcommand index and place detailed second-level subskill pages in `references/`.

## When to Use

- Use for explicit or routed `imsight-project-misc` requests.
- Use when `imsight` context requests miscellaneous project support without a more specific Imsight owner.
- Current supported work includes project-local Docker service setup.
- Do not use for generic project or Docker tasks without Imsight context.

## Workflow

1. If no subcommand or actionable task is present, handle `help`.
2. Load a named subcommand reference, or choose the applicable subcommand from a task-only request.
3. Follow the reference's discovery, file-layout, implementation, and verification steps.
4. If no matching command exists, use normal engineering judgment and consider adding a focused reference.

If the task does not map cleanly to these steps, use your native planning tool with the existing subcommands, project-directory rules, and constraints; keep work inside the requested project support scope.

## Invocation Contract

- Preferred explicit form: `$imsight-project-misc use <subcommand> to do <task>`.
- Task-only form: `$imsight-project-misc <task prompt>` means choose the applicable subcommand from the task.
- No subcommand and no task means `help`.
- `help` summarizes this skill and lists the subcommands below.

## Project Directory

Use the project directory explicitly provided by the user. If none is provided, use the current working directory after confirming it is the intended project root when the task would create files.

## Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `help` | Explain this miscellaneous project skill and list available subcommands | This entrypoint |
| `docker-service-setup` | Create project-local Docker service files under `<project-dir>/dockers/<service-name>/...` | `references/docker-service-setup.md` |

## Maintenance

Name new subskill references after the first-level subcommand, keep each reference self-contained, and avoid duplicating detailed workflows in this index.

## Guardrails

- DO NOT route work here when a more specific Imsight skill owns it.
- DO NOT create project-root Docker files for a service-local setup.
- DO NOT skip existing project-pattern and local-image discovery.
- DO NOT embed secrets.
- DO NOT overwrite existing Docker files without reading them first.
