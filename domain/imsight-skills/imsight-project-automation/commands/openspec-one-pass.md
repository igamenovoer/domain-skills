# OpenSpec One-Pass

Use this subcommand when the user provides one development request and wants it driven through the OpenSpec lifecycle in a single focused pass.

## Intent

Turn one request into:

1. explored requirements and constraints,
2. a concrete OpenSpec proposal,
3. an applied implementation,
4. synced final specs and an archived completed change.

## Execution Modes

- `automation` is the default. Continue through all workflow stages without asking for user intervention unless blocked by missing required information, failing commands, unsafe ambiguity, or an explicit approval requirement from a called OpenSpec skill. Make reasonable decisions that preserve design consistency, minimize user surprise, and keep changes scoped.
- `interactive` is used when the user asks for "step by step", "interactive", "pause between steps", "wait after each step", or similar. Stop after each workflow stage, summarize what happened, and ask whether to continue, revise, inspect something else, or stop.

## Workflow

1. Restate the request briefly and identify the target repository or workspace.
2. Invoke `openspec-explore` on the request.
   - Discover relevant existing specs, changes, docs, code paths, and tests.
   - Capture open questions only when they block safe implementation.
   - In `interactive` mode, stop here and wait for the next instruction.
3. Invoke `openspec-propose` using the explored task context.
   - Create the proposal, design/spec deltas, and task checklist expected by the local OpenSpec workflow.
   - Prefer one coherent change over several small changes unless the task clearly spans independent features.
   - In `interactive` mode, stop here and wait for the next instruction.
4. Invoke `openspec-apply-change` on the created change.
   - Implement the task list.
   - Run focused verification appropriate to the change.
   - Keep unrelated files and unrelated user changes intact.
   - In `interactive` mode, stop here and wait for the next instruction.
5. Sync and archive the completed change.
   - Prefer `openspec-archive-change` for finalization, because it assesses delta-spec sync and archives the completed change.
   - If the local workflow or archive prompt requires an explicit sync first, invoke `openspec-sync-specs` on the same change, then invoke `openspec-archive-change`.
   - In `interactive` mode, stop here after sync/archive and wait for final follow-up instructions if any.
6. Report the resulting change id/path, implementation summary, verification performed, archive location, and any residual risks. If a test, OpenSpec validation, sync, or archive operation failed, include the failure and the last successful stage.

If the task does not map cleanly to these steps, use your native planning tool only with the maintained OpenSpec lifecycle, current modes, stop conditions, and guardrails; do not invent stages.

## Invocation Guidance

- When the OpenSpec skills are available locally, invoke them directly in this order:
  - `openspec-explore`
  - `openspec-propose`
  - `openspec-apply-change`
  - `openspec-archive-change`
  - `openspec-sync-specs` only when explicit pre-archive sync is required.
- When forwarding to another Houmao-managed agent by direct prompt, use that agent's required OpenSpec command syntax:
  - Codex-based agents: `$openspec-* <message>`
  - Claude-based agents: `/openspec-* <message>`
- For mail-based messaging, include the OpenSpec invocation command in the mail body so it appears in the mail notification text.

## Guardrails

- DO NOT skip exploration.
- DO NOT apply before a proposal exists.
- DO NOT archive until the implementation is complete and verification has been attempted.
- DO NOT use broad destructive git operations.
- DO NOT silently ignore failed tests, failed OpenSpec validation, failed sync, or archive errors.
- DO NOT treat a one-pass request as a planning-only workflow.
- DO NOT ask routine confirmation questions in `automation` mode.
