# Kimi Code Client Wiring for a Gemini-Compatible Proxy

Use this reference after the proxy exposes a working Gemini endpoint. It configures Kimi Code CLI as a downstream client and enables a selectable thinking level for Gemini 3/4 models.

## Preflight

```bash
kimi --version
config_path="${KIMI_CODE_HOME:-$HOME/.kimi-code}/config.toml"
kimi doctor config "$config_path"
```

Confirm the installed build supports `type = "google-genai"`, `support_efforts`, and `default_effort` against the current Kimi Code docs:

- Providers: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/providers.html`
- Config fields: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/config-files.html`

## Provider and Model Contract

```toml
[providers.local-gemini]
type = "google-genai"
base_url = "http://<proxy-host>:<api-port>"
api_key = "<client-key>"

[models."local-gemini/<model-id>"]
provider = "local-gemini"
model = "<model-id>"
max_context_size = <context-size>
capabilities = [ "thinking", "image_in", "video_in", "audio_in", "tool_use" ]
support_efforts = [ "low", "medium", "high" ]
default_effort = "high"
display_name = "<display-name>"
```

Field rules:

- `base_url` is the host root only, for example `http://127.0.0.1:<api-port>`. The Google GenAI SDK appends `/v1beta` and the model path; a trailing `/v1beta` produces a doubled path and fails.
- `api_key` is the proxy's downstream client key, not the upstream provider key. Use `api_key_env = "<ENV_VAR>"` instead when the key comes from the launch environment; the variable must exist in the environment that starts `kimi`.
- `max_context_size` is required and must be positive. Take it from the proxy's model metadata or a conservative model-specific value; do not copy another model's window blindly.
- `capabilities` declares behavior the endpoint actually supports. Add `image_in`, `video_in`, or `audio_in` only after a real Kimi Code turn with that content succeeds.
- Use a distinct provider name such as `local-gemini` when an existing provider already points at another Gemini-compatible endpoint.
- Keep unrelated providers, models, and the existing `default_model` unchanged unless the user asks to switch.

## Thinking Effort Contract

- `capabilities = [ "thinking", ... ]` says the model can think. It does **not** create an effort selector.
- `support_efforts` is what enables the Low/Medium/High picker. List only levels the model accepts and include any global `[thinking].effort` value.
- `default_effort` sets the model-level default and should be a member of `support_efforts`.
- The global `[thinking]` table can override the model default for the main agent. Keep `[thinking].effort` inside every model's `support_efforts` list.

Kimi Code 2.3.0 selects the wire field by model id:

| Model id pattern | low | medium | high / xhigh / max | off |
| --- | --- | --- | --- | --- |
| contains `gemini-3` or `gemini-4` | `thinkingLevel: "LOW"` | `thinkingLevel: "MEDIUM"` | `thinkingLevel: "HIGH"` | `"MINIMAL"` for `gemini-3`; rejected for `gemini-4` |
| other Gemini ids | `thinkingBudget: 1024` | `thinkingBudget: 4096` | `thinkingBudget: 32000` | `thinkingBudget: 0` |

Kimi Code 2.2.x used `thinkingBudget` for `gemini-4` ids. Verify the installed build instead of assuming a tutorial's mapping still applies.

Gemini 4 models always reason, so `off` is invalid; choose `low`, `medium`, or `high`. A model id ending in `-high` sets a default tier, but an explicit request-level level overrides it in the proxy. A live comparison on a `gemini-4-*-high` endpoint showed low producing no thought tokens while high produced hundreds for the same small prompt; exact counts vary by prompt and account.

## Selecting and Applying

- After editing `config.toml`, run `/reload` in an idle TUI. A new session also picks up the change.
- `/effort` (alias `/thinking`) opens the thinking-effort selector. `/model` also exposes the model and its thinking choices during model selection.
- `Off` is not available for Gemini 4; select Low, Medium, or High.
- For non-interactive selection, use `kimi -m local-gemini/<model-id> -p "<prompt>"`.

## Verification

1. Run a real turn and confirm it succeeds:

   ```bash
   kimi -m "local-gemini/<model-id>" -p "Reply with exactly: CLIENT_OK"
   ```

2. Confirm the session recorded the intended effort. Recent builds write an `llm config` or `llm request` event with `thinkingEffort=<level>` in the session's `agents/main/wire.jsonl` or `logs/kimi-code.log`.

3. Confirm the level changes upstream reasoning, not only the footer. Compare two direct proxy calls with different `thinkingConfig.thinkingLevel` values and inspect `usageMetadata.thoughtsTokenCount`, or compare two Kimi Code turns with the same prompt at low and high. A UI label alone is not proof.

4. Check the failure paths: no client key returns 401, an unknown model returns 404, and a `base_url` ending in `/v1beta` produces a doubled path.

Recent CLI builds may include a Kimi Code session log with provider, model, and `thinkingEffort` for each request. Use it to confirm the client-side selection; use the proxy's thought-token response to confirm the upstream effect.

## Troubleshooting

- **No effort picker**: add `support_efforts` and `default_effort` to the model entry, then run `/reload`. A `thinking` capability alone is not enough.
- **`Off` is rejected for Gemini 4**: the model always reasons. Choose `low`, `medium`, or `high`.
- **Effort outside the supported list**: an explicit level not listed in `support_efforts` can fail. Keep the global and per-session values inside the list.
- **Compaction at a large context stalls or times out**: when `max_context_size` is configured near the model limit (for example `1048576`), Kimi Code's `full_compaction` re-sends the whole conversation to the same model. On Gemini 4 with `default_effort = "high"`, the summary can take several minutes; one observed request took 5m28s and the client cancelled at 5m22s. Lower `max_context_size` (for example `800000`) so compaction starts earlier, and lower the compaction effort if the client exposes it. Current Kimi Code documentation says `max_output_size` is only read by the `anthropic` provider, so do not rely on it to cap the summary for a `google-genai` provider.
- **Doubled `/v1beta/v1beta` or 404**: `base_url` includes the API version. Use the host root only.
- **401 from the proxy**: the model uses the upstream provider key instead of the downstream proxy client key. Put the upstream key in the proxy configuration, not the client provider.
- **Level seems ignored**: check the installed Kimi Code version's adapter mapping, the session's recorded `thinkingEffort`, and whether the proxy forwards `thinkingConfig`. A `-high` model suffix is a default tier, not proof that the request level was dropped.
- **No thought tokens at low**: some prompts need little or no reasoning, and some models suppress thought output. Compare with a reasoning-heavy prompt and a high-effort call before concluding the setting is broken.

## Guardrails

- DO NOT claim the thinking-level picker works from the footer or selector alone; confirm the recorded request and a real turn.
- DO NOT append `/v1beta` or a model path to `base_url`; give the host root only.
- DO NOT put client keys or upstream tokens in skill sources, examples, logs, or commits.
- DO NOT assume the Kimi Code adapter mapping is version-independent; verify the installed build.
- DO NOT list an effort in `support_efforts` that the endpoint cannot accept.
