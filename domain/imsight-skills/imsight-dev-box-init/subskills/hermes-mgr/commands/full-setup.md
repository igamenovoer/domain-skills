# Full Hermes and Hindsight Setup

Run the complete maintained setup in dependency order.

## Workflow

1. Execute [Configure Hermes With Kimi](configure-kimi.md).
2. Execute [Deploy Local Hindsight With Kimi](deploy-hindsight.md).
3. Execute [Connect Hermes to Local Hindsight](connect-hindsight.md).
4. Execute [Verify Hermes, Kimi, and Hindsight](verify-stack.md).
5. Report the final endpoints, model, persistence, gateway state, and any skipped mutating test.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step setup plan from the four linked procedural commands and user constraints, then execute the plan without skipping predecessor checks.

## Execution Contract

- Complete each command's verification before continuing.
- Reuse one `KIMI_CODING_API_KEY` through `~/.hermes/.env`; do not duplicate it into Compose.
- Use `k3-256k` for Hermes and Hindsight unless the user explicitly selects another available Kimi model.
- Keep Hindsight API/UI loopback-only.
- Install the Hermes gateway with `--start-on-login` when persistent messaging operation is requested.
- Keep Hindsight's named volume across restart and upgrade operations.

## Expected Result

```text
Hermes Agent
  provider: kimi-coding
  model: k3-256k
  gateway: enabled and active
  memory provider: hindsight (local_external, hybrid)

Hindsight
  API: http://127.0.0.1:18888
  UI: http://127.0.0.1:19999
  LLM: Kimi Coding Plan / k3-256k
  data: hermes-hindsight-data
  restart: unless-stopped
```

## Guardrails

- DO NOT continue to a dependent stage after its predecessor verification fails.
- DO NOT interpret `full-setup` as permission to expose services remotely or erase existing memory.
