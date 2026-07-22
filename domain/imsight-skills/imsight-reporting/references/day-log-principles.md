# Day-Log Reporting Principles

## Reader and Purpose

Write for a colleague, manager, collaborator, or stakeholder who did not read the repository or watch the work happen. The report should let that reader understand the day's outcomes, practical value, and delivery confidence without opening a commit, diff, task file, or generated artifact.

## Evidence Before Narrative

Collect evidence before choosing the three report points. Use this authority order when claims conflict:

1. Verified run, test, validation, approval, or publication records.
2. Current implemented state and focused diffs.
3. Committed history and completed task records.
4. Specifications, proposals, decisions, and plans.
5. Filenames, modification times, generated directories, and conversational recollection.

Lower-ranked evidence can identify work to inspect, but it cannot override a stronger contradictory record. Uncommitted changes count as work evidence, though the report should not imply they are merged, released, or delivered when that distinction matters.

## Synthesize Outcomes, Not Repository Activity

Group evidence that contributes to one outcome even when it spans several commits, repositories, specifications, and project records. A useful report point normally combines:

1. **Outcome**: what capability, research result, process improvement, or decision was completed or advanced.
2. **Value**: what problem it solves, risk it reduces, or next step it enables.
3. **Proof**: the concrete artifact, test, build, validation, approval, or measured result that supports the claim.

Default to three points because a daily report should emphasize the dominant work streams. Honor a different count when the user requests one, and never force unrelated work into one point merely to meet the default.

## External-Audience Language

- Name a public project, product, or research topic when it helps the reader orient, using its recognizable full name on first mention.
- Expand or omit internal abbreviations. Do not require the reader to understand branch names, repository folders, schema versions, skill identifiers, issue numbers, or commit hashes.
- Translate implementation mechanics into capability and impact, but retain concrete technical detail when it is itself the meaningful result.
- Explain specialized terms briefly when the intended audience may not know them.
- Do not hide the project identity behind generic phrases such as “the system” when the public name is useful.

## Claim Calibration

Match verbs to evidence:

| Evidence | Appropriate wording |
| --- | --- |
| Proposal, design, or task plan only | proposed, designed, specified, planned, refined |
| Implemented code or durable configuration | implemented, added, changed, migrated |
| Passing tests or authoritative validation | validated, verified, passed, confirmed |
| Successful artifact build record | built, generated successfully, compiled |
| Approval or publication gate record | approved, accepted, ready under the recorded gate |
| Partial or conflicting evidence | advanced, partially implemented, under validation, blocked |

Use “completed” only when the relevant implementation or artifact exists and required verification or acceptance evidence is satisfied. Do not convert an unchecked task, proposed design, draft filename, or recent modification time into a completion claim.

## Language Selection

Choose the report language in this order:

1. The language explicitly requested by the user.
2. The established language of an existing report series when the user asks to continue or revise it.
3. English by default.

Source material may use any language. Do not let the language of commits or project records silently override the reporting language.

## Report Shape

Use a dated Markdown heading for a saved report, followed by numbered points. Each point should be one compact paragraph, usually one or two sentences, and should remain understandable outside the repository.

Avoid appendices, commit lists, raw stats, internal evidence ledgers, and validation dumps unless the user requests an audit version. If important work remains unverified or incomplete, state that limitation in the relevant point rather than burying it in a generic footer.
