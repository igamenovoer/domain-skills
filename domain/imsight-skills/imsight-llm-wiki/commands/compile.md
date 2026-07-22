# Compile the Wiki

Use this subcommand to restructure wiki content from existing `raw/` material, split oversized pages, merge near-duplicates, and rebuild `wiki/index.md`.

## Workflow

1. **Read the schema** — read `README.md` and `wiki/index.md` from the wiki root.
2. **Read the target subtree** — read every file in the wiki tree that may need restructuring.
3. **Identify splits** — for each page over ~1200 words, plan a split into `wiki/concepts/<topic>/` with an `index.md` + sub-pages.
4. **Confirm splits and merges with the user** before writing.
5. **Apply rewrites** — split pages, merge near-duplicates, and update wikilinks.
6. **Regenerate `wiki/index.md`** so every page appears exactly once under the right category.
7. **Append a log entry**:
   ```markdown
   ## [HH:MM] compile | <what you did — files touched, splits, merges>
   ```

If the task does not map cleanly to these steps, use your native planning tool with this command's existing compile actions and constraints; retain confirmation requirements for structural rewrites.

## Constraints

- Every wiki page must appear exactly once in `wiki/index.md` after compilation.
- Wikilinks must remain canonical: `[[wiki/concepts/foo|Foo]]`.

## Quality Gates

### Metrics

- Page count before/after compile.
- Word count of the largest page after compile (lower is better; target ≤1200).

### Checks

- No dead wikilinks introduced.
- No orphan pages created.
- `wiki/index.md` lists every page exactly once.

## Guardrails

- DO NOT split or merge pages without user confirmation.
