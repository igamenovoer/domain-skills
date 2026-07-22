# Process Audit Feedback

Use this subcommand to process human feedback from `audit/`.

## Workflow

1. **Run the audit review helper**:
   ```bash
   python3 scripts/audit_review.py <wiki-root> --open
   ```
2. **For each open audit**, read the file and use `anchor_before` / `anchor_text` / `anchor_after` to locate the target range.
3. **Decide the action**:
   - **Accept**: apply the correction.
   - **Partially accept**: apply what makes sense and note the rest.
   - **Reject**: explain why in the resolution.
   - **Defer**: add to `README.md` "Open research questions" and leave the audit open with a comment.
4. **Append a `# Resolution` section** to the audit file:
   ```markdown
   # Resolution

   YYYY-MM-DD · accepted.
   Fixed the file count (was "~1,900", corrected to "~1,800" per commit abc123).
   Updated: tech/Claude_Code.md lines 47–48.
   ```
5. **Move the file** from `audit/` to `audit/resolved/`. Filename unchanged.
6. **Append a log entry** per resolved audit:
   ```markdown
   ## [HH:MM] audit | resolved <id> — <one-line what>
   ```

If the task does not map cleanly to these steps, use your native planning tool with this command's existing audit actions and constraints; do not invent resolutions or apply unapproved feedback.

## Constraints

- Never delete audit files, even rejected ones.
- Process `error` and `warn` before `suggest` and `info`.
- If an anchor is stale, flag it to the user instead of silently dropping it.

## Quality Gates

### Metrics

- Count of audits resolved, rejected, and deferred.

### Checks

- Every applied audit has a `# Resolution` section.
- Every moved audit is in `audit/resolved/` with `status: resolved` in frontmatter.
- Every resolution is logged.

## Guardrails

- DO NOT ignore open audits when the user has not asked for an audit pass.
- DO NOT apply corrections without bumping the target page's `updated:` frontmatter field.
- DO NOT delete rejected audits instead of archiving them with rationale.
