---
metadata:
  skill_invocation_notation: >
    Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
    SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
    accepted only as legacy input when SKILL-MAIN.md is absent.
    Skill and subskill entrypoints use bare object paths: `X` invokes skill X and
    `X->Y->Z` invokes subskill Z. Subcommands use parenthesized components:
    `X->cmd()` invokes a direct subcommand, `X->Y->cmd()` invokes a subcommand of
    subskill Y, and `X->parent()->child()` invokes child subcommand child exposed
    by parent subcommand parent. Intermediate subcommands act as object generators.
    Forms such as `X()` and `X->Y()` are invalid for skill or subskill entrypoints.
---

# Codex CLI Third-Party API Providers

Use this reference as the entrypoint for configuring Codex CLI to call third-party OpenAI-compatible APIs.

Codex CLI 0.2+ expects the OpenAI **Responses** wire protocol (`/v1/responses`) for custom providers. Do not configure `wire_api = "chat"`; current Codex rejects it.

There are two provider categories. Find your provider in the routing table below and follow the matching procedure.

Never bake API keys into this skill, generated documentation, git-tracked config, or launcher scripts. Store keys in environment variables, a local untracked secret file, or a shell-specific secret manager chosen by the user.

## Workflow

1. Select `responses-api` or `chat-completions-only` from **Subcommands**, testing `/v1/responses` when the provider is unlisted.
2. Follow the selected provider procedure without embedding API keys.
3. Preserve unrelated Codex configuration and launcher settings.
4. Run **Validation** and report the configured route.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the declared provider commands, configuration rules, validation checks, and user request, then execute the plan without inventing compatibility.

## Subcommands

Terminal invocation of `imsight-dev-box-init->coding-agent->codex-cli-3rd-party()` selects or summarizes a provider category.

| Subcommand | Category | Procedure |
| --- | --- | --- |
| `responses-api` | Providers that natively support `/v1/responses` | [Responses API compatible providers](#responses-api-compatible-providers) |
| `chat-completions-only` | Providers that only support `/v1/chat/completions` | [Chat-Completions-only providers](#chat-completions-only-providers) |

## Provider routing table

| Provider | Endpoint base | Category | Notes |
| --- | --- | --- | --- |
| OpenRouter | `https://openrouter.ai/api/v1` | `responses-api` | Responses-compatible gateway; proxy for many providers |
| SiliconFlow | `https://api.siliconflow.cn/v1` | `chat-completions-only` | Use `codex-relay` or OpenRouter |
| DeepSeek direct | `https://api.deepseek.com/v1` | `chat-completions-only` | Use `codex-relay` or OpenRouter |
| Kimi direct | `https://api.moonshot.cn/v1` | `chat-completions-only` | Use `codex-relay` or OpenRouter |
| Zhipu GLM direct | `https://open.bigmodel.cn/api/paas/v4` | `chat-completions-only` | Use `codex-relay` or OpenRouter |

If a provider is not listed, test `POST /v1/responses` directly. A `404` means it is `chat-completions-only`.

---

## Responses API compatible providers

These endpoints already implement `/v1/responses`. Configure Codex to call them directly.

### Generic config shape

```toml
model = "<model-name>"
model_provider = "<provider-id>"

[model_providers.<provider-id>]
name = "<display-name>"
base_url = "<provider-base-url>"
env_key = "<API_KEY_ENV_VAR>"
wire_api = "responses"
request_max_retries = 4
stream_max_retries = 5
stream_idle_timeout_ms = 300000

[profiles.<provider-id>]
model_provider = "<provider-id>"
model = "<model-name>"
model_reasoning_effort = "high"
model_reasoning_summary = "auto"
```

```bash
export <API_KEY_ENV_VAR>='<set locally, do not commit>'
codex exec -p <provider-id> --skip-git-repo-check "Reply with exactly: ok"
```

### Example: OpenRouter

OpenRouter supports `/v1/responses` and can proxy many Chat-only providers.

```toml
model = "zai-org/GLM-5.2"
model_provider = "openrouter"

[model_providers.openrouter]
name = "OpenRouter"
base_url = "https://openrouter.ai/api/v1"
env_key = "OPENROUTER_API_KEY"
wire_api = "responses"
```

```bash
export OPENROUTER_API_KEY='<set locally, do not commit>'
codex exec "Reply with exactly: ok"
```

---

## Chat-Completions-only providers

These endpoints implement `/v1/chat/completions` but return `404` for `/v1/responses`. You must run a local translator that accepts Responses from Codex and forwards Chat Completions to the upstream.

### Procedure

1. Pick a translator:
   - `codex-relay` (lightweight Rust, recommended)
   - OpenRouter (no local proxy needed; OpenRouter handles the translation)
   - CC Switch (desktop app with built-in proxy)
2. Configure Codex with `wire_api = "responses"` pointing at the translator.
3. Validate with a small `codex exec` request.

### Using codex-relay

Install:

```bash
uv tool install codex-relay
```

Start the relay for your provider. Example for SiliconFlow:

```bash
export SILICONFLOW_API_KEY='<set locally, do not commit>'

CODEX_RELAY_UPSTREAM=https://api.siliconflow.cn/v1 \
CODEX_RELAY_API_KEY="$SILICONFLOW_API_KEY" \
CODEX_RELAY_PORT=4446 \
codex-relay
```

Configure Codex:

```toml
model = "zai-org/GLM-5.2"
model_provider = "siliconflow-relay"

[model_providers.siliconflow-relay]
name = "SiliconFlow"
base_url = "http://127.0.0.1:4446/v1"
env_key = "OPENAI_API_KEY"
wire_api = "responses"
```

Codex needs a non-empty `OPENAI_API_KEY` for its client-side check, but the relay handles upstream auth:

```bash
export OPENAI_API_KEY='not-needed'
codex exec "Reply with exactly: ok"
```

### Using OpenRouter as the translator

If your model is listed on OpenRouter, you can skip the local proxy:

```toml
model = "zai-org/GLM-5.2"
model_provider = "openrouter"

[model_providers.openrouter]
name = "OpenRouter"
base_url = "https://openrouter.ai/api/v1"
env_key = "OPENROUTER_API_KEY"
wire_api = "responses"
```

```bash
export OPENROUTER_API_KEY='<set locally, do not commit>'
codex exec "Reply with exactly: ok"
```

### Isolated per-provider launcher

To avoid touching the default `~/.codex` config, wrap the relay in a launcher that uses `CODEX_HOME`:

```bash
#!/usr/bin/env bash
set -euo pipefail

export SILICONFLOW_API_KEY='<set locally, do not commit>'
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex-glm}"

PROXY_PORT='15401'
mkdir -p "$CODEX_HOME"

# Start codex-relay
CODEX_RELAY_UPSTREAM=https://api.siliconflow.cn/v1 \
CODEX_RELAY_API_KEY="$SILICONFLOW_API_KEY" \
CODEX_RELAY_PORT="$PROXY_PORT" \
codex-relay &>/tmp/codex-glm-relay.log &
RELAY_PID=$!

# Wait for relay
for i in $(seq 1 30); do
  if curl -sf "http://127.0.0.1:$PROXY_PORT/v1/models" >/dev/null 2>&1; then
    break
  fi
  sleep 0.5
done

# Isolated Codex config
cat > "$CODEX_HOME/config.toml" <<EOF
model = "zai-org/GLM-5.2"
model_provider = "siliconflow-relay"

[model_providers.siliconflow-relay]
name = "SiliconFlow"
base_url = "http://127.0.0.1:$PROXY_PORT/v1"
env_key = "OPENAI_API_KEY"
wire_api = "responses"
EOF

export OPENAI_API_KEY='not-needed'

cleanup() { kill "$RELAY_PID" 2>/dev/null || true; }
trap cleanup EXIT

exec codex --model 'zai-org/GLM-5.2' --dangerously-bypass-approvals-and-sandbox "$@"
```

Place in `~/.local/bin/codex-glm`, make it executable, and run:

```bash
codex-glm exec "Reply with exactly: ok"
```

### What not to do

- Do not set `wire_api = "chat"` in Codex config. Current Codex only accepts `wire_api = "responses"`.
- Do not point Codex directly at a Chat-only endpoint such as `https://api.siliconflow.cn/v1`. Codex will hit `/v1/responses` and get `404`.
- Do not rely on LiteLLM Proxy for this translation out of the box. LiteLLM Proxy routes Chat Completions and Responses separately; it does not translate Responses requests into Chat Completions requests for Codex.

---

## Validation

1. Determine the provider category:

```bash
curl -s <provider-base-url>/responses \
  -H "Authorization: Bearer <API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"model":"<model>","input":[{"role":"user","content":"hi"}]}'
```

- `200` → `responses-api`
- `404` → `chat-completions-only`

2. For `responses-api` providers, verify `/v1/models`:

```bash
curl -sS --fail-with-body \
  -H "Authorization: Bearer <API_KEY>" \
  <provider-base-url>/models
```

3. For `chat-completions-only` providers using `codex-relay`, verify the relay:

```bash
curl -s http://127.0.0.1:4446/v1/models
```

4. Run a small Codex request:

```bash
codex exec "Reply with exactly: ok"
```

Expected success: Codex returns `ok`.

---

## Notes

- Keep provider IDs stable so profiles and historical Codex sessions remain understandable.
- Prefer `env_key` over `experimental_bearer_token`; do not store bearer tokens in tracked config.
- Avoid `--ignore-user-config` except for tests. Normal setup should update `~/.codex/config.toml` or add a named profile.
- For providers that only expose a thinking on/off switch (such as SiliconFlow), Codex's `model_reasoning_effort` level may have no effect; the translator forwards the on/off switch only.
- Current Codex model listing may log errors if a third-party `/models` response shape differs from Codex's expected catalog schema. A small `codex exec` request is the decisive validation.
