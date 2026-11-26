# Verification and Criteria Principles

This reference teaches how to think when designing, running, judging, and auditing agent-driven tests for any kind of program (CLIs, services, batch or compute pipelines, libraries, compilers, interactive apps, or multi-agent systems). Each principle states a core mental model, illustrates the decision boundary with `Don't` / `Do` comparisons, and notes where engineering judgment adapts the rule.

## Principle Index

| Code | Canonical Name | Compact Reminder |
| --- | --- | --- |
| `v1` | `behavior-at-the-boundary` | Exercise the public interface a real user or caller touches; fail when observable behavior breaks and keep passing when only internals change. |
| `v2` | `quantify-structure-judge-meaning` | Quantify every structural, countable, or measurable invariant; reserve natural-language criteria strictly for irreducible semantics judged from artifacts. |
| `v3` | `independent-second-view` | Never trust a status message, flag name, or tested agent's self-report alone; confirm durable effects from an independent read-only angle and pair contrastive cases. |
| `v4` | `suspect-the-instrument-first` | Verify the target and observation channel (`Doctor`, build revision, owned state, non-empty artifacts) before trusting a pass or blaming the program on a failure. |
| `v5` | `preserve-the-bar` | Hold the stated preconditions and expectations intact without weakening checks to pass or inventing unrequested gates above the bar. |
| `v6` | `confusion-is-a-usability-signal` | Treat counter-intuitive behavior, misleading cues, or opaque error feedback that trips up the agent as a `usability-issue`, even when the case ultimately passes. |
| `v7` | `isolated-runs-surviving-proof` | Separate tracked definitions, ignored run outputs, and durable reports; clean up only run-owned processes and scratch state while preserving cited proof on disk. |

## Principles

The examples below illustrate general reasoning across program types. Learn the underlying decision move rather than hardcoding specific tools, schemas, or thresholds.

### `v1` — `behavior-at-the-boundary`

Test what users, operators, or external callers can observe through the program's real boundary: inputs, exit codes, outputs, errors, persisted state, and external effects. Judge every test against two imagined edits: (1) **break the user-visible behavior** — if the test still passes, the check is too loose or circular; (2) **refactor internal helpers or data structures while keeping observable behavior identical** — if the test fails, it is pinned to implementation.

**Don't:** Import an internal worker class, call `worker._process_payload()` directly, and assert private cache keys or internal helper call order.

**Do:** Invoke the real CLI command, daemon endpoint, or job entrypoint with concrete input and verify the observable output and persisted result.

**Judgment:** Setup helpers and fixtures may prepare initial state *before* the action under test, never inject the result the test claims to prove. For a library whose public contract *is* a programmatic API, calling that public API in a small driver script is exercising the real boundary.

---

### `v2` — `quantify-structure-judge-meaning`

Most real-world requirements mix structural obligations with semantic intent. Decompose every expected outcome into two parts: **quantified checks** for everything countable, typed, bounded, or structural (exit codes, record/message counts, routing headers, file or schema invariants, state transitions, resource or latency ceilings, zero unhandled errors), and **qualitative checks** in plain natural language strictly for meaning that has no honest formula (clarity of reasoning, coherence of an explanation, appropriateness of a decision). On executed cases, the runner must still render a definitive `PASS` or `FAIL` (never `INCONCLUSIVE`), citing captured artifacts and recording any borderline nuance under report uncertainty.

**Representative comparison.** Requirement: *"When Agent A sends a task to Agent B, Agent B must accept or reject it by email reply, clearly stating the reason."*

- **Don't (under-quantified):** Leave the entire expectation as *"Agent B responds properly to Agent A's task email,"* allowing a runner to skim logs and pass the case without checking whether an email actually arrived in A's inbox, matched the thread, or came from B.
- **Don't (over-quantified):** Force semantic meaning into brittle string matching such as `assert "I reject this task because" in reply.body`, which fails valid phrasing while passing a broken reply that echoes the template prefix followed by gibberish.
- **Do (decomposed):**
  - *Quantified checks:* `1` task message delivered to B; `1` reply email from B in A's inbox within the timeout window with matching `In-Reply-To` / thread ID; B's process exits or returns to idle with `0` unhandled errors.
  - *Qualitative checks:* Inspect the captured reply body (and B's execution transcript) to confirm B takes an unambiguous accept-or-reject stance rather than hedging, and states a reason consistent with B's role and the task payload.

**Judgment:** Quantified bounds should come from real invariants, contracts, or noise-cleared baselines — never arbitrary magic numbers. For numerical or performance claims, account for run-to-run spread and rule out confounders (such as cached or skipped work) before trusting a threshold.

---

### `v3` — `independent-second-view`

A program printing `"Success"`, a `--dry-run` flag claiming safety by name, or a tested agent summarizing `"I updated the configuration and notified the peer"` is a self-report, not proof of durable state. Whenever a scenario mutates state, sends messages, or claims to leave state untouched, confirm the outcome through an independent read-only view, and pair "this succeeds" cases with contrastive negative or boundary cases ("invalid input is rejected without partial writes").

**Don't:** Run `archive-tool --prune --older-than 30d`, see stdout `"Pruned 12 entries"`, and mark `PASS` without checking what remains in storage or whether newer entries survived.

**Do:** Query the store or output directory afterward from a read-only command or file inspection to confirm the 12 old entries are gone, recent entries remain intact, and a `--dry-run` invocation leaves byte-identical state.

**Judgment:** Pure stateless tools (such as a parser, formatter, or calculator whose entire contract is stdout and exit code) do not need an artificial second storage check; instead, pair valid inputs with malformed or boundary inputs so a constant or coincidental output cannot pass. When testing AI agents, keep evaluation meta-words (`eval`, `test`, `judge`, `rubric`, `benchmark`, `candidate`) out of agent-visible paths and prompts, and grade from execution transcripts and side effects rather than self-reports.

---

### `v4` — `suspect-the-instrument-first`

When a check fails — or passes suspiciously fast — suspect the observation method before the system under test. A port answering TCP does not mean initialization finished; a stale background daemon may belong to an earlier commit; a redirected log or capture file may be empty. Verify target identity and readiness (`Doctor`) before the first drive, on each fresh session, and after any unexpected failure, and inspect captured files on disk before citing them.

**Don't:** Point a test script at `localhost:8080` without checking which process owns it, hit a schema error from a leftover instance on an older branch, and report a `product-regression` on the current commit.

**Do:** Start an isolated instance (or verify explicit ownership), run `Doctor` to confirm PID/socket ownership, commit/version stamp, and usable readiness, and reset or relaunch cleanly when a healthy process enters a wedged session state.

**Judgment:** Match `Doctor` to the program's lifecycle. A long-lived service or multi-agent topology warrants process, version, and endpoint health checks; a one-shot CLI or batch binary needs only a lightweight preflight (expected binary/environment active, clean working directory, required device or fixture present).

---

### `v5` — `preserve-the-bar`

The stated preconditions and expected outcomes define the bar — neither lower nor higher. When a precondition cannot be met (missing credentials, hardware, or external service) or the program violates an expectation, report `VERIFIED-UNREACHABLE`, `BLOCKED`, or `FAIL` honestly instead of simplifying the journey to manufacture a pass. Conversely, do not invent extra approval gates or out-of-scope checks above what the case specifies, and separate newly broken behavior at HEAD from pre-existing baseline limitations.

**Don't:** Discover that a GPU or external model endpoint required by the case is offline, swap in a mock stub that bypasses the real execution path, and report `PASS`.

**Do:** Stop that case at the missing prerequisite, record the exact command attempted and the unmet dependency, and mark `VERIFIED-UNREACHABLE` (or `FAIL` under `product-regression` when preconditions held and behavior broke).

**Judgment:** Changing a test definition is appropriate only under explicit authoring (`author-case()`) or maintenance (`audit-case()`) authority when source, specs, or commit history confirm an intentional behavior change (`doc-drift`) or a brittle driver (`harness-gap`).

---

### `v6` — `confusion-is-a-usability-signal`

An agent driving a program from its public interface and help text experiences the same friction a new user or operator hits. When ambiguous flag names, silent no-ops, contradictory status output, or cryptic error messages mislead the agent into wrong assumptions or trial-and-error — even if the agent eventually inspects source or guesses the workaround and passes the functional check — surface that friction as a `usability-issue`.

**Don't:** Hit a generic `"Error: invalid configuration"` exit three times until discovering an undocumented required flag combination, complete the run, report `PASS`, and omit the dead ends.

**Do:** Report `PASS` if the functional contract succeeded once invoked properly, *and* log a `usability-issue` detailing what the agent tried, why the interface or error message misled it, and what actionable feedback was missing.

**Judgment:** Separate genuine product UX/CLI/error-feedback flaws (`usability-issue`) from mistakes inside the test bundle's own README or scenario text (`doc-drift` / `harness-gap`). Never rewrite a test case to hide a real `usability-issue` without reporting it first.

---

### `v7` — `isolated-runs-surviving-proof`

Keep the three artifact layers distinct: tracked **test definitions** (`<cases-dir>/<case-slug>/`) stay clean and read-only during runs; ignored **test outputs** (`<output-dir>/<test-slug>/`) hold disposable runtime state, per-run scripts, diagnostics, and raw `evidence/`; durable **test reports** summarize verified findings and may be Git-tracked independently. Cleanup must stop every process, session, or socket started by the run while leaving `evidence/` intact on disk so a reader can verify any claim without replaying the run.

**Don't:** Tear down a test run with `pkill -f server` (killing unrelated user processes) or `rm -rf <output-dir>/<test-slug>/` (deleting the logs and captures cited by the report).

**Do:** Record run-owned PIDs, sockets, and scratch paths in `run-meta.json`, tear down only those resources on both pass and fail, confirm `evidence/` files still exist afterward, and promote repeated throwaway scripts into `<cases-dir>/<case-slug>/helpers/` only through an explicit `author-case()` or `audit-case()` update.

**Judgment:** Evidence format follows the program — structured JSON/stdout/exit codes for CLIs, output artifacts and metrics for batch/compute jobs, message stores and transcripts for multi-agent runs, or UI snapshots when testing a graphical or terminal interface.
