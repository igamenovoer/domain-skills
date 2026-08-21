---
name: imsight-project-mgr
description: Use when the user explicitly invokes imsight-project-mgr or another loaded skill routes a supported project-foundation, external-resource setup, project-development, multi-change OpenSpec delivery, or GitHub release operation to it. Do not invoke implicitly for generic project tasks or from Imsight context alone.
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

# Imsight Project Manager

## Overview

Use this skill as the manually invoked or internally routed entrypoint for Imsight project-foundation and project-development operations. This includes on-demand setup of bootstrap-managed external-resource directories without coupling that operation to project initialization, plus evidence-gated multi-change OpenSpec delivery through its bundled subskill. It preserves the established public operations without absorbing project exploration, feature design, automation, host setup, networking, or miscellaneous infrastructure.

## When to Use

- Use only when the user explicitly invokes `imsight-project-mgr` or another loaded skill routes a supported operation here.
- Use for the project-foundation and isolated-development operations in **Subcommands**.
- Use to create or reconcile a documented, bootstrap-managed project directory for machine-local or third-party resources when requested independently of project initialization.
- Use for ordered implementation of multiple OpenSpec changes when each change needs application-specific evidence before the next begins.
- Use to install relevant shared rules in coding-agent project instruction files, either automatically or through rule-by-rule approval.
- Use for an explicit request to prepare and publish a project release on GitHub.
- Do not activate implicitly for generic project work or from Imsight context alone.

## Workflow

When this skill is invoked, execute the following steps in order.

1. **Confirm invocation eligibility**. Continue only when the user explicitly invoked `imsight-project-mgr` or another loaded skill explicitly routed the operation here. See **Invocation Contract**.
2. **Select the capability** from **Subcommands** or **Subskills**. If no capability or actionable task is present, handle `help`.
3. **Resolve the project root** when the selected operation needs one. Use the user-provided project directory, or the current repository root when the task clearly targets it.
4. **Load the selected capability**. For a subcommand, load the linked command page. For a subskill, load only its `SKILL-MAIN.md` and required local resources. Follow the selected workflow step by step.
5. **Report the result** using the selected capability's output and safety contract.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the subcommands, ownership boundaries, and constraints in this skill, then execute the plan.

## Invocation Contract

- Preferred explicit form: `$imsight-project-mgr use <subcommand> to do <task>`.
- Task-only explicit form: `$imsight-project-mgr <task prompt>` means choose the narrowest applicable subcommand or necessary sequence.
- Direct subskill form: invoke skill `imsight-project-mgr->impl-multi-openspec-changes` with the ordered or discoverable change set and verification requirements.
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
| `setup-external-ref-dir` | Create or reconcile a documented, bootstrap-managed home for external resources independently of project initialization | `commands/setup-external-ref-dir.md` |
| `setup-project-rules` | Inspect a project and add relevant rules to coding-agent instruction files automatically or through rule-by-rule approval | `commands/setup-project-rules.md` |
| `declare-universal-rules` | Add or refresh Imsight universal rules in a coding-agent project context file | `commands/declare-universal-rules.md` |
| `create-worktree` | Create a clean Git worktree and safely reuse eligible local state | `commands/create-worktree.md` |
| `impl-in-worktree` | Implement and verify a change on a fresh local branch in an isolated worktree | `commands/impl-in-worktree.md` |
| `github-release` | Prepare the project changelog and publish a verified GitHub release with an explicit change list | `commands/github-release.md` |
| `help` | Explain this skill, its invocation restriction, categories, and public subcommands | This entrypoint |

Each operational subcommand is independently invocable; the table order does not impose a lifecycle.

## Subskills

| Subskill | When to Route Here | Entrypoint |
| --- | --- | --- |
| `impl-multi-openspec-changes` | Route here when two or more changes must be delivered in dependency order and independently proven against the running application before later changes begin. | `subskills/impl-multi-openspec-changes/SKILL-MAIN.md` |

Load only the selected subskill's `SKILL-MAIN.md` and the local resources it explicitly requires.

## Ownership Boundaries

- Route requirements exploration and domain-language decisions to `imsight-project-explore`.
- Route staged feature and interface design to `imsight-project-design`.
- Route maintained one-pass development automation to `imsight-project-automation`.
- Route development-host setup and installation to `imsight-dev-box-init`.
- Route networking to `imsight-dev-box-network` and miscellaneous infrastructure to `imsight-project-misc`.
- Within `impl-in-worktree`, this skill owns the isolated branch, worktree, verification, and local-delivery boundary. The native coding workflow or explicitly named domain skill owns implementation logic.
- Within `github-release`, this skill owns release preparation, changelog maintenance, GitHub release publication through `gh`, and post-publication verification. Repository instructions own project-specific versioning, build, validation, signing, and asset requirements.
- Within `impl-multi-openspec-changes`, the bundled subskill owns change ordering, between-change artifact reconciliation, application-specific evidence gates, and final cross-change verification. The selected OpenSpec apply workflow owns each individual change's implementation mechanics.

## Guardrails

- DO NOT activate this skill for an ordinary project request that did not name it or was not routed from another skill.
- DO NOT treat the two subcommand categories as required phases.
- DO NOT rename, hide, or omit `init-pixi-project` or any other public subcommand; these names are part of the command contract.
- DO NOT mutate the original checkout after `impl-in-worktree` creates an isolated worktree.
- DO NOT bypass the bundled subskill's per-change evidence gate when delivering multiple OpenSpec changes.

## Maintenance

Keep this entrypoint as a compact router. Put executable subcommand workflows in `commands/`, shared policy in `references/`, and deterministic helpers in `scripts/`.
