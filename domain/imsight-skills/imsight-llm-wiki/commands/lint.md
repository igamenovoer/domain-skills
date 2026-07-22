# Lint the Wiki

Use this subcommand to run health checks on the wiki.

## Workflow

1. **Run the lint helper**:
   ```bash
   python3 scripts/lint_wiki.py <wiki-root>
   ```
2. **Read the report** and classify issues:
   - dead wikilinks,
   - orphan pages,
   - missing index entries,
   - frequently-linked missing pages,
   - `log/` shape problems,
   - `audit/` shape problems,
   - audit targets that do not exist,
   - non-canonical legacy wikilinks.
3. **Run quality scans** (by default):
   - overlong pages (>1200 words),
   - orphan concept pages (no inbound wikilinks),
   - missing or incomplete YAML frontmatter.
4. **Run stale checks only when explicitly requested** with `--stale` or `--stale-days N`:
   - articles whose `updated:` date is older than the threshold and whose raw sources have newer material.
5. **Write findings** to `outputs/lint-report-<YYYY-MM-DD>.md`.
6. **Propose a fix** for each issue and update `README.md` research gaps when the report identifies missing pages.
7. **Confirm fixes with the user** before applying them.
8. **Apply confirmed fixes** and re-run lint.
9. **Append a log entry**:
   ```markdown
   ## [HH:MM] lint | <N> issues found, <M> fixed
   ```

If the task does not map cleanly to these steps, use your native planning tool with this command's existing lint passes and constraints; keep fixes behind the required confirmation.

## Constraints

- Do not apply fixes without user confirmation unless the fix is unambiguous and safe.
- Do not run stale checks by default.
- Keep legacy-link rewrites canonical.

## Quality Gates

### Metrics

- Issue count before and after the fix pass.
- Number of quality issues by category.

### Checks

- Lint exits with code 0 after fixes, or a clear explanation is left in the log if some issues were deferred.
- Every resolved issue maps to a specific edit.
- A lint report is written when issues are found.

## Guardrails

- DO NOT run lint and ignore the output.
- DO NOT fix links silently when the user may want to review them.
- DO NOT run stale checks by default.
