# Shared Mentality Review Contract

## Workflow

1. Load the requested child's review entrypoint and selector/settings contract; this reference is shared support, not a standalone review action.
2. Resolve effective or invocation-only criteria under **Rule Selection**, plus any child-specific edit boundary. Validate the complete request before proceeding.
3. Establish the target and evidence baseline under **Code Scope**. Intersect that target with the child's permitted review surface.
4. Perform the child's diagnostic procedure under **Read-Only Effects**, using its definitions, counterexamples, and finding format.
5. Return the child's findings with **Coverage and Reporting**; save only on explicit request under **Saved Reports**.

If the task does not map cleanly to these steps, use the native planning tool to preserve the requested criteria, target, and child boundaries without activating rules or inventing a broader audit.

## Rule Selection

Keep configured effective selection `E` separate from invocation criteria `R`. Use [runtime-injection.md](runtime-injection.md) to resolve `E = (P union M+) minus M-`, including remembered negative overrides and conflicts across mentalities. All codes normalize through the selected child's selector reference.

| Request | Review criteria R | Effect on P, M+, M- |
| --- | --- | --- |
| No selectors | E | None. |
| Explicit codes, names, or groups | Exactly the validated expansion of those selectors | None. |
| Explicit `all` | All canonical IDs of the selected mentality | None. |

Explicit selectors replace rather than augment the baseline. They are a direct user instruction to assess those criteria for this review, including any normally disabled in memory. State that departure in chat; it neither clears negative overrides nor carries into subsequent tasks. Other explicit task constraints and unrelated repository or higher-priority instructions still apply. For default review, preserve project versus agent-memory provenance and family priorities when resolving conflicting selected principles; for explicit criteria, label their source `review-request` and resolve tensions through task requirements and judgment notes. Review never allocates or changes priorities or either scope's counter.

Reject an unknown or ambiguous explicit selector as a whole request; never fall back to all rules or silently review the valid subset. With omitted selectors and an empty `E`, report “No effective rules selected for this mentality; no diagnostic scan performed.” An explicit valid selection still defines `R` when `E` is empty. A request to review code or inspect a catalog never implicitly enables anything.

If project state is malformed, contains unresolved IDs, or the current agent's memory is unavailable after context loss, explain the uncertainty before relying on default selection. Explicit valid selectors can still define a review independently of an unavailable baseline; label the comparison with effective selection unavailable. Do not claim remembered overrides are empty. Bare invocation does not recall another agent's memory.

Review uses applicable selected criteria only. The report distinguishes rules excluded by selection from selected rules that were inapplicable, insufficiently supported, or not assessed. A scope-limited review is not a complete assessment merely because all rules were requested.

A child's explicit review intensity can expand a preset into R; it never changes stored intensity or edit scope. Resolve additional invocation settings through the child's schema. Read rule and setting meanings through shared [Definition Retention](runtime-injection.md#definition-retention), keeping review-only choices labeled as invocation criteria, never remembered activation or setting overrides. A review request is not permission to apply its recommendations, including when a child uses the term destructive.

## Code Scope

Honor explicit scope first: pasted code, supplied diff, file or directory list, staged changes, current working changes, commit range, or PR. A PR review uses its actual target branch and changed revision; a review of complete existing files may report existing issues within those files. A patch review primarily reports issues introduced or materially worsened by that patch. Nearby unchanged code supplies evidence; separately label pre-existing issues only when needed to explain a changed risk or when broader review was requested.

When no target is supplied, inspect local Git state with read-only commands:

1. Use `git status --short --untracked-files=all`, `git diff --cached`, and `git diff` to identify staged, unstaged, and untracked changes. Inspect changed untracked source files when they belong to the task. Review current changes together, reconcile overlapping staged/unstaged hunks, and disclose the layers inspected. A nonempty index must not hide unstaged work. Use only the index snapshot when the user explicitly asks for staged review.
2. If there are no local changes, resolve branch scope from an explicit base or available PR target. Otherwise inspect the chosen remote's configured default ref, such as `git symbolic-ref refs/remotes/origin/HEAD`, and disclose that inferred base. Resolve real refs and the merge base before using `git diff <base>...HEAD`; do not assume a branch named main or mistake the feature branch's tracking ref for its PR target.
3. If no meaningful scope or defensible base is available, ask for the target or base. Do not expand to the entire repository by default. Pasted code can be reviewed without Git; disclose missing caller or repository context.

Distinguish review targets from supporting context in the report. Inspect relevant callers, fixtures, contracts, and test configuration as needed, without treating every file read as a new target. Identify generated or vendored output from actual headers, generator configuration, or repository guidance and exclude its mechanical style from findings; inspect the maintained source when relevant. Hand-authored migrations and configuration can contain material behavior and are not excluded by filename alone. Explain skipped files.

Scale effort to risk and coupling. Large diffs may require sampling, but list the sampled areas and unassessed criteria. Small diffs can still affect dependency contracts or test reliability; size alone never drops a selected applicable dimension or proves decay. Re-read affected evidence if concurrent edits invalidate line references, and label the report as a snapshot rather than overwriting another agent's work.

A target names the code to consider, not permission to exceed a child's edit boundary. Ponytail new-code-only review may read existing infrastructure as context but only recommends changes to newly introduced code; its destructive review remains confined to infrastructure related to the assigned task. Follow the child's definition of the task baseline and report unavailable provenance instead of treating all untracked code as new.

## Read-Only Effects

Use read-only source, configuration, and Git inspection. Existing test output may support findings, but report its provenance and relevance. This review does not execute tests, generators, installers, or application code. If the user also requested test execution or fixes, handle that as a distinct authorized task phase and report its actual effects separately.

Neither installed upstream plugins, their configuration, nor past reports supply activation, suppression, or scoring state. Review uses the registered child's canonical vocabulary and current task instructions. It does not change AGENTS.md, catalogs, agent-memory overrides, or configured child settings; reading definitions does not constitute an activation change.

## Coverage and Reporting

Use the user's language and the child's finding format. Scale the report to the scope while retaining:

1. **Scope:** target, base/revision or working-tree layers, assessed areas, supporting context, excluded material, and sampling. Include a child's edit boundary and any baseline limits.
2. **Criteria:** effective or explicit selection, resolved R, provenance, exclusions, and invocation-only departures from ordinary settings. Explain comparisons with remembered overrides in chat, without serializing memory in an artifact.
3. **Coverage:** each selected ID is assessed, limited, not applicable, or not assessed; explain the latter three. Group IDs with the same status and reason. Assessed means relevant evidence was inspected, not that there was a finding.
4. **Findings:** use the child's evidence requirements and format. Retain canonical IDs and precise locations. Do not report the same underlying cause repeatedly under different labels.
5. **Limits and effects:** material unknowns, available execution evidence, and actual output-file effects. No supported findings within the assessed scope is not proof of whole-project quality. Empty selection or wholly unavailable evidence means review not performed, never a clean review or shipping approval.

## Saved Reports

Only an explicit save/export request authorizes an artifact. Use a user-specified destination when supplied; otherwise create `.imsight-arts/mentality/reviews/<UTC-timestamp>-<unique-run-id>/report.md` under the resolved project. Generate a fresh random suffix and reserve the directory exclusively; retry on collision. Do not overwrite an existing report or maintain a shared latest/history file. For an explicitly named existing file, use a distinct sibling unless replacement was explicitly authorized.

Label the artifact as historical review evidence with no activation effect. Record reviewed criteria, source mode, code scope, findings, and coverage limits; omit the agent's raw enabled/disabled record and any serialization intended for memory restoration. Explain comparisons with remembered overrides in chat. A later agent must not infer its own rules from this report. Writing the artifact never updates `AGENTS.md`, catalogs, memory, or an index of agents' selections. If saving fails, return the report in chat and describe any partial output accurately.

Reports may record the review's resolved intensity and edit boundary as historical criteria, never as settings to load into another task. Each artifact identifies its mentality. Concurrent reviews reserve independent directories and never update a shared latest/history index.

## Guardrails

- DO NOT turn explicit review criteria or settings into project or agent activation.
- DO NOT replace empty, invalid, or unavailable selection with all rules.
- DO NOT broaden the target or child edit boundary because an opportunity appears nearby.
- DO NOT imply full coverage when criteria were sampled, unsupported, or unassessed.
- DO NOT write files except for an explicitly requested report, or apply fixes as part of review.
- DO NOT load provenance snapshots or upstream mode state as runtime instructions.
