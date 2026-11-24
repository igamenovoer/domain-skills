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

# Instructional Test Case and Harness Contract

This reference defines the directory layout, project-local temporary workspace rules, harness contract, instructional test case schema, agent-behavior blinding rules, and operator prompting patterns shared by all `imsight-project-mgr->agent-driven-testing` subcommands.

## Realwork Directory Layout (`tests/instructional/`)

Instructional test suites are functional verification assets owned by the **realwork project**, never by a metaproj root. Keep all committed instructional test materials under `<realwork>/tests/instructional/`:

```text
<realwork>/tests/instructional/
├── README.md                  # Required. Harness contract, baseline preconditions, driving rules, and case index.
├── cases/                     # Required. One Markdown file per user-facing feature or scenario.
│   ├── <feature-or-flow>.md
│   └── ...
└── helpers/                   # Optional. Durable, executable helper scripts invoked by README.md or cases.
```

- Keep implementation internals out of `cases/`. Describe user-visible surfaces, stable handles, required preconditions, exact commands, and observable proof.
- Every file in `helpers/` must be executable and have its exact invocation documented in `tests/instructional/README.md` or the calling case.
- Never place disposable run logs, temporary scripts, secrets, auth tokens, screenshots, or recordings inside `tests/instructional/`.

## Project-Local Temporary Directory Contract

All temporary scripting, disposable runtime state, and raw test output artifacts belong inside a **project-local ignored temporary directory** (`<project-tmp-root>`), never in system `/tmp` or tracked directories.

### Discovery Priority

Resolve `<project-tmp-root>` in this exact order before creating any temporary script or running any case:

1. **User-specified path**: use the directory explicitly provided by the user.
2. **Project context**: inspect the realwork and enclosing metaproj `AGENTS.md`, `.gitignore`, `env.example` / `.env` (`<PREFIX>_DEV_TMP_ROOT`), and existing ignored temporary trees (for example `<meta-root>/tmp/<complete-checkout-key>/` in a metaproj, or `<realwork>/tmp/`, `<realwork>/.tmp/`, `<realwork>/.scratch/` in a standalone realwork).
3. **Project-local fallback**: when no convention is documented, choose `<meta-root>/tmp/<complete-checkout-key>/` (when attached to a metaproj) or `<realwork>/tmp/` (when standalone), confirm it is ignored by Git using `git check-ignore -q <path>`, and create it. If the path is not ignored, add or request an ignore rule before writing scratch files.

### Per-Run Workspace Layout

Allocate a unique run identifier (`<run-id>`, for example `YYYYMMDD-HHMMSS-<slug>`) so concurrent or repeated runs never collide:

```text
<project-tmp-root>/instructional-tests/<run-id>/
├── scripts/        # Disposable per-run driver scripts, Playwright snippets, tmux/env shims
├── runtime/        # Disposable app data dirs, configs, caches, PIDs, stdout/stderr logs, profiles
├── evidence/       # Proof artifacts that MUST survive cleanup (screenshots, ARIA snapshots, transcripts, JSON cross-checks)
└── run-meta.json   # Run identity: realwork path, commit SHA, dirty status, harness version, timestamps, PIDs/sockets started
```

- **Temporary scripts (`scripts/`)**: write one-off exploration wrappers, browser-driving scripts, or launch shims here. When agents keep rewriting the same temporary script across runs, promote a clean version into `<realwork>/tests/instructional/helpers/` and document it in `README.md`.
- **Disposable runtime state (`runtime/`)**: keep isolated data dirs, test databases, homes, logs, and browser profiles here. Delete or stop only what this run created during cleanup.
- **Surviving artifacts (`evidence/`)**: store every screenshot, terminal capture, ARIA snapshot, HTTP/CLI transcript, and read-only cross-check file here under `<case-id>/`. Cleanup must never delete `evidence/`.
- **OS socket-length exception**: if an IPC or tmux Unix socket path under `<project-tmp-root>` exceeds the OS `AF_UNIX` length limit, place only the short run-unique socket file under an isolated OS socket dir (such as `/tmp/tmux-<uid>/<project>-<run-id>/`), record its exact path in `run-meta.json`, clean up only that socket on teardown, and keep all scripts, runtime data, and evidence inside `<project-tmp-root>`.

## Harness Contract (`tests/instructional/README.md`)

Write `tests/instructional/README.md` for a cold agent reading the repo mid-task, with concrete repo commands and zero placeholders. Include these sections:

1. **Baseline Preconditions & Isolation**: how to resolve `<project-tmp-root>`, required env vars, seeded fixtures, isolated ports/data dirs/tmux sockets, and whether two instances can run side by side (if not, state explicitly to refuse double-driving a shared instance).
2. **Launch**: exact command to start the target from an empty disposable data directory (including build, migrations, or seeding), plus the concrete signal that proves the target is *usable* (not merely listening). For short-lived CLIs or TUIs, state the one-time build step and how each drive launches an isolated PTY or tmux server (`env -u TMUX -u TMUX_PANE -u TMUX_TMPDIR tmux -S <socket>`).
3. **Doctor**: one read-only command or check answering "is this instance worth driving?" — process alive, expected revision/version, port or socket owned by this run, auth/endpoints healthy, and stable app marker confirmed.
4. **Drive**: the exact driving surface and conventions (existing test harness first, otherwise Playwright/CDP for Web, PTY/isolated tmux for CLI/TUI, HTTP/CLI for services). Prefer stable handles (ARIA roles/names, data attributes, explicit flags, `--print-json` / `--format json`, exact route paths) over coordinates, generated CSS hashes, or fragile DOM positions.
5. **Evidence**: proof standards and artifact paths inside `<run-tmp>/evidence/<case-id>/`. Require exercising the real user path, capturing both the triggering action and resulting state, and performing a read-only second-view cross-check of side effects (files written, DB rows, mailbox state, logs, exit codes). For dry-run or safe modes, require observing what the mode actually skipped rather than trusting its flag name.
6. **Cleanup**: exact teardown steps that stop only PIDs, containers, gateways, or isolated tmux servers started by this run (recorded in `run-meta.json`), remove `runtime/` scratch state, and leave `evidence/` intact.
7. **Helpers** (when `helpers/` is present): list every executable script with its exact command-line invocation and purpose.
8. **Case Index**: link every file under `cases/` with a one-line user-visible summary and any required capability tags (such as `cli`, `web`, `multi-agent`, `external-model`).

## Instructional Test Case Template (`tests/instructional/cases/<case-slug>.md`)

Every case file starts with an H1 title and one concise paragraph describing the user-visible behavior under test, followed by **four fixed H2 sections** in this exact order:

```markdown
# <User-Facing Feature or Scenario Name>

<One-paragraph summary of what the user or operator can accomplish and observe.>

## Sub-cases

- `<case-id-1>`: <one-line observable behavior>
- `<case-id-2>`: <one-line observable behavior>

## How to get to it (user POV)

- <User entry point 1 (UI control, keyboard shortcut, CLI command, API route, or operator workflow)>
- <User entry point 2>

## Driving it with <harness-name>

Preconditions:

- <Isolated runtime healthy via Doctor check>
- <Exact seed fixture, config, or service prerequisite>

- **<Step label>.** <User intent.> Run `<exact literal command or harness action>`. <Observable result proving this step succeeded.>
- **<Next step label>.** ...
- **Cross-check.** <Read-only second view confirming durable side effects.>
- **Proof.** Save `<artifacts>` under `<run-tmp>/evidence/<case-slug>/` and confirm each file shows `<discriminating state>`.

## Gotchas

- <Known timing/debounce rule: wait for an observable state, never a fixed sleep when avoidable>
- <Known wrong surface, flag trap, or unmet precondition behavior>
- <Reset or cleanup note preserving proof artifacts>
```

### Rules for Good Cases

- **Test behavior, not implementation**: a case should fail if user-observable behavior breaks and keep passing if only internals change.
- **No silent entry-point substitution**: proving one entry point does not verify another entry point listed under `How to get to it (user POV)`.
- **Fail honestly on missing preconditions**: if seed data, credentials, or a required service is missing, report `VERIFIED-UNREACHABLE` or `BLOCKED` and record the cause in `Gotchas`. Never weaken assertions to force a pass.
- **Include negative and reset steps where meaningful**: pair "must succeed" flows with refusal/guardrail checks and explicit reset instructions when a case can be repeated twice (such as bug reproduction or before-and-after fix verification).

## Optional Addendum: Agent-Behavior and Multi-Agent Cases

When the system under test includes AI agents, system skills, prompts, or multi-agent coordination (for example, evaluating whether two managed agents coordinate over a mailbox or obey guardrails), add an optional `## Blinding and Transcript Checks` section at the bottom of the case file with these rules:

- **Prevent observer effect**: keep meta-words (`eval`, `test`, `judge`, `rubric`, `benchmark`, `candidate`, `arena`) out of directories, filenames, and prompts seen by the tested agent. Give an organic user/operator prompt.
- **Grade from transcripts and side effects, not self-report**: inspect the tested agent's actual execution transcript, tool calls, opened files, and durable outputs (mailbox state, written files, audit logs) rather than trusting the agent's final summary.
- **Isolate fixture roles from general behavior**: do not leave narrow smoke-test roles (such as acknowledgement-only instructions) active when testing general task execution.

## How to Instruct an Agent to Generate Test Cases

Users and operators can trigger `imsight-project-mgr->agent-driven-testing->generate-cases()` directly by specifying the target realwork, what source material to convert (repo features, a debug campaign, an OpenSpec change, or a bug/PR), any external dependencies or model lanes, and the project-local temp directory if non-default.

> **Example Warning:** The user/AI prompt examples below are for example purposes only. Learn their style, intent, and semantics rather than hardcoding the example text, filenames, or model names.

### Example 1: Bootstrap From a Realwork Repository

- **User prompt**: "Invoke `imsight-project-mgr->agent-driven-testing->generate-cases()` on `<realwork>`. Interview the repo, set up `tests/instructional/README.md` with Launch/Doctor/Drive/Evidence/Cleanup using the project-local `tmp/` directory, and generate instructional cases for the top 3 user-facing CLI and Web workflows. Self-prove one case end to end before finishing."
- **Expected AI response shape**: Reports the resolved realwork path and `<project-tmp-root>`, lists created/updated files under `tests/instructional/`, summarizes the self-proof run (exact commands, `Doctor` result, case driven, surviving artifact paths under `<run-tmp>/evidence/`, and cleanup verification), and flags any prerequisites that remained unreachable.

### Example 2: Distill a Debug Campaign or Bug Fix Into Reusable Cases

- **User prompt**: "Invoke `imsight-project-mgr->agent-driven-testing->generate-cases()` on `<realwork>` to convert the recent debug campaign in `context/campaigns/debug/<campaign>/` into reusable instructional cases under `tests/instructional/cases/`. Include both the happy path and the failure/guardrail cases discovered during debugging, use `<project-tmp-root>` for scratch scripts and artifacts, and verify one case live."
- **Expected AI response shape**: Lists each distilled case file mapped back to the campaign's observed scenarios and failure modes, confirms disposable scripts and proof artifacts stayed inside `<project-tmp-root>/instructional-tests/<run-id>/`, reports the live self-proof verdict and surviving evidence paths, and notes any deferred campaign arms not yet converted.

### Example 3: Add a Multi-Agent or Skill-Behavior Case With Blinding

- **User prompt**: "Invoke `imsight-project-mgr->agent-driven-testing->generate-cases()` on `<realwork>` to add an instructional case in `tests/instructional/cases/two-agent-coordination.md` that verifies peer discovery and task delegation over mail without observer-effect leakage. Grade compliance from agent transcripts and mailbox state, and run a live self-proof."
- **Expected AI response shape**: Confirms the new case includes the four standard H2 sections plus `## Blinding and Transcript Checks`, reports the live self-proof commands, transcript/mailbox cross-check findings, surviving artifact paths, and clean teardown of all spawned agents and isolated sessions.
