# Project Report Contract

A report contract is whatever a project uses to define its own reporting artifact: a reporting README, a documentation page, a style or terminology guide, a template, or an established series of dated reports. Discover the contract before drafting so the report matches its series without inventing conflicting structure.

When no project contract exists, apply this skill's defaults cleanly without inventing project-specific section headings or localized labels.

## Contract Discovery

Resolve the contract in this order, stopping at the first source that answers the **Extraction Checklist**:

1. An explicit instruction from the user for this report (including a template or example path).
2. Reporting instructions stored with the project (for example, `reporting/daylogs/README.md`, a documentation guide, a terminology guide, or `AGENTS.md`).
3. An unambiguous series of at least two consecutive dated reports establishing naming, language, and layout.
4. No contract.

Search only the user-named project, the current project root, and directly relevant project-owned nested repositories or worktrees—never unrelated repositories or vendored dependencies.

## Extraction Checklist

Re-read the contract on each run rather than relying on memory, because projects refine their reporting rules over time.

| Field | What to extract | Default when undeclared |
| --- | --- | --- |
| Artifact kinds and filenames | Report types (daily, weekly, milestone) and naming pattern | `YYYY-MM-DD.md` for daily; `YYYY-Www.md` for weekly |
| Body language | Language of the report body (may differ from repo language) | Language requested by the user, else English |
| Title form | Heading format, including date or week range syntax | Plain dated heading |
| Sections, order, and numbering | Required sections, exact order, and heading numbering | Compact outcome paragraphs |
| Bullet, prose, and table rules | Lead-bullet conventions, paragraph wrapping, and table rules | Concise paragraphs; tables only for two or more comparable rows/columns |
| Audience and scope filters | Target audience (e.g., management), excluded items (e.g., unit tests, CI checks), and preferred terms/lexicon | Apply [Reporting Principles](reporting-principles.md) (`r1`–`r9`) |

## Precedence

Apply sources in this order:

1. User's explicit instruction for this report.
2. The project report contract.
3. This skill's defaults and [Reporting Principles](reporting-principles.md).

Honor the project contract's declared section order, labels, numbering, body language, and preferred terminology verbatim. Never reorder a project's declared sections to force a generic template.

## Non-Overridable Floor

A project contract owns shape, section order, language, and style. It may not relax these rules:

- **Evidence honesty (`r4`)**: verified run/benchmark records outrank code, which outranks commits, which outranks proposals; never invent numbers or turn drafts into verified results.
- **Scope accuracy (`r5`)**: keep enabling mechanisms, component checks, and local metrics distinct from overarching research or full-system goals.
- **Reader independence (`r1`, `r8`)**: keep prose self-contained and clear without relying on unseen repository files or internal identifiers.
- **Secret and privacy exclusion (`r9`)**: never include credentials, private endpoints, tokens, or personal data.
