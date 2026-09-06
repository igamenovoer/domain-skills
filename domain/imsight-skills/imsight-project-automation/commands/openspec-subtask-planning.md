# OpenSpec Subtask Planning

Use this subcommand to add a concise execution reminder to an OpenSpec change's `tasks.md` so the task-executing agent creates task-specific plan documents and tracks implementation progress with checkbox todo lists.

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the OpenSpec change directory** from the user's request and verify that its `tasks.md` exists.
2. **Check for an existing task-plan reminder** near the start of `tasks.md`.
3. **Determine the note variant** from **Note Contract**. Include subagent planning only when the user explicitly requests it.
4. **Add or update one reminder** near the start of `tasks.md`. Preserve every task, section, and checkbox state.
5. **Verify the result**. Confirm that the reminder requires a checkbox todo list, the referenced plan path is scoped to the change, and no duplicate reminder remains.
6. **Report the edit** with the changed `tasks.md` path and whether the optional subagent sentence was included.

If the task does not map cleanly to these steps, use your native planning tool only with the target-resolution, note, preservation, and optional-subagent constraints in this command; do not broaden the edit beyond the OpenSpec task checklist.

## Note Contract

Use this reminder by default:

> Execution reminder: Before executing each numbered task, create `<openspec-change-dir>/subtasks/taskplan-<task-number>-<task-slug>.md` with a todo list of Markdown checkboxes (`- [ ]`). Use that task-specific plan to track implementation progress by marking completed items (`- [x]`).

When the user explicitly requests planning with a subagent, append this sentence to the same reminder:

> Have a planning subagent create each task-specific plan before implementation.

If `tasks.md` already contains a task-plan reminder, replace that reminder with the selected variant instead of adding a second one. Do not retain requirements for an internal planning tool or a same-model subagent unless the user explicitly asks for them.

## Guardrails

- DO NOT create the task-specific plan documents through this subcommand.
- DO NOT require subagent planning unless the user explicitly requests it.
- DO NOT alter task wording, order, hierarchy, or checkbox state.
- DO NOT modify OpenSpec artifacts other than the resolved change's `tasks.md`.
