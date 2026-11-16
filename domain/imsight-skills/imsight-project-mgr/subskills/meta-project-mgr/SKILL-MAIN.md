---
name: meta-project-mgr
description: Use when creating or migrating a metaproj development workspace, managing functional branch submodules under realworks, configuring shared environments/resources, or verifying parallel source isolation.
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

# Meta Project Manager

## Overview

Create the development workspace around functional branch checkouts. Use the [responsibility contract](../../references/project-responsibilities.md) and [Git lifecycle](references/git-lifecycle.md). Parallelism comes from independent registered submodules, explicit source selection, compatible shared environments, and coordinated meta edits.

## Workflow

1. **Resolve the workspace and intent.** Identify new setup, migration, checkout lifecycle, configuration, or verification. Existing product roots are migration inputs, not disposable scaffolds.
2. **Inspect ownership and state.** Read guidance, refs/remotes, submodules, local changes, environment definitions, and resource consumers. Separate functional source from shared development material.
3. **Select a command** from **Subcommands** and load its page; retain its explicit target and action through execution.
4. **Coordinate shared edits.** Establish one owner for overlapping meta files and retain separate realworks for concurrent product tasks.
5. **Verify and report.** Name checked-out revisions, gitlink changes, resource bindings, executed checks, and remaining limits. Keep publication/removal separate unless requested.

For cross-cutting requests, plan a sequence of these routines; do not turn every routine into a compulsory setup phase.

## Subcommands

| Subcommand | Use for | Detail |
| --- | --- | --- |
| `init-meta-project` | Initialize a Pixi-managed metaproj with a selected set of realwork branch submodules; defaults to `main`. | [init-meta-project.md](commands/init-meta-project.md) |
| `migrate-project` | Lift development out of an existing combined project while preserving source and local state. | [migrate-project.md](commands/migrate-project.md) |
| `manage-realworks` | List, inspect, create/register, restore a pin, record a pin, integrate commits, or remove an explicit checkout. | [manage-realworks.md](commands/manage-realworks.md) |
| `configure-workspace` | Reconcile environments, explicit command dispatch, agent routing, and resource variables. | [configure-workspace.md](commands/configure-workspace.md) |
| `verify-workspace` | Verify ownership, reproducibility, functional use, and parallel source selection. | [verify-workspace.md](commands/verify-workspace.md) |
| `help` | Explain the routines, checkout identity, and required action parameters. | This entrypoint |

`manage-realworks` takes an action argument; it is not a nested command generator. The bundled [launcher template](assets/workspace.py) supports read-only listing and explicit execution, not Git mutation. Native Git procedures own creation, integration, pinning, and removal.

For a new workspace, invoke `imsight-project-mgr->meta-project-mgr->init-meta-project()` with the desired branch set. It creates the meta Pixi setup and selected realworks together, defaulting to `main` only when no set is supplied; it does not invoke the standalone realwork Pixi initializer.

## Guardrails

- DO NOT create root `src/`, publish metaproj as a product package, or put feature implementations in meta tooling.
- DO NOT use `git worktree add`, `extern/trees/`, worker anchor branches, or automatic source/environment symlinks for the new parallel-development topology.
- DO NOT overwrite dirty checkout state, existing branch history, environment values, or resource directories during migration or registration.
- DO NOT treat shared meta files as independently writable by every parallel worker.
- DO NOT conflate restoring a gitlink, integrating code, recording a pin, and publishing revisions.
