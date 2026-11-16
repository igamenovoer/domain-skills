---
name: realwork-project-mgr
description: Use when a selected functional checkout needs project initialization, structure, acquisition controls, agent usage guidance, or a verified product release; parallel development and shared engineering setup belong to the meta manager.
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

# Realwork Project Manager

## Overview

Maintain the functional project, including experiments and verification that demonstrate its behavior. This child owns product-facing setup and release procedures, not the topology used to parallelize development. Apply the parent's [responsibility contract](../../references/project-responsibilities.md).

## Workflow

1. **Resolve the realwork.** Honor the selected checkout and branch. At a meta root require a named registered realwork; never silently choose `main`.
2. **Inspect existing contracts.** Read its `AGENTS.md`, package/build metadata, usage docs, tests, and optional enclosing meta guidance.
3. **Select a command** from **Subcommands** and load its page.
4. **Use the correct environment.** Prefer explicit meta activation with the selected realwork. Without meta, preserve or manually provision the requested standalone setup; never guess missing development resources.
5. **Execute and verify** only the requested functional setup, rules, resource controls, or release work, and report prerequisites that remain unprovisioned.

If the request does not match one command, use the native planning tool to combine the relevant procedures. Route parallel-checkout management, migration, and shared development setup to the meta manager.

## Subcommands

| Subcommand | Use for | Detail |
| --- | --- | --- |
| `structure-project` | Create or reconcile functional source, tests, metadata, and usage documentation. | [structure-project.md](commands/structure-project.md) |
| `init-pixi-project` | Explicitly provision a standalone functional Python checkout with Pixi; attached checkouts use meta instead. | [init-pixi-project.md](commands/init-pixi-project.md) |
| `setup-external-ref-dir` | Maintain functional model/dataset/source acquisition controls without committing payloads. | [setup-external-ref-dir.md](commands/setup-external-ref-dir.md) |
| `setup-project-rules` | Select relevant agent rules and place them at the correct owner. | [setup-project-rules.md](commands/setup-project-rules.md) |
| `declare-universal-rules` | Apply the bundled rule set with explicit development-versus-usage ownership. | [declare-universal-rules.md](commands/declare-universal-rules.md) |
| `github-release` | Prepare and publish a verified release of an explicit functional revision. | [github-release.md](commands/github-release.md) |
| `help` | Explain these commands and the development-workspace boundary. | This entrypoint |

`structure-project` owns functional layout; shared Pixi setup and parallel checkouts belong to the meta manager. A standalone clone supports end-user operation, experimental use, and feature verification after dependencies and resources are provided. Developers may prepare their own development environment or use the meta project's shared setup.

## Guardrails

- DO NOT add planning, agent-skill, OpenSpec, or shared engineering roots to an attached realwork.
- DO NOT treat usable experiments, feature tests, or operational scripts as development tooling solely because they are outside the package.
- DO NOT satisfy a functional dependency with an undeclared meta reference checkout.
- DO NOT create parallel checkouts or change shared environment state as a side effect of product setup.
- DO NOT claim runtime or release verification beyond the checks actually run.
