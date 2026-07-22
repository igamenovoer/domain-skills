# Inspect Slave

Use this primitive before any master dispatch that depends on a Houmao-managed slave's metadata. The master agent may be outside Houmao; the target slave must be selected through supported Houmao-managed agent surfaces.

## Inputs

- Required: slave selector, such as `agent_name`, `agent_id`, pair port, or an explicitly provided manifest path.
- Optional: requested delivery lane, request body, whether mail delivery is relevant, and whether the user explicitly asked for follow-up inspection.

## Workflow

1. Recover the slave selector from the current request or recent explicit context.
2. Choose one `houmao-mgr` launcher:
   - use `houmao-mgr` from `PATH` when available;
   - otherwise use `uv tool run --from houmao houmao-mgr`;
   - use another launcher only when the user explicitly asked for it or the environment requires it.
3. If the selector is missing or ambiguous, ask for it before continuing.
4. Identify or confirm the target with:
   ```text
   <houmao-mgr> agents list
   <houmao-mgr> agents state --agent-name <slave>
   <houmao-mgr> agents state --agent-id <slave-id>
   ```
5. Inspect gateway posture when prompt delivery may be used:
   ```text
   <houmao-mgr> agents gateway status --agent-name <slave>
   ```
6. Inspect mailbox posture only when mail delivery is requested or gateway prompt delivery is unavailable:
   ```text
   <houmao-mgr> agents mail resolve-live --agent-name <slave>
   ```
7. Read `manifest.json` only when the managed state output already exposes `manifest_path` or `session_root` and the needed metadata is not available from read-only command output.

If the task does not map cleanly to these steps, plan only from the supported read-only Houmao inspection commands; ask for the selector or requested delivery posture instead of guessing.

## Metadata To Recover

- `agent_name` or `agent_id`
- tool lane, especially `codex` or `claude`
- lifecycle state, especially active versus stopped
- transport kind and working directory
- gateway availability for prompt delivery
- mailbox availability when mail delivery is relevant
- `manifest_path` and `session_root` when exposed by state
- manifest metadata such as `agent_launch_authority.tool`, `agent_launch_authority.working_directory`, `launch_plan.tool`, `launch_plan.working_directory`, `launch_plan.mailbox`, and launch profile provenance when needed

## Dispatch Decisions

- If the tool is `codex`, render commands with `$` prefixes.
- If the tool is `claude`, render commands with `/` prefixes.
- If the tool cannot be determined, ask for clarification instead of guessing.
- Prefer live gateway prompt delivery when the gateway is healthy and request delivery is immediate.
- Use mailbox delivery only when requested, when gateway prompt is unavailable and mailbox is available, or when the master/slave workflow intentionally uses mail.

## Guardrails

- DO NOT mutate slave state during inspection.
- DO NOT start with raw tmux, raw runtime file searches, or direct `.houmao/runtime` scanning.
- DO NOT infer live gateway base URLs or mailbox bindings from stale context.
- DO NOT inspect follow-up output after delivery unless explicitly asked.
