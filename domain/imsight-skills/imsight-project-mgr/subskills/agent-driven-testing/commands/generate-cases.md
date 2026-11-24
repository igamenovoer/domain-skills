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

# Generate Instructional Test Cases

Create or extend a self-contained agent-driven instructional test bundle under `<output-dir>/<case-slug>/` (where `<output-dir>` is user-specified or defaults to `<realwork>/tests/instructional/`) so multiple test topics coexist cleanly and a cold agent can launch the realwork, verify its health, drive real user-facing flows, capture surviving evidence in a project-local temporary directory, and tear down cleanly.

## Workflow

When `imsight-project-mgr->agent-driven-testing->generate-cases()` is invoked, execute the following steps in order.

1. **Resolve the realwork target, `<output-dir>`, `<case-slug>`, and source inputs.** Identify the selected realwork checkout and branch, resolve `<output-dir>` and `<case-slug>` following **Output Location Resolution and Bundle Layout** in [case-and-harness-contract.md](../references/case-and-harness-contract.md) so the bundle directory is `<output-dir>/<case-slug>/` (never directly under `<output-dir>`), and collect any input sources named by the user (existing codebase features, a debug campaign under `context/campaigns/debug/`, OpenSpec specs/changes, or a bug/PR).
2. **Resolve the project-local temporary directory.** Follow the discovery order in [case-and-harness-contract.md](../references/case-and-harness-contract.md) to find or initialize `<project-tmp-root>` inside the project and verify it is ignored by Git.
3. **Interview the repository before asking the user.** Inspect code, docs, existing tests, and scripts across all five discovery axes. Ask the user only for facts that cannot be observed in the repo (such as private credentials, external model endpoints, or intentionally deferred scope). See **Repository Interview**.
4. **Verify a runnable baseline.** Confirm the checkout builds or starts as-is before writing instructions against it. If startup fails, report the exact failure (or fix only an explicitly authorized verification-scaffolding gap, documented for cleanup) instead of encoding broken launch steps.
5. **Author or update the bundle harness contract (`<output-dir>/<case-slug>/README.md`).** Populate all required sections (`Baseline Preconditions & Isolation`, `Launch`, `Doctor`, `Drive`, `Evidence`, `Cleanup`, `Helpers`, `Case Index`) grounded in real commands, stable handles, and `<project-tmp-root>` usage. If an optional top-level `<output-dir>/README.md` bundle index already exists, add or update the link to `<case-slug>/README.md` without mixing bundle instructions into `<output-dir>/README.md`.
6. **Author user-POV test scenarios (`<output-dir>/<case-slug>/cases/<scenario-slug>.md`).** Write one file per user-facing scenario inside `<output-dir>/<case-slug>/cases/` using the four fixed H2 sections and, when testing AI agent behavior, the optional `## Blinding and Transcript Checks` section. See **Authoring Cases and Helpers**.
7. **Prove the bundle end to end before handoff.** Execute `Launch`, `Doctor`, at least ONE mapped scenario in `<output-dir>/<case-slug>/cases/`, evidence capture into `<run-tmp>/evidence/<case-slug>/`, and `Cleanup`, then confirm the evidence still exists on disk after cleanup. See **Mandatory Self-Proof**.
8. **Report the generated bundle.** Summarize the resolved `<output-dir>/<case-slug>/`, files written inside it, the resolved `<project-tmp-root>`, the self-proof result with surviving artifact paths, any stand-in deltas, and recommended next steps (such as running `imsight-project-mgr->agent-driven-testing->run-cases()` across the full bundle).

If the user's request does not fit cleanly into a fresh bootstrap (for example, refactoring an existing manual test script into `<output-dir>/<case-slug>/`), use your native planning tool to sequence the interview, migration, and mandatory self-proof while preserving every contract rule.

## Repository Interview

Answer these five questions directly from the realwork codebase (and any referenced debug campaign or spec) before writing files:

- **Surface**: What does a user or operator actually touch (CLI, TUI, Web UI, HTTP service, multi-agent workflow, library)? Name the primary surface and secondary entry points.
- **Run**: How does the app start locally from an empty data directory? Prefer the repo's documented dev/runtime command (`pixi run`, `npm run`, `uv`, `cargo`, `Makefile`), noting ports, env vars, migrations, seed fixtures, and auth.
- **Drive**: What programmatic harness already exists in the repo (Playwright specs, fixture CLIs, PTY helpers, gateway/HTTP clients)? Reuse maintained repo harnesses first; only then choose a generic recipe (Playwright/CDP for Web, isolated tmux/PTY for CLI/TUI, HTTP/CLI for services).
- **Observe**: What concrete evidence proves behavior (screenshots, ARIA snapshots, terminal captures, JSON outputs, exit codes, log entries, DB/mailbox/file read-backs, or agent transcripts)?
- **Isolate**: Can multiple instances run side by side via isolated ports, data dirs, project-local temp workspaces, and dedicated tmux sockets (`tmux -S` with `TMUX` and `TMUX_PANE` cleared)? If two instances cannot coexist safely, declare that refusal explicitly in `README.md`.

## Authoring Cases and Helpers

Apply [case-and-harness-contract.md](../references/case-and-harness-contract.md) strictly:

- **User POV only**: name user entry points, stable selectors/flags, required preconditions, literal commands, expected observable states, and read-only cross-checks. Omit internal function names and implementation details.
- **Distilling debug campaigns or bugs**: convert each validated workflow arm and each real defect discovered during debugging into explicit sub-cases, including negative/guardrail assertions (such as busy refusals, unsupported mode rejections, or peer-discovery isolation) and known traps under `Gotchas`.
- **Promote repeated scripts to helpers**: during authoring or self-proof, put throwaway test scripts under `<project-tmp-root>/instructional-tests/<run-id>/scripts/`. When a setup, doctor, or driving wrapper will be needed on every future run, place a clean, executable, composable helper script in `<output-dir>/<case-slug>/helpers/` (with `--help`, machine-readable JSON output where useful, and actionable error messages) and show its exact invocation in `<output-dir>/<case-slug>/README.md`.
- **No placeholders**: never leave `<TODO>`, dummy selectors, or unverified commands in committed case files.

## Mandatory Self-Proof

An instructional test bundle that has never been executed is a draft, not a deliverable. Before finishing `generate-cases()`:

1. Allocate `<run-tmp>` at `<project-tmp-root>/instructional-tests/<run-id>/` with `scripts/`, `runtime/`, and `evidence/`.
2. Follow your own `<output-dir>/<case-slug>/README.md` literally: run `Launch`, run `Doctor`, drive at least one scenario from `<output-dir>/<case-slug>/cases/`, capture its proof artifacts into `<run-tmp>/evidence/<case-slug>/<scenario-slug>/`, and run `Cleanup`.
3. Run `Cleanup` after every failed iteration as well so broken attempts never leave stranded processes, ports, or isolated tmux servers.
4. After final cleanup, verify on disk that the proof artifacts under `<run-tmp>/evidence/<case-slug>/<scenario-slug>/` still exist and match the scenario's proof standard.
5. If self-proof ran in a stand-in environment (for example, a local mock endpoint or container instead of a remote target), record every setup step the stand-in performed that the real target will not; mark those steps unverified.

## Guardrails

- DO NOT write a bundle's harness `README.md`, `cases/`, or `helpers/` directly under `<output-dir>`; always output into `<output-dir>/<case-slug>/`.
- DO NOT leave placeholders, unverified commands, or internal implementation assertions in `<output-dir>/<case-slug>/README.md` or `<output-dir>/<case-slug>/cases/*.md`.
- DO NOT write disposable self-proof scripts, logs, or evidence inside `<output-dir>` or system `/tmp`.
- DO NOT hand off newly generated instructional bundles without completing at least one live end-to-end self-proof pass and confirming proof artifacts survived cleanup.
- DO NOT weaken a scenario's journey or omit a failing precondition just to make self-proof pass.
- DO NOT copy secrets, API keys, sign-in tokens, or session cookies into `<output-dir>` or `helpers/`.
