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

This reference defines the three-part artifact layout, `draft` vs. `proven` status, cold-agent harness contract, and general scenario template shared across `imsight-project-mgr->agent-driven-testing`. Pair these structural contracts with the thinking rules in [principles.md](principles.md).

## Part 1: Test Definitions (`<cases-dir>/<case-slug>/` — Tracked in Repo)

Resolve `<cases-dir>` in priority order: (1) user-specified path, (2) instructional test root declared in `AGENTS.md` or `tests/README.md`, (3) default `<realwork>/tests/instructional/`. Resolve `<case-slug>` as a concise kebab-case topic slug without double-nesting if the user passed a path already ending in `<case-slug>`.

```text
<cases-dir>/                         # Default: <realwork>/tests/instructional/ (Git-tracked)
├── README.md                        # Optional. Lightweight index of <case-slug>/ bundles only.
└── <case-slug>/                     # Required per-topic bundle directory.
    ├── README.md                    # Required. Status (`draft` | `proven`), harness contract, and scenario index.
    ├── cases/                       # Required. One or more user/caller-POV Markdown scenario files.
    │   └── <scenario-slug>.md
    └── helpers/                     # Optional. Durable, executable helper scripts/drivers scoped to <case-slug>.
```

- **Status metadata (`draft` vs. `proven`):** `author-case()` stamps `Status: draft` near the top of `<cases-dir>/<case-slug>/README.md` whenever creating a bundle or materially modifying its harness, steps, or helpers without a subsequent live run. Promoting to `Status: proven (commit <sha>, report <path>)` happens only through an explicit `author-case()` update backed by a verified `run-case()` report, or through a live-verified `audit-case()` pass. `run-case()` never edits `<cases-dir>`.
- **Helpers:** Every script in `helpers/` must be executable, expose clear usage (`--help`) and structured output where useful, and show its exact invocation in `<cases-dir>/<case-slug>/README.md`.

## Part 2: Test Output (`<output-dir>/<test-slug>/` — Git-Ignored, Can Hold Anything)

Resolve `<output-dir>` in priority order: (1) user-specified output path, (2) `<project-tmp-root>/instructional-tests/` where `<project-tmp-root>` comes from `AGENTS.md`, `.gitignore`, `<PREFIX>_DEV_TMP_ROOT`, or existing ignored scratch trees (`<meta-root>/tmp/<checkout-key>/` or `<realwork>/tmp/`), (3) a newly created project-local `tmp/instructional-tests/` verified via `git check-ignore -q`.

Allocate a run-unique `<test-slug>` (such as `YYYYMMDD-HHMMSS-<case-slug>`). `<output-dir>/<test-slug>/` may hold any artifact produced during execution:

```text
<output-dir>/<test-slug>/
├── scripts/        # Disposable per-run driver scripts, wrappers, or shims
├── runtime/        # Disposable working dirs, configs, caches, PIDs, stdout/stderr logs, temp stores
├── evidence/       # Proof artifacts that MUST survive cleanup, organized under <case-slug>/<scenario-slug>/
├── run-meta.json   # Realwork path, branch, commit SHA, dirty state, tool versions, spawned PIDs/sockets
└── ...             # Any extra traces, dumps, metrics, or scratch diagnostics needed by the run
```

If an `AF_UNIX` IPC or terminal socket path under `<output-dir>/<test-slug>/` exceeds OS length limits, place only that short run-unique socket in an isolated OS runtime directory, record its exact path in `run-meta.json`, remove it on teardown, and keep all other files inside `<output-dir>/<test-slug>/`.

## Part 3: Test Reports (Optionally Git-Tracked)

Durable Markdown reports live outside both `<cases-dir>` and raw `<output-dir>/<test-slug>/` (defaulting to `.imsight-arts/project-mgr/agent-driven-testing/reports/<timestamp>-<run-slug>.md`, or a user/env destination) and may be tracked in Git at the project's or user's choice. See [report-template.md](report-template.md).

## Harness Contract (`<cases-dir>/<case-slug>/README.md`)

Write `<cases-dir>/<case-slug>/README.md` for a cold agent that has never seen the program, grounded in real repo commands with zero placeholders:

1. **Status & Baseline Isolation**: `Status: draft | proven (...)`, how `<output-dir>/<test-slug>/` is laid out, required env vars/fixtures/resources, and whether concurrent instances can run safely side by side (if not, state explicitly to refuse concurrent runs).
2. **Launch**: how to build or start the program from an empty disposable state and tell when it is genuinely *usable* (not merely listening). For short-lived CLIs, compilers, libraries, or batch jobs, state the one-time build/env step and per-invocation isolation.
3. **Doctor**: a read-only check confirming the target is worth driving — expected revision/build, owned process/port/socket/workdir, healthy dependencies, or preflight readiness for batch binaries.
4. **Drive**: how an agent interacts with the real public boundary (existing repo harness/CLI first; otherwise programmatic client, API/RPC call, isolated PTY/terminal session, batch invocation, or UI driver when applicable). Prefer stable handles (explicit CLI flags, structured JSON output, public endpoints, semantic labels) over fragile positional or internal hooks.
5. **Evidence**: what artifacts to save under `<output-dir>/<test-slug>/evidence/<case-slug>/<scenario-slug>/` — both the triggering invocation and resulting output plus an independent read-only second view of side effects (persisted files/records, recipient inbox, execution transcripts, or dry-run non-mutation check per `v3`).
6. **Cleanup**: how to stop only the PIDs, daemons, containers, or isolated sessions recorded in `run-meta.json` and remove disposable `runtime/` scratch state while keeping `evidence/` intact.
7. **Helpers** (if present): exact command-line invocation and purpose of each executable in `helpers/`.
8. **Case Index**: links and one-line summaries for every scenario in `cases/`.

## Scenario Template (`<cases-dir>/<case-slug>/cases/<scenario-slug>.md`)

Write each scenario from the user's, operator's, or caller's POV using five fixed H2 sections in order (plus optional `## Blinding and Transcript Checks` when testing AI agents):

```markdown
# <Scenario Name>

<One-paragraph intent & scope: what user/caller-visible behavior this scenario verifies and why.>

## Sub-cases

- `<sub-case-id>`: <one-line observable behavior, pairing positive and contrastive negative/boundary paths where meaningful>

## How to get to it (user POV)

- <Public entry point(s): CLI command, API/RPC call, config/job submission, message trigger, or interactive control>

## Driving it with <harness-name>

Preconditions:

- <Target healthy/ready via Doctor check + exact seed fixture, input, or external resource>

- **<Step label>.** <Intent.> Run `<exact literal command or driver action>`. <Immediate observable progression.>
- **Cross-check.** <Independent read-only second view confirming durable side effects or non-mutation.>
- **Proof.** Save `<artifacts>` under `<output-dir>/<test-slug>/evidence/<case-slug>/<scenario-slug>/`.

## Expected Outcome

- **Quantified checks:** <Explicit, machine-checkable predicates and structural red lines for everything countable, typed, or bounded — exit codes, counts, delivery/routing headers, schema/file invariants, numeric/timing bounds, zero crashes or forbidden writes.>
- **Qualitative checks:** <Natural-language criteria strictly for irreducible semantic behavior that cannot honestly be formula-checked (or `None` when fully quantifiable), naming the exact captured artifacts the runner inspects to decide `PASS` vs. `FAIL`.>

## Gotchas

- <State-based wait conditions instead of fixed sleeps, flag/config traps, unmet-precondition behavior, cleanup notes>
```

When testing AI agents, prompts, or multi-agent coordination, append `## Blinding and Transcript Checks` specifying how to keep evaluation meta-words (`eval`, `test`, `judge`, `rubric`, `benchmark`, `candidate`, `arena`) out of agent-visible paths/prompts and which execution transcripts and durable side effects the runner must inspect instead of trusting agent self-reports.
