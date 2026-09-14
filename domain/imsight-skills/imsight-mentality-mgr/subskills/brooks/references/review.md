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
  invocation_contract: |
    - Invoke `imsight-mentality-mgr->brooks->review()` with a PR, diff, files, directory, or pasted code. Without a target, use Code Scope to resolve current changes.
    - Omitted selectors use effective Brooks rules. Explicit codes, names, or groups such as `r1 t2`, `production`, `tests`, or `all` replace criteria for this invocation only. “Full Brooks review” explicitly selects `all`; “review with Brooks” does not.
    - Natural form: `$imsight-mentality-mgr brooks review r1 t2` followed by the target. Selectors are arguments, not components of the invocation path.
    - Review returns findings in chat without changing files or memory. An explicit request to save the report permits only the report output described below. Review does not apply fixes.
---

# Brooks Review

## Overview

Review existing code for maintainability and test risks using the Brooks principle IDs already owned by this mentality. The workflow, all twelve diagnostic dimensions, judgment guidance, and report contract are bundled here. Prior deployment, a separately installed Brooks skill, upstream configuration, and access to source books are not prerequisites.

## Workflow

1. **Resolve the request and project** from the explicit review target and the shared [runtime contract](../../../references/runtime-injection.md). Identify requested selectors and whether a saved report was requested.
2. **Resolve review criteria** using **Rule Selection** and [state.md](state.md). Stop the diagnostic scan if there are no selected criteria or their resolution is materially uncertain; report the scope issue without changing state.
3. **Establish code scope** using **Code Scope**. Read the purpose, applicable repository instructions, relevant definitions, changed code, callers, and related tests. Record the revision or working-tree evidence inspected.
4. **Inspect selected dimensions** using **Diagnostic Pass** and the matching entries in [review-risks.md](review-risks.md). Load selected constructive definitions from the deployed catalog when valid, otherwise [principles.md](principles.md), following the shared runtime's definition policy.
5. **Validate each candidate** against **Evidence and Severity** and [review-sources.md](review-sources.md). Complete diagnosis before proposing a remedy; check counterexamples, causal consequences, and duplicate findings.
6. **Report coverage and findings** using **Report Contract**. Save only when explicitly requested, following **Saved Reports**. Preserve project and agent-memory selections throughout.

If the task does not map cleanly to these steps, use the native planning tool to build a bounded review from the requested criteria, available evidence, and read-only contract without assuming activation or expanding into a repository-wide audit.

## Rule Selection

Keep configured effective selection `E` separate from invocation criteria `R`. Use the shared runtime to resolve `E = (P union M+) minus M-`, including remembered negative overrides and conflicts across mentalities. All codes normalize through the Brooks selector reference.

| Request | Review criteria R | Effect on P, M+, M- |
| --- | --- | --- |
| No selectors | E | None. |
| Explicit codes, names, or groups | Exactly the validated expansion of those selectors | None. |
| Explicit `all` or full Brooks review | All twelve canonical IDs | None. |

Explicit selectors replace rather than augment the baseline. They are a direct user instruction to assess those criteria for this review, including any normally disabled in memory. State that departure in chat; it neither clears negative overrides nor carries into subsequent tasks. Other explicit task constraints and unrelated repository or higher-priority instructions still apply. For default review, preserve project versus agent-memory provenance when resolving conflicting selected principles; for explicit criteria, label their source `review-request` and resolve tensions through task requirements and judgment notes.

Reject an unknown or ambiguous explicit selector as a whole request; never fall back to all rules or silently review the valid subset. With omitted selectors and an empty `E`, report “No effective Brooks rules selected; no diagnostic scan performed.” An explicit valid selection still defines `R` when `E` is empty. A request to review code or inspect a catalog never implicitly enables anything.

If project state is malformed, contains unresolved IDs, or the current agent's memory is unavailable after context loss, explain the uncertainty before relying on default selection. Explicit valid selectors can still define a review independently of an unavailable baseline; label the comparison with effective selection unavailable. Do not claim remembered overrides are empty. Bare invocation does not recall another agent's memory.

Review uses applicable selected criteria only. The report distinguishes rules excluded by selection from selected rules that were inapplicable, insufficiently supported, or not assessed. A scope-limited review is not a full twelve-dimension assessment merely because all rules were requested.

### Selection examples

| State and request | Expected result |
| --- | --- |
| P = r1,r5; this agent M+ = t2 and M- = r5; default review | R = r1,t2. r5 stays suppressed. |
| Same state; review explicitly selects r5 | R = r5 with source review-request. Subsequent recall remains r1,t2. |
| Same project; a second fresh agent has no overrides | Its default review uses r1,r5, independently of the first agent. |
| Empty project and fresh memory; explicit all | R contains twelve IDs for this review; subsequent recall remains empty. |

## Code Scope

Honor explicit scope first: pasted code, supplied diff, file or directory list, staged changes, current working changes, commit range, or PR. A PR review uses its actual target branch and changed revision; a review of complete existing files may report existing issues within those files. A patch review primarily reports issues introduced or materially worsened by that patch. Nearby unchanged code supplies evidence; separately label pre-existing issues only when needed to explain a changed risk or when broader review was requested.

When no target is supplied, inspect local Git state with read-only commands:

1. Use `git status --short --untracked-files=all`, `git diff --cached`, and `git diff` to identify staged, unstaged, and untracked changes. Inspect changed untracked source files when they belong to the task. Review current changes together, reconcile overlapping staged/unstaged hunks, and disclose the layers inspected. A nonempty index must not hide unstaged work. Use only the index snapshot when the user explicitly asks for staged review.
2. If there are no local changes, resolve branch scope from an explicit base or available PR target. Otherwise inspect the chosen remote's configured default ref, such as `git symbolic-ref refs/remotes/origin/HEAD`, and disclose that inferred base. Resolve real refs and the merge base before using `git diff <base>...HEAD`; do not assume a branch named main or mistake the feature branch's tracking ref for its PR target.
3. If no meaningful scope or defensible base is available, ask for the target or base. Do not expand to the entire repository by default. Pasted code can be reviewed without Git; disclose missing caller or repository context.

Distinguish review targets from supporting context in the report. Inspect relevant callers, fixtures, contracts, and test configuration as needed, without treating every file read as a new target. Identify generated or vendored output from actual headers, generator configuration, or repository guidance and exclude its mechanical style from findings; inspect the maintained source when relevant. Hand-authored migrations and configuration can contain material behavior and are not excluded by filename alone. Explain skipped files.

Scale effort to risk and coupling. Large diffs may require sampling, but list the sampled areas and unassessed criteria. Small diffs can still affect dependency contracts or test reliability; size alone never drops a selected applicable dimension or proves decay. Re-read affected evidence if concurrent edits invalidate line references, and label the report as a snapshot rather than overwriting another agent's work.

## Diagnostic Pass

Read each selected rule's definition, diagnostic entry, and relevant source notes. Inspect production dimensions in this order when selected and applicable: r2 change boundaries, r1 comprehension, r3 decision ownership, r4 essential complexity, r5 dependencies, then r6 domain fidelity. This order guides investigation and does not establish rule priority.

For selected test dimensions, inspect related test bodies and fixtures, including existing tests for changed behavior. Assess t5 behavior protection, t4 boundary doubles, t1 readable intent, t2 resilience, t3 shared knowledge, and t6 suite placement/seams as applicable. Test-only changes still receive selected test checks. The bundled diagnostics cover all six test IDs; this is not limited to the upstream three-signal quick check.

No new test file is not proof of missing protection: trace the changed behavior to existing assertions, including integration evidence. Likewise, absence of tests from a pasted snippet is missing evidence, not proof the repository lacks tests. For t6, examine relevant seams and test configuration when available; a single diff rarely establishes suite-wide timings or architecture. Report that limit without inventing suite metrics or automatically launching a broader audit.

Use read-only source, configuration, and Git inspection. Existing test output may support findings, but report its provenance and relevance. This review does not execute tests, generators, installers, or application code. If the user also requested test execution or fixes, handle that as a distinct authorized task phase and report its actual effects separately.

## Evidence and Severity

Every finding follows **Symptom → Source → Consequence → Remedy**:

- **Symptom:** observable behavior or structure, with exact file and line evidence and relevant callers. For pasted code, use snippet line numbers or a named symbol; never invent repository locations.
- **Source:** canonical rule ID/name and the matching conceptual source from the bundled source notes. Book attribution explains the principle; it does not prove a code defect. Avoid unverified quotations or page numbers.
- **Consequence:** a concrete failure or maintenance cost with a supported causal path. Distinguish demonstrated behavior from a conditional risk and state the condition. Hypothetical future consumers do not justify speculative findings.
- **Remedy:** a specific target, action, and reason proportional to the observed problem. Explain a necessary design choice when evidence cannot determine it. Describing a remedy does not authorize applying it.

Before retaining a finding, check the documented counterexamples and any justified project tradeoff. Prefer one finding for one underlying cause, with related IDs when useful; do not double-count the same coupling as r2, r3, and r5. If only a threshold or an unsupported suspicion remains, omit it as a finding and record a material evidence gap when useful.

| Severity | Evidence needed |
| --- | --- |
| Critical | Demonstrated severe impact or a concrete near-term production/change-safety risk on an exercised path. State the trigger and impact. |
| Warning | A supported causal maintenance or regression risk in the affected work, with identifiable callers, decisions, or failure modes. |
| Suggestion | A concrete local improvement with modest demonstrated benefit and proportionate cost. Pure taste does not qualify. |

Apply consequence-based severity after diagnosis. Line counts, mock counts, fan-out, file counts, coverage percentages, and test ratios are prompts to inspect context, never automatic severity assignments. This procedure produces no numeric health score or trend comparison.

## Report Contract

Respond in the user's language. Keep canonical IDs stable and preserve the four finding fields. Scale presentation to the scope; a small review can use compact prose while retaining these facts:

1. **Scope:** target, base/revision or working-tree layers, files/areas assessed, supporting context, and generated or otherwise excluded material. Disclose sampling.
2. **Criteria:** effective or explicit mode, resolved R, provenance, exclusions, and any one-review departure from ordinary selection. Raw memory records are not part of the report artifact.
3. **Coverage:** list each selected ID as `assessed`, `limited`, `not applicable`, or `not assessed`, with a reason for the latter three. `Assessed` means the relevant evidence was inspected, not that the rule produced a finding. Group IDs sharing the same status and reason to keep small reports concise.
4. **Findings:** severity, concise title, canonical ID/name, exact location, and Symptom / Source / Consequence / Remedy. Sort Critical, Warning, then Suggestion. With many findings, give a short recommended fix order based on dependencies and impact.
5. **Limits and effects:** material unknowns, whether execution evidence was available, and actual file effects. If no findings remain, say “No supported findings within the assessed criteria and scope,” qualified by any coverage gaps. Empty selection or wholly unavailable evidence is a review not performed, never a clean review.

Do not offer automatic accept/dismiss/defer triage or persist suppressions. Neither `.brooks-lint.yaml` nor old reports supply selectors, severity overrides, custom risks, or activation state. The supported review vocabulary is the twelve bundled IDs; project instructions and explicit task scope still govern ordinary repository work.

## Saved Reports

Only an explicit save/export request authorizes an artifact. Use a user-specified destination when supplied; otherwise create `.imsight-arts/mentality/reviews/<UTC-timestamp>-<unique-run-id>/report.md` under the resolved project. Generate a fresh random suffix and reserve the directory exclusively; retry on collision. Do not overwrite an existing report or maintain a shared latest/history file. For an explicitly named existing file, use a distinct sibling unless replacement was explicitly authorized.

Label the artifact as historical review evidence with no activation effect. Record reviewed criteria, source mode, code scope, findings, and coverage limits; omit the agent's raw enabled/disabled record and any serialization intended for memory restoration. Explain comparisons with remembered overrides in chat. A later agent must not infer its own rules from this report. Writing the artifact never updates `AGENTS.md`, catalogs, memory, or an index of agents' selections. If saving fails, return the report in chat and describe any partial output accurately.

## Guardrails

- DO NOT treat an explicit review selector as a project or memory enable.
- DO NOT silently replace empty, invalid, or unavailable effective selection with all rules.
- DO NOT import activation, suppression, scoring, or custom-risk state from upstream configuration or report files.
- DO NOT report threshold crossings or missing snippets as established defects without causal evidence.
- DO NOT claim full review coverage when selected dimensions were sampled, inapplicable, or unassessed.
- DO NOT write files during review except for an explicitly requested report.
- DO NOT apply remedies, automatically run other Brooks skills, or load provenance snapshots as runtime instructions.
