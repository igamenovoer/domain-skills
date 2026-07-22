# Scaffold an LLM Wiki

Use this subcommand to create a new LLM Wiki directory tree.

## Workflow

1. **Confirm the wiki root and topic title** with the user if they are not already clear.
2. **Run the scaffold helper**:
   ```bash
   python3 scripts/scaffold.py <wiki-root> "<Topic Title>"
   ```
3. **Verify the created tree** includes `README.md`, `wiki/index.md`, `log/YYYYMMDD.md`, `audit/`, `raw/`, `wiki/`, and `outputs/`.
4. **Prompt the user** to fill in `README.md` scope, exclusions, naming conventions, and open research questions.
5. **Append a log entry** if the user asks for one:
   ```markdown
   ## [HH:MM] scaffold | Initialized <Topic Title> knowledge base
   ```

If the task does not map cleanly to these steps, use your native planning tool with this command's existing scaffold layout and constraints; do not overwrite a populated target.

## Constraints

- The target directory must either not exist or be empty before scaffolding.
- Do not overwrite an existing wiki root unless the user explicitly confirms.

## Quality Gates

### Checks

- `README.md` exists and contains the schema template.
- `wiki/index.md` exists with the recommended category layout.
- `log/YYYYMMDD.md` exists with a scaffold entry.
- `audit/` and `audit/resolved/` directories exist.

## Guardrails

- DO NOT scaffold into a directory that already contains files.
