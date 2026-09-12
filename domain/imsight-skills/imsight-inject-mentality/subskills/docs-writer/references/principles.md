# Docs Writer Constructive Principles

This catalog holds the Docs Writer rule definitions: canonical IDs, compact injected reminders, teaching examples, and judgment notes. The reminders are intentionally constructive rather than finding-oriented.

## Workflow

1. Load the current selected codes from Docs Writer state.
2. Use only the matching compact reminders from **Writing Rules**.
3. Ground each selected rule in its **Representative Do / Don't comparison**, then apply its judgment note while drafting, restructuring, and polishing the current document.
4. Render selected reminders without unselected content.

If the task does not map cleanly to these steps, use the native planning tool to apply the selected reminders proportionately to the document in scope.

## Writing Rules

| Code | Canonical name | Compact injected reminder |
| --- | --- | --- |
| `d1` | `single-pass-revision` | Revise each document as if no previous version exists: keep past versions out of the main text, where they confuse the reader, and confine history to sections explicitly designed to track previous records. |

### Representative Do / Don't comparisons

Use the comparison to recognize the writing move, not as a genre-specific recipe.

- **`d1` — `single-pass-revision`**

  Canonical statement: revise a document as if no previous version of the document exists, because mentioning past versions in the main text confuses the reader, except in document sections explicitly designed to track previous records.

  **Don't:** Let the main text narrate its own editing history.

  ```markdown
  ## Motivations

  This section now combines the former "What We Want" and "Why Debug"
  sections, which were merged to reduce duplication. The campaign compares
  two backends.
  ```

  **Do:** State the current content directly; keep revision notes in a section that exists to track records.

  ```markdown
  ## Motivations

  The campaign compares two backends.

  ...

  ## Revision History

  - 2026-09-13: merged "What We Want" and "Why Debug" into "Motivations".
  ```

### Judgment notes

- D1 targets incidental editing history in the main flow, not documented comparisons. Migration guides, changelogs, decision records, and evidence ledgers are designed tracking sections and remain legitimate.
- Deleting obsolete text is part of the rule; do not annotate deletions in the main text with notes such as "this paragraph was removed".
- Version control and diffs carry provenance; the document body carries current state.
- Citing earlier external documents is normal referencing, not self-revision history. D1 governs how a document speaks about its own past versions.

## Applicability

- Apply the writing rules when creating or revising durable prose documents: Markdown documentation, design notes, reports, plans, and intent documents.
- The rules concern the final text, not the editing process; they apply equally to full rewrites and small edits.
- If the task is a chat reply, commit message, or code-only change, Docs Writer is not applicable and renders no injection.

## Guardrails

- DO NOT mention a document's previous versions in its main text outside sections explicitly designed to track previous records.
- DO NOT inject rules that are absent from the selected state.
- DO NOT remove or gut a designed changelog, records, or migration section to satisfy the mentality.
