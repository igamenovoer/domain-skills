---
name: realwork-project-mgr
description: Use when a functional checkout needs initialization, structure, acquisition controls, agent usage guidance, product release, or temporary in-repo Git worktrees for standalone parallel development; metaproj workspaces and attached realwork submodules belong to the meta manager.
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

Maintain the functional project, including experiments, verification, and temporary in-repo worktrees for bounded parallel tasks in standalone realwork repositories. Multi-branch submodule topologies and shared meta engineering environments belong to `meta-project-mgr`. Apply the parent's [responsibility contract](../../references/project-responsibilities.md).

## Workflow

1. **Resolve the target and detect project topology.** Honor the selected checkout and branch. Run `scripts/detect_project_kind.sh` and check [project-topology-detection.md](references/project-topology-detection.md) before worktree or workspace-scoped work: at a `meta-project` root require a named registered realwork (or route parallel checkouts to `meta-project-mgr`), and allow temporary in-repo worktrees only for `standalone-realwork` checkouts.
2. **Inspect existing contracts.** Read its `AGENTS.md`, package/build metadata, usage docs, tests, and optional enclosing meta guidance.
3. **Select a command** from **Subcommands** and load its page.
4. **Use the correct environment.** Prefer explicit meta activation with the selected realwork when attached. For standalone temporary worktrees, follow [worktree-local-state-policy.md](references/worktree-local-state-policy.md); without meta, preserve or manually provision the requested standalone setup without guessing missing development resources.
5. **Execute and verify** only the requested functional setup, temporary worktree, rules, resource controls, or release work, and report prerequisites that remain unprovisioned.

If the request does not match one command, use the native planning tool to combine the relevant procedures. Route `meta-project` and `attached-realwork` parallel-checkout management, migration, and shared development setup to `imsight-project-mgr->meta-project-mgr`.

## Subcommands

| Subcommand | Use for | Detail |
| --- | --- | --- |
| `structure-project` | Create or reconcile functional source, tests, metadata, and usage documentation. | [structure-project.md](commands/structure-project.md) |
| `init-pixi-project` | Explicitly provision a standalone functional Python checkout with Pixi; attached checkouts use meta instead. | [init-pixi-project.md](commands/init-pixi-project.md) |
| `setup-external-ref-dir` | Maintain functional model/dataset/source acquisition controls without committing payloads. | [setup-external-ref-dir.md](commands/setup-external-ref-dir.md) |
| `setup-project-rules` | Select relevant agent rules and place them at the correct owner. | [setup-project-rules.md](commands/setup-project-rules.md) |
| `declare-universal-rules` | Apply the bundled rule set with explicit development-versus-usage ownership. | [declare-universal-rules.md](commands/declare-universal-rules.md) |
| `create-in-repo-worktree` | Create a temporary clean Git worktree inside a standalone realwork repository and link eligible local state. | [create-in-repo-worktree.md](commands/create-in-repo-worktree.md) |
| `impl-in-repo-worktree` | Implement and verify one change on a fresh isolated branch in a temporary in-repo worktree of a standalone realwork repository. | [impl-in-repo-worktree.md](commands/impl-in-repo-worktree.md) |
| `inspect-worktrees` | Report registered worktrees, lifecycle kind, branch divergence, and linked `.pixi` state without modifying them. | [inspect-worktrees.md](commands/inspect-worktrees.md) |
| `retire-worktree` | Safely retire a temporary in-repo worktree while preserving reachable work and leaving linked target directories intact. | [retire-worktree.md](commands/retire-worktree.md) |
| `github-release` | Prepare and publish a verified release of an explicit functional revision. | [github-release.md](commands/github-release.md) |
| `help` | Explain these commands, topology detection, and the development-workspace boundary. | This entrypoint |

`structure-project` owns functional layout; shared Pixi setup and `realworks/` submodule checkouts belong to `meta-project-mgr`. Temporary in-repo worktrees (`create-in-repo-worktree`, `impl-in-repo-worktree`, `inspect-worktrees`, `retire-worktree`) provide parallel isolation when a repository is a `standalone-realwork` checkout rather than a `meta-project` or `attached-realwork`.

## Project Topology Detection

Before creating temporary worktrees, verify repository kind using `bash <realwork-skill-dir>/scripts/detect_project_kind.sh --repo <target>` and [project-topology-detection.md](references/project-topology-detection.md). Look for metaproj-specific signatures (`realworks/` submodules in `.gitmodules`, `meta_configs/workspace.toml`, `meta_src/`, `meta_scripts/`, `meta_configs/`, the `metaproj` branch without root `src/`, or an enclosing metaproj superproject) rather than generic directories like `context/`, `openspec/`, `docs/`, `skillset/`, or `extern/`. Route `meta-project` and `attached-realwork` targets to `imsight-project-mgr->meta-project-mgr->manage-realworks()`.

## Guardrails

- DO NOT add planning, agent-skill, OpenSpec, or shared engineering roots to an attached realwork.
- DO NOT create temporary in-repo worktrees when project topology detection identifies `meta-project`, `attached-realwork`, or `ambiguous`, or when already inside a linked Git worktree.
- DO NOT create persistent sibling worktrees, `.proj-local/goal.md`, or `extern/trees/` symlinks.
- DO NOT mutate the original checkout after `impl-in-repo-worktree()` creates an isolated worktree, or retire a worktree with `rm -rf` or `git worktree remove --force`.
- DO NOT treat usable experiments, feature tests, or operational scripts as development tooling solely because they are outside the package.
- DO NOT satisfy a functional dependency with an undeclared meta reference checkout.
- DO NOT create parallel checkouts or change shared environment state as a side effect of product setup.
- DO NOT claim runtime or release verification beyond the checks actually run.
