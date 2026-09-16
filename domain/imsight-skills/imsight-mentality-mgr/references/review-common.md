# Shared Mentality Review Contract

## Workflow

1. Load the requested child's review and selector/settings contract.
2. Resolve criteria through **Rule Selection** and target through **Code Scope**, respecting child boundaries.
3. Run the child's diagnostics under **Read-Only Effects**.
4. Report findings and coverage; save only on explicit request.

For other requests, use the native planning tool without expanding scope or activating rules. This reference supports child reviews, not a standalone action.

## Rule Selection

Keep effective configured rules `E` separate from invocation criteria `R`:

| Selectors | R |
| --- | --- |
| Omitted | E, with original scopes and priorities. |
| Explicit codes/names/groups | Exactly their validated expansion. |
| Explicit `all` | Every canonical ID of this mentality. |

Explicit criteria replace the baseline, including normally memory-disabled rules, for this review only. Label them `review-request`, explain departures in chat, and use task requirements/judgment for tensions. They change no selection, setting, priority, or counter. Child intensity may expand into R; invocation settings follow its schema.

Reject invalid/ambiguous requests entirely. Empty default E means no diagnostic scan; report that rather than a clean review. Unavailable memory or malformed project state makes default selection uncertain. Valid explicit selectors can still define R; mark comparison with effective state unavailable rather than claiming memory is empty.

Use [Definition Retention](runtime-injection.md#definition-retention) and applicable criteria only. Distinguish unselected rules from selected but inapplicable, unsupported, or unassessed ones. Review never authorizes implementing recommendations, including destructive-mode recommendations.

## Code Scope

Honor explicit pasted code, files/directories, diff, staged changes, working changes, commit range, or PR. PRs use their actual target/revision. Patch reviews focus on introduced or materially worsened issues; unchanged code is context. Label pre-existing issues separately when relevant to changed risk or a broader requested review.

Without an explicit target:

1. Inspect `git status --short --untracked-files=all`, `git diff --cached`, and `git diff`. Include task-related untracked source and reconcile staged/unstaged overlap; disclose inspected layers. Use index-only scope only when requested.
2. If clean, use an explicit base or PR target; otherwise resolve the chosen remote's configured default ref and disclose it. Verify refs/merge base before `git diff <base>...HEAD`; do not assume `main` or use a feature tracking ref as its PR target.
3. If no defensible target/base exists, ask; do not expand to the whole repository. Pasted code needs no Git, but missing context limits conclusions.

Read relevant callers, contracts, fixtures, and configuration as support without expanding targets. Exclude generated/vendored mechanical style using actual provenance and inspect maintained sources when relevant. Do not exclude hand-authored migrations/configuration by filename alone.

Scale effort to risk and coupling. Disclose sampling and skipped areas; a small diff does not waive applicable criteria. Re-read evidence after concurrent edits and identify the report as a snapshot.

Ponytail review follows its task baseline: new-code-only may inspect old infrastructure but recommends changes only to eligible new code. Destructive remains task-related. Untracked status alone does not prove code is newly authored.

## Read-Only Effects

Inspect source, configuration, and Git only. Existing test output may support findings with stated provenance; review does not run tests, installers, generators, or application code. Separately authorized execution/fixes are distinct phases with separately reported effects.

Upstream plugins, configurations, and past reports supply no runtime activation or scoring state. Review changes no instruction files (`AGENTS.md`, `CLAUDE.md`, etc.), catalogs, memory, or settings.

## Coverage and Reporting

Use the user's language and child's finding format. Include:

- Target/base/revision, working layers, supporting context, exclusions/sampling, and child boundary limits.
- Resolved R, effective versus explicit provenance, and invocation-only departures.
- Each selected ID's status: assessed, limited, inapplicable, or unassessed. Group matching statuses and explain limits; assessment does not require a finding.
- Supported findings with canonical IDs and precise locations; deduplicate common causes.
- Unknowns, execution evidence, and actual file effects. No findings is not whole-project approval; empty selection or unavailable evidence means review not performed.

## Saved Reports

Save only on explicit request. Use the specified destination; otherwise reserve `.imsight-arts/mentality/reviews/<UTC-timestamp>-<unique-run-id>/report.md` with a fresh random suffix and exclusive directory creation, retrying collisions. Never overwrite an existing report without explicit replacement authorization; use a sibling instead. Maintain no shared latest/history index.

Label reports as historical evidence with no activation effect. Include mentality, criteria, source mode, scope, findings, coverage, and any reviewed intensity/edit boundary. Exclude raw memory records or restoration data; explain comparisons with remembered overrides in chat. Reports never supply future activation/settings or change instruction files, catalogs, or memory. On save failure, return findings in chat and disclose partial output.

## Guardrails

- DO NOT turn review criteria into activation or widen the target/edit boundary.
- DO NOT replace empty or unresolved selection with all rules.
- DO NOT claim complete coverage from sampling or unsupported evidence.
- DO NOT execute code, apply fixes, or write unrequested reports as part of review.
