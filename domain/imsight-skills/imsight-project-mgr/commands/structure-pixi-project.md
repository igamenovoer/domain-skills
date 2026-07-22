# Structure Pixi Python Project

Use this command to initialize, scaffold, review, or normalize a Pixi-managed Python project. Adapt names and details to the existing repository while preserving compatible project choices.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Resolve the project root**. Work from the Python project root, not a mega-workspace parent.
2. **Inspect existing Pixi state**. Check `pixi.lock`, `pixi.toml`, and `[tool.pixi]` in `pyproject.toml` before changing files.
3. **Choose the manifest and package names**. Preserve the existing manifest form and package name; otherwise prefer `pyproject.toml` and derive the package name from the project name.
4. **Create or reconcile the project structure**. Follow **Directory Structure**, **Directory Roles**, and **Standard Files** without overwriting compatible existing content.
5. **Initialize or reconcile Pixi**. Follow **Pixi Initialization**, preserve existing dependency constraints, and add only missing requested dependencies.
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
|   |-- .gitignore
|   |-- tracked/
|   `-- orphan/
|-- scripts/
|-- tests/
|   |-- unit/
|   |-- integration/
|   `-- manual/
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
- `extern/tracked/`: pinned third-party code, typically Git submodules tracked through `.gitmodules`.
- `extern/orphan/`: local-only clones or checkouts that must not be committed.
- `scripts/`: command-line helpers and project automation.
- `tests/unit/`: fast deterministic tests, mirroring source modules where useful.
- `tests/integration/`: filesystem, service, multi-component, or slower integration checks.
- `tests/manual/`: manually executed checks that default CI and test commands should not collect.
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
```

Ensure the project `.gitignore` includes:

```gitignore
.pixi/
tmp/
```

Do not add `.git/` to `.gitignore` unless it matches an existing local standard. Add `skillset/README.md` explaining that project-specific agent skills live there and use `<project-slug>-<what>` names.

Create `context/plans/`, `context/features/`, `context/design/`, `context/summaries/`, and `context/archived/` even when the new project has no context artifacts yet. Add `.gitkeep` to any empty context home that must survive the initial Git commit, and remove that placeholder after substantive content is added.

## Pixi Initialization

For a new project:

```bash
pixi init . --format pyproject -c conda-forge
pixi add python=<version>
pixi add --pypi scipy mdutils ruff mkdocs-material mypy attrs omegaconf imageio
pixi install
```

Choose the Python version from existing project requirements first. Otherwise, use one minor version behind the latest stable Python release. Do not select a newer version only because it is available.

For an existing project, inspect the manifest first and add only missing requested dependencies. Preserve an existing Python version unless the user asks to change it.

## Review Checklist

- Project commands run from the project root.
- Pixi configuration exists in the selected manifest format.
- Package name and `src/<package_name>` agree.
- Tests use unit, integration, and manual homes when those categories exist.
- External dependency folders distinguish tracked submodules from local-only clones.
- `.pixi/`, `tmp/`, and `extern/orphan/*` are ignored.
- Documentation and AI context have distinct homes.
- `context/` contains the `plans/`, `features/`, `design/`, `summaries/`, and `archived/` homes with no project knowledge placed in an ambiguous catch-all location.
- `skillset/README.md` documents the `<project-slug>-<what>` naming convention for project-specific skills.
