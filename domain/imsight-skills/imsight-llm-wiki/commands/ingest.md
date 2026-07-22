# Ingest a Source

Use this subcommand to add a new source to `raw/` and update the wiki with summaries, concept pages, and entity pages.

## Workflow

1. **Identify the source** — URL, PDF, note, or provided text.
2. **Save the source** to the right subfolder:
   - web article → `raw/articles/<slug>.md`
   - paper → `raw/papers/<slug>.md`
   - note → `raw/notes/<slug>.md`
   - large binary → `raw/refs/<slug>.md` pointer file
3. **Read the source** in full.
4. **Create `wiki/summaries/<slug>.md`** — 200–400 words of key takeaways, not a rewrite.
5. **Create or update concept pages** in `wiki/concepts/`. Split if a page would exceed 1200 words.
6. **Create or update entity pages** in `wiki/entities/` for people, tools, papers, or organizations.
7. **Add raw references only if explicitly requested** — if the user asks, add a `## Raw references` section on each touched wiki page.
8. **Update `wiki/index.md`** with the new pages.
9. **Append a log entry**:
   ```markdown
   ## [HH:MM] ingest | <slug> — <one-line description> (touched N pages)
   ```

If the task does not map cleanly to these steps, use your native planning tool with this command's existing ingest actions and constraints; preserve raw-source and index rules.

## Constraints

- `raw/` files are immutable after ingestion. Fix mistakes by re-ingesting, not by editing `raw/`.
- Do not copy large binaries into `raw/`; use `raw/refs/` pointer files.
- One source typically touches 5–15 wiki pages.

## Quality Gates

### Metrics

- Summary length: 200–400 words.
- Concept page length: 400–1200 words.

### Checks

- Every new page appears in `wiki/index.md`.
- Wikilinks use canonical vault-root targets.
- YAML frontmatter is present on every new wiki page.

## Guardrails

- DO NOT save a source to the wrong `raw/` subfolder.
- DO NOT write a full rewrite instead of a summary.
- DO NOT cram a topic into one oversized page.
- DO NOT add raw references unless the user asks for them.
