---
name: imsight-project-mgr
description: Use when the user explicitly invokes imsight-project-mgr or another loaded skill routes project setup, a metaproj/realworks migration, branch-specific submodule development, temporary in-repo worktrees in standalone repositories, project rules, editor configuration, agent-driven instructional testing, or product release management here.
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

# Imsight Project Manager

## Overview

Manage functional projects and the development workspaces around them. See [the responsibility contract](references/project-responsibilities.md) for detailed placement and coordination rules.

## Project Definitions

A **realwork project** is a functional project checkout with four characteristics:

1. **Primarily for end users.** Its instructions, documentation, configuration, and manifests such as `pyproject.toml` or `package.json` help users install dependencies and run the provided features.
2. **Supports experimental use.** It includes usable in-development features and the instructions needed to try them, even when they are not yet part of the stable public interface.
3. **Supports verification and CI.** It includes feature tests, verification scripts, fixtures, and relevant test configuration so its functionality can be checked or exercised by CI after the required dependencies and resources are provisioned.
4. **Does not promise a complete development environment.** Developers who want to extend it prepare their own development environment or use the meta project for shared tools, environments, and development resources.

A **meta project** (`metaproj`) is a development workspace with six characteristics:

1. **Primarily for developers and agents.** Its instructions, documentation, and environment manifests support developing, verifying, and maintaining the realwork projects.
2. **Owns development knowledge.** It keeps design and planning documents, engineering decisions, agent skills, and OpenSpec specifications and change records together.
3. **Provides shared development infrastructure.** It owns development environments, engineering tools, repository policy, and CI orchestration. Compatible realworks share environments; incompatible requirements use separate environments within metaproj.
4. **Organizes parallel development.** It contains selected independent branch-specific checkouts, such as `main` and feature branches, as tracked Git submodules under `realworks/`. Commands explicitly select a realwork, while edits to shared meta files are coordinated.
5. **Shares resources with explicit isolation.** It hosts shared data, models, references, and development inputs exposed through declared resource bindings. Temporary outputs and task state are separated by realwork and run.
6. **Is not an end-user product to publish.** Product features and their tests belong in the selected realwork. Metaproj's own maintained development tools belong in `meta_src/`, experimental development scripts in `meta_scripts/`, and it has no root product `src/`.

The distinction is purpose: product functionality and its verification belong to a selected realwork; development support and coordination belong to metaproj. A request made from the meta project still implements product features in the selected realwork. When a repository is a standalone realwork rather than a metaproj workspace or attached submodule, bounded parallel tasks may use temporary in-repo worktrees through `realwork-project-mgr`.

## Workflow

1. **Confirm scope.** Continue on explicit invocation or an explicit route from a loaded skill. Honor discussion-only requests without writing reports or project files.
2. **Resolve ownership and topology.** Identify the requested functional checkout, meta workspace, or standalone project; when parallel development or temporary worktrees are requested, detect `meta-project` versus `realwork` signatures first via `subskills/realwork-project-mgr/scripts/detect_project_kind.sh`. Do not interpret the shell cwd as permission to edit every repository beneath it.
3. **Select a child** from **Subskills** and load only its `SKILL-MAIN.md` plus the linked resources needed by the request.
4. **Pass explicit context.** Include the selected checkout and branch, meta root when present, detected topology, requested operation, existing authorization, and relevant specification location.
5. **Report the result.** Distinguish files, refs, environment setup, verification, and publication actually completed from remaining work.

If the request crosses several capabilities, use the native planning tool to order the required child workflows while retaining their ownership and authorization boundaries.

## Subskills

| Subskill | When to Route Here | Entrypoint |
| --- | --- | --- |
| `realwork-project-mgr` | Route here for functional project structure, acquisition controls, project guidance, product releases, or temporary in-repo Git worktrees in standalone realwork repositories. | [SKILL-MAIN.md](subskills/realwork-project-mgr/SKILL-MAIN.md) |
| `meta-project-mgr` | Route here to create or migrate a metaproj workspace, manage realwork branch submodules, or configure shared tools and resources. | [SKILL-MAIN.md](subskills/meta-project-mgr/SKILL-MAIN.md) |
| `vscode-config` | Route here to scope editor file watching or Python analysis around authored source and large obtained/generated trees. | [SKILL-MAIN.md](subskills/vscode-config/SKILL-MAIN.md) |
| `agent-driven-testing` | Route here to author, execute, audit, or report live agent-driven verification suites under a realwork's `tests/instructional/` directory using a project-local temporary workspace. | [SKILL-MAIN.md](subskills/agent-driven-testing/SKILL-MAIN.md) |

## Subcommands

| Subcommand | Use for |
| --- | --- |
| `help` | Explain the ownership split and available children; perform no setup. |

Invoke `imsight-project-mgr->meta-project-mgr->init-meta-project()` to initialize a Pixi-managed meta workspace with a selected set of branch submodules, defaulting to `realworks/main`, or `imsight-project-mgr->meta-project-mgr->migrate-project()` for an existing combined project. Standalone functional project setup and temporary in-repo worktrees belong to `realwork-project-mgr`.

## Output and External Routes

For skill-owned reports, honor an explicit destination, then `IMSIGHT_SKILL_OUTPUT_DIR` resolved from the owning project, then `<meta-root>/.imsight-arts/project-mgr/` when attached or `<realwork-root>/.imsight-arts/project-mgr/` otherwise. Project files retain their intentional locations. Do not create a report merely to answer a discussion.

Requirements and feature design remain with `imsight-project-explore` and `imsight-project-design`; general automation with `imsight-project-automation`; host and network setup with `imsight-dev-box-init` and `imsight-dev-box-network`. Invoke only available, relevant workflows. This skill establishes workspace boundaries; the selected coding or domain workflow implements product behavior.

## Guardrails

- DO NOT invoke implicitly for generic project work or mere mention of Imsight.
- DO NOT use linked-worktree layouts, worker anchor branches, or `extern/trees/` inside a metaproj workspace or attached realwork; limit temporary in-repo worktrees to standalone realwork repositories via `realwork-project-mgr`.
- DO NOT confuse a realwork branch with the metaproj branch or advance a gitlink merely because a branch name matches.
- DO NOT infer permission to commit, push, publish, delete branches, stop services, or remove data from setup or verification alone.
