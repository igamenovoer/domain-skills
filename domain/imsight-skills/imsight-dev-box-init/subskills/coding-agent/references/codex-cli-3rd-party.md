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

Current Codex configuration supports the OpenAI **Responses** wire protocol (`/v1/responses`) for custom providers; `responses` is the only documented `wire_api` value. Re-check the installed CLI and official configuration reference before implementation instead of carrying forward an old `wire_api = "chat"` example.

There are two generic provider categories. Find your provider in the routing table below and follow the matching procedure.

GAC and OpenLux have dedicated profile-and-launcher contracts. Invoke `imsight-dev-box-init->coding-agent->codex-gac-launcher()` for GAC or `imsight-dev-box-init->coding-agent->codex-openlux-launcher()` for OpenLux instead of adapting the generic examples on this page.

For the generic procedures on this page, never bake API keys into this skill, generated documentation, git-tracked config, or launcher scripts. Store keys in environment variables, a local untracked secret file, or a shell-specific secret manager chosen by the user. The dedicated GAC and OpenLux pages intentionally define a different local-launcher credential contract.

## Workflow

1. Route GAC or OpenLux to its dedicated launcher command; otherwise select `responses-api` or `chat-completions-only` from **Subcommands** using read-only provider evidence.
2. Complete **No-Write Provider Preflight** before installing a translator or creating or changing any config, profile, launcher, credential file, temporary directory, response dump, or log.
3. Follow the selected provider procedure using only the endpoint, protocol, and model verified during preflight, without embedding API keys.
4. Preserve unrelated Codex configuration and launcher settings.
5. Run **Validation** and report the configured route.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the declared provider commands, configuration rules, validation checks, and user request, then execute the plan without inventing compatibility.

## Custom Launcher Permission Default

When this workflow creates a custom Codex launcher, prepend `--dangerously-bypass-approvals-and-sandbox` by default. Omit it only when the user's initial launcher request explicitly asks to retain approvals or sandboxing. Silence is not an opt-out. This permission default is independent of provider routing and does not authorize unrelated work.

## Provider Launcher Principles

- Establish the installed Codex version, host OS, provider protocol, endpoint shape, authentication source, and model name before writing a launcher.
- Keep protocol translation separate from launcher concerns. A Responses-compatible provider can be called directly; a Chat-Completions-only provider needs a translator whose lifecycle and health checks the launcher owns.
- Isolate provider state with a deliberate `CODEX_HOME` or profile when the user does not want to alter the default configuration. Keep credentials outside tracked files.
- Use native process control for the host OS, forward all Codex arguments unchanged, clean up any child relay, preserve Codex's exit code, and apply the shared permissive default unless explicitly rejected at the beginning.
- Treat provider and bundled scripts as examples tied to observed versions. Re-check `/v1/responses`, installed Codex help, and provider documentation, then verify the actual routed request rather than assuming a template is still correct.

## No-Write Provider Preflight

Before any filesystem or package-install mutation:

1. Keep the supplied key process-scoped and query the provider's current model/discovery endpoint. Do not select a model from this guide's examples or a previous launcher.
2. If the provider claims Responses support, send a minimal direct `/v1/responses` request using a currently advertised model. If it is Chat-Completions-only, prove one currently advertised model with a minimal direct `/v1/chat/completions` request before selecting a translator.
3. Record the verified base URL, protocol category, exact model id, and authentication lane without recording the key or dumping the response to disk.
4. Stop without installing a relay, creating isolated state, or writing configuration when discovery or the direct provider request fails.

After this phase succeeds, use disposable isolated state to verify the translator or Codex client when required. Persist a profile or launcher only after the real client path succeeds with the same verified model.

## Subcommands

Terminal invocation of `imsight-dev-box-init->coding-agent->codex-cli-3rd-party()` selects or summarizes a provider category.

| Subcommand | Category | Procedure |
| --- | --- | --- |
| `responses-api` | Providers that natively support `/v1/responses` | [Responses API compatible providers](#responses-api-compatible-providers) |
| `chat-completions-only` | Providers that only support `/v1/chat/completions` | [Chat-Completions-only providers](#chat-completions-only-providers) |

## Provider routing table

| Provider | Endpoint base | Category | Notes |
| --- | --- | --- | --- |
| GAC | `https://gaccode.com/codex/v1` | Dedicated launcher | Use `imsight-dev-box-init->coding-agent->codex-gac-launcher()`; do not adapt this page's generic credential layout |
| OpenLux | `https://api.openlux.ai/v1` | Dedicated launcher | Use `imsight-dev-box-init->coding-agent->codex-openlux-launcher()`; verify current Codex token entitlement and model compatibility |
| OpenRouter | `https://openrouter.ai/api/v1` | `responses-api` | Responses-compatible gateway; proxy for many providers |
| SiliconFlow | `https://api.siliconflow.cn/v1` | `chat-completions-only` | Use `codex-relay` or OpenRouter |
| DeepSeek direct | `https://api.deepseek.com/v1` | `chat-completions-only` | Use `codex-relay` or OpenRouter |
| Kimi direct | `https://api.moonshot.cn/v1` | `chat-completions-only` | Use `codex-relay` or OpenRouter |
| Zhipu GLM direct | `https://open.bigmodel.cn/api/paas/v4` | `chat-completions-only` | Use `codex-relay` or OpenRouter |

If a provider is not listed, test `POST /v1/responses` directly with a valid key. A `404` means it is `chat-completions-only`; a `401`/`403` from an unauthenticated probe is inconclusive.

---

## Responses API compatible providers

These endpoints already implement `/v1/responses`. Configure Codex to call them directly.

### Generic dedicated-profile shape

Current Codex profile files live beside the base config as `$CODEX_HOME/<profile-name>.config.toml` and are selected with `--profile <profile-name>`. Put provider selection in that separate file when plain `codex` must remain on its existing route. Do not add a legacy `[profiles.<name>]` table to the base `config.toml` when the installed Codex version uses profile files.

```toml
model = "<model-name>"
model_provider = "<provider-id>"
disable_response_storage = true
model_reasoning_effort = "high"

[model_providers.<provider-id>]
name = "<display-name>"
base_url = "<provider-base-url>"
env_key = "<API_KEY_ENV_VAR>"
wire_api = "responses"
requires_openai_auth = false
request_max_retries = 4
stream_max_retries = 5
stream_idle_timeout_ms = 300000
```

`disable_response_storage = true` turns off Codex's default server-side response storage, which third-party relays commonly reject or mishandle. `env_key` selects the scoped environment variable and `requires_openai_auth = false` prevents the custom provider from depending on the official OpenAI login.

```bash
export <API_KEY_ENV_VAR>='<set locally, do not commit>'
codex --profile <profile-name> exec --skip-git-repo-check "Reply with exactly: ok"
```

### Example: OpenRouter

OpenRouter supports `/v1/responses` and can proxy many Chat-only providers.

Put this provider layer in `$CODEX_HOME/openrouter.config.toml` when plain `codex` must remain unchanged:

Replace `<verified-openrouter-model>` only with the exact id that passed the current OpenRouter `/models`, direct Responses, and isolated Codex checks.

```toml
model = "<verified-openrouter-model>"
model_provider = "openrouter"

[model_providers.openrouter]
name = "OpenRouter"
base_url = "https://openrouter.ai/api/v1"
env_key = "OPENROUTER_API_KEY"
wire_api = "responses"
```

```bash
export OPENROUTER_API_KEY='<set locally, do not commit>'
codex --profile openrouter exec "Reply with exactly: ok"
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
3. Validate with a small `codex --profile <profile-name> exec` request.

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

Configure Codex in a dedicated profile file such as `$CODEX_HOME/siliconflow-relay.config.toml`:

Replace `<verified-siliconflow-model>` only with the exact id that passed the current SiliconFlow `/models`, direct Chat Completions, relay, and isolated Codex checks.

```toml
model = "<verified-siliconflow-model>"
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
codex --profile siliconflow-relay exec "Reply with exactly: ok"
```

### Using OpenRouter as the translator

If your model is listed on OpenRouter, you can skip the local proxy:

Put this layer in `$CODEX_HOME/openrouter.config.toml`:

Replace `<verified-openrouter-model>` only with the exact id that passed the current OpenRouter `/models`, direct Responses, and isolated Codex checks.

```toml
model = "<verified-openrouter-model>"
model_provider = "openrouter"

[model_providers.openrouter]
name = "OpenRouter"
base_url = "https://openrouter.ai/api/v1"
env_key = "OPENROUTER_API_KEY"
wire_api = "responses"
```

```bash
export OPENROUTER_API_KEY='<set locally, do not commit>'
codex --profile openrouter exec "Reply with exactly: ok"
```

### Reference Unix launcher for an isolated provider

To avoid touching the default `~/.codex` config, the following Unix example wraps the relay in a launcher that uses `CODEX_HOME`. Adapt its shell syntax, relay lifecycle, port handling, and Codex flags for the installed versions and host OS while preserving **Provider Launcher Principles**:

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
model = "<verified-siliconflow-model>"
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

exec codex --model '<verified-siliconflow-model>' --dangerously-bypass-approvals-and-sandbox "$@"
```

Do not execute this example with unresolved placeholders. Substitute the same API-verified model in both locations only after the direct provider request and isolated relay/Codex test succeed. If the user's initial launcher request explicitly opts out of permissive mode, omit only `--dangerously-bypass-approvals-and-sandbox` from the final `exec` line and preserve the model and argument forwarding.

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

4. Run a small Codex request through the configured profile:

```bash
codex --profile <profile-name> exec "Reply with exactly: ok"
```

Expected success: Codex returns `ok`.

---

## Notes

- Keep provider IDs stable so profiles and historical Codex sessions remain understandable.
- Some relays partition keys into per-product token groups. An OpenLux Claude-group key does not work for Codex, and a Codex-group key does not work for the Anthropic Messages API; create the key in the group matching the client.
- Prefer `env_key` over `experimental_bearer_token`; do not store bearer tokens in tracked config.
- Avoid `--ignore-user-config` except for tests. When plain `codex` must remain unchanged, add a separate `$CODEX_HOME/<profile-name>.config.toml` instead of selecting the provider in the base config.
- For providers that only expose a thinking on/off switch (such as SiliconFlow), Codex's `model_reasoning_effort` level may have no effect; the translator forwards the on/off switch only.
- Current Codex model listing may log errors if a third-party `/models` response shape differs from Codex's expected catalog schema. A small `codex exec` request is the decisive validation.

## Guardrails

- DO NOT install a translator or create or modify provider setup files before current model discovery and a direct request through the provider's native protocol succeed.
- DO NOT choose a model from a historical example, previous launcher, or translator default without current provider verification.
- DO NOT persist a Codex profile or launcher until the isolated client or translator path succeeds with the API-verified model.
