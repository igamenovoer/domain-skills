---
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

# Inspect Worktrees

Inspect all Git worktrees registered for a standalone realwork repository without changing files, branches, refs, links, or environments. Use this command before integrating or retiring temporary in-repo worktrees.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Detect project topology first**. Run `bash <realwork-skill-dir>/scripts/detect_project_kind.sh --repo <target>` and apply [project-topology-detection.md](../references/project-topology-detection.md). If `PROJECT_KIND` is `meta-project` or `attached-realwork`, report that registered parallel checkouts are `realworks/` submodules managed by `imsight-project-mgr->meta-project-mgr->manage-realworks()` (listing any legacy linked worktrees read-only with `git worktree list --porcelain` if present).
2. **Resolve the repository and primary checkout**. Use `git worktree list --porcelain` and Git's common directory; do not infer registration from directory names alone.
3. **Classify each worktree**. Assign each registered entry using **Classification Contract**.
4. **Inspect Git state**. For every accessible worktree, report path, HEAD, branch or detached state, lock or prune state, tracked and untracked cleanliness, and submodule state when relevant. Distinguish skill-owned local-state symlinks from unexpected untracked files.
5. **Compare branches**. Resolve the requested primary branch, calculate merge bases and left/right commit counts, and report ahead or behind without fetching unless network access was requested.
6. **Inspect local environment links**. Report whether `.pixi` is absent, an independent directory, or a symlink, and inspect linked agent directories.
7. **Report health and suggested operations**. Identify stale registrations, dirty worktrees, unintegrated commits, and divergence; suggest the narrowest command without mutating state.

If the task does not map cleanly to these steps, use your native planning tool to build a read-only inspection plan from the topology, Git, lifecycle, and environment evidence in this command, then execute the plan.

## Output

Use a compact table with `Name`, `Kind`, `Path`, `Branch`, `Clean`, `Versus Primary`, and `Pixi`. Follow it with details for states that require attention, distinguishing local branch divergence from remote-tracking divergence.

## Classification Contract

- `primary`: the main worktree recorded by Git.
- `in-repo temporary`: a registered clean temporary worktree inside the primary repository, normally under `.imsight-arts/worktrees/`.
- `in-repo temporary implementation`: a registered isolated implementation worktree inside the primary repository, normally under `.imsight-arts/impl-branches/`.
- `external unclassified`: any other registered worktree. Do not relabel or manage it without evidence.

## Guardrails

- DO NOT run fetch, checkout, switch, reset, merge, rebase, prune, unlink, install, or cleanup commands.
- DO NOT follow linked worktrees in broad recursive searches; inspect each exact registered root separately.
- DO NOT claim a worktree is synchronized from working-tree cleanliness alone; compare commits.
- DO NOT treat a missing directory as safe to prune until Git's registration, lock state, and intended lifecycle are understood.

## Example Prompts

- `Use $imsight-project-mgr->realwork-project-mgr inspect-worktrees and show which temporary branches are ahead of main.`
- `Use $imsight-project-mgr->realwork-project-mgr inspect-worktrees before we retire the temporary feature worktree.`
