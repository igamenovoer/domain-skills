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

GAC and OpenLux have provider-specific profile-and-launcher contracts. Invoke `imsight-dev-box-init->coding-agent->codex-gac-launcher()` for GAC or `imsight-dev-box-init->coding-agent->codex-openlux-launcher()` for OpenLux instead of adapting the generic examples on this page.

For the generic procedures on this page, never bake API keys into this skill, generated documentation, git-tracked config, or launcher scripts. Store keys in environment variables, a local untracked secret file, or a shell-specific secret manager chosen by the user. The provider-specific GAC and OpenLux pages intentionally define a different local-launcher credential contract.

## Workflow

1. Route GAC or OpenLux to its provider-specific launcher command; otherwise select `responses-api` or `chat-completions-only` from **Subcommands** using current provider and target-CLI documentation.
2. Complete **Target-CLI Compatibility Gate** using a temporary profile in the normal Codex home and disposable translator state when needed. Do not require handcrafted provider API calls before or instead of the actual Codex path.
3. Follow the selected provider procedure using only the endpoint, protocol, and model proven by that Codex end-to-end test, without embedding API keys.
4. Preserve unrelated Codex configuration and launcher settings.
5. Run **Validation** and report the configured route.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the declared provider commands, configuration rules, validation checks, and user request, then execute the plan without inventing compatibility.

## Custom Launcher Permission Default

When this workflow creates a custom Codex launcher, prepend `--dangerously-bypass-approvals-and-sandbox` by default. Omit it only when the user's initial launcher request explicitly asks to retain approvals or sandboxing. Silence is not an opt-out. This permission default is independent of provider routing and does not authorize unrelated work.

## Provider Launcher Principles

- Establish the installed Codex version, host OS, documented provider protocol, endpoint shape, authentication source, and a candidate model before writing a persistent launcher.
- Keep protocol translation separate from launcher concerns. A Responses-compatible provider can be called directly; a Chat-Completions-only provider needs a translator whose lifecycle and health checks the launcher owns.
- When creating a custom launcher that must preserve plain `codex`, put the custom provider in a separate profile inside the user's normal `CODEX_HOME` and select it only with `--profile`. Leave the base config and cached OAuth state unchanged, do not set `CODEX_HOME` in the launcher, and keep credentials outside tracked files.
- Make the launcher profile portable across an invocation-time `CODEX_HOME` redirect: embed the verified non-secret profile TOML, resolve the active home at runtime, leave an exact existing profile untouched, ask before creating a missing profile, and stop in noninteractive or divergent-file cases. Do not copy `config.toml`, `auth.json`, or other Codex state into the redirected home. Follow **Codex Profile Bootstrap for Redirected Homes** in `SKILL-MAIN.md`.
- Preserve provider credentials exactly as single-line HTTP values. Validate the value before a temporary Codex test and validate the generated launcher's actual load/assignment path before its end-to-end run; a clean manually exported value does not prove that a file-backed or embedded launcher serialized the same bytes.
- Use native process control for the host OS, forward all Codex arguments unchanged, clean up any child relay, preserve Codex's exit code, and apply the shared permissive default unless explicitly rejected at the beginning.
- Treat provider and bundled scripts as examples tied to observed versions. Re-check installed Codex help plus current Codex and provider documentation, then verify the actual routed request through Codex rather than assuming a template or a raw API probe is still correct.

## Target-CLI Compatibility Gate

Use the target Codex client itself as the compatibility authority:

1. Inspect the installed Codex version and help plus current Codex and provider documentation. Determine the documented endpoint, protocol category, authentication lane, and candidate model without changing persistent state. Do not select a model from this guide's examples or a previous launcher.
2. Resolve the user's normal `CODEX_HOME` without changing it. Create a uniquely named temporary provider profile beside the normal config when the installed Codex version requires a file, never overwrite an existing profile, and keep credentials process-scoped. Do not modify `config.toml`, `auth.json`, or the configured credential store.
3. For a documented Responses-compatible provider, run one minimal real `codex --profile <profile-name> exec` turn against it. Use Codex's own model/status surface when model inspection is needed.
4. For a documented Chat-Completions-only provider, start the selected translator in disposable state, point the temporary shared-home Codex profile at it, and run the same real Codex turn through the complete translation path. Temporary package or process state needed for this test is allowed; do not install or persist the final launcher yet.
5. If the user requested a model, pass that exact id through Codex and require the real turn to succeed. Otherwise use a current documented/default candidate and record the model the client reports.
6. Inspect the target client's complete result, including authentication failures from any background request. Remove the temporary profile and translator state afterward, then confirm the base config and OAuth credential store are unchanged.

If the Codex turn fails, stop without writing a persistent profile or launcher. Report the client-visible failure; do not compensate with standalone `/models`, `/responses`, or `/chat/completions` calls. A successful raw API request does not prove compatibility with the installed target client, and a raw API failure caused by an obsolete handcrafted request does not disprove it.

Persist a profile or launcher only after the real client path succeeds through the normal shared home. Use a separate `CODEX_HOME` only when a controlled target-CLI comparison proves a version-specific state or authentication collision and the user accepts isolation of config, sessions, logs, skills, and package metadata.

## Credential Value Integrity

`env_key` names an environment variable; it does not promise to sanitize the variable's value. Current Codex source checks a trimmed view only to decide whether the value is empty, then uses the original string as the bearer credential. In Codex CLI 0.154.0, leading or trailing CR/LF bytes could make HTTP header construction fail and leave a request unauthenticated without identifying the malformed credential clearly.

Apply these rules to every provider key and every full header value supplied through `env_http_headers`:

- Require a non-empty, one-line value before invoking Codex. Reject CR, LF, NUL, tabs, spaces, other control characters, and DEL. For the bearer-key providers covered here, accept only visible ASCII bytes `33..126` unless current provider documentation defines a narrower alphabet.
- Fail closed instead of silently trimming, deleting whitespace, or using command substitution to make a malformed value appear valid. Ask for a clean key when validation fails.
- Put an embedded shell or PowerShell assignment on one physical line using syntax appropriate for that shell. Derive `Bearer <key>` only after the raw key passes validation.
- Check the generated launcher's assignment or secret-loading path without printing the secret, then run the real Codex request through that launcher. Presence of the variable name alone is not sufficient verification.

The launcher should report only that the credential shape is invalid. It may report a length or boolean shape result when useful, but must never print the value, its bytes, the assignment line, or a reversible encoding.

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

### Generic provider-profile shape

Current Codex profile files live beside the base config as `$CODEX_HOME/<profile-name>.config.toml` and are selected with `--profile <profile-name>`. Use the user's normal `CODEX_HOME`; the separate profile can coexist with `auth.json` because `env_key` plus `requires_openai_auth = false` selects provider-specific authentication for that profile. Do not add provider selection or a legacy `[profiles.<name>]` table to the base `config.toml` when the installed Codex version uses profile files.

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

When this profile is selected by a custom launcher, embed the TOML above without the credential and apply the shared runtime bootstrap before this command. A launcher invoked with `CODEX_HOME=/some/other/home` must check `/some/other/home/<profile-name>.config.toml`, ask before creating a missing file, and continue only after the user accepts. Matching content is reused; divergent content and noninteractive missing-profile cases fail closed.

### Example: OpenRouter

OpenRouter supports `/v1/responses` and can proxy many Chat-only providers.

Put this provider layer in `$CODEX_HOME/openrouter.config.toml` when plain `codex` must remain unchanged:

Replace `<verified-openrouter-model>` only with the exact id that completed the current shared-home Codex check through OpenRouter.

```toml
model = "<verified-openrouter-model>"
model_provider = "openrouter"

[model_providers.openrouter]
name = "OpenRouter"
base_url = "https://openrouter.ai/api/v1"
env_key = "OPENROUTER_API_KEY"
wire_api = "responses"
requires_openai_auth = false
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

Configure Codex in a separate provider profile file such as `$CODEX_HOME/siliconflow-relay.config.toml`:

Replace `<verified-siliconflow-model>` only with the exact id that completed the current shared-home Codex check through the translator and SiliconFlow.

```toml
model = "<verified-siliconflow-model>"
model_provider = "siliconflow-relay"

[model_providers.siliconflow-relay]
name = "SiliconFlow"
base_url = "http://127.0.0.1:4446/v1"
env_key = "OPENAI_API_KEY"
wire_api = "responses"
requires_openai_auth = false
```

Codex needs a non-empty `OPENAI_API_KEY` for its client-side check, but the relay handles upstream auth:

```bash
export OPENAI_API_KEY='not-needed'
codex --profile siliconflow-relay exec "Reply with exactly: ok"
```

### Using OpenRouter as the translator

If your model is listed on OpenRouter, you can skip the local proxy:

Put this layer in `$CODEX_HOME/openrouter.config.toml`:

Replace `<verified-openrouter-model>` only with the exact id that completed the current shared-home Codex check through OpenRouter.

```toml
model = "<verified-openrouter-model>"
model_provider = "openrouter"

[model_providers.openrouter]
name = "OpenRouter"
base_url = "https://openrouter.ai/api/v1"
env_key = "OPENROUTER_API_KEY"
wire_api = "responses"
requires_openai_auth = false
```

```bash
export OPENROUTER_API_KEY='<set locally, do not commit>'
codex --profile openrouter exec "Reply with exactly: ok"
```

### Reference Unix launcher for a profile-scoped provider

Create `$CODEX_HOME/siliconflow-relay.config.toml` once, using the provider profile shown above and the same relay port as the launcher. The launcher should not rewrite Codex config at runtime or replace `CODEX_HOME`; it scopes credentials, manages the relay, and selects the provider profile. Adapt its shell syntax, relay lifecycle, port handling, and Codex flags for the installed versions and host OS while preserving **Provider Launcher Principles**:

```bash
#!/usr/bin/env bash
set -euo pipefail

export SILICONFLOW_API_KEY='<set locally, do not commit>'
credential_pattern='^[!-~]+$'
if ! (LC_ALL=C; [[ $SILICONFLOW_API_KEY =~ $credential_pattern ]]); then
  echo 'codex-glm: SILICONFLOW_API_KEY must be one line of visible ASCII' >&2
  exit 2
fi
PROXY_PORT='4446'

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

export OPENAI_API_KEY='not-needed'

cleanup() { kill "$RELAY_PID" 2>/dev/null || true; }
trap cleanup EXIT

exec codex --profile siliconflow-relay --model '<verified-siliconflow-model>' --dangerously-bypass-approvals-and-sandbox "$@"
```

Do not execute this example with unresolved placeholders. Substitute the client-verified model only after the shared-home relay/Codex test succeeds. If the user's initial launcher request explicitly opts out of permissive mode, omit only `--dangerously-bypass-approvals-and-sandbox` from the final `exec` line and preserve the profile, model, and argument forwarding.

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

Also verify that the launcher's actual credential assignment or loading path passes **Credential Value Integrity** without printing the value. Then verify that the launcher uses the same provider profile in the user's normal `CODEX_HOME` that was tested in disposable state, does not assign `CODEX_HOME`, leaves `auth.json` and the base config unchanged, produces no background authentication failures, preserves arguments and exit status, and leaves plain `codex` on its ordinary route. A local relay readiness check may help manage its process, but it is not provider-compatibility evidence and never replaces this Codex turn.

### Optional separate-home fallback

Do not create another `CODEX_HOME` merely because the normal home contains `auth.json`. Offer a separate home only when a controlled comparison shows that the installed Codex client repeatedly fails through an otherwise correct shared-home provider profile because of a state or authentication collision, while the same target-CLI request succeeds from a clean disposable home. Before making that topology persistent, tell the user that it also isolates base config, sessions, logs, skills, and package metadata, and obtain their choice.

---

## Notes

- Keep provider IDs stable so profiles and historical Codex sessions remain understandable.
- Some relays partition keys into per-product token groups. An OpenLux Claude-group key does not work for Codex, and a Codex-group key does not work for the Anthropic Messages API; create the key in the group matching the client.
- Prefer `env_key` over `experimental_bearer_token`; do not store bearer tokens in tracked config.
- Avoid `--ignore-user-config` except for tests. To leave plain `codex` unchanged, put the custom provider in a separate `<profile-name>.config.toml` beside the ordinary base config, select it only with `--profile <profile-name>`, and keep provider selection out of the base `config.toml`.
- For providers that only expose a thinking on/off switch (such as SiliconFlow), Codex's `model_reasoning_effort` level may have no effect; the translator forwards the on/off switch only.
- Current Codex model listing may log errors if a third-party `/models` response shape differs from Codex's expected catalog schema. A small `codex exec` request is the decisive validation.

## Guardrails

- DO NOT require, recommend, or use standalone provider `/models`, `/responses`, or `/chat/completions` probes as launcher compatibility evidence.
- DO NOT choose a model from a historical example, previous launcher, or translator default without current target-Codex verification.
- DO NOT persist a Codex profile or launcher until the shared-home client or translator path succeeds with the client-verified model.
- DO NOT set `CODEX_HOME` in the ordinary launcher, modify or copy `auth.json`, or select the third-party provider in the base `config.toml`; put the provider in its own profile file inside the normal Codex home.
- DO NOT make a separate provider home persistent unless the controlled target-CLI comparison described above demonstrates a real collision and the user accepts the broader isolation effects.
- DO NOT accept a multiline, whitespace-padded, or control-character-bearing provider credential; do not trim it into apparent validity, and do not treat a clean manual export as proof that the generated launcher carries the same value.
- DO NOT accept a successful agent turn when background model discovery repeatedly returns `401` or `403`; fix or disable the incompatible discovery path using currently documented Codex behavior before persistence.
- DO NOT lower Codex's retry defaults or repeatedly invoke a throttled provider without current evidence that doing so is appropriate.
