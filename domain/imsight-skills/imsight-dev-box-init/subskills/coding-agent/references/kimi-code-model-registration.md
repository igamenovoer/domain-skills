# Kimi Code Model Registration (Generic)

Use this reference when the user wants to add any provider or model to a Kimi Code CLI home and no provider-specific page applies — including newly released, unreleased, or unadvertised model ids. This page teaches the general handling; the provider-specific sibling pages (`kimi-openlux-gpt-provider.md`, `kimi-openlux-gemini-provider.md`, `kimi-deepseek-provider.md`) are dated worked examples of it, not the procedure itself. Every concrete model id, context window, effort level, and CLI behavior on those pages and in this one is a dated observation: re-resolve against live sources instead of copying forward.

## Workflow

1. Resolve the target Kimi Code home, provider name, credential source, and requested model set. Use the user's explicit `KIMI_CODE_HOME`, or `~/.kimi-code` for the default home; keep the existing `default_model` unchanged unless the user explicitly asks to switch it.
2. Complete **Compatibility Preflight** without writing configuration; stop when the installed CLI or current documentation does not expose the provider type or fields the plan needs.
3. Resolve each model's facts under **Model Fact Discovery** from live sources, recording the source and resolution date. Never seed facts from this page, a sibling page, a previous profile, or memory.
4. Back up the target `config.toml` when it is not under version control, then merge provider and model entries under **Provider and Model Contract**, respecting **Managed Versus User Providers** for where each field is allowed to live.
5. Apply **Thinking Effort and Defaults**; when the model serves a subagent with a specific thinking level, follow the derived-model rule there and route the subagent definition itself to the `imsight-project-subagents` skill.
6. Validate the file and run real end-to-end turns with the installed `kimi` binary under **Verification**; do not substitute a raw HTTP probe for the CLI result.
7. Report the changed configuration path, model aliases, fact sources and resolution date, credential form, effort defaults, skipped ids with reasons, and any provider-side limitation.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's contracts, the installed CLI, the discovery sources, and the user's constraints, then execute the plan without exposing any credential.

## Compatibility Preflight

Run read-only checks before editing anything:

```bash
kimi --version
kimi --help
config_path="${KIMI_CODE_HOME:-$HOME/.kimi-code}/config.toml"
kimi doctor config "$config_path"
rg -n '^\[providers\.|^\[models\.|^default_model' "$config_path"
```

Confirm against the current documentation that the intended provider `type` and every field the plan writes still exist:

- Provider types: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/providers.html`
- Config fields: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/config-files.html`

Stop without writing when a required provider type or field is absent, or when the target provider or model alias already exists with different content. `kimi doctor config` validates TOML syntax and known schema shape; it does not prove the provider type is recognized or that the endpoint answers.

## Model Fact Discovery

Resolve each requested id's facts from live sources, in this preference order, and record which source supplied what, with the resolution date:

1. **The provider's own catalog or model documentation** — for OpenAI-compatible providers typically `GET <base_url>/models` with the key; for official vendors, their documented catalog endpoint or model pages. Take context window, output limits, input modalities, and reasoning levels from the response when published.
2. **The vendor's current model documentation** when the catalog omits a fact.
3. **Source repositories and release notes** when both lag a newly shipped model.

Field-specific rules:

- `max_context_size` must be positive and justified. Use a catalog value when published; otherwise the vendor documentation; otherwise the model family's documented window, recorded as an assumption. Never invent a number.
- `capabilities` starts minimal. Add `"thinking"` and `"tool_use"` after those behaviors verify with the installed client; add `"image_in"` or other modalities only when the catalog declares them and a real turn exercising them succeeds.
- `support_efforts` is the intersection of the id's discovered reasoning levels and the Kimi Code vocabulary (`low`, `medium`, `high`, `xhigh`, `max`). Drop levels the vocabulary cannot select and report the gap.
- A missing id fails the real turn with a model-not-found error; report it as unavailable rather than guessing a replacement id.

## Provider and Model Contract

- One provider entry per wire protocol per endpoint. Do not share one provider across protocols (for example OpenAI Chat Completions versus Responses, or an OpenAI-compatible route versus a Gemini-native route on the same host); create a distinctly named provider per protocol.
- `base_url` must match the protocol client's path appending exactly; a missing or doubled `/v1` segment produces wrong paths. Take the correct shape from the provider-specific page or the vendor's documentation, not from assumption.
- `model` is the upstream id; the alias is local. Prefer `<provider>/<model-id>`, quote the TOML key when the alias contains a dot, and keep the alias stable when the upstream id changes.
- Choose exactly one credential form per provider: `api_key_env = "<VAR>"` (preferred) or inline `api_key` only in a local `config.toml` kept at mode `0600`. Kimi Code does not fall back to ambient shell variables unless `api_key_env` names one.

## Managed Versus User Providers

Where a setting is allowed to live depends on who owns the entry:

- **Managed providers** (notably `managed:kimi-code`, provisioned by `/login`): a login or catalog refresh may rewrite the entry's top-level fields. Do not edit them. When a managed model needs a different default thinking level or effort list, pin `[models."<alias>".overrides]` (for example `default_effort = "max"`); overrides survive refreshes and outrank the top-level field for every runtime consumer.
- **User-defined providers**: nothing refreshes them, so write `default_effort`, `support_efforts`, and the other model fields directly in the `[models]` entry.

## Thinking Effort and Defaults

Kimi Code exposes a model's effort levels through `support_efforts` and chooses a default through `default_effort`. Four rules keep the configuration least-surprising:

1. Do not touch settings that managed refreshes rewrite (see **Managed Versus User Providers**).
2. A different default for a managed Kimi model goes through `[models."<alias>".overrides]`.
3. Defaults for non-managed models are set directly in their own `[models]` entries.
4. A subagent-specific thinking level gets a derived model: register `<provider>/<model>-<effort>` as a standalone `[models]` entry for the same upstream id with only `default_effort` changed (copy every other field in full; variants inherit nothing), keep the bare alias on the model's own default, and name the suffixed alias in the subagent definition's `description`. Subagent definitions and `[secondary_model]` pool bindings are owned by the `imsight-project-subagents` skill; route that part there.

Further effort rules:

- The global `[thinking]` table's `effort` overrides the model default for the main agent; pool-bound subagents follow the bound entry's `default_effort` instead. Check the session's effective effort when strict model-level behavior matters.
- Configuring `support_efforts` is necessary but not sufficient proof: the installed client must also send the concrete level. Confirm the session's recorded `thinkingEffort`; a footer label change alone is not proof, and a provider may accept the parameter without returning visible reasoning text.

## Verification

Verify against the same home and credential source the user will launch:

```bash
config_path="${KIMI_CODE_HOME:-$HOME/.kimi-code}/config.toml"
kimi doctor config "$config_path"
kimi provider list
kimi -p "Reply with exactly: REG_OK" --model <provider>/<model-id>
kimi -p "Use the Bash tool to run exactly: printf TOOL_OK. Then reply with the command output only." --model <provider>/<model-id>
```

Require the markers in the final answers and a successful tool result. Also confirm the alias appears in `/model` with the expected effort choices, the session log records the intended `thinkingEffort` for effort claims, the previous `default_model` and unrelated tables are unchanged, and no credential appears in shell history, command arguments, logs, or the report. A raw HTTP probe is diagnostic evidence only; the installed `kimi` binary completing a real turn with the persisted config is the compatibility gate.

## Dated Worked Examples

| Page | Recorded | Covers |
| --- | --- | --- |
| `kimi-openlux-gpt-provider.md` | 2026-10-23, Kimi Code 2.3.0 | OpenAI-compatible relay route, Codex-catalog model discovery, endpoint-type splitting |
| `kimi-openlux-gemini-provider.md` | 2026-10, Kimi Code 2.x | Gemini-native route, side-file credential reuse |
| `kimi-deepseek-provider.md` | 2026-10-23 | Official vendor catalog fields (`context_window`, `effort.supported_levels`), `reasoning_key` |

These pages instantiate this generic procedure for one provider each. Consult them for protocol-specific quirks; consult this page for the decision order and the ownership rules.

## Guardrails

- DO NOT print, commit, or expose any credential in skill sources, documentation, logs, command arguments, or reports.
- DO NOT add models the user did not request unless the user explicitly asked for a discovered set.
- DO NOT edit top-level fields of managed (`managed:kimi-code`) provider or model entries; use `[models."<alias>".overrides]` for different managed defaults.
- DO NOT seed model facts from this page, sibling pages, previous profiles, or memory; re-resolve them from live sources and record the source and date.
- DO NOT change `default_model` or unrelated provider and model tables unless the user explicitly requests it.
- DO NOT mix wire protocols under one provider entry.
- DO NOT treat `kimi doctor config`, `kimi provider list`, or a raw provider API probe as proof that the route works without a real CLI turn.
