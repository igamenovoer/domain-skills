# Manage Project Outputs

Use this subcommand to group related outputs into a deliverable folder.

## Workflow

### `project create <slug> "<goal>"`

1. **Create `outputs/projects/<slug>/`**.
2. **Write `outputs/projects/<slug>/WHY.md`** with the goal and rationale:
   ```markdown
   # WHY — <Slug>

   **Goal**: <goal>

   **Created**: YYYY-MM-DD
   ```
3. **Append a log entry**:
   ```markdown
   ## [HH:MM] project | created <slug>
   ```

### `project add <slug> <file-or-query>`

1. **Resolve the target project** from `outputs/projects/<slug>/`.
2. **Copy or generate the artifact** into the project folder:
   - If `file-or-query` is an existing file path, copy it into the project folder.
   - If it is a question, run the `query` workflow and save the result into the project folder.
3. **Append a log entry**:
   ```markdown
   ## [HH:MM] project | added <artifact> to <slug>
   ```

### `project list`

1. **Enumerate `outputs/projects/*/`** folders.
2. **Read each `WHY.md`** title.
3. **Present a concise list** of active projects with slug, title, and deliverable count.

### `project archive <slug>`

1. **Move `outputs/projects/<slug>/`** to `outputs/projects/.archive/<slug>/`.
2. **Append a log entry**:
   ```markdown
   ## [HH:MM] project | archived <slug>
   ```

If the task does not map cleanly to these steps, use your native planning tool with this command's existing project actions and constraints; preserve project layout and archive behavior.

## Constraints

- Project folders live only under `outputs/projects/`.
- The `WHY.md` file is required for every project.
- Archived projects remain readable but are hidden from `project list` by default.

## Quality Gates

### Metrics

- Number of deliverables per project.

### Checks

- Every project has a `WHY.md`.
- `project list` shows only active projects by default.
- Archive moves, not deletes, project contents.

## Guardrails

- DO NOT create a project without a clear goal.
- DO NOT move originals into the project folder instead of copying them.
- DO NOT delete archived projects instead of moving them to `.archive/`.
