# Manage Ingest Inventory

Use this subcommand to maintain a lightweight backlog of ingest candidates.

## Workflow

### `inventory add`

1. **Capture the candidate** title, optional URL, and optional notes from the user.
2. **Create `wiki/inventory/<slug>.md`** with YAML frontmatter:
   ```yaml
   ---
   title: <Candidate Title>
   status: open
   url: <optional URL>
   created: YYYY-MM-DD
   updated: YYYY-MM-DD
   ---
   ```
3. **Append a log entry**:
   ```markdown
   ## [HH:MM] inventory | added <slug>
   ```

### `inventory list`

1. **Enumerate `wiki/inventory/*.md`** files.
2. **Filter to `status: open`** by default (use `--all` to show every status).
3. **Present a concise list** with title, URL, age, and slug.

### `inventory ingest <slug>`

1. **Read the candidate file**.
2. **Run the existing `ingest` workflow** on the candidate's URL or text description.
3. **Update the candidate** status to `ingested` and bump `updated:`.
4. **Append a log entry**:
   ```markdown
   ## [HH:MM] inventory | promoted <slug> to ingest
   ```

### `inventory reject <slug>`

1. **Read the candidate file**.
2. **Capture the reason** from the user if not provided via `--reason`.
3. **Update the candidate** status to `rejected`, append the reason, and bump `updated:`.
4. **Append a log entry**:
   ```markdown
   ## [HH:MM] inventory | rejected <slug> — <reason>
   ```

If the task does not map cleanly to these steps, use your native planning tool with this command's existing inventory actions and constraints; do not invent candidate states or transitions.

## Constraints

- Candidates are mutable backlog items, not immutable sources. They live under `wiki/inventory/`, not `raw/`.
- Do not auto-ingest candidates without explicit user action.
- Rejected candidates are kept for history, not deleted.

## Quality Gates

### Metrics

- Count of open, ingested, and rejected candidates.

### Checks

- Every candidate file has valid YAML frontmatter with `title` and `status`.
- `inventory list` shows only open candidates by default.
- Promotions and rejections are logged.

## Guardrails

- DO NOT treat inventory candidates as raw sources.
- DO NOT delete rejected candidates instead of updating their status.
- DO NOT let open candidates grow stale without review.
