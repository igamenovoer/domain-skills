# Configure Hermes With Kimi

Configure Hermes Agent to use a Kimi Coding Plan key and `k3-256k`.

## Workflow

1. Confirm Hermes is installed and read `../references/verified-defaults.md`.
2. Store the Kimi Coding Plan key without printing it.
3. Configure the `kimi-coding` provider, endpoint, model, and reasoning effort.
4. Run the configuration and live-model checks below.
5. Restart the Hermes gateway when it is already installed.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this command's credential, provider, model, and verification contracts, then execute the plan without exposing secrets.

## Prerequisites

- `hermes --version` succeeds.
- The user has a Kimi Coding Plan key, normally prefixed `sk-kimi-`.
- The installed Hermes release supports provider `kimi-coding`.

Do not use a Moonshot Platform key unintentionally. The two key types route to different endpoints and billing products.

## Store the Key

Resolve `<hermes-mgr-subskill-dir>` to the directory containing this command's parent `SKILL-MAIN.md`, then run:

```bash
<hermes-mgr-subskill-dir>/scripts/set-kimi-coding-key.py
```

The script prompts through a hidden input, upserts only `KIMI_CODING_API_KEY` in `~/.hermes/.env`, removes duplicate active definitions of that variable, preserves the rest of the file, and enforces mode `0600`.

The interactive upstream path is also supported:

```bash
hermes model
```

Choose **Kimi / Moonshot**, provide the coding-plan key, and select `k3-256k`. Hermes recognizes `sk-kimi-` keys and selects the Coding Plan endpoint automatically.

## Configure Non-Secret Settings

Set the maintained route explicitly:

```bash
hermes config set model.provider kimi-coding
hermes config set model.default k3-256k
hermes config set model.base_url https://api.kimi.com/coding
hermes config set agent.reasoning_effort high
```

Use the endpoint without `/v1`. Hermes uses the Anthropic Messages-compatible Coding Plan surface and appends the correct message path.

`high` is the maintained balanced effort. Do not select `max` merely because it is available; reserve it for workloads where additional latency and quota use are acceptable.

## Verification

Check non-secret state:

```bash
hermes config get model.provider
hermes config get model.default
hermes config get model.base_url
hermes config get agent.reasoning_effort
```

Expected values are `kimi-coding`, `k3-256k`, `https://api.kimi.com/coding`, and `high`.

Refresh the provider catalog when model availability may have changed:

```bash
hermes model --refresh
```

Run one small API request:

```bash
hermes chat --provider kimi-coding --model k3-256k --quiet \
  --query 'Reply with exactly: kimi-ok'
```

If the gateway is installed, apply the new model to new gateway work:

```bash
hermes gateway restart
hermes gateway status
```

## Guardrails

- DO NOT print or pass the Kimi key as a visible command-line argument.
- DO NOT configure Hermes' Coding Plan endpoint with a trailing `/v1`.
- DO NOT overwrite `~/.hermes/.env` when only one secret variable needs changing.
