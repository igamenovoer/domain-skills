# Project Report Contract

A report contract is whatever a project uses to define its own reporting artifact: a reporting README, a documentation page, a contributing guide, a style directory, a template, or a series of dated reports that establish a convention. This page defines how to find that contract, what to extract from it, and which rules it cannot override.

The contract is optional. When none exists, the skill's defaults apply and no project-specific structure is invented.

## Contract Discovery

Resolve the contract in this order, and stop at the first source that answers the **Extraction Checklist**:

1. An explicit instruction from the user, including a path to a template or an example report.
2. Reporting instructions stored with the project: a reporting or documentation directory, a README or contributing entry about reports, a style or terminology guide, or an agent-guidance file.
3. An established series of dated reports whose shape is unambiguous across at least two consecutive artifacts. Infer shape and naming from them, and treat a conflicting newer artifact as a deviation rather than as a second convention.
4. No contract.

Search the project the user named, the current project root, and project-owned nested repositories or worktrees that the requested report covers. Do not adopt a convention from an unrelated repository, a vendored dependency, or a generated directory.

## Extraction Checklist

Extract these fields. A field the project does not declare keeps the default in the right-hand column; do not infer a stricter rule than the project states.

| Field | What to extract | Default when undeclared |
| --- | --- | --- |
| Artifact kinds and filenames | Which reports exist, such as daily, weekly, or per-milestone, and their naming pattern | `YYYY-MM-DD.md` for daily and `YYYY-Www.md` for weekly |
| Body language | The language of the report body, which may differ from the language of the repository | The language the user requested, else English |
| Title form | The heading pattern, including how a date or date range appears | A dated heading |
| Sections, order, and numbering | Required sections, their order, and whether headings are numbered | Compact outcome points, or the structured shape when the user requests it |
| Bullet and prose discipline | Whether a section leads with bullets, and whether prose must follow | Bullets first in the structured shape; compact paragraphs in the default |
| Table rules | When the project permits, requires, or forbids tables | Tables only for two or more comparable rows or columns |
| Style and lexicon sources | In-repository style guides, terminology lists, banned phrasing, and preferred technical names | None; follow the reader and evidence rules in this skill |
| Project claim or scope rules | Additional separation the project requires, such as a hardware, model, or parity boundary | The skill's own claim rules |

Record the resolved values in one private note before drafting. Do not emit the checklist into the report.

## Precedence

Apply sources in this order:

1. The user's explicit instruction for this report.
2. The project contract.
3. This skill's defaults.

A lower source supplies a value only when a higher source leaves that field undeclared. When two project sources disagree, prefer the one attached to the artifact being written, then the newest one the project still maintains.

## Non-Overridable Floor

A contract may change shape, language, naming, and style. It may not relax these rules:

- Evidence authority: verified run, test, validation, approval, or publication records outrank implemented state, which outranks committed history, which outranks plans and proposals.
- Claim calibration: status verbs match the available evidence, and completion requires verification.
- No invention: measurements, causes, coverage, and completion status are never inferred to fill a template.
- Conclusion separation: logical correctness, strict output parity, numerical-drift diagnosis, task quality, and performance remain separate conclusions.
- Reader independence: unfamiliar terms are defined and no internal identifier substitutes for an explanation.
- Credential and personal-data exclusion.

## Applying the Contract

1. Re-read the contract at the start of each report instead of relying on a remembered copy, because projects revise their conventions.
2. Translate declared section labels into the three section purposes when the contract selects a structured report. See [structured-report-shape.md](structured-report-shape.md).
3. Use the declared filename and title patterns verbatim.
4. Use the declared default silently when the contract is silent on a field; do not discuss the omission inside the report.
5. Keep both records when the contract conflicts with a verified project artifact: follow the declared contract, and tell the user about the discrepancy after delivery.

## Contract Absence

Without a contract, produce the compact form described in the parent skill's **Report Shapes** section: the requested language, a dated heading, and a small number of numbered outcome paragraphs. Do not invent section headings, numbering, a localized body language, or a project-specific structure.
