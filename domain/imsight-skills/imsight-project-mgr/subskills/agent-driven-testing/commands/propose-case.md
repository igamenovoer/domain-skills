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

**Phase 1 (Discussion Only).** Interview the realwork repository read-only and propose a concrete test design — intent, scope, preconditions, driving plan, and decomposed **quantified + qualitative criteria** — before any files are written or any program runs.

## Workflow

When `imsight-project-mgr->agent-driven-testing->propose-case()` is invoked, execute the following steps in order.

1. **Resolve target realwork and `<cases-dir>/<case-slug>/`.** Identify the realwork checkout, branch, and tracked test-definition location per [case-and-harness-contract.md](../references/case-and-harness-contract.md), plus any existing bundle, spec, PR, or debug campaign named by the user.
2. **Interview the repository, not the user.** Answer the five discovery axes from the codebase and ask the user only what cannot be observed in code. See **Repository Interview**.
3. **Decompose test criteria following [principles.md](../references/principles.md) (`v1`–`v3`).** Separate everything countable, typed, or structural into explicit **Quantified checks**, and reserve **Qualitative checks** strictly for irreducible natural-language semantics that the runner will judge from captured artifacts.
4. **Present the proposal in chat and stop.** Return the structured proposal below and wait for user feedback or an explicit `imsight-project-mgr->agent-driven-testing->author-case()` request.

If the user is comparing alternative designs or scoping multiple bundles, use your native planning tool to structure the read-only interview while keeping `propose-case()` strictly free of file writes and execution.

## Repository Interview

Answer from source, configs, scripts, and existing tests before asking the user:

- **Surface:** what public interface does a user, operator, or caller actually touch (CLI, service/API, batch or compute pipeline, library, daemon, multi-agent workflow, TUI/GUI)? Pick the primary surface and note secondary entry points.
- **Run:** how does the program build and start locally from clean state? Note commands, env vars, seed inputs, hardware/service dependencies, and readiness signals.
- **Drive:** what harness or client already exists in the repo? Reuse maintained repo tools first before picking a generic driver.
- **Observe:** what outputs and independent read-only second views prove what happened (`v3`)?
- **Isolate:** can concurrent runs isolate state, ports, sockets, and `<output-dir>/<test-slug>/` directories safely, or must runs serialize?

## Proposal Shape

1. **Placement:** realwork checkout, `<cases-dir>/<case-slug>/`, expected `<output-dir>/<test-slug>/`, report destination, and whether creating or updating definitions.
2. **Intent & Scope:** user/caller-visible behavior under test, proposed sub-cases (pairing positive and contrastive negative/boundary paths per `v1`/`v3`), and explicit non-goals.
3. **Preconditions, Isolation & Doctor:** required fixtures/inputs/credentials, isolation boundaries, and what `Doctor` (or preflight) checks before driving (`v4`).
4. **Driving & Second-View Plan:** literal public entry points, driver approach, independent read-only cross-checks, and artifacts to capture.
5. **Expected Outcome (`v2`):**
   - **Quantified checks:** explicit, machine-checkable predicates for every structural, countable, or bounded invariant (exit codes, counts, routing/header fields, schema/state invariants, numeric bounds, zero unhandled errors).
   - **Qualitative checks:** plain natural-language criteria only for irreducible semantic behavior (or `None` when fully quantifiable), naming which artifacts the runner inspects to decide `PASS` vs. `FAIL`.
6. **Risks, Blinding & Open Questions:** timing/state traps, usability watchpoints (`v6`), blinding needs if testing AI agents (`v3`), and unresolved questions for the user.

## Guardrails

- DO NOT create, edit, or delete any files during `propose-case()`.
- DO NOT build, launch, or run the target program during `propose-case()`.
- DO NOT ask the user questions the repository already answers.
- DO NOT leave structural or countable expectations unquantified, and DO NOT force irreducible semantics into brittle string-match assertions.
- DO NOT proceed to `author-case()` or `run-case()` unless the user explicitly asked to chain phases.
