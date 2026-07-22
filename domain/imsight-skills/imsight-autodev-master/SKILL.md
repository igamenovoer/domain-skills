---
name: imsight-autodev-master
description: Use when explicitly invoking imsight-autodev-master, routing from another Imsight skill, or using Imsight context to dispatch a maintained master workflow, raw OpenSpec invocation, or imsight-autodev-slave operation to a Houmao-managed slave. Do not use implicitly for ordinary development tasks.
---

# Imsight Autodev Master

## Overview

This skill is a master-agent entrypoint. The master agent may be any capable caller, but the target slave is expected to be a Houmao-managed agent. Keep this file small; reusable behavior belongs in the layered pages below.

## When to Use

- Use when the user explicitly invokes `imsight-autodev-master` or asks to use this exact skill.
- Use when another Imsight skill routes a maintained dispatch operation here.
- Use when `imsight` context asks for a maintained master workflow, raw OpenSpec invocation, or `imsight-autodev-slave` invocation.
- Do not activate implicitly for ordinary development tasks.

## Workflow

1. If no subcommand or actionable task is present, handle `help`: summarize this skill and list the subcommands.
2. If the request names a subcommand, follow that subcommand's linked page.
3. If the request is task-only, choose the applicable subcommand or sequence; for higher-level outcomes, read the matching layered workflow first.
4. For explicit raw OpenSpec or `imsight-autodev-slave` calls, read the matching invocation page.
5. Before dispatch, use [references/primitives/inspect-slave.md](references/primitives/inspect-slave.md) to recover the metadata required for rendering and delivery.
6. If the operation, target slave, or request body is missing or ambiguous, ask for the smallest clarification needed.
7. After a request is accepted or delivered, finish the turn by default.

If the task does not map cleanly to these steps, use your native planning tool to plan from the existing subcommands, layered pages, primitives, and guardrails; do not invent a delivery lane or broaden the requested operation.

## Invocation Contract

- Preferred explicit form: `$imsight-autodev-master use <subcommand> to do <task>`.
- Task-only form: `$imsight-autodev-master <task prompt>` means choose the applicable subcommand or sequence from the task.
- No subcommand and no task means `help`.
- `help` summarizes this skill and lists the subcommands below.

## Output Contract

When this skill writes master-side notes, reports, manifests, or other skill-owned artifacts, choose the output directory in this order:

1. Use the output location explicitly provided by the user.
2. Otherwise, use `IMSIGHT_SKILL_OUTPUT_DIR` when set; relative values are resolved from the current project directory and absolute values are used as-is.
3. Otherwise, use `<project-dir>/.imsight-arts/autodev-master/`.

This contract does not move slave-owned OpenSpec artifacts or target-workdir mutations; those remain in the target slave workspace selected by the dispatched workflow.

## Layered Pages

### Workflows

Use workflows when the user describes an outcome and the master must decide which invocation to send.

- [commands/workflows/prepare-slave-for-openspec.md](commands/workflows/prepare-slave-for-openspec.md): Ask the slave to ensure `openspec/` exists in its own workdir.
- [commands/workflows/delegated-openspec-lifecycle.md](commands/workflows/delegated-openspec-lifecycle.md): Choose whole-lifecycle delegation versus a bounded phase.
- [commands/workflows/bounded-openspec-phase.md](commands/workflows/bounded-openspec-phase.md): Dispatch one explicit OpenSpec phase.
- [commands/workflows/continue-existing-change.md](commands/workflows/continue-existing-change.md): Continue an existing OpenSpec change from known state.
- [commands/workflows/recover-or-finalize-change.md](commands/workflows/recover-or-finalize-change.md): Recover, sync, or archive partially completed OpenSpec work.

### Raw OpenSpec Invocations

Use raw invocation leaves when the master already knows the exact OpenSpec skill to invoke on the slave.

- [commands/invocations/raw-openspec/explore.md](commands/invocations/raw-openspec/explore.md): Dispatch `$openspec-explore` or `/openspec-explore`.
- [commands/invocations/raw-openspec/propose.md](commands/invocations/raw-openspec/propose.md): Dispatch `$openspec-propose` or `/openspec-propose`.
- [commands/invocations/raw-openspec/apply-change.md](commands/invocations/raw-openspec/apply-change.md): Dispatch `$openspec-apply-change` or `/openspec-apply-change`.
- [commands/invocations/raw-openspec/sync-specs.md](commands/invocations/raw-openspec/sync-specs.md): Dispatch `$openspec-sync-specs` or `/openspec-sync-specs`.
- [commands/invocations/raw-openspec/archive-change.md](commands/invocations/raw-openspec/archive-change.md): Dispatch `$openspec-archive-change` or `/openspec-archive-change`.

### Slave Skill Invocations

Use slave-skill invocation leaves for predefined `imsight-autodev-slave` operations.

- [commands/invocations/slave-skill/init-openspec.md](commands/invocations/slave-skill/init-openspec.md): Dispatch `imsight-autodev-slave init-openspec`.
- [commands/invocations/slave-skill/openspec-one-pass.md](commands/invocations/slave-skill/openspec-one-pass.md): Dispatch `imsight-autodev-slave openspec-one-pass`.

### Shared Primitives

All workflows and invocation leaves should reuse these primitives instead of duplicating dispatch rules.

- [references/primitives/inspect-slave.md](references/primitives/inspect-slave.md): Recover supported slave metadata.
- [references/primitives/render-invocation.md](references/primitives/render-invocation.md): Render Codex `$...` versus Claude `/...` command syntax.
- [references/primitives/deliver-to-slave.md](references/primitives/deliver-to-slave.md): Deliver through supported Houmao messaging surfaces.
- [references/primitives/mail-notifier-policy.md](references/primitives/mail-notifier-policy.md): Treat mail-notifier appendix text as persistent policy, not one-off mail steering.

## Subcommands

### Procedural Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `inspect-slave` | Recover supported slave metadata | `references/primitives/inspect-slave.md` |
| `init-slave-for-openspec` | Ask the slave to initialize `openspec/` | `commands/workflows/prepare-slave-for-openspec.md` |
| `openspec-one-pass` | Dispatch the slave-owned one-pass OpenSpec lifecycle | `commands/invocations/slave-skill/openspec-one-pass.md` |
| `openspec-explore` | Dispatch `$openspec-explore` or `/openspec-explore` | `commands/invocations/raw-openspec/explore.md` |
| `openspec-propose` | Dispatch `$openspec-propose` or `/openspec-propose` | `commands/invocations/raw-openspec/propose.md` |
| `openspec-apply-change` | Dispatch `$openspec-apply-change` or `/openspec-apply-change` | `commands/invocations/raw-openspec/apply-change.md` |
| `openspec-sync-specs` | Dispatch `$openspec-sync-specs` or `/openspec-sync-specs` | `commands/invocations/raw-openspec/sync-specs.md` |
| `openspec-archive-change` | Dispatch `$openspec-archive-change` or `/openspec-archive-change` | `commands/invocations/raw-openspec/archive-change.md` |

### Helper Subcommands

No helper subcommands are currently exposed. The internal primitives remain listed under **Layered Pages**.

### Misc Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `help` | Explain this master dispatch skill and list available subcommands | This entrypoint |

## Guardrails

- DO NOT guess the slave agent selector, tool lane, gateway posture, mailbox posture, or delivery lane.
- DO NOT bypass supported Houmao inspection and messaging surfaces with direct runtime file searches.
- DO NOT mix Codex `$...` syntax with Claude `/...` syntax when rendering slave commands.
- DO NOT initialize, copy, or mutate files in the slave workdir directly.
- DO NOT wait for or inspect the slave's follow-up, gateway state, mailbox state, TUI output, or results unless the user explicitly asks.
