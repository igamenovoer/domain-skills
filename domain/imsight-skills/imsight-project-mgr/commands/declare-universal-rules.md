# Declare Universal Rules

Use this command to add or refresh Imsight universal project rules in a coding-agent native project context file such as `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md`.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Resolve the project root**. Work from the product repository root, not a mega-workspace parent.
2. **Select the target context file**. Follow **Target Selection** and honor user-provided targets first.
3. **Load the canonical rules** from `../references/universal-project-rules.md`.
4. **Add or refresh the managed section**. Follow **Update Rules**, preserve project-specific guidance, and adjust heading depth to the target document.
5. **Verify idempotency**. Confirm the target contains exactly one managed `Universal Project Rules` section with the canonical content.
6. **Report the result**. Name each updated file and state whether the section was added or refreshed.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the target-selection, preservation, heading, and idempotency constraints in this command, then execute the plan.

## Target Selection

1. If the user names one or more target context files, update those files.
2. Otherwise, update the existing native context file for the active agent when clear: `AGENTS.md` for Codex/OpenAI, `CLAUDE.md` for Claude, or `GEMINI.md` for Gemini.
3. If the active agent is unclear and `AGENTS.md` exists, prefer `AGENTS.md` as the shared cross-agent context file.
4. If no native context file exists, create `AGENTS.md` unless the user requested a different file.
5. When the user requests every native context file, update every existing repository-level file that matches the request. Do not create extra agent-specific files unless requested.

## Update Rules

1. Read the target file before editing.
2. Preserve existing project-specific guidance and ordering.
3. Add or refresh one section titled `Universal Project Rules`.
4. If the section exists, replace only that section rather than appending a duplicate.
5. Place the section near other general coding or project rules. If no obvious location exists, append it near the end.
6. When the target already uses one top-level `#` title, demote the canonical section and its child headings by one level.
7. Keep Markdown paragraphs on logical lines without hard wrapping.
8. After editing, verify exactly one managed section exists and the surrounding content remains intact.
