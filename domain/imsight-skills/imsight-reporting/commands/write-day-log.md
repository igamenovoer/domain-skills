# Write Day Log

## Workflow

When this subcommand is invoked, execute the following steps in order.

1. **Resolve the day boundary and scope**. Fix the requested date and timezone, then select the repositories and directly relevant nested or external checkouts. See **Scope and Evidence**.
2. **Load the project report contract**. Re-read the project's reporting instructions so filename, title, language, section layout, and terminology match the series. See [Project Report Contract](../references/project-report-contract.md).
3. **Inspect the day's evidence**. Read commits across branches, uncommitted and untracked work, and authoritative non-Git run or validation records. See **Scope and Evidence**.
4. **Prioritize by project goal**. When the day spans many unrelated workstreams or heavy upstream dependency changes, rank candidate additions and verified results by relevance to this project's goal and offer a quick focus pick before drafting—unless the user already specified the focus or asked to draft immediately.
5. **Apply the reporting mentality and write**. Remember the nine principles in [Reporting Principles](../references/reporting-principles.md) (`r1`–`r9`) and apply them directly while drafting, rather than filling a mechanical checklist.
6. **Deliver or save**. Follow the parent skill's **Output Contract** and report the written path when saved.

If the day's work spans unusual repositories, evidence systems, or audience constraints, use the native planning tool to plan evidence gathering and focus selection within these principles, then execute the plan.

## Scope and Evidence

Keep scope bounded to repositories named by the user, the current project root, and directly connected submodules, nested repositories, or external checkouts. Do not double-count commits across worktrees.

When collecting evidence for the day:

- Check all branches within the date window (`git log --all` with explicit `--since`/`--until` timestamps) plus `git status --short`, staged/unstaged diffs, and relevant untracked files.
- Check whether relevant external or orphan checkouts are up to date through the reporting cutoff; sync them if authorized or note the actual revision boundary inspected.
- Inspect authoritative non-Git records—live qualification reports, benchmark outputs, experiment logs, design decisions, and release notes—rather than inferring completion from filenames or timestamps.
- Separate real-world verification (live runs, end-to-end tests, external service checks, profiling, benchmarks) from routine CI checks (unit tests, lint, typecheck) so only decision-relevant proof enters the stakeholder report.

## Drafting Posture

Let the project contract determine whether the day log uses a structured section layout or compact outcome paragraphs, and keep the contract's exact section order and numbering. With [Reporting Principles](../references/reporting-principles.md) active in mind:

- Lead with what was actually built, discovered, or verified today (`r3`, `r4`).
- Keep the explanation self-contained for a stakeholder who will never open the repo (`r1`).
- Hold every claim to its real scope—an enabling runtime mechanism is not the finished research goal (`r5`), and every material number needs its baseline and conditions (`r7`).
- Write directly in clear, natural prose in the target language instead of translating English commit or spec phrasing word-for-word (`r8`).

## Guardrails

- DO NOT turn a day log into a commit digest, file list, or catalog of missing work.
- DO NOT cite unit-test counts, lint, typecheck, or internal spec checks as report outcomes unless the user explicitly requested an engineering audit.
- DO NOT describe an untracked draft or proposal as verified or completed work.
