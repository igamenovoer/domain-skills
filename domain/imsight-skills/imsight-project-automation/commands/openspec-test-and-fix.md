# OpenSpec Test And Fix

Use this subcommand to execute test cases supplied by the user, preserve evidence for unexpected outcomes, continue coverage with only minimal source patches, and resolve confirmed product bugs through `openspec-propose` followed by `openspec-apply-change`.

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the target project and output root**. See **Run Output**.
2. **Capture the baseline**. Record repository revision, existing user changes, relevant environment facts, and the commands or manual procedures available for the requested tests.
3. **Normalize the user-provided test cases**. Assign stable case IDs and record steps and expected outcomes. Ask only when a missing expectation or prerequisite prevents safe execution.
4. **Execute test cases in order**. Record each outcome and retain relevant evidence.
5. **Handle every unexpected outcome** using **Unexpected Outcome Handling**. Document it before changing source code.
6. **Continue independent coverage** until all runnable cases finish or a **Stop Threshold** is reached.
7. **Select confirmed product bugs for OpenSpec**. Exclude pure test, environment, ambiguous, and external failures unless they expose a product defect.
8. **Invoke `openspec-propose`** once with the selected bug bundle, evidence, continuation patches, and regression expectations. Do not invoke `openspec-explore`.
9. **Invoke `openspec-apply-change`** on the created change to complete the fixes and focused verification.
10. **Rerun affected tests and document fixes**. Update bug statuses and create fix records using **Fix Documentation**.
11. **Report the run** with the output path, cases executed, bugs found, stop reason, OpenSpec change, fixes, verification, and residual failures. Stop without syncing or archiving the change.

If the task does not map cleanly to these steps, use your native planning tool only with the testing, evidence, continuation-patch, stop-threshold, and OpenSpec constraints in this command. Do not add lifecycle stages, broaden the source-change scope, or silently convert uncertain outcomes into product bugs.

## Run Output

Resolve `<output-root>` through the parent skill's output contract, then create one run directory:

```text
<output-root>/openspec-test-and-fix/<YYYY-MM-DD-HHMMSS>-<slug>/
├── README.md
├── test-cases/
│   └── tc-001-<slug>.md
├── bugs/
│   └── bug-001-<slug>.md
├── fixes/
│   └── fix-001-<slug>.md
└── evidence/
    └── tc-001/
```

Copy and fill the templates under `assets/templates/openspec-test-and-fix/`. Create only bug, fix, and evidence entries that the run needs. Keep OpenSpec artifacts in the target project's normal `openspec/` tree.

The run `README.md` is the ledger for:

- the target and baseline revision;
- pre-existing dirty or untracked files;
- test-case status and evidence links;
- unexpected outcomes and classifications;
- discovery-time continuation patches;
- stop reason and unexecuted cases;
- OpenSpec change identifier and path;
- apply and final verification results;
- residual failures and risks.

## Test Case Execution

Treat the user's instructions as the authoritative test scope. Normalize each distinct case into `tc-NNN-<slug>.md` without changing its semantics.

Use these case statuses:

| Status | Meaning |
| --- | --- |
| `pending` | Not yet attempted |
| `passed` | Observed outcome matches the expectation |
| `unexpected` | Observed outcome differs from the expectation |
| `blocked` | A prerequisite or failure prevents execution |
| `skipped` | Intentionally not run, with a recorded reason |

For each attempt, record the exact command or manual action, relevant inputs, observed outcome, exit status when applicable, timestamp, and evidence paths. Preserve concise logs, screenshots, structured output, or reproduction files when they materially support the result. Do not place secrets or large generated datasets in the run bundle.

## Unexpected Outcome Handling

For each unexpected outcome:

1. Capture evidence before editing source code.
2. Create `bugs/bug-NNN-<slug>.md` and link the originating test case.
3. Classify the outcome using **Bug Classification**.
4. Identify the narrowest plausible cause and whether later independent cases can still run.
5. Apply a **Minimal Continuation Patch** only when it is required to unlock meaningful remaining coverage and satisfies every continuation criterion.
6. Record the exact patch and rationale in the bug document and run ledger.
7. Rerun the blocked step or focused case after a continuation patch, then proceed to independent cases.

Do not erase the original failure record when a continuation patch changes the outcome. A continuation patch is provisional discovery work, not the formal completion of the bug fix.

## Bug Classification

| Classification | OpenSpec Treatment |
| --- | --- |
| `confirmed-product-bug` | Include in the proposal |
| `probable-product-bug` | Include when evidence and a bounded expected correction are sufficient; otherwise mark ambiguous |
| `test-defect` | Exclude unless the maintained product test infrastructure itself is defective |
| `environment-defect` | Exclude unless project-owned setup or configuration is the defect |
| `ambiguous` | Exclude until evidence distinguishes expected behavior from a defect |
| `external-defect` | Exclude unless the product is missing required resilience or error handling |

Record the evidence and reasoning for the classification. Do not alter a user-stated expected outcome merely to make a result pass.

## Minimal Continuation Patch

A discovery-time source patch is allowed only when all of these are true:

- it is necessary to execute additional meaningful test cases;
- the failure and evidence are already documented;
- the cause and patch are sufficiently understood;
- the edit is localized, reversible, and preserves pre-existing user changes;
- it does not change public contracts, schemas, migrations, architecture, dependencies, or broad ownership boundaries;
- it does not require a multi-component refactor or a wide test rewrite.

Prefer the smallest change that restores testability. Record modified files and the before/after behavior. Include the bug and patch in the later OpenSpec proposal even when the rerun passes, so the formal apply stage can review, retain or revise, and verify it.

## Stop Threshold

Stop discovery when continuing would require many or broad source changes rather than another minimal patch. Use change topology, not a fixed bug count. Stop when any of these applies:

- a shared subsystem failure blocks most remaining cases;
- the next patch changes a public API, schema, migration, dependency, architecture, or cross-component contract;
- progress requires coordinated edits across several modules or a substantial refactor;
- provisional patches would obscure the original baseline or create cascading failures;
- repository state makes source ownership unsafe or user changes cannot be preserved confidently;
- no independent runnable cases remain.

Document the stop reason, blocked or skipped cases, and the source areas that would need broader change. Then proceed to the OpenSpec stages with the bugs already supported by evidence. Stop the entire routine only when OpenSpec itself cannot proceed safely or required project access, credentials, or external state is unavailable.

## OpenSpec Handoff

When at least one confirmed or sufficiently supported probable product bug exists:

1. Invoke `openspec-propose` with one coherent change covering the selected bugs. Provide the run ledger, bug documents, evidence paths, continuation-patch diff, expected fixes, and regression cases.
2. Validate that the proposal preserves the requested behavior and does not broaden into unrelated cleanup.
3. Invoke `openspec-apply-change` for that change.
4. Let the apply workflow review any continuation patches as part of the implementation rather than assuming they are final.

If no product bug qualifies, do not create an empty OpenSpec change. Finish the run documentation and report the classifications and next evidence needed.

Do not invoke `openspec-explore`, `openspec-sync-specs`, or `openspec-archive-change` through this subcommand.

## Fix Documentation

After apply, rerun every previously unexpected case affected by the change and any focused regression checks required by the proposal. For each resolved or attempted product bug, create `fixes/fix-NNN-<slug>.md` and link it from the bug document.

Record:

- linked bug and OpenSpec change;
- root cause established during implementation;
- final source change and whether it retained, revised, or replaced a continuation patch;
- commands or manual steps used for verification;
- final observed outcomes and evidence;
- residual limitations, failures, or follow-up work.

Use bug statuses `open`, `provisional-patch`, `proposed`, `applied`, `verified`, `unresolved`, or `not-product-bug`. Mark a bug `verified` only after a successful rerun. If verification cannot be performed, retain `applied` or `unresolved` and document the reason.

## Guardrails

- DO NOT overwrite, discard, or hide pre-existing user changes.
- DO NOT use destructive git operations to clean the worktree or hide failures.
- DO NOT edit source before capturing evidence for the unexpected outcome.
- DO NOT erase the original outcome after a continuation patch changes a rerun.
- DO NOT expand testing beyond the user-provided cases and directly required regression checks.
- DO NOT continue through unsafe commands, missing credentials, inaccessible external systems, or ambiguity that could cause harmful changes.
- DO NOT conceal failed tests, failed validation, or incomplete apply work.
- DO NOT sync or archive the OpenSpec change.
