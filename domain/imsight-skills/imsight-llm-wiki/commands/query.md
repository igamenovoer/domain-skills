# Query the Wiki

Use this subcommand to answer a question grounded in the wiki, not from general knowledge.

## Workflow

1. **If `--resume` is set**, load the most recent `outputs/queries/<YYYY-MM-DD>-<question-slug>.md` file as context.
2. **Read `wiki/index.md`** and scan for relevant pages by category.
3. **Read identified pages** in full; follow one level of wikilinks.
4. **If the wiki lacks enough material**, say so and suggest what to ingest next.
5. **Synthesize the answer**, citing pages inline with canonical links such as `[[wiki/concepts/page-slug|Page Name]]`. When resuming, reference the prior question and summarize the continuation.
6. **Save the answer** to `outputs/queries/<YYYY-MM-DD>-<question-slug>.md`.
7. **Promote durable answers** — if the answer is a comparison, analysis, or new synthesis, create or update a concept page and add it to `wiki/index.md`.
8. **Append a log entry**:
   ```markdown
   ## [HH:MM] query | <question-slug>
   ```
   If resuming, include the prior slug:
   ```markdown
   ## [HH:MM] query | <question-slug> (resumed from <prior-slug>)
   ```
   If promoted, add a separate `promote` line.

If the task does not map cleanly to these steps, use your native planning tool with this command's existing query, filing, promotion, and resume rules; ground answers in the wiki.

## Constraints

- The answer must be grounded in wiki content.
- Do not hallucinate when the wiki lacks material.
- Promoted content must be cleaned up and fit the concept-page template.
- `--resume` loads only the most recent query output. To resume an older query, reference it explicitly.

## Quality Gates

### Metrics

- Number of wiki pages consulted.
- Number of canonical citations in the answer.

### Checks

- Every claim traces to a wiki page or raw source.
- Query output file is saved under `outputs/queries/`.
- Promoted content appears in `wiki/index.md`.
- Resumed queries reference the prior query slug.

## Guardrails

- DO NOT answer from general knowledge instead of the wiki.
- DO NOT promote a transient answer that should stay in `outputs/`.
