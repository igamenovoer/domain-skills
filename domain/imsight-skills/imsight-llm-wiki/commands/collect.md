# Collect External Artifacts

Use this subcommand to find, deduplicate, and catalog a bounded set of external artifacts matching a user query.

## Workflow

1. **Capture the query and scope** from the user's request. Infer the collection kind (tool, project, example, meme, person, etc.) when not explicit.
2. **Discover candidates** by searching the web. Use the same provider-agnostic strategy as `research`.
3. **Bound the collection**. Default to a maximum of 20 candidates unless the user sets a different limit. For large or unbounded requests, present a preview and ask for confirmation before writing.
4. **Extract catalog rows** for each candidate:
   - title,
   - canonical URL,
   - source URL and title where found,
   - description,
   - evidence for inclusion,
   - provenance confidence (high, medium, low),
   - tags.
5. **Deduplicate** candidates by canonical URL, name + creator, or clear repost relationships. Keep alternate URLs and aliases in notes.
6. **Rank** candidates by provenance, relevance, and confidence.
7. **Write the collection** to `wiki/collections/<slug>.md` with frontmatter and a catalog table.
8. **Update `wiki/index.md`** with the new collection.
9. **Append a log entry**:
   ```markdown
   ## [HH:MM] collect | <slug> — cataloged N artifacts
   ```

If the task does not map cleanly to these steps, use your native planning tool with this command's existing collection actions and constraints; do not broaden the requested artifact set.

## Constraints

- `collect` searches the open web, not the existing local wiki.
- Do not recursively crawl; follow only direct source links needed to verify a candidate.
- Do not download large binaries into the wiki without confirmation.
- Keep the catalog bounded and provenance-rich.

## Quality Gates

### Metrics

- Candidate count before and after deduplication.
- Average provenance confidence.

### Checks

- The collection page is written to `wiki/collections/<slug>.md`.
- Duplicates are merged, not repeated.
- `wiki/index.md` lists the collection.
- A log entry is appended.

## Guardrails

- DO NOT interpret "all" as an unbounded request to collect from the entire internet.
- DO NOT record naked URLs without context or provenance.
- DO NOT create a collection so large it becomes unreadable.
