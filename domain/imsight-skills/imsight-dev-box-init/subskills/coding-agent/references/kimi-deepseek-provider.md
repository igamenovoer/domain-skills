# Kimi Code DeepSeek Provider Setup

Use this reference when the user wants to add DeepSeek's official OpenAI-compatible API (`https://api.deepseek.com`) to Kimi Code CLI as a provider authenticated with a DeepSeek API key, including `deepseek-flash` and selectable thinking effort. Model ids and metadata change; re-resolve them under **Model Selection** instead of copying this page forward.

## Workflow

1. Resolve the target Kimi Code home, provider name, credential source, and requested model set under **Target Home and Naming**, **Credential Placement**, and **Model Selection**.
2. Complete **Compatibility Preflight** without writing configuration; stop when the installed CLI does not expose the required provider type or model effort fields.
3. Resolve each id and its window, output limit, input modalities, and effort levels from the official DeepSeek catalog under **Model Selection**.
4. Back up the target `config.toml` when it is not under version control, then merge the provider and model entries from **Provider and Model Contract** without replacing unrelated tables.
5. Add the thinking-effort fields and choose the effective default under **Thinking Effort Contract**; `deepseek-flash` defaults to `max` in this project.
6. Validate the file and run real end-to-end turns with the installed `kimi` binary under **Verification**; do not substitute a raw HTTP probe for the CLI result.
7. Report the changed configuration path, model aliases, catalog source and date, credential form, context and output limits, effort defaults, skipped ids, and any provider-side limitation.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's contracts, the installed CLI, the official catalog, and the user's constraints, then execute the plan without exposing the key.

## Target Home and Naming

- **Home**: use the user's explicit `KIMI_CODE_HOME`, or `~/.kimi-code` for the default home. When targeting an isolated launcher home such as `~/kimi-homes/kimi-<suffix>`, apply the same `KIMI_CODE_HOME` to every edit and verification command.
- **Provider name**: prefer `deepseek`, matching the provider name used by the project's Kimi Code setup. Keep it distinct from launcher-specific provider names so the official route can coexist with relay routes.
- **Model alias**: prefer `deepseek/<model-id>`, for example `deepseek/deepseek-flash`. The alias is the name used by `-m`, `default_model`, and `/model`; it does not have to match the upstream id.
- **Default model**: leave the existing `default_model` unchanged unless the user explicitly asks to switch it. Select the new model with `-m` or `/model`.

## Model Selection

DeepSeek model ids and metadata change. Never seed the inventory from this page or a previous profile.

Apply this decision order:

1. **The user names specific model ids** — add exactly those ids, one alias each. Do not add other models.
2. **The user asks for the provider but names no models** — stop and ask which ids to add.

Resolve each id against the official catalog before writing any model entry:

```bash
curl -sS -H "Authorization: Bearer $DEEPSEEK_API_KEY" https://api.deepseek.com/models
```

- Populate `DEEPSEEK_API_KEY` from the user's designated credential source without printing it or passing the value as a command argument.
- Each entry carries `context_window`, `max_output_tokens`, `input_modalities`, and `effort.supported_levels` / `effort.default_level`. Use those fields rather than a family assumption.
- A missing id fails the turn with `model_not_found`. Report it as unavailable instead of retrying with another name.

Observed on 2026-10-23: `deepseek-flash` reports `context_window = 1048576`, `max_output_tokens = 393216`, `input_modalities = ["text", "image"]`, and effort levels `low`, `high`, `max` with catalog default `high`. `deepseek-v4-pro` reports the same window and effort levels but text-only input. Re-query rather than relying on this observation.

## Compatibility Preflight

Run these checks read-only before editing anything:

```bash
kimi --version
kimi --help
config_path="${KIMI_CODE_HOME:-$HOME/.kimi-code}/config.toml"
kimi doctor config "$config_path"
rg -n '^\[providers\.|^\[models\.|^default_model' "$config_path"
```

Confirm the installed version and current documentation still expose `type = "openai"`, `support_efforts`, and `default_effort`:

- Provider types: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/providers.html`
- Config fields: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/config-files.html`

Stop without writing when the provider type or effort fields are absent, when the target provider or model alias already exists with different content, or when the proposed home collides with another launcher. `kimi doctor config` validates TOML syntax and known schema shape; it does not prove that the provider type is recognized or that the endpoint will answer, so it is only one part of the gate.

## Credential Placement

The requested form is an API key in the provider entry:

- **Inline local key (requested form)**: set `api_key = "<DEEPSEEK_API_KEY>"` in the user's local `config.toml`, keep that file at mode `0600`, and never place the key in a repository, skill source, generated document, command transcript, or log.
- **Environment variable (alternative)**: set `api_key_env = "DEEPSEEK_API_KEY"` instead. The variable is read at request time and must exist in the actual launch environment.

Kimi Code does not fall back to shell environment variables for provider credentials unless `api_key_env` names the variable explicitly. An unset variable fails the request with an error naming it. Set exactly one of `api_key` and `api_key_env`.

## Provider and Model Contract

Merge these entries under the target config's existing tables. The id below is the requested example; replace or extend it according to **Model Selection**.

```toml
[providers.deepseek]
type = "openai"
base_url = "https://api.deepseek.com"
api_key = "<DEEPSEEK_API_KEY>"

[models."deepseek/deepseek-flash"]
provider = "deepseek"
model = "deepseek-flash"
max_context_size = 1048576
max_output_size = 393216
capabilities = [ "thinking", "image_in", "tool_use" ]
support_efforts = [ "low", "high", "max" ]
default_effort = "max"
reasoning_key = "reasoning_content"
display_name = "DeepSeek V4.1 Flash (official API)"
```

Known model defaults (recorded 2026-10-23; re-check before relying on them):

| Upstream id | `max_context_size` | `max_output_size` | Input | `support_efforts` | `default_effort` |
| --- | --- | --- | --- | --- | --- |
| `deepseek-flash` | `1048576` | `393216` | text, image | `low`, `high`, `max` | `max` (project default; catalog default `high`) |

The catalog publishes these values directly. The `default_effort = "max"` choice is this project's override for `deepseek-flash`; the catalog's own default is `high`.

Field rules:

- `base_url` uses the official host without a trailing slash. The OpenAI-protocol client appends `/chat/completions`; `https://api.deepseek.com` and `https://api.deepseek.com/v1` both resolve, but never produce a doubled `/v1/v1`.
- `type = "openai"` selects Chat Completions and injects `reasoning_effort` for a model that declares thinking support.
- `model` is the upstream id; the alias is local. Keep the alias stable when the upstream id changes so `-m` and session references keep working.
- `max_context_size` and `max_output_size` come from the catalog's `context_window` and `max_output_tokens`. Current Kimi Code documentation says only the `anthropic` provider reads `max_output_size`; record it for parity but do not rely on it to cap output through this provider.
- `capabilities` should include `"thinking"` and `"tool_use"`. Add `"image_in"` only when `input_modalities` includes `image` and a real image turn succeeds; `deepseek-flash` declares image input, while `deepseek-v4-pro` does not.
- `support_efforts` is the catalog's `effort.supported_levels` restricted to the Kimi Code vocabulary `low`, `medium`, `high`, `xhigh`, `max`. For `deepseek-flash` that is `low`, `high`, `max`.
- `default_effort` should honor the user's requested level; otherwise use the recorded project default in **Known model defaults**, then the catalog's `effort.default_level`.
- `reasoning_key = "reasoning_content"` matches the official DeepSeek Chat Completions response, which returns reasoning text under `reasoning_content`; verify the field on a real turn instead of assuming it.

## Thinking Effort Contract

Kimi Code exposes a model's effort levels through `support_efforts` and chooses a default through `default_effort`:

- `support_efforts` lists the levels the model accepts. Keep it aligned with the levels the installed client can send; an out-of-list value can fail.
- `default_effort` supplies the model-level default. Set it from the user's request, then the recorded default in **Known model defaults**, then the catalog's `effort.default_level`.
- The global `[thinking]` table can also set `effort` for the main agent. A global concrete effort can override the model default, so check the session's effective effort when strict model-level behavior matters.
- In the TUI, `/effort` (alias `/thinking`) opens the thinking-effort selector, and `/model` exposes the model and its thinking choices during model selection. Use `-m deepseek/<model-id>` for non-interactive selection.

Configuring `support_efforts` is necessary but not sufficient proof: the installed client must also send the concrete level. Prefer the target CLI's own observability for that check. Confirm the session's recorded `thinkingEffort` and, when the provider reports them, reasoning-token counts.

Observed on 2026-10-23 with the official DeepSeek route: `deepseek-flash` accepted `reasoning_effort: "max"` over Chat Completions, returned `reasoning_content`, and reported `reasoning_tokens` in usage. Re-verify the accepted levels and visibility behavior against the current endpoint and CLI rather than relying on this observation.

## Verification

Run the checks against the same home and credential source that the user will launch:

```bash
config_path="${KIMI_CODE_HOME:-$HOME/.kimi-code}/config.toml"
kimi doctor config "$config_path"
kimi provider list
kimi -p "Reply with exactly: DEEPSEEK_OK" --model deepseek/deepseek-flash
kimi -p "Use the Bash tool to run exactly: printf TOOL_OK. Then reply with the command output only." --model deepseek/deepseek-flash
```

Require the markers in the final answers and a successful tool result. For an isolated home, prefix each command with `KIMI_CODE_HOME="$HOME/kimi-homes/kimi-<suffix>"` or export it for the whole check.

Also confirm:

- `kimi provider list` shows the provider and the expected model count.
- The new alias appears in `/model` and exposes `low`, `high`, and `max`.
- The session log records the intended `thinkingEffort`; a footer label change alone is not proof.
- The previous `default_model` and unrelated provider/model tables are unchanged.
- No key appears in the shell history, process arguments, logs, or the final report.

A raw `curl` success against `/chat/completions` is useful diagnostic evidence, but it is not the compatibility gate. The installed `kimi` binary must complete a real turn with the persisted config.

## Troubleshooting

- **`401 Authentication Fails`**: the key is missing or invalid. With `api_key_env`, the named variable is unset in the launch environment; Kimi Code does not read ambient shell variables without it.
- **`402 Insufficient Balance`**: the account cannot pay for the request. Do not retry; report the account state.
- **`404` or `model_not_found`**: the id is wrong or not served to this key. Re-query `/models` and use the catalog id.
- **`Model "..." must declare a wire protocol`**: the provider `type` was not recognized. Use `openai`.
- **`Model "..." must define a positive max_context_size`**: add a positive `max_context_size` to the model entry.
- **404 or a doubled `/v1/v1` path**: `base_url` is wrong. This provider accepts `https://api.deepseek.com`; never append another `/v1`.
- **No effort picker**: add `support_efforts` and `default_effort`; a `thinking` capability alone exposes thinking mode but not a level list.
- **No reasoning text**: DeepSeek returns it under `reasoning_content` on Chat Completions. Confirm `reasoning_key` and the installed client's session log before concluding the setting was ignored.

## Guardrails

- DO NOT print, commit, or expose the DeepSeek key in skill sources, documentation, logs, command arguments, or reports.
- DO NOT add models the user did not request.
- DO NOT treat this page's ids, windows, or effort levels as current; re-query the official catalog.
- DO NOT change `default_model` or unrelated provider and model tables unless the user explicitly requests it.
- DO NOT append a second `/v1` to the official base URL.
- DO NOT claim that `max_output_size` enforces an output cap through the `openai` provider.
- DO NOT treat `kimi doctor config`, `kimi provider list`, or a raw provider API probe as proof that the Kimi Code route works without a real turn.
