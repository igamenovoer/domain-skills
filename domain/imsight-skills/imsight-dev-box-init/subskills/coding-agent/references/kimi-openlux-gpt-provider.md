# Kimi Code OpenLux GPT Provider Setup

Use this reference when the user wants to add OpenLux's OpenAI-compatible (`https://api.openlux.ai/v1`) route to Kimi Code CLI as a provider with GPT models and selectable thinking effort, while preserving the existing default Kimi Code route and unrelated provider configuration. Model ids in this catalog change frequently: treat every id in this page as an example that must be re-resolved under **Model Selection** rather than copied forward.

## Workflow

1. Resolve the target Kimi Code home, provider name, credential source, and requested model set under **Target Home and Naming**, **Credential Placement**, and **Model Selection**.
2. Complete **Compatibility Preflight** without writing configuration; stop when the installed CLI does not expose the required provider type or model effort fields.
3. Resolve the model inventory under **Model Selection**: add the user's explicit ids, or run discovery only when the user explicitly asks for the Codex-supported set.
4. Back up the target `config.toml` when it is not under version control, then merge the provider and model entries from **Provider and Model Contract** without replacing unrelated tables; set each `max_context_size` from **Known model defaults** when the id is listed, otherwise from resolved provider metadata and record the assumption.
5. Add the thinking-effort fields and choose the effective default under **Thinking Effort Contract**.
6. Validate the file and run real end-to-end turns with the installed `kimi` binary under **Verification**; do not substitute a raw HTTP probe for the CLI result.
7. Report the changed configuration path, model aliases, discovery source and date, credential source, context-window source, effort defaults, skipped ids, and any provider-side limitation.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's contracts, the installed CLI, the discovery sources, and the user's constraints, then execute the plan without exposing the key.

## Target Home and Naming

- **Home**: use the user's explicit `KIMI_CODE_HOME`, or `~/.kimi-code` for the default home. When targeting an isolated launcher home such as `~/kimi-homes/kimi-<suffix>`, apply the same `KIMI_CODE_HOME` to every edit and verification command.
- **Provider name**: prefer `openlux-gpt`. Keep it distinct from `openlux-gemini`, which uses the Gemini-native `https://api.openlux.ai` route, and from any older `openlux` OpenAI-compatible provider, so the protocols can coexist.
- **Model alias**: prefer `openlux-gpt/<model-id>`, for example `openlux-gpt/gpt-6-astra`. The alias is the name used by `-m`, `default_model`, and `/model`; it does not have to match the upstream id. Quote the TOML key when the alias contains a dot: `[models."openlux-gpt/gpt-6.1-sol"]`.
- **Default model**: leave the existing `default_model` unchanged unless the user explicitly asks to switch it. Select the new model with `-m` or `/model`.

## Model Selection

Codex model ids, their supported reasoning levels, and their availability on OpenLux all change quickly. Never seed the inventory from this page, from a previously configured profile, or from a model list embedded in an older launcher.

Apply this decision order:

1. **The user names specific model ids** — add exactly those ids, one alias each. Do not add other models.
2. **The user explicitly requests every Codex-supported model** — discover the current set, then add every discovered id that the target key can serve:
   - **Local installed Codex first**, when present: run `codex --version`, then read the model catalog cache at `${CODEX_HOME:-$HOME/.codex}/models_cache.json`. Check its `fetched_at` and `client_version`; the candidate ids are `models[].slug`, and entries with `visibility = "list"` and `supported_in_api = true` are the advertised set. The interactive `/model` picker and `codex doctor` confirm what the installed build offers, but the cache is the machine-readable source.
   - **OpenAI's current model documentation** when local Codex is absent or its cache is stale.
   - **The `openai/codex` GitHub source and release notes** when the installed build or documentation lags a newly shipped model.
   - Record which source supplied the list and the resolution date in the final report.
3. **The user asks for the provider but names no models** — stop and ask which ids to add. Do not silently expand the request into the full Codex set.

Resolve availability against the target key before writing any model entry:

- Query the key's catalog with `curl -s -H "Authorization: Bearer $OPENLUX_API_KEY" https://api.openlux.ai/v1/models`, populating that variable from the user's designated credential source without printing it or passing the value as a command argument. Each entry carries `supported_endpoint_types` and catalog metadata; the catalog is scoped to the key's token and group.
- Add an id to this `type = "openai"` provider only when its endpoint list contains `openai`. Ids that expose only `openai-response` — several Codex ids do — require a separate `type = "openai_responses"` provider on the same `/v1` base URL; name it distinctly, for example `openlux-gpt-responses` with aliases `openlux-gpt-responses/<model-id>`, or report the id as skipped instead of forcing it into this one.
- An id can be missing for a particular key even when OpenLux serves it for another key. A request then fails with `model_not_found` and a `No available channel for this model on the current token` message. Report those ids as unavailable rather than retrying with another model name.

## Compatibility Preflight

Run these checks read-only before editing anything:

```bash
kimi --version
kimi --help
config_path="${KIMI_CODE_HOME:-$HOME/.kimi-code}/config.toml"
kimi doctor config "$config_path"
rg -n '^\[providers\.|^\[models\.|^default_model' "$config_path"
```

Confirm the installed version and current documentation still expose `type = "openai"` or `openai_responses`, `support_efforts`, and `default_effort`:

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
- **Existing OpenLux credential source**: the OpenLux launcher family may store the key in a side file such as `$HOME/.local/bin/openlux-api-key-<suffix>` at mode `0600`, and some launchers embed it directly. Read a launcher or side file only when the user designates it as the source, and never reproduce the value in skill sources, reports, or logs.

Kimi Code does not fall back to shell environment variables for provider credentials unless `api_key_env` names the variable explicitly. An unset variable fails the request with an error naming it.

## Provider and Model Contract

Merge these entries under the target config's existing tables. The two ids below are examples of the requested shape; replace or extend them according to **Model Selection**.

```toml
[providers.openlux-gpt]
type = "openai"
base_url = "https://api.openlux.ai/v1"
api_key_env = "OPENLUX_API_KEY"

[models."openlux-gpt/gpt-6.1-sol"]
provider = "openlux-gpt"
model = "gpt-6.1-sol"
max_context_size = 500000
capabilities = [ "thinking", "tool_use" ]
support_efforts = [ "low", "medium", "high", "xhigh", "max" ]
default_effort = "xhigh"
display_name = "GPT-6.1 Sol (OpenLux)"

[models."openlux-gpt/gpt-6-astra"]
provider = "openlux-gpt"
model = "gpt-6-astra"
max_context_size = 372000
capabilities = [ "thinking", "tool_use" ]
support_efforts = [ "low", "medium", "high", "xhigh", "max" ]
default_effort = "xhigh"
display_name = "GPT-6 Astra (OpenLux)"
```

Known model defaults (recorded 2026-10-23; re-check before relying on them):

| Upstream id | `max_context_size` | `default_effort` |
| --- | --- | --- |
| `gpt-6.1-sol` | `500000` | `xhigh` |
| `gpt-6-astra` | `372000` | `xhigh` |

These are the project's recorded serving defaults, not catalog fields: the OpenLux `/v1/models` response lists both ids but publishes no numeric context window for either. The default thinking level for both ids is `xhigh`. `gpt-6-astra` is the only Astra id in the current catalog; do not invent a `gpt-6.1-astra` id or alias from the product name.

Field rules:

- `base_url` must end in `/v1` for this provider. The OpenAI-protocol client appends `/chat/completions` or `/responses`, so the Gemini-native host root, or a doubled `/v1/v1`, produces the wrong path. Do not share one provider entry across the two protocols.
- `type = "openai"` selects Chat Completions and injects `reasoning_effort` for a model that declares thinking support. `type = "openai_responses"` is a separate protocol for ids that only advertise `openai-response`; use a separately named provider rather than mixing endpoint types under one name.
- `model` is the upstream id; the alias is local. Keep the alias stable when the upstream id changes so `-m` and session references keep working.
- `max_context_size` must be a positive window you can justify. Use the recorded default from **Known model defaults** when the id is listed there. For any other id, take the value from provider metadata or OpenAI's model documentation; when the exact window is unpublished, use the family window and record that assumption. Re-check instead of copying: ids, aliases, and served windows change.
- `capabilities` should include `"thinking"` and `"tool_use"` after those behaviors have been verified with the installed client. Add `"image_in"` only when the catalog declares vision for that id and a real image turn succeeds.
- `support_efforts` must be the intersection of the id's discovered reasoning levels and the levels Kimi Code can select: `low`, `medium`, `high`, `xhigh`, `max`. Codex's catalog also advertises `ultra`, which the Kimi Code effort vocabulary cannot select; drop it and report the gap.
- `default_effort` should honor the user's requested level; otherwise use the recorded default from **Known model defaults** when the id is listed there, then the id's discovered Codex default restricted to `support_efforts`, then fall back to `high`.
- Do not set `reasoning_key` speculatively. Set it only when the gateway returns reasoning content under a non-standard field name; the tested OpenLux build returned no reasoning content at all.

## Thinking Effort Contract

Kimi Code exposes a model's effort levels through `support_efforts` and chooses a default through `default_effort`:

- `support_efforts` lists the levels the model accepts. Keep it aligned with the levels the installed client can send; an out-of-list value can fail, and the installed client resolves a global value that is outside the list according to its own mapping.
- `default_effort` supplies the model-level default. Set it from the user's request, then the recorded default in **Known model defaults** when the id is listed there, then the discovered Codex default rather than from a memorized value.
- The global `[thinking]` table can also set `effort` for the main agent. A global concrete effort can override the model default, so check the session's effective effort when strict model-level behavior matters.
- In the TUI, `/effort` (alias `/thinking`) opens the thinking-effort selector, and `/model` exposes the model and its thinking choices during model selection. Use `-m openlux-gpt/<model-id>` for non-interactive selection.

Configuring `support_efforts` is necessary but not sufficient proof: the installed client must also send the concrete level. Prefer the target CLI's own observability for that check. The OpenAI-protocol adapter injects `reasoning_effort`; a gateway may accept the parameter without returning reasoning text, so confirm the session's recorded `thinkingEffort` and, when the gateway reports them, reasoning-token counts.

Observed on 2026-10-22 with Kimi Code 2.3.0 and the OpenLux OpenAI-compatible route: both `gpt-6-astra` and `gpt-6.1-sol` accepted `reasoning_effort` at `low`, `high`, and `max` over Chat Completions, and Codex's catalog listed `low`, `medium`, `high`, `xhigh`, `max`, and `ultra` for them. OpenLux returned no `reasoning_content` over Chat Completions and no reasoning summary or reasoning events over Responses, so effort changed the model's internal reasoning without producing visible thinking text. Re-verify both the accepted levels and the visibility behavior against the current gateway and CLI rather than relying on this observation.

## Verification

Run the checks against the same home and credential source that the user will launch:

```bash
config_path="${KIMI_CODE_HOME:-$HOME/.kimi-code}/config.toml"
kimi doctor config "$config_path"
kimi provider list
kimi -p "Reply with exactly: OPENLUX_OK" --model openlux-gpt/gpt-6-astra
kimi -p "Reply with exactly: OPENLUX_OK" --model openlux-gpt/gpt-6.1-sol
kimi -p "Use the Bash tool to run exactly: printf TOOL_OK. Then reply with the command output only." --model openlux-gpt/gpt-6-astra
```

Require the markers in the final answers and a successful tool result. For an isolated home, prefix each command with `KIMI_CODE_HOME="$HOME/kimi-homes/kimi-<suffix>"` or export it for the whole check.

Also confirm:

- `kimi provider list` shows the provider and the expected model count.
- `test -n "${OPENLUX_API_KEY:-}"` succeeds when `api_key_env` is used, without printing the value.
- The new aliases appear in `/model` and expose the expected effort choices.
- For thinking-level claims, confirm the session log records the intended `thinkingEffort`; a footer label change alone is not proof.
- The previous `default_model` and unrelated provider/model tables are unchanged.
- Every discovered id that was skipped is reported with its reason: absent from the key's catalog, only `openai-response`, unsupported effort vocabulary, or unknown context window.
- No key appears in the shell history, process arguments, logs, or the final report.

A raw `curl` success against `/v1/chat/completions` or `/v1/responses` is useful diagnostic evidence, but it is not the compatibility gate. The installed `kimi` binary must complete a real turn with the persisted config.

## Troubleshooting

- **`No available channel for this model on the current token`**: the key's token group does not serve that id even though OpenLux lists it elsewhere. Use a key whose `/v1/models` includes it, or report the id as unavailable.
- **`Invalid URL (GET /v1/chat/completions)`**: those routes are POST-only. Do not probe them with `GET`; use the CLI turn as the check.
- **`Token not provided`**: the credential is missing. With `api_key_env`, the named variable is unset in the launch environment; Kimi Code does not read ambient shell variables without it.
- **404 or a doubled `/v1/v1` path**: `base_url` is wrong. This provider needs exactly `https://api.openlux.ai/v1`; the Gemini-native provider needs the host root.
- **`Model "..." must declare a wire protocol`**: the provider `type` was not recognized. Use `openai`, or `openai_responses` for Responses-only ids.
- **`Model "..." must define a positive max_context_size`**: add a positive `max_context_size` to the model entry.
- **No effort picker**: add `support_efforts` and `default_effort`; a `thinking` capability alone exposes thinking mode but not a level list.
- **No thinking output**: the current OpenLux route does not return reasoning text on either protocol. Treat effort as internal to the model, and check the session's recorded `thinkingEffort` before concluding the setting was ignored.
- **An older model id stops working**: the catalog changed. Re-run **Model Selection** and update the alias entries instead of guessing a replacement id.

## Guardrails

- DO NOT print, commit, or expose the OpenLux key in skill sources, documentation, logs, command arguments, or reports.
- DO NOT add models the user did not request unless the user explicitly asked for the full Codex-supported set.
- DO NOT treat this page's example ids, a previous profile, or an older launcher as the current Codex model list; re-discover it.
- DO NOT place `ultra` in `support_efforts`; the Kimi Code effort vocabulary stops at `max`.
- DO NOT change `default_model` or unrelated provider and model tables unless the user explicitly requests it.
- DO NOT use the Gemini-native host root or a doubled `/v1` for this provider.
- DO NOT treat `kimi doctor config`, `kimi provider list`, or a raw provider API probe as proof that the Kimi Code route works without a real turn.
