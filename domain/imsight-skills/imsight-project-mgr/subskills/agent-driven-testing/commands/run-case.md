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

# Run Instructional Test Cases

**Phase 3 (Live Execution, Strictly Read-Only on Test Definitions).** Execute one `<cases-dir>/<case-slug>/` instructional test bundle (or all `<case-slug>/` bundles under `<cases-dir>`, defaulting `<cases-dir>` to `<realwork>/tests/instructional/`) against the live realwork checkout, store all execution artifacts inside `<output-dir>/<test-slug>/`, judge qualitative soft goals definitively from surviving evidence, record any `usability-issue` encountered, and write the durable Markdown test report — never modifying original test definitions.

## Predecessors

- Requires an existing test definition bundle under `<cases-dir>/<case-slug>/` (`README.md` and `cases/*.md`), created by `imsight-project-mgr->agent-driven-testing->author-case()`.
- If no matching bundle exists, stop without creating one and point the user to `imsight-project-mgr->agent-driven-testing->propose-case()` and `imsight-project-mgr->agent-driven-testing->author-case()`.

## Workflow

When `imsight-project-mgr->agent-driven-testing->run-case()` is invoked, execute the following steps in order.

1. **Resolve the realwork checkout, `<cases-dir>`, and target `<case-slug>` bundle(s).** Identify the realwork path, branch, commit SHA, dirty state, `<cases-dir>` (per **Part 1: Test Definitions** in [case-and-harness-contract.md](../references/case-and-harness-contract.md)), and the target `<cases-dir>/<case-slug>/` bundle(s) and scenario files under `cases/`. Read each target bundle's `<cases-dir>/<case-slug>/README.md` (including its `draft` or `proven` status) first. If no bundle exists, refuse to run and direct the user to `propose-case()` / `author-case()`.
2. **Initialize the test output directory (`<output-dir>/<test-slug>/`).** Resolve `<output-dir>` per **Part 2: Test Output** in [case-and-harness-contract.md](../references/case-and-harness-contract.md) (defaulting to `<project-tmp-root>/instructional-tests/`) and allocate `<output-dir>/<test-slug>/` with `scripts/`, `runtime/`, `evidence/`, and `run-meta.json` (recording the realwork checkout, `<cases-dir>`, target `<case-slug>` bundle paths, and `<output-dir>/<test-slug>/`). Verify `<output-dir>` is Git-ignored before writing files.
3. **Select the execution mode** from **Execution Modes** based on the user's goal (standard live pass, before-and-after fix verification, parallel slice fan-out, or blinded agent-behavior eval).
4. **Launch and health-check (`Doctor`).** For each targeted `<cases-dir>/<case-slug>/` bundle, follow its `README.md` `Launch` model (one long-lived instance driven serially for servers/UIs, or a fresh isolated session per drive for short-lived CLIs/TUIs). Run `Doctor` and verify stable app markers, revision, owned ports/sockets, and auth before executing any scenario step.
5. **Drive each selected scenario while holding the live-pass invariants.** Write any temporary driving scripts, probe dumps, traces, or scratch files inside `<output-dir>/<test-slug>/` (`scripts/`, `runtime/`, or ad-hoc diagnostic files), capture all proof artifacts and read-only cross-checks into `<output-dir>/<test-slug>/evidence/<case-slug>/<scenario-slug>/`, and note any counter-intuitive system behavior or opaque error feedback as `usability-issue`. See **Live-Pass Invariants**.
6. **Clean up disposable runtime state without touching evidence or test definitions.** Tear down every process, gateway, container, browser profile, and isolated tmux server recorded in `run-meta.json`, clean disposable `runtime/` state if requested or safe, verify on disk that every captured file in `<output-dir>/<test-slug>/evidence/` survived cleanup, and confirm `<cases-dir>/<case-slug>/` was never modified.
7. **Judge soft goals definitively and produce the test report.** Inspect captured evidence on disk, render a forced verdict (`PASS`, `FAIL`, `BLOCKED`, or `VERIFIED-UNREACHABLE` — never `INCONCLUSIVE`) for every scenario with evidence-cited rationale, record every `usability-issue` (including on passing runs) and any residual uncertainty or open questions in the report, and invoke `imsight-project-mgr->agent-driven-testing->report-results()` (or apply [report-template.md](../references/report-template.md) directly) to write the durable Markdown test report to the resolved report destination and return the concise in-chat summary. See **Judging Soft Goals, Usability Issues, and Failures**.

If a task requires custom sequencing (such as pausing at human-watched checkpoints during a live interactive review), use your native planning tool to insert explicit pause gates between steps while keeping every `Doctor`, evidence, read-only test-definition, and cleanup invariant intact.

## Execution Modes

Choose the mode that matches the user's verification goal:

| Mode | When to Select | Required Discipline |
| --- | --- | --- |
| **Standard live pass** | Routine verification of one `<cases-dir>/<case-slug>/` bundle or all bundles under `<cases-dir>` | Follow each bundle's `README.md` Launch model; run `Doctor`; drive every selected entry point and read-only cross-check; capture surviving proof in `<output-dir>/<test-slug>/evidence/`; judge soft goals definitively and record any usability issues. |
| **Before-and-after fix verification** | Proving a bug fix or PR resolves a reported symptom | Run identical environment inputs on baseline and patched builds. Observe the discriminating broken state **twice** (with an independent state reset between attempts) on baseline, then observe the expected fixed state **twice** on the patched build. Compilation or unit tests never count as "after" evidence. |
| **Parallel slice fan-out** | Large suites where `README.md` confirms isolated instances can run concurrently | Partition disjoint cases across parallel subagents, each with its own `<output-dir>/<test-slug>/` slice, ports, and exact commit SHA. Require every worker to return `PASS`, `FAIL`, `BLOCKED`, or `VERIFIED-UNREACHABLE` with SHA, soft-goal rationale, usability observations, and artifact paths; drop and respawn once if SHA or evidence is missing. |
| **Blinded agent-behavior eval** | Cases with `## Blinding and Transcript Checks` testing prompts, skills, or managed agents | Strip meta-words (`eval`, `test`, `judge`, `rubric`, `benchmark`, `candidate`, `arena`) from candidate workspaces and prompts; run organic requests; judge soft goals from actual execution transcripts and side effects rather than candidate self-report. |

## Live-Pass Invariants

Hold all five invariants across the entire run, regardless of failures:

1. **Doctor before every untrusted drive**: run `Doctor` before the first drive, on every fresh isolated session, and immediately after any failed or surprising drive. When `Doctor` sees a healthy process whose UI, TUI, or agent session is wedged, capture diagnostic evidence, reset to a known baseline or relaunch, and re-run `Doctor` before proceeding.
2. **Real user paths only**: execute the literal commands, clicks, keys, or API calls documented in the case. Arrange preconditions through documented fixtures or setup steps only; never mutate internal state, storage, or DOM directly to simulate a symptom or pass.
3. **Evidence survives every cleanup**: capture both the triggering action and the resulting state plus the read-only second-view cross-check into `<output-dir>/<test-slug>/evidence/<case-slug>/<scenario-slug>/`. After every cleanup step, check the filesystem to confirm those files still exist.
4. **Zero leaked residue on failure**: record every spawned PID, port, and isolated tmux socket in `<output-dir>/<test-slug>/run-meta.json` at startup. Clean up failed-iteration residue whether the drive succeeded, failed, hung, or exited abnormally. For shared long-lived instances, reset the scenario's residue rather than killing the instance prematurely; perform final teardown only after the last drive finishes.
5. **Original test definitions remain read-only**: never edit `<cases-dir>/<case-slug>/README.md`, `cases/*.md`, `helpers/*`, or `<cases-dir>/README.md` during `run-case()` — not even to flip `Status: draft` to `Status: proven` or patch a broken selector. Record any recommended definition update in the report for explicit follow-up via `author-case()` or `audit-case()`.

## Judging Soft Goals, Usability Issues, and Failures

- **Forced verdict on executed cases**: after inspecting the captured artifacts under `<output-dir>/<test-slug>/evidence/<case-slug>/<scenario-slug>/` and read-only cross-checks, the executing agent must decide `PASS` or `FAIL` against `## Expected Outcome (Soft Goals)`. Do not emit `INCONCLUSIVE`.
  - If any **Hard disqualifier** triggered or required evidence/cross-check is missing, the verdict is `FAIL` (or `BLOCKED` if the harness itself failed to start).
  - If no hard disqualifier triggered, weigh the observed evidence honestly against each qualitative soft goal, pick `PASS` or `FAIL`, cite the exact artifact paths in the judgment rationale, and document any residual uncertainty, borderline nuance, or open questions in the report's `Uncertainty & caveats` and `Uncertainty and Open Questions` sections.
- **Usability issues (`usability-issue`)**: whenever the system under test behaves counter-intuitively, misleads the agent into a wrong mental model or operation, confuses state, or fails to give actionable error feedback needed to recover, log it as a `usability-issue` (with exact steps, what confused the agent, missing feedback, and evidence path) in both the scenario details and the report's `## Usability Issues` section — **even if the scenario ultimately passes**.
- **Failures and tentative triage**: on `FAIL`, capture failing stdout/stderr, logs, screenshots/ARIA snapshots, and read-only state into `<output-dir>/<test-slug>/evidence/<case-slug>/<scenario-slug>/`, classify tentatively (`doc-drift`, `harness-gap`, `product-regression`, and/or `usability-issue`), and clean up residue before any next scenario.
- **Unmet external precondition**: if a case cannot run because of missing credentials, external service outage, entitlement, or unsupported OS capability, record the exact attempted command and unmet prerequisite and mark it `VERIFIED-UNREACHABLE` (never `PASS`).
- **Missing harness or broken startup**: if `Launch` or `Doctor` fails and cannot start a drivable instance, mark the affected run `BLOCKED` with the exact error output.
- **Draft bundles**: if a `Status: draft` bundle runs cleanly and passes, report that it is ready for explicit promotion to `Status: proven` via `author-case()`; do not edit the definition file during `run-case()`.

## Guardrails

- DO NOT create, edit, or delete any file under `<cases-dir>` (including `<cases-dir>/<case-slug>/README.md`, `cases/*.md`, and `helpers/*`) during `run-case()`.
- DO NOT emit an `INCONCLUSIVE` verdict; make a definitive `PASS`, `FAIL`, `BLOCKED`, or `VERIFIED-UNREACHABLE` call and document uncertainty or open questions in the test report.
- DO NOT hide or omit counter-intuitive behavior, misleading cues, or opaque error feedback encountered during execution; always report them under `usability-issue`.
- DO NOT drive an instance you did not start or verify with `Doctor`.
- DO NOT write raw execution scripts, runtime state, or proof artifacts outside `<output-dir>/<test-slug>/` (except the documented OS socket-length fallback), and DO NOT write durable reports outside the resolved report destination.
- DO NOT edit product source code or weaken test cases while executing `run-case()`.
- DO NOT treat a passing unit test, clean build, or tested agent's self-report as proof for an instructional case.
- DO NOT report a skipped entry point as verified because a different entry point passed.
- DO NOT delete `<output-dir>/<test-slug>/evidence/` during teardown, and DO NOT kill processes by bare name or disrupt user-owned tmux sessions.
