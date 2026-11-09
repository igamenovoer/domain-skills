# Structured Report Shape

Use this shape when a project contract selects it or when the user explicitly asks for a structured engineering report. It describes section purposes rather than section titles: the contract supplies the labels, the language, and the numbering, while this page supplies the discipline underneath them.

## Section Purposes

A structured engineering report places three functional sections in this order, after a short summary and a background section:

| Purpose | Question it answers | Typical content |
| --- | --- | --- |
| Capability | What can be done now that could not be done before? | Shipped or integrated behavior, its practical value, and the verification that supports it |
| Investigation | What did we try to find out, and what did the evidence show? | The question, the comparison, the measured result, its cost, and what remains unknown |
| Remaining work | What is still unresolved, and how will we know it is resolved? | Concrete decisions, tests, or implementation targets, each with an observation that would settle it |

Keep one summary section before the background and one closing section after the third purpose. All future work belongs in the closing section, not at the end of each investigation.

Map the contract's headings onto these purposes; do not reorder the purposes to match a heading order that mixes them. When a project declares fewer sections, merge the remaining purpose into an existing one rather than inventing a fourth.

## Summary and Background

The summary carries the report's most decision-relevant conclusions, one bullet each: the most valuable capability, the main investigation answer with its comparison and cost, and the material limitation. Every summary bullet must be traceable to a body section.

The background section explains why the work exists before any mechanism appears: the problem or decision it informs, why it matters now, and the constraint or risk that shapes it. Keep it short. Do not restate the report's results there, and do not turn it into project history.

## Trigger Context

When an experiment result caused the work, the background section carries the original observation that triggered it, not the later result that resolved it. Show the primary metric per relevant arm, with its unit and comparison condition, and label the effective implementation, kernel, or runtime when that difference may explain the outcome. Never reduce the trigger to a ratio alone.

Use a table only when at least two rows or columns compare the same metric in the same unit. A single row, or a row that packs several observations into one cell, is a list and belongs in bullets. Do not duplicate the full result table; the background table exists to show why the work started.

## Bullets Before Prose

Every section and subsection opens with result-bearing bullets, then explanatory prose. The bullets state what was achieved, measured, or concluded; the prose explains the mechanism, the conditions, and the limits. Headings navigate, while bullets are the scan surface.

Avoid label-only bullets such as "background", "progress", or "validation". A bullet that carries no result, number, or limitation is a heading in disguise and should be rewritten or removed.

Do not repeat one sentence at several levels. A main section states the class of work and its progress; its subsections state specific conclusions.

## Investigation Sections

Title each investigation subsection with the question it answers, not with the sequence of runs. "Why does enabling the cache make decode slower?" is a title; "first attempt, then second attempt" is a transcript.

When one investigation answers several sub-questions, nest them as child sections under the parent using the contract's numbering. Keep the parent's bullets about the overall answer, and let each child state its own finding.

Report the motivation and the configuration needed to read a result before the numbers. Organize by question rather than by chronology. Omit debugging steps that do not affect the conclusion, and keep the failures, unresolved differences, and evidence gaps that do.

## Numbers and Claim Separation

Every material number carries its unit, comparison baseline, and the conditions that limit it: workload shape, hardware or model scope, repetition policy, and environment state. State whether a value is measured, estimated, or hypothesized.

Keep separate conclusions for logical correctness, strict output parity, numerical-drift diagnosis, task quality, and performance. A component or reduced-scale check does not establish whole-system behavior, and a performance result obtained with diagnostic outputs enabled is not an ordinary serving result.

Prefer an exact value to an adjective. When evidence is partial, keep the project's own wording for an unresolved status instead of smoothing it into a positive claim.

## Tables

Use a table when at least two rows or columns compare the same metric under the same unit. Use prose or bullets for a single observation, and split a cell that packs several numbers into separate rows. Keep the metric, the unit, and the comparison direction consistent across the table.

## Closing Section

Collect every unresolved question, planned check, and intended implementation target in the final section. Each item names what would settle it: a measurement, a comparison, a test, or a completion condition. Phrase an unproven explanation as a hypothesis.

Do not append another main section after the closing section.

## Applying the Shape

1. Resolve the section labels, language, numbering, and output naming from the project contract. See [project-report-contract.md](project-report-contract.md).
2. Assign each piece of evidence to one of the three purposes. Evidence that fits none is either background or a limitation, and belongs there.
3. Draft bullets first, then prose, then tables.
4. Validate that every summary bullet is supported by the body, that every number carries a condition, and that all future work sits in the closing section.
