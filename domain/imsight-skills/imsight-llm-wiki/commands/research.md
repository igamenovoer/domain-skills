# Research a Topic

Use this subcommand to research a topic on the web and ingest high-signal sources into the wiki.

## Workflow

1. **Capture the topic** from the user's request.
2. **Discover sources** using the best available web-search capability:
   - Use the agent's native web-search tool or skill (e.g., Tavily skills) when available.
   - Fall back to known CLI providers such as `tvly`.
   - For explicit URLs, fetch directly when no search provider is available.
   - If no provider is available, refuse with a clear message telling the user how to install or configure one.
3. **Rank and filter** results for relevance and signal quality. Skip paywalled, duplicate, or low-relevance sources unless the user explicitly requests inclusion.
4. **Present discovered sources** to the user for confirmation, unless the user explicitly requested automatic ingestion with `--auto`.
5. **Ingest approved sources** through the existing `ingest` pipeline:
   - Save sources to `raw/articles/` or the appropriate subfolder.
   - Create `wiki/summaries/<slug>.md` for each.
   - Update relevant `wiki/concepts/` and `wiki/entities/` pages.
   - Update `wiki/index.md`.
6. **Append a log entry**:
   ```markdown
   ## [HH:MM] research | <topic> — ingested N sources (touched M pages)
   ```

If the task does not map cleanly to these steps, use your native planning tool with this command's existing research, source, ingest, and logging constraints; do not weaken provenance requirements.

## Constraints

- Do not ingest sources without user confirmation unless `--auto` is set.
- Do not treat low-quality or irrelevant search results as authoritative.
- Respect the same raw-file policy as `ingest`: large binaries get pointer files, not copies.

## Quality Gates

### Metrics

- Number of sources discovered.
- Number of sources approved and ingested.

### Checks

- Every ingested source has a corresponding `raw/` file and `wiki/summaries/` page.
- `wiki/index.md` is updated with new pages.
- A log entry is appended.

## Guardrails

- DO NOT ingest search results without reading them.
- DO NOT treat search snippets as enough evidence to create concept pages.
