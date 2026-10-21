# Kimi Code OpenLux Gemini Provider Setup

Use this reference when the user wants to add OpenLux's Gemini-native endpoint to Kimi Code CLI as a provider and model, including a selectable thinking effort level, while preserving the existing default Kimi Code route and any unrelated provider configuration.

## Workflow

1. Resolve the target Kimi Code home, provider name, model alias, and credential source under **Target Home and Naming** and **Credential Placement**.
2. Complete **Compatibility Preflight** without writing configuration; stop when the installed CLI does not expose the required provider type or model effort fields.
3. Back up the target `config.toml` when it is not under version control, then merge the provider and model entries from **Provider and Model Contract** without replacing unrelated tables.
4. Add the thinking-effort fields and choose the effective default under **Thinking Effort Contract**.
5. Validate the file and run real end-to-end turns with the installed `kimi` binary under **Verification**; do not substitute a raw HTTP probe for the CLI result.
6. Report the changed configuration path, model alias, credential source, effort default, and any provider-side limitation.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's contracts, the installed CLI, and the user's constraints, then execute the plan without exposing the key.

## Target Home and Naming

- **Home**: use the user's explicit `KIMI_CODE_HOME`, or `~/.kimi-code` for the default home. When targeting an isolated launcher home such as `~/kimi-homes/kimi-<suffix>`, apply the same `KIMI_CODE_HOME` to every edit and verification command.
- **Provider name**: prefer `openlux-gemini`. Keep it distinct from an existing `openlux` provider that uses the OpenAI-compatible `https://api.openlux.ai/v1` route, so the two protocols can coexist.
- **Model alias**: prefer `openlux-gemini/gemini-4-argon`. The alias is the name used by `-m`, `default_model`, and `/model`; it does not have to match the upstream model id.
- **Default model**: leave the existing `default_model` unchanged unless the user explicitly asks to switch it. Select the new model with `-m` or `/model`.

## Compatibility Preflight

Run these checks read-only before editing anything:

```bash
kimi --version
kimi --help
config_path="${KIMI_CODE_HOME:-$HOME/.kimi-code}/config.toml"
kimi doctor config "$config_path"
rg -n '^\[providers\.|^\[models\.|^default_model' "$config_path"
```

Confirm the installed version and current documentation still expose `type = "google-genai"`, `support_efforts`, and `default_effort`:

- Provider types: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/providers.html`
- Config fields: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/config-files.html`

Stop without writing when the provider type or effort fields are absent, when the target provider or model alias already exists with different content, or when the proposed home collides with another launcher. `kimi doctor config` validates TOML syntax and known schema shape; it does not prove that the provider type is recognized or that the endpoint will answer, so it is only one part of the gate.

## Credential Placement

Choose exactly one credential form for the provider:

- **Environment variable (preferred)**: set `api_key_env = "OPENLUX_API_KEY"` in the provider table. The variable is read at request time and must exist in the actual launch environment. If a `kimi-<suffix>` launcher does not already export it, add an export from the side key file before `exec kimi`, without printing it:

```bash
export OPENLUX_API_KEY="$(tr -d '[:space:]' < "$HOME/.local/bin/openlux-api-key-<suffix>")"
```

- **Inline local key**: use `api_key = "<OPENLUX_API_KEY>"` only in the user's local `config.toml`, keep that file at mode `0600`, and never place the key in a repository, skill source, generated document, command transcript, or log.
- **Existing side key file**: the OpenLux launcher family already stores keys under `$HOME/.local/bin/openlux-api-key-<suffix>` at mode `0600`. Read that file at launch or copy the value into the local config; do not commit or redistribute it.

Kimi Code does not fall back to shell environment variables for provider credentials unless `api_key_env` names the variable explicitly. An unset variable fails the request with an error naming it.

## Provider and Model Contract

Merge these entries under the target config's existing tables:

```toml
[providers.openlux-gemini]
type = "google-genai"
base_url = "https://api.openlux.ai"
api_key_env = "OPENLUX_API_KEY"

[models."openlux-gemini/gemini-4-argon"]
provider = "openlux-gemini"
model = "gemini-4-argon"
max_context_size = 1048576
capabilities = [ "thinking", "tool_use" ]
support_efforts = [ "low", "medium", "high" ]
default_effort = "high"
display_name = "Gemini 4 Argon (OpenLux Gemini API)"
```

Field rules:

- `base_url` is the host root only. The Google GenAI SDK appends the API version and model path itself; a trailing `/v1beta` produces `/v1beta/v1beta/...` and fails. Do not use the OpenAI-compatible `/v1` URL for this provider.
- `model = "gemini-4-argon"` is the OpenLux model id observed in its Gemini-native catalog. The catalog reports a 1,048,576-token input limit; set `max_context_size` from the actual model metadata rather than copying another model's window.
- `max_output_size` is optional. Current Kimi Code documentation says the field is only read by the `anthropic` provider, so do not rely on it to cap Gemini output; the endpoint's own output limit still applies.
- `capabilities` should include `"thinking"` and `"tool_use"` when those behaviors have been verified. Add `"image_in"` or `"video_in"` only after the provider accepts the corresponding content in a real Kimi Code turn; the OpenLux catalog does not declare per-model modalities.
- Use a distinct provider name when an OpenAI-compatible `openlux` provider already exists. Do not rewrite the existing provider or its model aliases to point at the new protocol.

## Thinking Effort Contract

Kimi Code exposes a model's effort levels through `support_efforts` and chooses a default through `default_effort`:

- `support_efforts` lists the levels the model accepts. Keep it aligned with the levels the installed client can send; an explicit effort outside the list can fail, and the installed client resolves a global value that is outside the list according to its own mapping.
- `default_effort` supplies the model-level default. Set it to `"high"` for `gemini-4-argon` because that is the level that reliably produced reasoning in tests.
- The global `[thinking]` table can also set `effort` for the main agent. On Kimi Code 2.3.0, a global concrete effort is recorded and, for `gemini-3`/`gemini-4` ids, mapped to native `thinkingLevel`; older 2.2.x builds mapped `gemini-4` ids to `thinkingBudget`. Other global values can override the model default, so check the session's effective effort when strict high behavior matters.
- In the TUI, `/effort` (alias `/thinking`) opens the thinking-effort selector; `/model` exposes the model and its thinking choices during model selection. Use `-m openlux-gemini/gemini-4-argon` for non-interactive selection.

The installed Kimi Code Gemini adapter selects the wire field by model id and version:

| Model id pattern | Wire field for effort |
| --- | --- |
| contains `gemini-3` or `gemini-4` | `thinkingLevel`: low `LOW`, medium `MEDIUM`, high/xhigh/max `HIGH`; off `MINIMAL` for `gemini-3` and rejected for `gemini-4` |
| other Gemini ids | `thinkingBudget`: off `0`, low `1024`, medium `4096`, high/xhigh/max `32000` |

For `gemini-4`, `off` is rejected because the model always reasons; use a concrete `low`, `medium`, or `high`.

Observed on Kimi Code 2.3.0: the adapter maps `gemini-4` ids to native `thinkingLevel`; a live low-versus-high comparison on a Gemini 4 Argon route produced different thought-token usage, and high returned thought parts plus `thoughtsTokenCount`. On Kimi Code 2.2.0 the same id mapped to `thinkingBudget` instead, with high using a 32,000-token budget. The adapter mapping is version-dependent, so re-verify it against the installed `kimi` binary rather than relying on a tutorial written for another release.

Configuring `support_efforts` is necessary but not sufficient proof: the installed client must also send the concrete level. Verify with a real turn and inspect the session's recorded `thinkingEffort`; a UI label alone is not evidence.

## Verification

Run the checks against the same home and credential source that the user will launch:

```bash
config_path="${KIMI_CODE_HOME:-$HOME/.kimi-code}/config.toml"
kimi doctor config "$config_path"
kimi -p "Reply with exactly: OPENLUX_OK" --model openlux-gemini/gemini-4-argon
kimi -p "Use the Bash tool to run exactly: printf TOOL_OK. Then reply with the command output only." --model openlux-gemini/gemini-4-argon
```

Require both markers in the final answers. For an isolated home, prefix each command with `KIMI_CODE_HOME="$HOME/kimi-homes/kimi-<suffix>"` or export it for the whole check.

Also confirm:

- `test -n "${OPENLUX_API_KEY:-}"` succeeds when `api_key_env` is used, without printing the value.
- The new alias appears in `/model` and exposes the expected effort choices.
- For thinking-level claims, confirm the session log records the intended `thinkingEffort` and compare thought-token usage on a reasoning prompt between two levels; `/effort` changing the footer alone is not proof.
- The previous `default_model` and unrelated provider/model tables are unchanged.
- No key appears in the shell history, process arguments, logs, or the final report.

A raw `curl` success against `/v1beta/...` is useful diagnostic evidence, but it is not the compatibility gate. The installed `kimi` binary must complete a real turn with the persisted config.

## Troubleshooting

- **`Model "..." must declare a wire protocol`**: the provider `type` was not recognized. Use `google-genai`, not the archived `gemini` type.
- **`Model "..." must define a positive max_context_size`**: add a positive `max_context_size` to the model entry.
- **401 or 403**: the key is missing, the `api_key_env` variable is unset in the launch environment, or the key is not valid for OpenLux's Gemini-native route. Kimi Code does not silently read a shell variable unless `api_key_env` names it.
- **404 or a doubled `/v1beta/v1beta` path**: `base_url` includes an API-version suffix. Use `https://api.openlux.ai`.
- **No thinking output**: try effort `high`, then confirm the installed Kimi Code version maps the model id to the intended wire field. On 2.3.0, `gemini-3`/`gemini-4` use native `thinkingLevel`; older 2.2.x used `thinkingBudget` for `gemini-4`. The endpoint also decides whether a prompt needs reasoning, so compare a reasoning-heavy prompt and the session's recorded `thinkingEffort`.
- **No effort picker**: add `support_efforts` and `default_effort` to the model entry; a `thinking` capability alone exposes thinking mode but not a level list.
- **The old OpenAI-compatible route is used**: check the model entry's `provider` field. The `/v1` route belongs to an OpenAI-compatible provider, not the `google-genai` provider.

## Guardrails

- DO NOT print, commit, or expose the OpenLux key in skill sources, documentation, logs, command arguments, or reports.
- DO NOT change `default_model` or unrelated provider and model tables unless the user explicitly requests it.
- DO NOT append `/v1beta` or a model path to `base_url`; give the host root only.
- DO NOT assume the Kimi Code adapter mapping is version-independent; verify the installed build (2.3.0+ sends native `thinkingLevel` for `gemini-3`/`gemini-4`, while older 2.2.x used `thinkingBudget` for `gemini-4`).
- DO NOT treat `kimi doctor config` alone, or a raw provider API probe, as proof that the Kimi Code route works.
- DO NOT overwrite an existing provider or model alias; merge the new tables or choose a distinct name.
