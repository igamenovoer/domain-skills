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

# Author Instructional Test Cases

**Phase 2 (Create or Update Tracked Test Definitions Only).** Create or update a self-contained agent-driven instructional test definition bundle under `<cases-dir>/<case-slug>/` (where `<cases-dir>` defaults to `<realwork>/tests/instructional/` and is tracked in Git) grounded in static repository inspection, without launching the app or executing the test cases.

## Predecessors

- Normally follows an approved design from `imsight-project-mgr->agent-driven-testing->propose-case()`, or an explicit user instruction to create/update a specific `<cases-dir>/<case-slug>/` bundle (for example, promoting `status: draft` -> `status: proven` after a verified `run-case()` report, or folding in `harness-gap` / `doc-drift` fixes reported by `run-case()`).
- If the scope, preconditions, or soft goals are still ambiguous and no prior proposal exists, stop and recommend running `imsight-project-mgr->agent-driven-testing->propose-case()` first.

## Workflow

When `imsight-project-mgr->agent-driven-testing->author-case()` is invoked, execute the following steps in order.

1. **Resolve target realwork, `<cases-dir>`, `<case-slug>`, and authoring intent.** Confirm whether creating a new bundle or updating an existing `<cases-dir>/<case-slug>/` bundle per **Part 1: Test Definitions** in [case-and-harness-contract.md](../references/case-and-harness-contract.md), and gather the approved proposal or explicit update instructions (plus any referenced specs, PRs, debug campaigns, or prior `run-case()` reports).
2. **Ground every command and handle statically against the repository.** Inspect the repo read-only across `Surface`, `Run`, `Drive`, `Observe`, and `Isolate` (if not already completed in `propose-case()`) and confirm that every referenced CLI command, flag, route, selector convention, script path, and fixture actually exists in the current checkout. Do not launch the app or run live tests.
3. **Author or update the bundle harness contract (`<cases-dir>/<case-slug>/README.md`).** Populate all required sections (`Status`, `Baseline Preconditions & Isolation`, `Launch`, `Doctor`, `Drive`, `Evidence`, `Cleanup`, `Helpers`, `Case Index`) with concrete repo commands and zero placeholders, pointing execution outputs to `<output-dir>/<test-slug>/`. Set `Status: draft` whenever creating a new bundle or materially changing its harness, steps, or helpers; set `Status: proven (commit <sha>, report <path>)` only when the user explicitly instructs promoting a bundle backed by a cited verified `run-case()` report. If an optional top-level `<cases-dir>/README.md` bundle index already exists, update only its link to `<case-slug>/README.md`.
4. **Author or update user-POV scenarios (`<cases-dir>/<case-slug>/cases/<scenario-slug>.md`).** Write or update one file per user-facing scenario using the five fixed H2 sections (`Sub-cases`, `How to get to it (user POV)`, `Driving it with <harness-name>`, `Expected Outcome (Soft Goals)`, `Gotchas`) and, when testing AI agent behavior, the optional `## Blinding and Transcript Checks` section. See **Authoring Cases and Helpers**.
5. **Author or update optional helpers (`<cases-dir>/<case-slug>/helpers/`).** When a reusable setup, doctor, or driving wrapper belongs in the bundle, write a clean, executable, composable script (with `--help`, machine-readable JSON output where useful, and actionable error messages), verify basic syntax statically (for example `bash -n` or `py_compile`), and document its exact invocation in `<cases-dir>/<case-slug>/README.md`.
6. **Run static hygiene checks and report authored definitions.** Re-read every written or modified file to verify zero placeholders, valid relative links, executable helper bits, and accurate `Status: draft` / `Status: proven` labeling. Summarize the resolved `<cases-dir>/<case-slug>/`, files written/updated, static checks performed, confirmation that no live run was executed, and recommended next step (`imsight-project-mgr->agent-driven-testing->run-case()`).

If the user's request involves migrating an existing manual test script or updating multiple scenarios from a `run-case()` report, use your native planning tool to sequence static verification, file updates, and link hygiene while keeping `author-case()` strictly free of live test execution.

## Authoring Cases and Helpers

Apply [case-and-harness-contract.md](../references/case-and-harness-contract.md) strictly:

- **User POV only**: name user entry points, stable selectors/flags, required preconditions, literal commands, read-only cross-checks, and qualitative soft goals. Omit internal function names and implementation details.
- **Soft goals with concrete grounding**: write qualitative user-visible outcomes under `## Expected Outcome (Soft Goals)`, paired with **Observable signals to inspect** and **Hard disqualifiers** so the executing agent in `run-case()` has clear criteria for a forced `PASS`/`FAIL` decision.
- **Distilling debug campaigns or bugs**: convert each validated workflow arm and each real defect discovered during debugging into explicit sub-cases, including negative/guardrail assertions (such as busy refusals, unsupported mode rejections, or peer-discovery isolation) and known traps under `Gotchas`.
- **Promote repeated scripts to helpers**: when prior `run-case()` reports show agents rewriting the same throwaway script in `<output-dir>/<test-slug>/scripts/`, promote a clean executable helper into `<cases-dir>/<case-slug>/helpers/` and document its exact invocation in `<cases-dir>/<case-slug>/README.md`.
- **Honest draft status**: per `pstack`, an unexecuted bundle is a draft, not a proven deliverable. Never stamp `Status: proven` without an explicit user update backed by a verified `run-case()` report and commit SHA.
- **No placeholders**: never leave `<TODO>`, dummy selectors, or unverified placeholder commands in committed case files.

## Guardrails

- DO NOT launch the target application, start services, or execute live test scenarios during `author-case()` unless the user explicitly requested chaining `run-case()`.
- DO NOT mark a newly created or materially modified unexecuted bundle as `Status: proven`; stamp it `Status: draft`.
- DO NOT write a bundle's harness `README.md`, `cases/`, or `helpers/` directly under `<cases-dir>`; always output into `<cases-dir>/<case-slug>/`.
- DO NOT leave placeholders, ungrounded commands, or internal implementation assertions in `<cases-dir>/<case-slug>/README.md` or `<cases-dir>/<case-slug>/cases/*.md`.
- DO NOT write disposable scripts, logs, raw test outputs, or test reports inside `<cases-dir>` or system `/tmp`.
- DO NOT copy secrets, API keys, sign-in tokens, or session cookies into `<cases-dir>` or `helpers/`.
- DO NOT edit product source code during `author-case()`.
