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

**Phase 2 (Create or Update Tracked Definitions Only).** Write or update a self-contained test bundle under `<cases-dir>/<case-slug>/` for a cold agent, grounded statically in the repository without launching the program or running tests.

## Predecessors

- Follows an approved proposal from `imsight-project-mgr->agent-driven-testing->propose-case()`, or an explicit user instruction to create or update `<cases-dir>/<case-slug>/` (including promoting `Status: draft` -> `Status: proven` from a verified `run-case()` report or folding in reported `doc-drift` / `harness-gap` fixes).
- If scope, preconditions, or criteria remain unsettled, stop and point to `propose-case()`.

## Workflow

When `imsight-project-mgr->agent-driven-testing->author-case()` is invoked, execute the following steps in order.

1. **Resolve `<cases-dir>/<case-slug>/` and ground commands statically.** Confirm every command, flag, entrypoint, config key, and helper path against the current codebase across the five interview axes in [propose-case.md](propose-case.md). Leave zero `<TODO>` placeholders.
2. **Write or update `<cases-dir>/<case-slug>/README.md`.** Follow the **Harness Contract** in [case-and-harness-contract.md](../references/case-and-harness-contract.md) (`Status`, `Launch`, `Doctor`, `Drive`, `Evidence`, `Cleanup`, `Helpers`, `Case Index`), routing run outputs to `<output-dir>/<test-slug>/`. Stamp `Status: draft` whenever creating a bundle or materially changing its harness, steps, or helpers; stamp `Status: proven (commit <sha>, report <path>)` only when explicitly authorized with a cited verified `run-case()` report. Update any existing `<cases-dir>/README.md` bundle index link if adding or removing a bundle.
3. **Write or update `<cases-dir>/<case-slug>/cases/<scenario-slug>.md`.** Apply [case-and-harness-contract.md](../references/case-and-harness-contract.md) and [principles.md](../references/principles.md) (`v1`–`v3`): describe user/caller-visible steps, independent read-only cross-checks, **Quantified checks** for every structural/measurable obligation, and **Qualitative checks** strictly for irreducible natural-language semantics (plus `## Blinding and Transcript Checks` when testing AI agents).
4. **Write or update optional `<cases-dir>/<case-slug>/helpers/`.** Promote reusable driver or setup logic into clean, executable scripts (`chmod +x`, `--help`, structured output where useful), check syntax statically (such as `bash -n` or `py_compile`), and show exact invocations in `<cases-dir>/<case-slug>/README.md`.
5. **Re-read and report.** Re-read every written file to verify links, executable permissions, zero placeholders, and accurate `Status: draft | proven` metadata. Report files written/updated, confirm no live run occurred, and point to `imsight-project-mgr->agent-driven-testing->run-case()` as the next phase.

If migrating legacy manual scripts or applying multi-file updates from a run report, use your native planning tool to sequence static checks and edits without starting live runs.

## Guardrails

- DO NOT launch the target program, start services, or run test scenarios during `author-case()` unless the user explicitly asked to chain `run-case()`.
- DO NOT stamp an unexecuted new or materially modified bundle as `Status: proven`; mark it `Status: draft`.
- DO NOT write bundle files directly under `<cases-dir>`; always nest under `<cases-dir>/<case-slug>/`.
- DO NOT encode private implementation details where boundary behavior belongs (`v1`), leave structural checks unquantified (`v2`), or leave placeholders in committed files.
- DO NOT store disposable scripts, logs, raw outputs, secrets, or test reports inside `<cases-dir>`, or edit product source code during `author-case()`.
