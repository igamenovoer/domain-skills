# Universal Project Rules

## Code Placement Classification

Before creating a module, script, fixture, or other code file, inspect the repository instructions, current directory layout, manifests, build and test configuration, and ignore rules. Classify the file by purpose as `distro`, `CI`, `utility`, or `temp`, then place it in an existing purpose-specific directory that matches the classification. The directory names below are conventional examples, not required names; prefer an established project-specific location with the same role.

- `distro` is part of the released product. Use the project's product source or package tree, such as `src/`, `lib/`, `app/`, or a package-local source directory, for core functionality and stable, reusable infrastructure, including reusable test infrastructure maintained as supported package code.
- `CI` is part of quality control for production code. Use the appropriate existing test or verification tree, such as `tests/`, `test/`, or `spec/`, for test cases, suite-specific fixtures, and verification helpers; production modules must remain independent of test-only trees.
- `utility` provides development, testing, migration, characterization, or operational tooling. Use an existing tooling tree, such as `scripts/<purpose-dir>/`, `tools/<purpose-dir>/`, or a project-specific equivalent. Keep reusable product logic in the product source tree and make utility entrypoints thin where practical.
- `temp` is disposable state tightly coupled to a one-off test or experiment. Use an existing ignored scratch or temporary tree, such as `tmp/<purpose-dir>/`, `.tmp/<purpose-dir>/`, or a project-specific equivalent. It may be deleted at any time, must not be tracked by Git, and must not be required by production code, committed tests, or durable workflows.

If no suitable directory exists, create a purpose-specific location consistent with the repository's conventions and update ignore, packaging, or build configuration as required by the classification. Do not create uncategorized code at the repository root, introduce a conventional directory when an equivalent project-specific home already exists, or add new files directly under a broad tooling or temporary directory when a purpose-specific subdirectory is appropriate.

## Documentation

- When writing Markdown, do not hard-wrap normal paragraphs. Let Markdown viewers and editors handle line wrapping.

## Python

- Write Python in a strongly typed style. Tighter types are preferred over vague ones.
- Repo-owned Python should pass `mypy` after edits.
- Use NumPy-style docstrings for all public-facing Python functions, classes, and data models.

## C++

- Use Doxygen-style docstrings for all public-facing C++ functions, classes, and data models or structs.

## Feature Design

- This project is in active development and accepts breaking changes.
- When designing new features, do not spend effort on compatibility with previous iterations or external users unless explicitly requested.
- Favor a clear internal design over compatibility layers.
- If a change breaks another part of this repository, fix the dependent code in the same change so repository workflows continue to work together.
