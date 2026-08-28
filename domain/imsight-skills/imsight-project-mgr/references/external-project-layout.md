# External Project Layout

This policy defines the documented `extern/` taxonomy shared by project structuring, external-resource setup, and persistent sibling-worktree exposure.

## Standard Layout

```text
extern/
├── README.md
├── .gitignore
├── tracked/
│   └── README.md
├── orphan/
│   └── README.md
└── trees/
    └── README.md
```

Projects may add other immediate subdirectories such as `resources/`. Every immediate `extern/<subdir>/` must contain a tracked `README.md` that explains its role and current logical contents.

## Directory Purposes

- `extern/tracked/` contains pinned third-party code represented by tracked files, vendored sources, or Git submodules.
- `extern/orphan/` contains ignored local-only or disposable third-party checkouts used for research, comparison, or evidence gathering. Project runtime code and build configuration must not depend on them.
- `extern/trees/` contains ignored symlinks to persistent sibling Git worktrees. The links let developers and agents browse long-running parallel workers from the current repository without making the target part of this repository. Do not expose temporary in-repo worktrees here.
- Another immediate subdirectory must define its own tracking, ownership, setup, and runtime-dependency policy in its README.

## README Contract

Create or reconcile `extern/README.md` as the index for the complete external layout. It must identify each immediate subdirectory, its tracking status, its purpose, and the document or command that explains setup and cleanup. When useful, use a table with `Path`, `Status`, `Purpose`, and `Setup` columns.

Create or reconcile `extern/<subdir>/README.md` for every immediate subdirectory. Each README must explain:

- what belongs in the subdirectory and what does not;
- whether entries, links, metadata, or source contents are tracked or ignored;
- the current logical entries and why the project uses them;
- upstream identity, revision, branch, or ownership information needed to understand an entry;
- how to initialize, recreate, verify, update, or remove an entry safely;
- whether project code, builds, tests, or CI may depend on the entries.

Preserve established project-specific documentation. Reconcile indexes when entries or immediate subdirectories are added, removed, renamed, or repurposed. Use repository-relative paths and portable commands in committed documentation. Do not record credentials, private URLs, or machine-specific absolute targets.

## Tracking and Ignore Contract

Use narrow ignore rules that preserve the documentation control plane. The standard `extern/.gitignore` baseline is:

```gitignore
orphan/*
!orphan/README.md
trees/*
!trees/README.md
```

Adapt the policy for additional subdirectories without ignoring tracked documentation or metadata. The README itself keeps each standard directory in Git, so do not create a new `.gitkeep` beside it. Preserve an existing placeholder unless its cleanup is explicitly in scope.

Verify ignored content and trackable documentation with `git check-ignore -v`, `git status --short --untracked-files=all`, and `git ls-files` as appropriate.

## Linked Worktree Contract

Treat each `extern/trees/<name>` entry as a view into a persistent sibling Git worktree. It is never vendored code, a submodule, a runtime dependency, or permission to mutate the linked project outside the user's task. The link represents a durable worker identity rather than an individual feature branch.

When creating an exposed link:

1. Resolve the exact worktree and confirm the destination name is unused.
2. Prefer a relative symlink when the source repository and worktree have a stable relative relationship; otherwise create an explicit link without placing the absolute target in committed documentation.
3. Verify the link with `readlink`, resolve it with `realpath`, and confirm the target is the intended Git worktree.
4. Confirm `extern/trees/*` ignores the link while `extern/trees/README.md` remains trackable.
5. Update `extern/README.md` and `extern/trees/README.md` with the logical name, project relationship, purpose, branch or ref when stable, and recreation or removal method.

Create exposed worktrees with `create-sibling-worktree`. Temporary worktrees created by `create-in-repo-worktree` or `impl-in-repo-worktree` remain unexposed. Remove a persistent link only through the verified cleanup in `retire-worktree` or through an explicit repair of a broken link.

Exclude linked trees from broad parent-project searches, formatting, builds, tests, and recursive Git operations unless the user explicitly places a named tree in scope. Run Git commands for a linked tree from its own root and report its changes separately.
