# Write Day Log

## Workflow

When this subcommand is invoked, execute the following steps in order.

1. **Resolve the day boundary**. Convert the requested date or "today" into an explicit start and end timestamp in the user's timezone or the current environment timezone.
2. **Resolve reporting scope**. Include the current repository, repositories explicitly named by the user, and directly relevant project-owned nested repositories or worktrees. See **Repository Scope**.
3. **Load the project report contract and select the shape**. Extract the project's own naming, language, sections, and style, or record that none exists; then choose the compact or structured report shape. See **Project Contract** and **Shape Selection**.
4. **Inspect Git evidence**. Read all-branch commits within the day boundary plus staged, unstaged, and relevant untracked changes. See **Git Inspection**.
5. **Inspect project materials**. Read authoritative non-Git records that establish work performed, decisions made, artifacts produced, or validation completed. See **Project Material Inspection**.
6. **Build a private evidence ledger**. Record candidate outcomes, delivery state, supporting evidence, verification, and uncertainty; use it for synthesis but do not emit it unless the user requests an audit view.
7. **Group evidence into report themes**. Merge commits, diffs, specifications, and project artifacts that support the same outcome; remove duplicate evidence and incidental mechanics.
8. **Draft the report**. Apply [../references/day-log-principles.md](../references/day-log-principles.md) and the selected shape, defaulting to the requested language and three numbered outcome points.
9. **Verify every sentence**. Confirm names, counts, status verbs, validation claims, and artifact outcomes against the inspected evidence.
10. **Deliver or save**. Follow the parent skill's **Output Contract**, then state the output path when a file was written.

If the requested report spans unusual repositories, dates, evidence systems, or audience constraints, use the native planning tool to build a bounded inspection and synthesis plan from this workflow and the user's scope, then execute the plan.

## Repository Scope

Use a bounded scope rather than every Git repository visible on the host:

1. Repositories and worktrees explicitly named by the user.
2. The current project repository.
3. Project-owned submodules, nested topic repositories, or external checkouts whose paths or records are directly connected to the day's work.

Inspect all branches and reachable refs within each selected repository. Include a separate repository only when it contributes evidence to the requested report; do not count the same commit twice through multiple worktrees.

## Project Contract

Check for the project's own reporting instructions before drafting, so that the report matches the artifact series it belongs to. See [Project Report Contract](../references/project-report-contract.md) for the discovery order and the fields to extract. When no contract exists, keep the skill defaults and do not invent project-specific sections or a localized body language.

Record the resolved filename, title form, body language, section set, numbering, and table rules in one private note. Re-read the contract on each run rather than reusing a remembered copy.

## Shape Selection

| Shape | Produces | Use when |
| --- | --- | --- |
| Compact | A dated heading and three numbered outcome paragraphs in the requested language | No contract selects a structure, or the user asks for a short recap |
| Structured | Contract-defined sections over capability, investigation, and remaining work, with result-bearing bullets first | The contract defines report sections, or the user asks for an engineering report |

Resolve the shape from the contract first, then the user's request, then an unambiguous existing series. Apply [../references/structured-report-shape.md](../references/structured-report-shape.md) for the structured shape. Do not mix the two: a structured report does not fall back to bare paragraphs, and a compact report does not grow section headings.

## Git Inspection

For each selected repository, collect enough evidence to reconstruct the day:

- Use `git log --all` with explicit `--since` and `--until` timestamps, stable date output, subjects, and focused stats or name-status information.
- Read selected commit diffs when subjects and stats do not establish the actual outcome.
- Inspect `git status --short`, `git diff`, and `git diff --cached` so the report includes relevant uncommitted work.
- Inspect relevant untracked files before describing them; a filename alone does not establish completion.
- Distinguish committed delivery, completed but uncommitted work, partial implementation, proposal-only work, archival movement, and generated output.
- De-duplicate changes visible in both a commit and later working-tree material.

Prefer `rg` and `rg --files` for repository searches. Exclude generated environments, caches, Git object databases, and unrelated vendor trees unless the requested work specifically concerns them.

## Project Material Inspection

Git does not capture every meaningful daily outcome. Inspect project materials that can confirm or qualify the work, including:

- Project and research-topic manifests, intent records, task status, issue records, and decision logs.
- OpenSpec or other design artifacts, completed task lists, archived changes, and synchronized canonical specifications.
- Build runs, test reports, validation payloads, publication or approval gates, generated artifacts, and revision logs.
- Research reading lists, evidence ledgers, source digests, paper drafts, experiment results, and other domain records.
- Changelogs, release notes, pull requests, or external-repository commits when they fall inside the requested scope.

Prefer authoritative structured records over modification times and filenames. A generated file proves that an artifact exists; use its run or validation record to claim build success, readiness, approval, or publication posture.

## Evidence Ledger

Maintain a compact private ledger with these fields:

| Field | Purpose |
| --- | --- |
| Candidate outcome | The reader-facing result that several evidence items may support |
| Evidence | Commits, diff sections, tasks, records, runs, or artifacts that substantiate it |
| Delivery state | Proposed, designed, implemented, validated, archived, generated, approved, partial, or blocked |
| Practical value | The problem resolved, risk reduced, capability added, or research progress achieved |
| Verification | Tests, build status, validation verdict, approval gate, or other checked result |
| Uncertainty | Missing evidence, uncommitted status, conflicting records, or scope limitations |

The ledger is a synthesis aid, not the normal day-log output.

## Completion Check

Before delivery, confirm that:

- The date and timezone match the requested reporting day.
- All selected repositories include both committed and uncommitted evidence.
- Relevant project materials were inspected rather than inferred from filenames.
- The report uses the requested language, or the contract's declared language, or English when neither exists.
- The default report contains three outcome-oriented points, not three arbitrary commits.
- A reader unfamiliar with the repository can understand every point.
- Public project and topic names use their recognizable full forms, while internal abbreviations are expanded or omitted.
- Completion and validation verbs match the evidence.
- The filename and title match the contract or the default naming rule.
- A structured report places its sections over the three purposes in order, leads every section with bullets, and keeps all future work in the closing section.
- A report triggered by an experiment shows the original primary metric by arm in the background section, with a table only when at least two comparable rows or columns exist.
