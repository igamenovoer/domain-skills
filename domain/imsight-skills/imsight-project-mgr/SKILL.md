---
name: imsight-project-mgr
description: Use when the user explicitly invokes imsight-project-mgr or another loaded skill routes a supported project-foundation or project-development operation to it. Covers Pixi/Python project initialization and structure, universal project rules, clean Git worktrees, and isolated implementation. Do not invoke implicitly for generic project tasks or from Imsight context alone.
---

# Imsight Project Manager

## Overview

Use this skill as the manually invoked or internally routed entrypoint for Imsight project-foundation and project-development operations. It preserves the established public operations without absorbing project exploration, feature design, automation, host setup, networking, or miscellaneous infrastructure.

## When to Use

- Use only when the user explicitly invokes `imsight-project-mgr` or another loaded skill routes a supported operation here.
- Use for the project-foundation and isolated-development operations in **Subcommands**.
- Do not activate implicitly for generic project work or from Imsight context alone.

## Workflow

When this skill is invoked, execute the following steps in order.

1. **Confirm invocation eligibility**. Continue only when the user explicitly invoked `imsight-project-mgr` or another loaded skill explicitly routed the operation here. See **Invocation Contract**.
2. **Select the subcommand** from **Subcommands**. If no subcommand or actionable task is present, handle `help`.
3. **Resolve the project root** when the selected operation needs one. Use the user-provided project directory, or the current repository root when the task clearly targets it.
4. **Load the linked command page** and follow its `## Workflow` step by step.
5. **Report the result** using the selected command's output and safety contract.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the subcommands, ownership boundaries, and constraints in this skill, then execute the plan.

## Invocation Contract

- Preferred explicit form: `$imsight-project-mgr use <subcommand> to do <task>`.
- Task-only explicit form: `$imsight-project-mgr <task prompt>` means choose the narrowest applicable subcommand or necessary sequence.
- Routed form: another loaded skill may explicitly route a supported operation to `imsight-project-mgr` with the target and request body.
- No subcommand and no actionable task means `help`.
- Do not activate this skill implicitly for generic project work or merely because the prompt or context mentions Imsight.

## Output Contract

When this skill writes skill-owned notes, reports, or manifests, resolve the output directory in this order:

1. Use the output location explicitly provided by the user or routing skill.
2. Otherwise, use `IMSIGHT_SKILL_OUTPUT_DIR` when set; resolve relative values from the project root and use absolute values as-is.
3. Otherwise, use `<project-root>/.imsight-arts/project-mgr/`.

This contract does not replace intentional project-foundation edits in the target repository. Clean worktrees remain under `<project-root>/.imsight-arts/worktrees/` by default, and isolated implementation homes remain under `<project-root>/.imsight-arts/impl-branches/` by default.

## Subcommands

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `init-pixi-project` | Perform first-time Pixi/Python initialization, then reconcile the standard project structure | `commands/init-pixi-project.md` |
| `structure-pixi-project` | Initialize, scaffold, review, or normalize a Pixi-managed Python project | `commands/structure-pixi-project.md` |
| `declare-universal-rules` | Add or refresh Imsight universal rules in a coding-agent project context file | `commands/declare-universal-rules.md` |
| `create-worktree` | Create a clean Git worktree and safely reuse eligible local state | `commands/create-worktree.md` |
| `impl-in-worktree` | Implement and verify a change on a fresh local branch in an isolated worktree | `commands/impl-in-worktree.md` |
| `help` | Explain this skill, its invocation restriction, categories, and public subcommands | This entrypoint |

Each operational subcommand is independently invocable; the table order does not impose a lifecycle.

## Ownership Boundaries

- Route requirements exploration and domain-language decisions to `imsight-project-explore`.
- Route staged feature and interface design to `imsight-project-design`.
- Route maintained one-pass development automation to `imsight-project-automation`.
- Route development-host setup and installation to `imsight-dev-box-init`.
- Route networking to `imsight-dev-box-network` and miscellaneous infrastructure to `imsight-project-misc`.
- Within `impl-in-worktree`, this skill owns the isolated branch, worktree, verification, and local-delivery boundary. The native coding workflow or explicitly named domain skill owns implementation logic.

## Guardrails

- DO NOT activate this skill for an ordinary project request that did not name it or was not routed from another skill.
- DO NOT treat the two subcommand categories as required phases.
- DO NOT rename, hide, or omit `init-pixi-project` or any other public subcommand; these names are part of the command contract.
- DO NOT mutate the original checkout after `impl-in-worktree` creates an isolated worktree.

## Maintenance

Keep this entrypoint as a compact router. Put executable subcommand workflows in `commands/`, shared policy in `references/`, and deterministic helpers in `scripts/`.
