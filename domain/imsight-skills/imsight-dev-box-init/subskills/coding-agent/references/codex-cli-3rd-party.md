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

1. Route GAC or OpenLux to its dedicated launcher command; otherwise select `responses-api` or `chat-completions-only` from **Subcommands** using current provider and target-CLI documentation.
2. Complete **Target-CLI Compatibility Gate** using disposable isolated state. Do not require handcrafted provider API calls before or instead of the actual Codex path.
3. Follow the selected provider procedure using only the endpoint, protocol, and model proven by that Codex end-to-end test, without embedding API keys.
4. Preserve unrelated Codex configuration and launcher settings.
5. Run **Validation** and report the configured route.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the declared provider commands, configuration rules, validation checks, and user request, then execute the plan without inventing compatibility.

## Custom Launcher Permission Default

When this workflow creates a custom Codex launcher, prepend `--dangerously-bypass-approvals-and-sandbox` by default. Omit it only when the user's initial launcher request explicitly asks to retain approvals or sandboxing. Silence is not an opt-out. This permission default is independent of provider routing and does not authorize unrelated work.

## Provider Launcher Principles

- Establish the installed Codex version, host OS, documented provider protocol, endpoint shape, authentication source, and a candidate model before writing a persistent launcher.
- Keep protocol translation separate from launcher concerns. A Responses-compatible provider can be called directly; a Chat-Completions-only provider needs a translator whose lifecycle and health checks the launcher owns.
- When creating a custom launcher that must preserve plain `codex`, give it a fixed launcher-owned `CODEX_HOME` with no copied `auth.json` or official login state. Put the provider profile there, ignore an ambient runtime `CODEX_HOME`, and keep credentials outside tracked files.
- Use native process control for the host OS, forward all Codex arguments unchanged, clean up any child relay, preserve Codex's exit code, and apply the shared permissive default unless explicitly rejected at the beginning.
- Treat provider and bundled scripts as examples tied to observed versions. Re-check installed Codex help plus current Codex and provider documentation, then verify the actual routed request through Codex rather than assuming a template or a raw API probe is still correct.

## Target-CLI Compatibility Gate

Use the target Codex client itself as the compatibility authority:

1. Inspect the installed Codex version and help plus current Codex and provider documentation. Determine the documented endpoint, protocol category, authentication lane, and candidate model without changing persistent state. Do not select a model from this guide's examples or a previous launcher.
2. Create a disposable auth-free `CODEX_HOME` outside the ordinary home. Write only the minimum temporary provider profile needed by the installed Codex version and keep credentials process-scoped.
3. For a documented Responses-compatible provider, run one minimal real `codex --profile <profile-name> exec` turn against it. Use Codex's own model/status surface when model inspection is needed.
4. For a documented Chat-Completions-only provider, start the selected translator in disposable state, point the disposable Codex profile at it, and run the same real Codex turn through the complete translation path. Temporary package or process state needed for this isolated test is allowed; do not install or persist the final launcher yet.
5. If the user requested a model, pass that exact id through Codex and require the real turn to succeed. Otherwise use a current documented/default candidate and record the model the client reports.
6. Inspect the target client's complete result, including authentication failures from any background request. Remove disposable files and stop the translator afterward.

If the Codex turn fails, stop without writing a persistent profile or launcher. Report the client-visible failure; do not compensate with standalone `/models`, `/responses`, or `/chat/completions` calls. A successful raw API request does not prove compatibility with the installed target client, and a raw API failure caused by an obsolete handcrafted request does not disprove it.

Persist a profile or launcher only after the real client path succeeds. A custom launcher must preserve the tested auth-free home topology in its fixed persistent `CODEX_HOME`.

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

If a provider is not listed, consult its current protocol documentation and the installed Codex client's supported provider settings. When the protocol remains unclear, stop and request authoritative provider guidance rather than classifying it with a handcrafted endpoint probe.

---

## Responses API compatible providers

These endpoints already implement `/v1/responses`. Configure Codex to call them directly.

### Generic dedicated-profile shape

Current Codex profile files live beside the base config as `$CODEX_HOME/<profile-name>.config.toml` and are selected with `--profile <profile-name>`. For a custom launcher that preserves plain `codex`, make `$CODEX_HOME` a fixed launcher-owned, auth-free directory rather than the ordinary Codex home. Do not add a legacy `[profiles.<name>]` table to the ordinary base `config.toml` when the installed Codex version uses profile files.

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
```

`disable_response_storage = true` turns off Codex's default server-side response storage, which third-party relays commonly reject or mishandle. `env_key` selects the scoped environment variable and `requires_openai_auth = false` prevents the custom provider from depending on the official OpenAI login. Omit retry settings to inherit the installed Codex defaults unless current provider evidence justifies an override.

```bash
export <API_KEY_ENV_VAR>='<set locally, do not commit>'
codex --profile <profile-name> exec --skip-git-repo-check "Reply with exactly: ok"
```

### Example: OpenRouter

OpenRouter supports `/v1/responses` and can proxy many Chat-only providers.

Put this provider layer in `$CODEX_HOME/openrouter.config.toml` when plain `codex` must remain unchanged:

Replace `<verified-openrouter-model>` only with the exact id that completed the current isolated Codex check through OpenRouter.

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

Replace `<verified-siliconflow-model>` only with the exact id that completed the current isolated Codex check through the translator and SiliconFlow.

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

Replace `<verified-openrouter-model>` only with the exact id that completed the current isolated Codex check through OpenRouter.

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
export CODEX_HOME="$HOME/.codex-glm"

PROXY_PORT='15401'
mkdir -p "$CODEX_HOME"

# Start codex-relay
CODEX_RELAY_UPSTREAM=https://api.siliconflow.cn/v1 \
CODEX_RELAY_API_KEY="$SILICONFLOW_API_KEY" \
CODEX_RELAY_PORT="$PROXY_PORT" \
codex-relay &>/tmp/codex-glm-relay.log &
RELAY_PID=$!

# Let the relay bind, but leave protocol validation to the Codex invocation below.
sleep 1
if ! kill -0 "$RELAY_PID" 2>/dev/null; then
  echo 'codex-relay exited before Codex could connect' >&2
  wait "$RELAY_PID" || exit $?
  exit 1
fi

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

Do not execute this example with unresolved placeholders. Substitute the same client-verified model in both locations only after the isolated relay/Codex test succeeds. If the user's initial launcher request explicitly opts out of permissive mode, omit only `--dangerously-bypass-approvals-and-sandbox` from the final `exec` line and preserve the model and argument forwarding.

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

Run a small Codex request through the configured profile:

```bash
codex --profile <profile-name> exec "Reply with exactly: ok"
```

Expected success: Codex returns `ok`.

Also verify that the launcher uses the same fixed auth-free `CODEX_HOME` topology tested in disposable state, background client requests do not produce authentication failures, arguments and exit status are preserved, and plain `codex` remains on its ordinary route. A local relay readiness check may help manage its process, but it is not provider-compatibility evidence and never replaces this Codex turn.

---

## Notes

- Keep provider IDs stable so profiles and historical Codex sessions remain understandable.
- Some relays partition keys into per-product token groups. An OpenLux Claude-group key does not work for Codex, and a Codex-group key does not work for the Anthropic Messages API; create the key in the group matching the client.
- Prefer `env_key` over `experimental_bearer_token`; do not store bearer tokens in tracked config.
- Avoid `--ignore-user-config` except for tests. When a custom launcher must leave plain `codex` unchanged, use a fixed launcher-owned, auth-free `CODEX_HOME` and put `<profile-name>.config.toml` there instead of selecting the provider in the ordinary base config.
- For providers that only expose a thinking on/off switch (such as SiliconFlow), Codex's `model_reasoning_effort` level may have no effect; the translator forwards the on/off switch only.
- Current Codex model listing may log errors if a third-party `/models` response shape differs from Codex's expected catalog schema. A small `codex exec` request is the decisive validation.

## Guardrails

- DO NOT require, recommend, or use standalone provider `/models`, `/responses`, or `/chat/completions` probes as launcher compatibility evidence.
- DO NOT choose a model from a historical example, previous launcher, or translator default without current target-Codex verification.
- DO NOT persist a Codex profile or launcher until the isolated client or translator path succeeds with the client-verified model.
- DO NOT put a custom launcher's third-party profile in the ordinary Codex home, copy `auth.json` into its provider home, or let an ambient `CODEX_HOME` redirect it.
- DO NOT accept a successful agent turn when background model discovery repeatedly returns `401` or `403`; fix or disable the incompatible discovery path using currently documented Codex behavior before persistence.
- DO NOT lower Codex's retry defaults or repeatedly invoke a throttled provider without current evidence that doing so is appropriate.
