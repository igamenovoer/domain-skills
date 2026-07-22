# Scaffold

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the feature design directory** using the entrypoint's **Output Directory** rules.
2. **Create the folder skeleton**. Create `<feature-dir>/`, `<feature-dir>/usecases/`, and `<feature-dir>/design/`.
3. **Copy placeholder templates** from `assets/templates/feature/` into the feature design folder:
   - `README.md` to `<feature-dir>/README.md`
   - `feature-requirement.md` to `<feature-dir>/feature-requirement.md`
   - `usecases/README.md` to `<feature-dir>/usecases/README.md`
   - `design/README.md` to `<feature-dir>/design/README.md`
   - `agent-task.md` to `<feature-dir>/agent-task.md`
4. **Avoid overwrites**. If any destination file exists, leave it unchanged unless the user explicitly asked to refresh placeholders.
5. **Report the scaffold**. List created and skipped files, then ask whether to run `define-feature` next.

If the task does not map cleanly to these steps, create only the minimum safe skeleton and report what decision is needed before proceeding.

## Template Rule

Do not fill in feature content during `scaffold`. Keep placeholders such as `<FEATURE_NAME>`, `<STATUS>`, and `<OPEN_QUESTION>` in copied files so later subcommands can replace them with discussed design content.
