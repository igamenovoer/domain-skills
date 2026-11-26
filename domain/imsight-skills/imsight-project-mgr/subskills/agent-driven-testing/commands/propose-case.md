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

# Propose Instructional Test Cases

**Phase 1 (Discussion Only).** Interview the realwork repository read-only and propose a concrete instructional test case design — intent, scope, preconditions, driving plan, and qualitative **soft goals** — so the user can review and refine the design before any tracked test definitions are written or any app is launched.

## Workflow

When `imsight-project-mgr->agent-driven-testing->propose-case()` is invoked, execute the following steps in order.

1. **Resolve target realwork, `<cases-dir>`, `<case-slug>`, and source inputs.** Identify the realwork checkout and branch, resolve the tracked test-definitions location `<cases-dir>/<case-slug>/` per **Part 1: Test Definitions** in [case-and-harness-contract.md](../references/case-and-harness-contract.md), and inspect any existing bundle at `<cases-dir>/<case-slug>/` plus any user-referenced specs, PRs, issues, or debug campaigns.
2. **Interview the repository read-only.** Inspect code, docs, existing harnesses, scripts, and tests across all five discovery axes (`Surface`, `Run`, `Drive`, `Observe`, `Isolate`) without modifying files or launching the app. Note only the facts that cannot be observed in the repository as explicit questions for the user. See **Repository Interview**.
3. **Design the test case proposal with soft goals.** Draft the proposed bundle scope, sub-cases, preconditions, `Doctor` and driving approach, observable signals, hard disqualifiers, and qualitative soft goals (explicitly specifying how the future runner agent will judge `PASS` vs. `FAIL` from captured evidence and watch for `usability-issue` friction). See **Proposal Structure**.
4. **Present the proposal in chat and stop.** Return the structured proposal and open questions for user review. Do not create or edit any files, do not write a durable report, and do not launch or test the app; wait for the user to iterate or explicitly invoke `imsight-project-mgr->agent-driven-testing->author-case()`.

If the user is comparing alternative test designs or scoping a large multi-bundle verification plan, use your native planning tool to break the read-only interview across subsystems while keeping `propose-case()` strictly discussion-only with zero disk writes or live execution.

## Repository Interview

Answer these five questions directly from the realwork codebase (and any referenced debug campaign, PR, or OpenSpec change) before proposing a design:

- **Surface**: what does a user or operator actually touch (CLI, TUI, Web UI, HTTP service, multi-agent workflow, library)? Name the primary surface and secondary entry points.
- **Run**: how does the app start locally from an empty data directory? Prefer the repo's documented dev/runtime command (`pixi run`, `npm run`, `uv`, `cargo`, `Makefile`), noting ports, env vars, migrations, seed fixtures, and auth.
- **Drive**: what programmatic harness already exists in the repo (Playwright specs, fixture CLIs, PTY helpers, gateway/HTTP clients)? Reuse maintained repo harnesses first; only then choose a generic recipe (Playwright/CDP for Web, isolated tmux/PTY for CLI/TUI, HTTP/CLI for services).
- **Observe**: what concrete evidence proves behavior (screenshots, ARIA snapshots, terminal captures, JSON outputs, exit codes, log entries, DB/mailbox/file read-backs, or agent transcripts)?
- **Isolate**: can multiple instances run side by side via isolated ports, data dirs, isolated test output directories (`<output-dir>/<test-slug>/`), and dedicated tmux sockets (`tmux -S` with `TMUX` and `TMUX_PANE` cleared)? If two instances cannot coexist safely, flag that constraint upfront.

## Proposal Structure

Present every proposal in chat with these sections so the user can approve or adjust the design in one pass:

1. **Target & Artifact Placement**: resolved realwork checkout, tracked test definitions path (`<cases-dir>/<case-slug>/`), expected test output root (`<output-dir>/<test-slug>/`), durable report destination, whether creating new or updating existing definitions, and whether any helpers are recommended.
2. **Intent & Scope**: what user-visible behavior is being verified, why it matters (what unit tests cannot prove), proposed sub-cases, and explicit non-goals.
3. **Preconditions & Isolation**: required fixtures, configs, credentials/models, isolated ports/data dirs/sockets, and what `Doctor` will check before driving.
4. **Driving & Evidence Plan**: user POV entry points, literal harness strategy, read-only second-view cross-checks, and proof artifacts to save under `<output-dir>/<test-slug>/evidence/`.
5. **Expected Outcome (Soft Goals) & Pass/Fail Definition**:
   - **Soft goals**: qualitative descriptions of what successful behavior looks like from the user's POV; the executing agent in `run-case()` will inspect captured evidence and make the final definitive decision (`PASS` or `FAIL`, no `INCONCLUSIVE`).
   - **Observable signals to inspect**: exact artifacts and cross-checks the runner must cite in its rationale.
   - **Hard disqualifiers**: non-negotiable failure conditions that trigger an automatic `FAIL` regardless of qualitative judgment.
   - **Usability watchpoints**: places where counter-intuitive flows, misleading labels, or weak error feedback should be noted as `usability-issue` during execution.
6. **Gotchas, Blinding Needs & Open Questions**: known timing/environment traps, whether `## Blinding and Transcript Checks` is needed (for AI-agent behavior cases), and any decisions requiring user input before moving to `author-case()`.

## Guardrails

- DO NOT create, edit, or delete any files (including `<cases-dir>/<case-slug>/`, helper scripts, test output files, or durable reports) during `propose-case()`.
- DO NOT build, launch, or drive the target application, start background services, or run test cases during `propose-case()`.
- DO NOT ask the user questions that can already be answered by inspecting the repository.
- DO NOT write brittle implementation-level assertions where user-visible soft goals and observable signals belong.
- DO NOT automatically proceed to `author-case()` or `run-case()` unless the user explicitly instructed chaining phases.
