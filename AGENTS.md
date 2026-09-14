# Repository Guidelines

## Project Structure & Module Organization

Skills live under `domain/imsight-skills/`, `domain/cuda/`, and `domain/model-inference/`. Each skill has a `SKILL.md` entrypoint; supporting material belongs in `commands/`, `references/`, `scripts/`, `assets/`, or `agents/openai.yaml`. Imsight subskills use `subskills/<name>/SKILL-MAIN.md`.

`src/domain_skills/` is a minimal Python package scaffold. Root `tests/unit/`, `tests/integration/`, and `tests/manual/` are placeholders. The bundled wiki viewer lives in `domain/imsight-skills/imsight-llm-wiki/viewer/`, with shared TypeScript utilities in `audit-shared/` and server/client code in `web/`. Preserve migration snapshots under skill-local `org/` directories; edit the active skill tree.

## Build, Test, and Development Commands

Run from the repository root:

- `pixi install`: install the locked Python 3.13 environment; the workspace targets Linux.
- `pixi run lint`: run Ruff checks.
- `pixi run format`: apply Ruff formatting.
- `pixi run typecheck`: run strict mypy checks on `src/`.

For the wiki viewer, first run `cd domain/imsight-skills/imsight-llm-wiki/viewer/web`:

- `npm install`: install viewer dependencies.
- `npm run build`: bundle browser assets.
- `npm test`: run search tests.
- `npm run typecheck`: check TypeScript without emitting files.
- `npm start -- --wiki /absolute/path/to/vault`: build and serve a local wiki on `127.0.0.1:4175`.

## Coding Style & Naming Conventions

Use four-space Python indentation, Ruff's 100-character line limit, and type annotations. Match the viewer's two-space TypeScript indentation, double quotes, and semicolons. Use two-space YAML indentation.

Name skill directories and command pages in kebab-case, retaining domain prefixes such as `imsight-` or `krnopt-cuda-`. Keep entrypoints compact and link detailed procedures. For Imsight content, follow `domain/imsight-skills/style-guide.md`, including numbered `## Workflow` steps and focused `## Guardrails`. Keep frontmatter, subcommand indexes, links, and agent metadata consistent when changing skill behavior.

## Testing Guidelines

No root test runner or coverage threshold is configured. Viewer tests use Node's `node:test` through `tsx`, with `*.test.ts` filenames; its test command currently targets `server/routes/search.test.ts`, so update the command when adding suites. For documentation changes, verify relative links, referenced files, and invocation examples. For executable changes, run relevant checks and record reproducible smoke-test steps.

## Commit & Pull Request Guidelines

History uses both imperative subjects (`Add Imsight skill discovery bootstrap`) and scoped Conventional Commits (`feat(dev-box-init): ...`, `fix(mentality): ...`). Keep commits focused. PRs should explain the problem, affected skills, behavior changes, and validation; link relevant issues and include screenshots for viewer UI changes.

## Universal Project Rules

### Code Placement Classification

Before creating a module, script, fixture, or other code file, inspect the repository instructions, current directory layout, manifests, build and test configuration, and ignore rules. Classify the file by purpose as `distro`, `CI`, `utility`, or `temp`, then place it in an existing purpose-specific directory that matches the classification. The directory names below are conventional examples, not required names; prefer an established project-specific location with the same role.

- `distro` is part of the released product. Use the project's product source or package tree, such as `src/`, `lib/`, `app/`, or a package-local source directory, for core functionality and stable, reusable infrastructure, including reusable test infrastructure maintained as supported package code.
- `CI` is part of quality control for production code. Use the appropriate existing test or verification tree, such as `tests/`, `test/`, or `spec/`, for test cases, suite-specific fixtures, and verification helpers; production modules must remain independent of test-only trees.
- `utility` provides development, testing, migration, characterization, or operational tooling. Use an existing tooling tree, such as `scripts/<purpose-dir>/`, `tools/<purpose-dir>/`, or a project-specific equivalent. Keep reusable product logic in the product source tree and make utility entrypoints thin where practical.
- `temp` is disposable state tightly coupled to a one-off test or experiment. Use an existing ignored scratch or temporary tree, such as `tmp/<purpose-dir>/`, `.tmp/<purpose-dir>/`, or a project-specific equivalent. It may be deleted at any time, must not be tracked by Git, and must not be required by production code, committed tests, or durable workflows.

If no suitable directory exists, create a purpose-specific location consistent with the repository's conventions and update ignore, packaging, or build configuration as required by the classification. Do not create uncategorized code at the repository root, introduce a conventional directory when an equivalent project-specific home already exists, or add new files directly under a broad tooling or temporary directory when a purpose-specific subdirectory is appropriate.

### Documentation

- When writing Markdown, do not hard-wrap normal paragraphs. Let Markdown viewers and editors handle line wrapping.

### Python

- Write Python in a strongly typed style. Tighter types are preferred over vague ones.
- Repo-owned Python should pass `mypy` after edits.
- Use NumPy-style docstrings for all public-facing Python functions, classes, and data models.

### C++

- Use Doxygen-style docstrings for all public-facing C++ functions, classes, and data models or structs.

### Feature Design

- This project is in active development and accepts breaking changes.
- When designing new features, do not spend effort on compatibility with previous iterations or external users unless explicitly requested.
- Favor a clear internal design over compatibility layers.
- If a change breaks another part of this repository, fix the dependent code in the same change so repository workflows continue to work together.
