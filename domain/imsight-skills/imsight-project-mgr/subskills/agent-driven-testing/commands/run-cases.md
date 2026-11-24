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

Execute one, several, or all instructional test cases under `<realwork>/tests/instructional/` against the live realwork checkout while using a project-local temporary directory for disposable scripts, isolated runtime state, and surviving proof artifacts.

## Workflow

When `imsight-project-mgr->agent-driven-testing->run-cases()` is invoked, execute the following steps in order.

1. **Resolve the realwork checkout and target cases.** Identify the realwork path, branch, commit SHA, dirty state, and which cases under `<realwork>/tests/instructional/cases/` are in scope. Read `<realwork>/tests/instructional/README.md` first. If `tests/instructional/` is missing, stop and direct the user to `imsight-project-mgr->agent-driven-testing->generate-cases()`.
2. **Initialize the project-local run workspace.** Resolve `<project-tmp-root>` per [case-and-harness-contract.md](../references/case-and-harness-contract.md) and create `<run-tmp> = <project-tmp-root>/instructional-tests/<run-id>/` with `scripts/`, `runtime/`, `evidence/`, and `run-meta.json`. Verify `<project-tmp-root>` is Git-ignored before writing files.
3. **Select the execution mode** from **Execution Modes** based on the user's goal (standard live pass, before-and-after fix verification, parallel slice fan-out, or blinded agent-behavior eval).
4. **Launch and health-check (`Doctor`).** Follow `tests/instructional/README.md`'s `Launch` model (one long-lived instance driven serially for servers/UIs, or a fresh isolated session per drive for short-lived CLIs/TUIs). Run `Doctor` and verify stable app markers, revision, owned ports/sockets, and auth before executing any case step.
5. **Drive each selected case while holding the live-pass invariants.** Put any throwaway per-run driving or probe scripts in `<run-tmp>/scripts/` and capture all proof artifacts into `<run-tmp>/evidence/<case-slug>/`. See **Live-Pass Invariants**.
6. **Clean up disposable runtime state without touching evidence.** Tear down every process, gateway, container, browser profile, and isolated tmux server recorded in `run-meta.json`, clean disposable `runtime/` state if requested or safe, and verify on disk that every captured file in `<run-tmp>/evidence/` survived cleanup.
7. **Produce the test report.** Invoke `imsight-project-mgr->agent-driven-testing->report-results()` (or apply [report-template.md](../references/report-template.md) directly) to write the durable Markdown report and return the concise in-chat summary.

If a task requires custom sequencing (such as pausing at human-watched checkpoints during a live interactive review), use your native planning tool to insert explicit pause gates between steps while keeping every `Doctor`, evidence, and cleanup invariant intact.

## Execution Modes

Choose the mode that matches the user's verification goal:

| Mode | When to Select | Required Discipline |
| --- | --- | --- |
| **Standard live pass** | Routine verification of one, several, or all cases in `tests/instructional/` | Follow `README.md`'s Launch model; run `Doctor`; drive every selected entry point and read-only cross-check; capture surviving proof. |
| **Before-and-after fix verification** | Proving a bug fix or PR resolves a reported symptom | Run identical environment inputs on baseline and patched builds. Observe the discriminating broken state **twice** (with an independent state reset between attempts) on baseline, then observe the expected fixed state **twice** on the patched build. Compilation or unit tests never count as "after" evidence. |
| **Parallel slice fan-out** | Large suites where `README.md` confirms isolated instances can run concurrently | Partition disjoint cases across parallel subagents, each with its own `<run-tmp>` slice, ports, and exact commit SHA. Require every worker to return `PASS`, `FAIL`, `BLOCKED`, or `VERIFIED-UNREACHABLE` with SHA and artifact paths; drop and respawn once if SHA or evidence is missing. |
| **Blinded agent-behavior eval** | Cases with `## Blinding and Transcript Checks` testing prompts, skills, or managed agents | Strip meta-words (`eval`, `test`, `judge`, `rubric`, `benchmark`, `candidate`, `arena`) from candidate workspaces and prompts; run organic requests; grade compliance from actual execution transcripts and side effects rather than candidate self-report. |

## Live-Pass Invariants

Hold all four invariants across the entire run, regardless of failures:

1. **Doctor before every untrusted drive**: run `Doctor` before the first drive, on every fresh isolated session, and immediately after any failed or surprising drive. When `Doctor` sees a healthy process whose UI, TUI, or agent session is wedged, capture diagnostic evidence, reset to a known baseline or relaunch, and re-run `Doctor` before proceeding.
2. **Real user paths only**: execute the literal commands, clicks, keys, or API calls documented in the case. Arrange preconditions through documented fixtures or setup steps only; never mutate internal state, storage, or DOM directly to simulate a symptom or pass.
3. **Evidence survives every cleanup**: capture both the triggering action and the resulting state plus the read-only second-view cross-check into `<run-tmp>/evidence/<case-slug>/`. After every cleanup step, check the filesystem to confirm those files still exist.
4. **Zero leaked residue on failure**: record every spawned PID, port, and isolated tmux socket in `<run-tmp>/run-meta.json` at startup. Clean up failed-iteration residue whether the drive succeeded, failed, hung, or exited abnormally. For shared long-lived instances, reset the case's residue rather than killing the instance prematurely; perform final teardown only after the last drive finishes.

## Handling Failures and Unreachable Paths

- **Symptom or assertion fails**: capture failing stdout/stderr, logs, screenshots/ARIA snapshots, and read-only state into `<run-tmp>/evidence/<case-slug>/`, record expected vs. observed state, classify tentatively (`doc-drift`, `harness-gap`, or `product-regression`), and continue cleaning up residue before any next case.
- **Unmet external precondition**: if a case cannot run because of missing credentials, external service outage, entitlement, or unsupported OS capability, record the exact attempted command and unmet prerequisite and mark it `VERIFIED-UNREACHABLE` (never `PASS`).
- **Missing harness or broken startup**: if `Launch` or `Doctor` fails and cannot start a drivable instance, mark the affected run `BLOCKED` with the exact error output.

## Guardrails

- DO NOT drive an instance you did not start or verify with `Doctor`.
- DO NOT write temporary driving scripts, shims, runtime state, or raw proof artifacts outside `<project-tmp-root>/instructional-tests/<run-id>/` (except the documented OS socket-length fallback).
- DO NOT edit product source code or weaken test cases while executing `run-cases()`.
- DO NOT treat a passing unit test, clean build, or tested agent's self-report as proof for an instructional case.
- DO NOT report a skipped entry point as verified because a different entry point passed.
- DO NOT delete `<run-tmp>/evidence/` during teardown, and DO NOT kill processes by bare name or disrupt user-owned tmux sessions.
