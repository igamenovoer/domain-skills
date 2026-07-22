# Initialize Pixi Python Project

Use this command for focused first-time initialization of a Pixi-managed Python project. It owns Pixi manifest and dependency bootstrap, then hands baseline layout reconciliation to `structure-pixi-project`.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Resolve the target root**. Use the user-provided project directory, or the current directory when the task clearly targets it; do not initialize a mega-workspace parent accidentally.
2. **Inspect existing project evidence**. Check for `pixi.toml`, `pixi.lock`, `[tool.pixi]` in `pyproject.toml`, existing Python requirements, package names, and repository guidance.
3. **Handle existing Pixi state**. If Pixi is already configured, preserve the manifest and dependency constraints, skip initialization commands, and continue with `structure-pixi-project`.
4. **Resolve initialization choices**. Select the manifest form, project/package name, Python version, channel, and dependency baseline from explicit user input and repository evidence. See **Initialization Choices**.
5. **Initialize Pixi**. Run the applicable commands from **Pixi Bootstrap** only after confirming they will not overwrite an incompatible manifest.
6. **Reconcile the project structure**. Load `structure-pixi-project.md` and follow its `## Workflow`, treating the new Pixi manifest and selected package name as established inputs.
7. **Verify and report**. Confirm Pixi recognizes the workspace, report commands and files created, list selected versions and dependencies, and surface any install or structural validation failure.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the evidence, initialization, preservation, structural, and validation constraints in this command, then execute the plan.

## Existing Pixi Detection

Treat the target as an existing Pixi project when any of these signals is present:

- `pixi.toml`
- `pixi.lock`
- A `[tool.pixi]` table or subtable in `pyproject.toml`

Do not rerun `pixi init` or replace the manifest for an existing Pixi project. Preserve declared Python and dependency constraints unless the user explicitly asks to change them.

## Initialization Choices

Resolve choices in this order:

1. Explicit user requirements.
2. Existing repository files, documentation, and coding-agent guidance.
3. Existing host-project conventions.
4. Imsight defaults from this command.

Use `pyproject.toml` by default. If an incompatible `pyproject.toml` already exists without Pixi configuration, do not overwrite it; ask whether to integrate Pixi into that manifest or use `pixi.toml`.

Derive the package name from an explicit package name or the project name by lowercasing and replacing hyphens with underscores. Choose the Python version from established project requirements first; otherwise use one minor version behind the latest stable Python release.

Use `conda-forge` as the default channel. Use the established Imsight PyPI dependency baseline only when the user did not provide another dependency set: `scipy`, `mdutils`, `ruff`, `mkdocs-material`, `mypy`, `attrs`, `omegaconf`, and `imageio`.

If the target root, manifest form, project/package name, or Python version remains ambiguous in a way that could create the wrong project, ask for the smallest missing decision before initialization.

## Pixi Bootstrap

Run from the resolved target root:

```bash
pixi init . --format pyproject -c conda-forge
pixi add python=<version>
pixi add --pypi scipy mdutils ruff mkdocs-material mypy attrs omegaconf imageio
pixi install
```

Replace the manifest format, channel, Python version, or dependency list when resolved choices require it. For a requested `pixi.toml` manifest, use `--format pixi`.

If dependency installation fails, preserve the initialized manifest and lock evidence, report the failing command, and do not claim initialization succeeded fully.

## Structural Handoff

After Pixi bootstrap, execute `structure-pixi-project` to create or reconcile the import package, tests, documentation, scripts, external dependency homes, project skill home, ignore rules, and review checklist. The structural handoff must create `context/plans/`, `context/features/`, `context/design/`, `context/summaries/`, and `context/archived/`; do not replace that hierarchy with a single undifferentiated `context/` directory.

## Example Prompts

- `Use $imsight-project-mgr init-pixi-project to initialize a new Pixi Python project in this directory.`
- `Use $imsight-project-mgr init-pixi-project to create a Python 3.12 project named analysis-tools using pyproject.toml.`
- `Use $imsight-project-mgr init-pixi-project on this existing repository; preserve any Pixi configuration already present.`
