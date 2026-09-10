# Structure Pixi Python Project

Use this command to initialize, scaffold, review, or normalize a Pixi-managed Python project. Adapt names and details to the existing repository while preserving compatible project choices, including a documented external-project layout.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Resolve the project root**. Work from the Python project root, not a mega-workspace parent.
2. **Inspect existing Pixi state**. Check `pixi.lock`, `pixi.toml`, and `[tool.pixi]` in `pyproject.toml` before changing files.
3. **Choose the manifest and package names**. Preserve the existing manifest form and package name; otherwise prefer `pyproject.toml` and derive the package name from the project name.
4. **Create or reconcile the project structure**. Follow **Directory Structure**, **Directory Roles**, **Standard Files**, and `../references/external-project-layout.md` without overwriting compatible existing content.
5. **Initialize or reconcile Pixi**. Follow **Pixi Initialization** and **Pixi Test Tasks**, preserve existing dependency constraints and compatible task behavior, and add only missing requested dependencies.
6. **Validate the result**. Apply the **Review Checklist** and use `pixi run ...` for project commands when available.
7. **Report changes**. List created or updated files, preserved choices, commands run, validation results, and unresolved project decisions.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the structure, Pixi, preservation, and validation constraints in this command, then execute the plan.

## Directory Structure

```text
<project-root>/
|-- pyproject.toml
|-- pixi.lock
|-- .gitignore
|-- .github/
|   `-- workflows/
|-- src/
|   `-- <package_name>/
|       `-- __init__.py
|-- extern/
|   |-- README.md
|   |-- .gitignore
|   |-- tracked/
|   |   `-- README.md
|   |-- orphan/
|   |   `-- README.md
|   `-- trees/
|       `-- README.md
|-- scripts/
|-- tests/
|   |-- README.md
|   |-- core/
|   |   |-- unit/
|   |   |-- integration/
|   |   `-- manual/
|   `-- aux/
|       |-- unit/
|       |-- integration/
|       `-- manual/
|-- docs/
|-- context/
|   |-- plans/
|   |-- features/
|   |-- design/
|   |-- summaries/
|   `-- archived/
|-- skillset/
|   `-- README.md
`-- tmp/
```

## Directory Roles

- `.github/workflows/`: CI, documentation deployment, automated tests, and package build workflows.
- `src/<package_name>/`: importable package code.
- `extern/`: documented index of external code and related worktrees. Its README explains the taxonomy and points to every immediate subdirectory.
- `extern/tracked/`: pinned third-party code, typically Git submodules tracked through `.gitmodules`.
- `extern/orphan/`: local-only clones or checkouts that must not be committed or become runtime dependencies.
- `extern/trees/`: ignored symlinks to persistent sibling Git worktrees that developers and agents may browse from the current project. Linked workers remain independent worktrees and are not project dependencies. Temporary in-repo worktrees do not appear here.
- `scripts/`: command-line helpers and project automation.
- `tests/core/`: tests for code and artifacts that are part of the project's distribution, primarily `src/` packages and other installed or shipped runtime content.
- `tests/core/unit/`: fast deterministic tests of individual distribution components, mirroring `src/` modules where useful.
- `tests/core/integration/`: integration checks across distribution components or their supported runtime boundaries.
- `tests/core/manual/`: manually executed checks of distributed behavior that default CI and test commands should not collect.
- `tests/aux/`: tests and verification for repository-supporting content that is not part of the distribution, such as `scripts/`, documentation tooling or examples under `docs/`, CI helpers, and development automation.
- `tests/aux/unit/`: fast deterministic tests of individual auxiliary components.
- `tests/aux/integration/`: filesystem, toolchain, documentation-build, or multi-component checks for auxiliary project content.
- `tests/aux/manual/`: manually executed checks of auxiliary workflows that default CI and test commands should not collect.
- `docs/`: Markdown documentation source, typically suitable for MkDocs Material.
- `context/`: durable project knowledge for agents and developers, separated by purpose from user-facing documentation.
- `context/plans/`: actionable implementation, migration, refactor, and investigation plans.
- `context/features/`: feature-planning bundles such as requirements, use cases, interface designs, and implementation handoffs.
- `context/design/`: project goals, architecture sketches, system designs, design analyses, and technical decision material.
- `context/summaries/`: durable synthesized summaries of investigations, sessions, systems, or external material.
- `context/archived/`: superseded or historical context retained for reference but excluded from the active working set.
- `skillset/`: project-specific agent skills.
- `tmp/`: disposable working files.

## Standard Files

Create `src/<package_name>/__init__.py` with a short module docstring. Add `extern/.gitignore` with:

```gitignore
orphan/*
!orphan/README.md
trees/*
!trees/README.md
```

Create or reconcile `extern/README.md` and one `README.md` in every immediate `extern/<subdir>/`, including `tracked/`, `orphan/`, and `trees/`. Follow the inventory and tracking-status contract in `../references/external-project-layout.md`. The README retains the directory in Git, so do not add a new `.gitkeep` beside it.

Ensure the project `.gitignore` includes:

```gitignore
.pixi/
tmp/
```

Do not add `.git/` to `.gitignore` unless it matches an existing local standard. Add `skillset/README.md` explaining that project-specific agent skills live there and use `<project-slug>-<what>` names.

Create `tests/README.md` as the guide to the test layout. It must explain the `core/` versus `aux/` ownership boundary, define the `unit/`, `integration/`, and `manual/` categories, give representative placement examples such as `src/` tests under `core/` and `scripts/` or `docs/` checks under `aux/`, state that both `manual/` trees are excluded from default CI collection, and document `pixi run test`, `pixi run test-core`, and `pixi run test-aux` along with any project-specific manual-test commands. Preserve compatible project-specific testing conventions.

Create `context/plans/`, `context/features/`, `context/design/`, `context/summaries/`, and `context/archived/` even when the new project has no context artifacts yet. In each subdirectory, create a `README.md` that briefly describes the subdirectory's purpose based on **Directory Roles**.

Also create a top-level `context/README.md` that explains the `context/` layout and points to each subdirectory. Do not add `.gitkeep` to a subdirectory that already contains a `README.md`; add `.gitkeep` only to an empty context subdirectory that must survive the initial Git commit, and remove that placeholder after substantive content is added.

## Pixi Test Tasks

Define separate Pixi tasks for the two test ownership domains and make the default test task depend on both. Use `[tool.pixi.tasks]` in `pyproject.toml` or `[tasks]` in `pixi.toml`. For the default Pytest setup, use:

```toml
test-core = "python -m pytest tests/core/unit tests/core/integration"
test-aux = "python -m pytest tests/aux/unit tests/aux/integration"
test = { depends-on = ["test-core", "test-aux"] }
```

The explicit paths keep `tests/core/manual/` and `tests/aux/manual/` out of the default test task. Preserve an established test runner and compatible extra behavior when normalizing an existing project, but ensure `pixi run test-core` and `pixi run test-aux` retain the ownership split and `pixi run test` runs both. If no test runner is established, use Pytest and add it to the Pixi environment.

## Pixi Initialization

For a new project:

```bash
pixi init . --format pyproject -c conda-forge
pixi add python=<version>
pixi add --pypi scipy mdutils pytest pytest-xdist ruff mkdocs-material mypy attrs omegaconf hydra-core imageio
pixi install
```

Choose the Python version from existing project requirements first. Otherwise, use one minor version behind the latest stable Python release. Do not select a newer version only because it is available.

For an existing project, inspect the manifest first and add only missing requested dependencies. Preserve an existing Python version unless the user asks to change it.

## Review Checklist

- Project commands run from the project root.
- Pixi configuration exists in the selected manifest format.
- Package name and `src/<package_name>` agree.
- Tests for distributed code and artifacts live under `tests/core/`; tests for non-distributed repository support such as `scripts/` and `docs/` live under `tests/aux/`.
- Both `tests/core/` and `tests/aux/` use `unit/`, `integration/`, and `manual/` homes when those categories exist, and default CI does not collect either `manual/` tree.
- `tests/README.md` documents the ownership boundary, test categories, representative placement examples, manual-test exclusion policy, and Pixi suite commands.
- `pixi run test-core` collects core unit and integration tests, `pixi run test-aux` collects auxiliary unit and integration tests, and `pixi run test` runs both without collecting manual tests.
- External dependency folders distinguish tracked submodules, local-only clones, and linked worktrees.
- `extern/README.md` indexes every immediate external subdirectory, and each `extern/<subdir>/README.md` explains its contents, purpose, tracking policy, and reconstruction or cleanup method.
- `extern/trees/` is reserved for ignored links to persistent sibling Git worktrees and is excluded from runtime dependencies and broad project operations.
- `.pixi/`, `tmp/`, `extern/orphan/*`, and `extern/trees/*` are ignored while their external-layout README files remain trackable.
- Documentation and AI context have distinct homes.
- `context/` contains the `plans/`, `features/`, `design/`, `summaries/`, and `archived/` homes with no project knowledge placed in an ambiguous catch-all location.
- Each `context/` subdirectory contains a `README.md` describing its purpose.
- `skillset/README.md` documents the `<project-slug>-<what>` naming convention for project-specific skills.
