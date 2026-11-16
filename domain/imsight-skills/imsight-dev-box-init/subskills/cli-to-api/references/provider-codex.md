# Codex OAuth Worked Case

This case shows how to expose a Codex/ChatGPT OAuth account through CLIProxyAPI as an OpenAI-compatible API, how to request the Fast (`priority`) and `ultrafast` service tiers, and how to expose those tiers as separate client-visible model names for clients that have no service-tier concept. Flags, model IDs, tier support, and response metadata change between releases; confirm them against the installed proxy build and the account's live model list.

## Workflow

1. **Confirm build support.** Inspect `<install-dir>/cli-proxy-api -h` and the release's configuration example for `-codex-login`, `-codex-device-login`, `oauth.model-alias`, and `requests.payload.override`. Verify whether the installed build normalizes `priority`, `fast`, and `ultrafast`.
2. **Choose the upstream route.** Use Codex OAuth when the user owns a ChatGPT/Codex subscription; use an OpenAI API key only when the user explicitly wants API billing. See **Route Selection**.
3. **Complete the login.** Use `-codex-login` on an interactive host or `-codex-device-login` on a headless host. Never copy the Codex CLI's credential file. See **Login**.
4. **Discover the live catalog.** Query `/v1/models` and record exact IDs, context sizes, and capabilities. Do not assume IDs from another account or release. See **Model Discovery**.
5. **Select a service tier.** Send `priority` for Fast or `ultrafast` for the highest tier; use `fast` only as a Codex-client alias. Treat the upstream response field as non-evidence. See **Service Tiers**.
6. **Expose tiers as model names when the client cannot send a tier.** Add a forked proxy alias and a matching payload override, then point the client at the alias. See **Exposing Tiers as Model Names**.
7. **Wire the client.** For Kimi Code, add an `openai` or `openai_responses` provider and model entries whose `model` is the proxy alias. See **Kimi Code Client Wiring**.
8. **Verify end to end.** Confirm the alias appears in the model list, the final outbound request carries the requested tier, a real generation succeeds, and any declared tool or image path works. See **Verification**.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the provider account, the installed proxy build, the client protocol, and the user's constraints, then execute the plan.

## Route Selection

| Route | Upstream credential | Best for | Important limit |
| --- | --- | --- | --- |
| Codex OAuth | ChatGPT/Codex account | Reusing a Codex CLI subscription through an OpenAI-compatible API | Quota, model catalog, and service-tier entitlement follow the ChatGPT plan |
| OpenAI API key | OpenAI API key | Stable API billing with documented tier fields | Separate billing and account; not the same as the Codex subscription |

Choose the route from the credential the user actually owns. Do not convert an API-key task into an OAuth task or the reverse; quota, billing, and terms differ.

## Login

### Interactive Host

```bash
<install-dir>/cli-proxy-api -config <config-path> -codex-login
```

Add `-no-browser` when the host cannot open a browser; the login process prints the authorization URL instead. The loopback callback commonly uses port `1455`; use the build's override flag only if the provider's redirect URI permits it, otherwise prefer the default or the device flow.

### Headless Host

```bash
<install-dir>/cli-proxy-api -config <config-path> -codex-device-login
```

The device flow prints a verification URL and a short code, polls until the user approves, then writes the credential and exits. It avoids the callback listener and is the preferred route on SSH-only or container hosts. The code expires; if approval arrives too late, restart the login and use the new code.

### Credential Persistence

- A successful login writes a per-account file such as `codex-<account>.json` into `<auth-dir>` with owner-only permissions.
- Recent releases watch the auth directory and reload the credential without a restart. Confirm the reload in the proxy log before debugging the endpoint.
- Do not start a second proxy instance for the login. The login command is a one-off process; the long-running proxy keeps serving.
- Do not copy `~/.codex/auth.json` or another CLI's credential store into the proxy's auth directory. Use the proxy's supported login flow so refresh tokens stay valid and account binding remains explicit.

## Model Discovery

```bash
curl -s -H "Authorization: Bearer <client-key>" \
  http://<proxy-host>:<api-port>/v1/models
```

- Use the exact `id` values from the response. Codex entries commonly report `owned_by` as `openai` or `codex`, but the hint is not part of the model contract.
- Model IDs, context windows, and tier support are account-specific. Do not hardcode a list from another account or an older release.
- `/v1/models` does not expose service-tier metadata. A Codex client catalog such as `models_cache.json` may list `service_tiers` and `additional_speed_tiers`; treat that as client-side metadata, not proof that the proxy exposes or applies the tier.
- Record the context window and modalities for each model before writing client configuration. Do not copy another model's window blindly.

## Service Tiers

A service tier is a request field, not a model-ID suffix. The model name identifies what to run; `service_tier` asks how the provider should schedule it.

| Request value | Meaning | Operational note |
| --- | --- | --- |
| `priority` | Fast tier, typically 1.5–2× speed with increased usage | The wire value for Codex Fast; current translators preserve it |
| `fast` | Codex client-side alias | Current translators normalize it to `priority`; a raw `fast` value may be rejected upstream |
| `ultrafast` | Highest available tier | Support arrived later than `priority`; verify the installed build forwards it |
| `auto`, `default`, `flex` | Standard/default or unsupported | Dropped or treated as standard; not a Fast request |

Rules for interpreting the result:

- The upstream response's `service_tier` is commonly `default` or `auto` even when the final outbound request carried `priority` or `ultrafast`. Do not use that response field as proof.
- Authoritative evidence is the final outbound request body, or an `effective_service_tier` field in usage records on builds that report it. At the time of writing, CLIProxyAPI adds effective-tier reporting in v8.0.39 and later; older builds record only the client-requested tier and the upstream response tier.
- The upstream may accept the tier field and still serve the request at standard tier when the account lacks entitlement. The proxy cannot create entitlement; report the limitation instead of promising a speedup.
- Both Chat Completions and Responses routes are expected to normalize the tier in current builds. Verify the installed release's translator support because `priority`, `fast`, and `ultrafast` landed at different times.

## Exposing Tiers as Model Names

Kimi Code and many OpenAI-compatible clients have no `service_tier` setting. A client-local model alias is not enough: the proxy sees only the `model` string, so two client aliases that send the same upstream ID are indistinguishable. Define the distinguishing name at the proxy layer.

### 1. Add a Forked Proxy Alias

In the v8 configuration layout:

```yaml
oauth:
  auth-dir: "<auth-dir>"
  model-alias:
    codex:
      - name: "<upstream-model-id>"
        alias: "<upstream-model-id>-fast"
        fork: true
        display-name: "<display-name> Fast"
      - name: "<upstream-model-id>"
        alias: "<upstream-model-id>-ultrafast"
        fork: true
        display-name: "<display-name> Ultrafast"
```

- `fork: true` keeps the original model and exposes each alias as an additional client-visible model.
- Older builds may accept the top-level `oauth-model-alias` form instead of the nested `oauth.model-alias` key; use the shape in the installed release's configuration example.
- `force-mapping: true` is optional; it rewrites response model fields back to the alias but is not required for tier selection.
- Use a unique alias per tier. Do not point both tiers at the same client-visible name.

### 2. Inject the Tier for the Alias

```yaml
requests:
  payload:
    override:
      - models:
          - name: "<upstream-model-id>-fast"
            protocol: "codex"
        params:
          service_tier: priority
      - models:
          - name: "<upstream-model-id>-ultrafast"
            protocol: "codex"
        params:
          service_tier: ultrafast
```

- Payload rules match the client-visible requested model before alias resolution, so the alias name is targetable even though the outbound request uses `<upstream-model-id>`.
- Match `protocol: "codex"` for a Codex target. If the installed build names the target protocol differently, inspect its configuration example rather than guessing.
- Keep the override rule scoped to the alias. A rule matching `<upstream-model-id>` applies the tier to the original model as well.
- After reload, confirm the alias appears in `/v1/models` and the override count was loaded in the proxy log.

## Kimi Code Client Wiring

Use an OpenAI-compatible provider. `openai` uses Chat Completions; `openai_responses` uses the Responses API. Choose the surface the proxy and client handle best, and verify with a real turn.

```toml
[providers.codex-local]
type = "openai"
base_url = "http://<proxy-host>:<api-port>/v1"
api_key = "<client-key>"

[models."codex-local/<upstream-model-id>-fast"]
provider = "codex-local"
model = "<upstream-model-id>-fast"
max_context_size = <context-size>
capabilities = [ "thinking", "tool_use" ]
support_efforts = [ "low", "medium", "high", "xhigh", "max" ]
default_effort = "xhigh"
display_name = "<display-name> (Fast)"
```

Field rules:

- `model` must be the proxy alias, not the upstream model ID. Sending the upstream ID bypasses the alias and the tier override.
- `base_url` includes the OpenAI API version prefix, commonly `/v1`. Confirm the provider type's convention; a doubled version path produces 404s.
- `api_key` is the proxy's downstream client key, not the Codex credential. Use `api_key_env` when the key comes from the launch environment.
- `max_context_size` must be positive and should come from the live catalog. The upstream may expose a different window from a sibling model.
- Add only capabilities verified by a real turn. Add `image_in` after an image turn succeeds; do not infer it from the model family.
- List only effort levels the endpoint accepts, and keep any global `[thinking].effort` inside that list. `support_efforts` enables the picker; `capabilities = [ "thinking" ]` alone does not.
- Add the same model alias to `[secondary_model.models]` when subagents should be able to select it. Omitting it keeps the model available to the main agent only.
- Run `/reload` in an idle TUI or start a new session after editing the config.

For the Gemini-native Kimi Code provider shape and its thinking-level mapping, see [client-kimi-code.md](client-kimi-code.md). This section covers only the OpenAI-compatible Codex route.

## Verification

1. **Model list.** With a valid client key, `/v1/models` includes the original model and each tier alias; without a key, the endpoint rejects the request.
2. **Direct alias generation.** Send a request to `<upstream-model-id>-fast` with no client-provided `service_tier` and confirm it completes.
3. **Outbound evidence.** Enable temporary request logging or read `effective_service_tier` on a build that reports it. Confirm the outbound model is `<upstream-model-id>` and the tier is `priority` or `ultrafast`. Do not use the response's `service_tier` field as evidence.
4. **Client turn.** Run a real Kimi Code turn through the alias. If the model declares `tool_use`, include a tool-call turn; if it declares an image capability, include an image turn.
5. **Speed evidence when required.** Compare the tier alias with the original model using the same prompt, output cap, and account. A single run is not proof; describe variance and do not promise a fixed multiplier.
6. **Cleanup.** Disable request logging and remove the generated logs; they can contain request headers.
7. **Error paths.** Confirm an unknown alias returns 404, a missing client key returns 401, and a quota or entitlement failure is surfaced rather than masked.

## Troubleshooting

- **The tier alias returns 404.**
  - If the alias is absent from `/v1/models`, then the proxy alias was not loaded or the client sent the upstream ID. Re-check `oauth.model-alias`, the reload log, and the client model entry.
- **The response says `service_tier: default` or `auto`.**
  - If the final outbound request carried `priority` or `ultrafast`, then this is expected upstream behavior, not proof of failure. Inspect the outbound request or `effective_service_tier`.
- **The tier is dropped.**
  - If the build's translator does not support the value, then normalize `fast` to `priority` and verify `ultrafast` support. Upgrade when the installed release predates the translator change.
- **The tier is forwarded but the response is not faster.**
  - If the account lacks entitlement or the upstream downgrades the request, then the proxy cannot force the tier. Measure with a controlled A/B run and report the account limitation.
- **The usage record lacks an effective tier.**
  - If the build predates effective-tier reporting, then use a temporary request log or upgrade; the client-requested and response tiers alone cannot prove what was sent.
- **Tools or images fail on an otherwise working model.**
  - If the capability was never verified or the translator lacks support, then remove the capability claim or switch to a supported protocol/model; do not assume text support implies full modality support.

## Guardrails

- DO NOT copy `~/.codex/auth.json` or another CLI's credential store into the proxy's auth directory.
- DO NOT treat the upstream response's `service_tier` as proof that Fast or Ultrafast was applied.
- DO NOT hardcode model IDs, context windows, or tier support; discover them from the running build and account.
- DO NOT write host-specific values, client keys, tokens, or account identifiers into the skill or its examples.
- DO NOT claim a tier is guaranteed; upstream entitlement, quota, and routing determine the effective service.
- DO NOT expose the proxy without client authentication and a trusted network boundary.
