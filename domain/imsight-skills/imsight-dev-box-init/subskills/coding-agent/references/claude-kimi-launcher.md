# Claude-Kimi Launcher Setup

Use this reference when the user wants a local `claude-kimi` or `claude-kimi-<suffix>` launcher that runs Claude Code against a Kimi Anthropic-compatible endpoint.

## Workflow

1. Inspect the installed Claude Code version/help, host OS and shell, and current Kimi documentation without changing any file.
2. Obtain the Kimi key under **Required Input**; stop without creating a launcher or key file when it is unavailable.
3. Determine the key's lane from the issuing console, the user's explicit account information, and current Kimi documentation. Do not probe Kimi APIs directly to infer it; ask the user when the issuer remains ambiguous.
4. Derive a candidate model mapping from current provider and Claude Code documentation, then complete **Claude Code Compatibility Test** with those settings scoped to a temporary Claude Code invocation.
5. Resolve the optional suffix and platform paths only after Claude Code completes a minimal real turn. Treat **Fallback Model Knowledge** only as explanatory context; it never authorizes an untested mapping.
6. Implement the launcher from the provider lane, OS, and runtime contracts using the client-verified mapping; use the bundled scripts as reference implementations only when their assumptions still match and pass explicit verified model arguments instead of accepting dated generator defaults.
7. Put the launcher directory on PATH for new shells under **Ensure Launcher Directory On PATH**; skipping this leaves the resolved launcher name unresolvable in fresh terminals.
8. Run every applicable check in **Verification**.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's inputs, defaults, launcher contract, verification rules, and user constraints, then execute the plan without exposing credentials.

## Launcher Name and Suffix Contract

Use `claude-kimi` when no suffix is provided. When the user provides a suffix such as `work`, use `claude-kimi-work`. Accept lowercase letters, digits, and internal hyphens; omit the separator when the suffix is absent.

The suffix is a user-facing launcher and credential-file namespace only. It does not choose the Kimi Platform API or Coding Plan lane, endpoint, account type, model mapping, context size, permission mode, or pricing. A suffixed launcher uses `kimi-api-key-<suffix>` by default so separate launcher variants cannot accidentally share credentials; the suffix itself still has no runtime meaning. In examples, `<key-file-name>` means `kimi-api-key` without a suffix or `kimi-api-key-<suffix>` with one. Do not ask for a suffix when the user does not provide one.

## Launcher Design Principles

- Determine the agent CLI version, host OS, provider lane, and key type before choosing syntax. Kimi Platform API and Kimi Coding Plan use different endpoints, auth variables, model catalogs, and entitlements.
- Scope provider variables to the launched Claude process. On Unix, export them in a child launcher and `exec` Claude; on Windows, use a native PowerShell launcher or function that does not permanently contaminate the caller's environment.
- Keep credential placement an explicit design choice. This guide's default is a protected local key file, but the runtime contract matters more than the example path.
- Use the resolved full launcher name and matching key-file namespace consistently; never derive provider behavior from the optional suffix.
- Derive model aliases and context settings from current provider documentation and the installed Claude Code version. Treat dated mappings below as fallback evidence, not timeless constants.
- Apply the shared permissive-launcher default, preserve all caller arguments, avoid duplicate `--model` injection, and return Claude's exit code.
- Validate the effective endpoint, auth lane, model mapping, permission mode, and argument forwarding. Merely running a generator is not proof that the launcher is correct.

## Required Input

The user must provide a Kimi API key during setup so Claude Code can verify the selected provider lane and model mapping before any persistent launcher or key file is created. Prefer an existing process-scoped `KIMI_API_KEY` or `ANTHROPIC_API_KEY` only when the user explicitly wants to use it for this setup. If no key is available, stop without writing a placeholder launcher.

```text
Please provide your Kimi API key and identify whether it came from Kimi Open Platform or the Kimi Code Console so I can verify that lane with Claude Code before creating the launcher.
```

The generated launcher must not hard-code the API key and must not rely on shell-specific automatic env loading. After the compatibility test, setup writes the key to the resolved protected key file. At runtime the launcher reads that file directly and assigns the lane's auth variable (`ANTHROPIC_AUTH_TOKEN` on the **Using Kimi Platform API** lane, `ANTHROPIC_API_KEY` on the **Using Kimi Coding Plan** lane) for the launched Claude process only.

## Determine The Key's Lane

Kimi open-platform keys and Kimi Code (coding plan) keys come from different consoles and authenticate against different endpoints. Identify the issuing console before choosing the lane: the lane must match the key or Claude Code fails authentication. Prefer the user's account source and current provider documentation over key-prefix guesses.

Prefix heuristic (community-observed — use only as a prompt for clarification, not proof):

- `sk-kimi-...` — Kimi Code Console key → **Using Kimi Coding Plan** lane.
- `sk-...` — Kimi Open Platform key → **Using Kimi Platform API** lane.

When the key source is unknown, ask which console issued it. Do not send the key to several endpoints to guess the lane.

## Claude Code Compatibility Test

Complete this test before running a generator, creating a persistent key file, cleaning settings, or changing PATH or shell startup files:

1. Select the lane from the issuing console and current provider guidance.
2. Derive explicit tier candidates from current Kimi and Claude Code documentation. Historical tables and generator defaults are not candidates by themselves.
3. Scope the chosen base URL, auth variable, tier mappings, context settings, and the supplied key to one temporary Claude Code process using its current non-interactive mode.
4. Run a minimal real Claude Code turn for the startup alias. When multiple aliases matter, exercise them through Claude Code's own `--model`, `/model`, or equivalent surface rather than a standalone API call.
5. If Claude Code rejects a model and exposes an actionable current choice, revise the temporary mapping and retry once. Otherwise stop and ask the user or consult updated provider guidance; do not probe `/models` or `/messages` manually.

Record the client-verified lane, exact model ids, mapping rationale, context assumptions, and any thinking requirement without recording the key. If several mappings remain with material cost, quality, or latency differences, ask the user before persistence rather than guessing from model names.

## Defaults

- Unix launcher path: `$HOME/.local/bin/<launcher-name>`.
- Unix key file: `$HOME/.local/bin/kimi-api-key` without a suffix, or `$HOME/.local/bin/kimi-api-key-<suffix>` with one.
- Windows launcher path: `%LOCALAPPDATA%\Programs\kimi-launchers\<launcher-name>.ps1`.
- Windows command shim path: `%LOCALAPPDATA%\Programs\kimi-launchers\<launcher-name>.cmd`.
- Windows key file: `%LOCALAPPDATA%\Programs\kimi-launchers\kimi-api-key[-<suffix>]`.
- Provider lane: use the lane identified by the key's issuing console and confirmed by **Claude Code Compatibility Test**. A user request does not override a failed target-client authentication result.
- Default startup alias: `opus` — the launcher starts Claude Code with `--model opus`, and `ANTHROPIC_DEFAULT_OPUS_MODEL` must resolve to the most capable appropriate model established by the current client test. This guide does not supply a persistent default model id.
- `DISABLE_AUTOUPDATER=1`, overridable by the caller. Claude Code's background auto-updater reinstalls the npm package mid-session; an interrupted install leaves the placeholder `claude` shim behind and breaks every launcher on the box (see **Notes**). Updates become deliberate: `npm update -g @anthropic-ai/claude-code`.

Imsight's local launcher runs Claude Code with `--dangerously-skip-permissions` by default. Use the generator's permission-prompting option only when the user's initial launcher request explicitly opts out of permissive mode. The generator derives the auth lane, the tier mapping, and the compact window from `--base-url` and the model options.

## Check Latest Kimi Info First

Kimi model names, lane endpoints, and Claude Code settings change over time — the whole `kimi-k2-*` family is already deprecated. Before generating or updating a launcher, look up the latest information online instead of relying on memory or on the snapshot in this page:

- Kimi API Platform model list: `https://platform.kimi.ai/docs/models` — canonical lineup for the Platform API lane, including deprecation and sunset notices.
- Kimi API Platform guide "Use Kimi in Claude Code": `https://platform.kimi.ai/docs/guide/claude-code-kimi` — the Platform API lane's official Claude Code configuration.
- Kimi Code third-party coding-agent guide: `https://www.kimi.com/code/docs/en/third-party-tools/other-coding-agents.html` — canonical Coding Plan lane configuration, model names, and membership-tier availability.
- Kimi Code provider docs: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/providers.html` — Kimi-native provider endpoint shape.
- Claude Code model configuration docs: `https://code.claude.com/docs/en/model-config` and `https://code.claude.com/docs/en/settings` — how `/model`, `--model`, `ANTHROPIC_DEFAULT_*_MODEL`, `availableModels`, and `modelOverrides` behave in the current Claude Code release.
Rule of thumb: use current provider documentation to propose the lineup and the installed Claude Code client to prove the actual launcher behavior. When current documentation or the target client disagrees with this page, the current evidence wins.

## Fallback Model Knowledge

This embedded snapshot is dated explanatory context for understanding aliases and past provider behavior. It never authorizes launcher creation or model selection without a current Claude Code end-to-end test.

### How Claude Code Model Selection Works

Selection surfaces, in priority order: `/model <alias|name>` mid-session (also saves to user settings), `claude --model <alias|name>` at startup, `ANTHROPIC_MODEL`, then the `model` field in `settings.json`. The tier variables control what each alias resolves to:

- `ANTHROPIC_DEFAULT_OPUS_MODEL` → `opus`
- `ANTHROPIC_DEFAULT_SONNET_MODEL` → `sonnet`
- `ANTHROPIC_DEFAULT_HAIKU_MODEL` → `haiku`
- `ANTHROPIC_DEFAULT_FABLE_MODEL` → `fable`
- `CLAUDE_CODE_SUBAGENT_MODEL` → subagents

Behind a custom `ANTHROPIC_BASE_URL`, Claude Code passes any model string through without validation, so `/model <kimi-model-name>` also works directly. Listing a full custom model ID in `availableModels` in `~/.claude/settings.json` adds it as its own labeled row in the `/model` picker — useful for variants not covered by an alias:

```json
{
  "availableModels": [
    "kimi-k3",
    "kimi-k2.7-code",
    "kimi-k2.7-code-highspeed",
    "kimi-k2.6"
  ]
}
```

`availableModels` is an allowlist — it restricts every model-selection surface, so include all variants the user may select.

### Mapping Rule: Map By Cost

When Kimi or Claude Code updates their model lists, re-derive the tier mapping instead of copying a saved table. Order Claude Code's tiers by descending cost and capability: `fable` > `opus` > `sonnet` > `haiku`. Order the Kimi models available on the user's key the same way, then assign them in sequence: the top model to `fable`, the next to `opus`, the next to `sonnet`, and the cheapest to `haiku` and subagents. With fewer Kimi models than tiers, adjacent tiers share a model — give the higher tier the better model and let `haiku`/subagents share the cheapest.

- Platform API lane: rank models by per-token price from the price details linked on `https://platform.kimi.ai/docs/models`; price is the provider's own capability ranking.
- Coding Plan lane: models have no per-token price, so rank by the membership tier that unlocks each model — a model gated behind a higher plan ranks above one available on lower plans (for example the 1M `k3` class above `k3-256k` above `kimi-for-coding`).
- Never map an alias to a highspeed variant (`kimi-k2.7-code-highspeed`, `kimi-for-coding-highspeed`): highspeed models cost more per token but buy speed rather than capability, so cost alone would rank them wrong. They stay reachable by direct name or through `availableModels` picker entries.
- Verify every literal provider model id through an actual Claude Code turn before mapping. Claude Code's `X[1m]` suffix is its own 1M-context notation, not necessarily a provider id — the recorded coding endpoint rejected `k3[1m]` and served the 1M model as literal `k3`.

### Default Tier Mapping (Snapshot 2026-07-25)

These tables are dated examples of the cost rule applied to the 2026-07-25 lineup; re-derive them with **Mapping Rule: Map By Cost** when the lineup changes. The launcher maps each Claude Code tier to a different Kimi model so `/model` switches between real variants.

Platform API lane:

| Alias | Resolves to | Why |
| --- | --- | --- |
| `fable` | `kimi-k3` | Top of the lineup, 1M window |
| `opus` (startup default) | `kimi-k3` | Shares the top model |
| `sonnet` | `kimi-k2.7-code` | Balanced coding model |
| `haiku` | `kimi-k2.6` | Cheapest, thinking optional |
| subagent | `kimi-k2.7-code` | Subagents |

Coding Plan lane (verified on an Allegretto-class key):

| Alias | Resolves to |
| --- | --- |
| `fable` | `k3` (1M window; literal id `k3`, not `k3[1m]`) |
| `opus` (startup default) | `k3-256k` |
| `sonnet` | `kimi-for-coding` |
| `haiku` | `kimi-for-coding` |
| subagent | `kimi-for-coding` |

### Caveats

- **Thinking requirement**: `kimi-k2.7-code` / `kimi-for-coding` reject requests unless Thinking is enabled in Claude Code (Alt+T on Windows/Linux, Option+T on macOS). Switching to an alias mapped to a K2.7 variant requires Thinking on; `kimi-k3` and `kimi-k2.6` don't have this constraint.
- **Fixed compact window**: `CLAUDE_CODE_AUTO_COMPACT_WINDOW` is set once at launch from the resolved startup model's context window (1048576 for 1M models such as `kimi-k3`/`k3`, 262144 for 256K models such as the K2 series and `k3-256k`). Switching mid-session from a 1M alias to a 256K alias doesn't shrink the window, so long sessions switched down to a 256K model can hit the smaller context limit.
- **Stale `model` in settings.json**: `/model` persists the alias to user settings, but the launcher's `--model` flag overrides it on next launch. The Coding Plan lane additionally requires cleaning stale model entries from `~/.claude/settings.json` before first launch (see that lane's section).

### Model Lineup Snapshot (2026-07-25)

Platform API lane (`api.moonshot.ai`):

| Model | Context | Good for |
| --- | --- | --- |
| `kimi-k3` | 1M | Flagship; native vision, thinking on by default. Software engineering, knowledge work, deep reasoning. Default choice. |
| `kimi-k2.7-code` | 256K | Dedicated coding model; reliable long-context instruction following. Requires thinking enabled. |
| `kimi-k2.7-code-highspeed` | 256K | K2.7 Code at ~180 tok/s output — interactive coding where latency matters. |
| `kimi-k2.6` | 256K | Vision + text, thinking optional, dialogue and agent tasks; latency-sensitive simple tasks. |
| `kimi-k2.5` | 256K | Sunsetting; unavailable to new users, full sunset Aug 31. Migrate away. |
| `moonshot-v1-*` | 8K–128K | Legacy plain text generation — sunsetting. |

Coding Plan lane (`api.kimi.com/coding/`), availability by membership tier:

| Model | Good for |
| --- | --- |
| `k3` / `k3[1m]` | K3 on the coding plan; `k3[1m]` is the 1M-window variant (Allegretto tier and above). |
| `kimi-for-coding` | K2.7 Code on the plan; requires Thinking enabled or requests fall back to K2.6. |
| `kimi-for-coding-highspeed` | High-speed K2.7 Code variant (Allegretto+). |

Deprecated — do not use: `kimi-k2-0905-preview`, `kimi-k2-0711-preview`, `kimi-k2-turbo-preview`, `kimi-k2-thinking`, `kimi-k2-thinking-turbo` (discontinued 2026-05-25), `kimi-latest` (2026-01-28), `kimi-thinking-preview` (2025-11-11).

## Using Kimi Platform API

Use this lane only when the key came from Kimi Open Platform and succeeds during **Claude Code Compatibility Test**, following the Kimi API Platform guide "Use Kimi in Claude Code".

- Base URL: `https://api.moonshot.ai/anthropic`
- Auth: `ANTHROPIC_AUTH_TOKEN` with a key created on Kimi Open Platform (the launcher clears `ANTHROPIC_API_KEY` and `CLAUDE_CODE_OAUTH_TOKEN`)
- Startup alias: `opus`, resolved to `<verified-platform-opus-model>` from the current Claude Code test
- Tier mapping: the generated launcher exports `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, `ANTHROPIC_DEFAULT_FABLE_MODEL`, and `CLAUDE_CODE_SUBAGENT_MODEL`, derived with **Mapping Rule: Map By Cost** (see the **Default Tier Mapping** snapshot for dated examples)
- `ENABLE_TOOL_SEARCH=false` (the Kimi endpoint does not support Claude Code Tool Search)
- `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1048576` for K3-class resolved startup models; `262144` for K2-series

Generate for this lane only with an explicit tier mapping derived from current documentation and proven by the current key through Claude Code. Replace every placeholder before execution:

```bash
<coding-agent-subskill-dir>/scripts/create-claude-kimi-launcher.sh \
  --base-url https://api.moonshot.ai/anthropic \
  --model opus \
  --model-opus <verified-platform-opus-model> \
  --model-sonnet <verified-platform-sonnet-model> \
  --model-haiku <verified-platform-haiku-model>
```

Verify inside Claude Code with `/status`: Base URL `https://api.moonshot.ai/anthropic`, with each alias resolving to the exact model proven during the current compatibility test.

## Using Kimi Coding Plan

Use this lane when the provided key is a coding-plan key (see **Determine The Key's Lane**), when the user has a Kimi membership with Kimi Code benefits and asks for the coding-plan endpoint, or wants help choosing between the lanes. It follows the Kimi Code third-party coding-agent guide.

- Base URL: `https://api.kimi.com/coding/`
- Auth: `ANTHROPIC_API_KEY` with a key created in the Kimi Code Console (the launcher clears `ANTHROPIC_AUTH_TOKEN` and `CLAUDE_CODE_OAUTH_TOKEN`)
- Tier mapping: `ANTHROPIC_DEFAULT_FABLE_MODEL`, `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, and `CLAUDE_CODE_SUBAGENT_MODEL`, derived with **Mapping Rule: Map By Cost** and adjusted to the user's membership tier (see the **Default Tier Mapping** snapshot for dated examples)
- `CLAUDE_CODE_MAX_CONTEXT_TOKENS` matches the derived window; the launcher exports `CLAUDE_CODE_EFFORT_LEVEL=max` only when the resolved startup model is K3 (`k3` or `k3[1m]`), because only K3 supports that field
- The launcher passes the startup model with Claude Code `--model` instead of exporting `ANTHROPIC_MODEL`; stale model entries in the `env` field of `~/.claude/settings.json` override launcher exports, so clean them before first launch (the coding guide's pre-launch Node script removes them and also sets `penguinModeOrgEnabled` alongside `hasCompletedOnboarding`)

Pick tier models by membership tier:

| Plan | Available models | Window |
| --- | --- | --- |
| Andante | `kimi-for-coding` | `262144` |
| Moderato | `k3` or `kimi-for-coding` | `262144` |
| Allegretto and above | `k3[1m]`, `kimi-for-coding`, `kimi-for-coding-highspeed` | `1048576` for `k3[1m]`, `262144` for the K2.7 Code series |

Thinking: K3 models support `low`, `high`, and `max` effort and default to
`high` when the Coding Plan request omits an effort. `kimi-for-coding` (K2.7
Code) is always-thinking but does not expose those effort levels; keep Thinking
enabled in Claude Code (Option+T on macOS, Alt+T on Windows/Linux), or requests
fall back to K2.6.

### Set Coding Plan Thinking Effort

Apply an explicit effort only to K3 models (`k3` and `k3-256k`):

| Effort | Use |
| --- | --- |
| `low` | Lower-latency, lower-reasoning work |
| `high` | Balanced default for normal coding and memory processing |
| `max` | Hard problems where extra reasoning latency and quota use are acceptable |

For the generated Claude Code launcher, set the effort for one invocation:

```bash
CLAUDE_CODE_EFFORT_LEVEL=low claude-kimi
CLAUDE_CODE_EFFORT_LEVEL=high claude-kimi
CLAUDE_CODE_EFFORT_LEVEL=max claude-kimi
```

The launcher preserves a caller-provided `CLAUDE_CODE_EFFORT_LEVEL`; when it
starts a K3 model without one, it currently pins `max`. Do not set this variable
for `kimi-for-coding`.

In Kimi Code CLI, switch the active session directly:

```text
/effort low
/effort high
/effort max
```

`/thinking` is an alias. `/effort` without an argument opens the selector:
Left/Right changes the level, Enter applies it, and Alt+S applies it to the
current session only. Kimi Code intentionally does not persist the highest
declared level (`max`) as the global default; it applies `max` to the current
session and lets later sessions return to the model default (`high`).

For Kimi-native or OpenAI-compatible Coding Plan clients, match Kimi Code's
wire format by sending a top-level `thinking` object:

```json
{
  "model": "k3-256k",
  "thinking": {
    "type": "enabled",
    "effort": "high"
  }
}
```

Kimi Code constructs this as
`thinking: {type: "enabled", effort: "low"|"high"|"max"}`. Do not assume a
generic client's `reasoning_effort` setting is translated to this Kimi-specific
field. For wrappers that expose an OpenAI `extra_body`, put `thinking` there.
For example, Hindsight accepts:

```bash
HINDSIGHT_API_LLM_EXTRA_BODY='{"thinking":{"type":"enabled","effort":"high"}}'
```

If no explicit `thinking.effort` reaches the Coding Plan API, K3 uses `high`.

Generate for this lane by passing the coding-plan endpoint and the exact mapping proven by the current key through Claude Code. Replace every placeholder before execution:

```bash
<coding-agent-subskill-dir>/scripts/create-claude-kimi-launcher.sh \
  --base-url https://api.kimi.com/coding/ \
  --model opus \
  --model-opus <verified-coding-opus-model> \
  --model-fable <verified-coding-fable-model>
```

The generator derives `ANTHROPIC_API_KEY` auth, the tier defaults, and the compact window from the endpoint. Verify inside Claude Code with `/status`: Base URL `https://api.kimi.com/coding/`; the model name may still appear Claude-like even though calls go to the Kimi Code API.

## Official Kimi References

- Kimi API Platform guide "Use Kimi in Claude Code": `https://platform.kimi.ai/docs/guide/claude-code-kimi`
  - Relevant Claude Code settings: `ANTHROPIC_BASE_URL=https://api.moonshot.ai/anthropic`, `ANTHROPIC_AUTH_TOKEN=<key>`, every model variable set from the current verified mapping, `ENABLE_TOOL_SEARCH=false`, and a compact window derived from the verified model's current documented context limit.
  - `/status` in Claude Code should show the Moonshot base URL and the resolved model.
- Kimi Code official third-party coding-agent guide: `https://www.kimi.com/code/docs/en/third-party-tools/other-coding-agents.html`
  - The **Using Kimi Coding Plan** lane: `ANTHROPIC_BASE_URL=https://api.kimi.com/coding/`, `ANTHROPIC_API_KEY=<key>`, every model variable set to the tier's model, `CLAUDE_CODE_MAX_CONTEXT_TOKENS`, and `CLAUDE_CODE_EFFORT_LEVEL=max` for K3 models.
  - The page also includes a pre-first-launch Node script that sets `penguinModeOrgEnabled` and `hasCompletedOnboarding` and removes stale model entries from `~/.claude/settings.json`.
- Kimi Code provider docs: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/providers.html`
  - Confirms Kimi Code's provider endpoint shape: `https://api.kimi.com/coding/v1` for Kimi-native provider configuration.
- Kimi Code model docs: `https://www.kimi.com/code/docs/en/kimi-code/models.html`
  - Confirms K3 and K3-256K support `low`, `high`, and `max`, with `high` as the Coding Plan default.
- Kimi Code environment variable docs: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/environment-variables.html`
  - Use for Kimi CLI's own `KIMI_*` variables. Do not substitute these for Claude Code's `ANTHROPIC_*` variables.
- Claude Code model configuration: `https://code.claude.com/docs/en/model-config` and `https://code.claude.com/docs/en/settings`
  - Alias resolution, `/model` persistence, `availableModels`, and `modelOverrides` semantics.

## Reference Implementations

The bundled scripts are worked Linux and Windows implementations of the principles above. Resolve `<coding-agent-subskill-dir>` to the `subskills/coding-agent/` directory whose `references/` folder contains this page, inspect the relevant script, and do not run it before **Claude Code Compatibility Test** succeeds. Pass explicit client-verified model mappings; do not accept its recorded model defaults merely because its endpoint and OS assumptions match. Otherwise adapt the implementation and run the same verification checks.

The following commands demonstrate the current examples; they are not the only valid way to implement the launcher. If an installed skill copy lost the script's execute bit, invoke the example through the interpreter: `bash <coding-agent-subskill-dir>/scripts/create-claude-kimi-launcher.sh ...` (or `pwsh -File ...ps1` on Windows).

## Ensure Launcher Directory On PATH

A launcher that is not on PATH fails with `command not found` in new terminals. After creating the launcher, make its directory resolvable in the user's everyday shell, not only in login shells.

On Unix, `~/.profile` typically adds `$HOME/.local/bin` for login shells only. Most terminal emulators start non-login interactive shells that read `~/.bashrc` (bash) or `~/.zshrc` (zsh) and never see that entry, so `<launcher-name>` is missing from fresh terminals until the rc file adds it. Check a fresh interactive shell first:

```bash
bash -ic 'command -v claude-kimi'   # zsh: zsh -ic 'command -v claude-kimi'
```

If the check fails, append a guarded block to the matching rc file (`~/.bashrc`, or `~/.zshrc` for zsh):

```bash
# User-local launchers (e.g. claude-kimi)
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) [ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH" ;;
esac
```

If the launcher was written to a non-default `--output` directory, substitute that directory. Already-open terminals pick up the change only after `source ~/.bashrc` or a new window.

On Windows, add `%LOCALAPPDATA%\Programs\kimi-launchers` to the user PATH so the `.cmd` shim resolves from `cmd.exe`, PowerShell, and other launchers.

## Runtime Argument Contract

`<launcher-name>` runtime arguments are Claude Code arguments by default. The launcher prepends `--dangerously-skip-permissions` unless permission prompts were explicitly requested at the beginning of the launcher task. It may observe arguments only to avoid injecting duplicate defaults, such as not adding its default `--model` when the user already passed `--model`. It must not consume, rename, reorder, or reinterpret underlying Claude CLI arguments, and the setup-time suffix must never be forwarded as one.

If a future launcher needs its own runtime flags, use launcher-prefixed names such as `--claude-kimi-key-file` or `--claude-kimi-no-default-model`, and strip only those prefixed launcher flags before calling `claude`.

### Unix Or Linux Shell

After the compatibility test, execute the fully substituted lane-specific generator command from **Using Kimi Platform API** or **Using Kimi Coding Plan** and add `--api-key "$KIMI_API_KEY"`. The invocation must contain the explicit client-verified model mapping; do not run the generator with only an API key.

The script also accepts `--suffix`, `--output`, `--key-file`, `--base-url`, `--model`, `--model-opus`, `--model-sonnet`, `--model-haiku`, `--model-fable`, `--model-subagent`, `--compact-window`, and `--claude-bin`. Use the model and context options as required current inputs, not optional convenience overrides. For example, `--suffix work` creates `claude-kimi-work` with `kimi-api-key-work`. Add `--require-permission-prompts` to the same fully specified command only for an explicit initial opt-out.

### Windows PowerShell

The PowerShell script creates a `.ps1` launcher and adjacent `.cmd` shim in a common `kimi-launchers` directory. After the compatibility test, pass `-ApiKey $env:KIMI_API_KEY`, the verified `-BaseUrl`, and explicit `-ModelOpus`, `-ModelSonnet`, `-ModelHaiku`, `-ModelFable`, and `-ModelSubagent` values proven through the target client. Do not invoke the script with its recorded model defaults. The `.cmd` shim lets users run the resolved launcher name from `cmd.exe`, PowerShell, or other launchers when the directory is on `PATH`.

The script also accepts `-Suffix`, `-OutputPath`, `-KeyFilePath`, `-Model`, `-CompactWindow`, and `-ClaudeBin`. For example, `-Suffix work` creates `claude-kimi-work.ps1`, `claude-kimi-work.cmd`, and `kimi-api-key-work`. Add `-RequirePermissionPrompts` to the same fully specified command only for an explicit initial opt-out.

## Verification

Verify the Unix launcher exists:

```bash
command -v <launcher-name>
bash -ic 'command -v <launcher-name>'   # must also resolve in a fresh non-login terminal; fix PATH per **Ensure Launcher Directory On PATH** if not
test -x "$HOME/.local/bin/<launcher-name>"
ls -l "$HOME/.local/bin/<launcher-name>"
test -f "$HOME/.local/bin/<key-file-name>"
```

Verify the Windows launcher exists:

```powershell
Test-Path "$env:LOCALAPPDATA\Programs\kimi-launchers\<launcher-name>.ps1"
Test-Path "$env:LOCALAPPDATA\Programs\kimi-launchers\<launcher-name>.cmd"
Test-Path "$env:LOCALAPPDATA\Programs\kimi-launchers\<key-file-name>"
```

Inspect generated launchers and key files only with redaction:

```bash
rg -n 'kimi-api-key|ANTHROPIC_BASE_URL|ANTHROPIC_DEFAULT_|CLAUDE_CODE_SUBAGENT_MODEL|ENABLE_TOOL_SEARCH|CLAUDE_CODE_AUTO_COMPACT_WINDOW|DISABLE_AUTOUPDATER|dangerously-skip-permissions' "$HOME/.local/bin/<launcher-name>"
test -f "$HOME/.local/bin/<key-file-name>" && sed 's/.*/<redacted>/' "$HOME/.local/bin/<key-file-name>"
```

```powershell
Select-String -Path "$env:LOCALAPPDATA\Programs\kimi-launchers\<launcher-name>.ps1" -Pattern 'kimi-api-key|ANTHROPIC_BASE_URL|ANTHROPIC_DEFAULT_|CLAUDE_CODE_SUBAGENT_MODEL|ENABLE_TOOL_SEARCH|CLAUDE_CODE_AUTO_COMPACT_WINDOW|DISABLE_AUTOUPDATER|dangerously-skip-permissions'
if (Test-Path "$env:LOCALAPPDATA\Programs\kimi-launchers\<key-file-name>") { '<redacted>' }
```

Inside Claude Code, `/status` should show the selected base URL and every alias must resolve to the exact mapping proven before generation. The default generated launcher must invoke `claude` with `--dangerously-skip-permissions`; an explicit permission-prompting opt-out must omit it.

## Notes

- Store the Kimi key in the resolved `kimi-api-key[-<suffix>]` file next to the launcher, not in the launcher script itself. Unsuffixed launchers retain the existing `kimi-api-key` default.
- Keep reference launcher implementations in `<coding-agent-subskill-dir>/scripts/`; do not make a script invocation the only explanation of the launcher contract.
- Prefer `ANTHROPIC_AUTH_TOKEN` on the **Using Kimi Platform API** lane and clear `ANTHROPIC_API_KEY` and `CLAUDE_CODE_OAUTH_TOKEN` so Claude Code does not choose an older auth lane. On the **Using Kimi Coding Plan** lane (`api.kimi.com`), the generated launcher uses `ANTHROPIC_API_KEY` instead and clears `ANTHROPIC_AUTH_TOKEN`.
- The default startup model is `opus`. Override it with `CLAUDE_KIMI_MODEL=<model> <launcher-name> ...` or an explicit Claude Code `--model`; `CLAUDE_KIMI_MODEL` is the single knob that resets the startup model and every tier at once. Per-tier runtime overrides are `CLAUDE_KIMI_MODEL_OPUS`, `CLAUDE_KIMI_MODEL_SONNET`, `CLAUDE_KIMI_MODEL_HAIKU`, `CLAUDE_KIMI_MODEL_FABLE`, and `CLAUDE_KIMI_MODEL_SUBAGENT`.
- If `claude` is not on `PATH`, install Claude Code first before testing the launcher.
- If `claude` prints `Error: claude native binary not installed`, the Claude Code package's postinstall did not run; repair it with `node <npm-global-root>/node_modules/@anthropic-ai/claude-code/install.cjs` and re-verify `claude --version`. The usual cause is the background auto-updater: it reinstalls the npm package mid-session, and an install interrupted between package extraction and postinstall leaves the placeholder shim as the `claude` entrypoint. Generated launchers prevent recurrence by exporting `DISABLE_AUTOUPDATER=1`; update deliberately with `npm update -g @anthropic-ai/claude-code` instead.
- If first launch gets stuck in Claude Code onboarding, run the official Kimi guide's Node onboarding-complete script before starting `<launcher-name>`.

## Guardrails

- DO NOT print, hard-code, or echo the Kimi API key in commands, responses, or the generated launcher.
- DO NOT create a persistent key file, launcher, PATH entry, settings cleanup, or shell-profile block before the temporary Claude Code end-to-end test succeeds.
- DO NOT run the generator with its recorded model defaults; pass the exact mapping proven through the current Claude Code compatibility test.
- DO NOT require or use direct Kimi model or Messages API probes as launcher compatibility evidence.
- DO NOT use the dated fallback snapshot to authorize setup without a successful current Claude Code test.
- DO NOT map Claude Code model aliases to highspeed Kimi variants (`kimi-k2.7-code-highspeed`, `kimi-for-coding-highspeed`) in launcher defaults; keep them selectable only by direct model name or `availableModels` picker entries.
- DO NOT remove the `--dangerously-skip-permissions` flag from the generated launcher unless the user's initial launcher request explicitly asks for permission prompts.
- DO NOT assign endpoint, lane, account, model, routing, pricing, credential, context, or permission semantics to the optional suffix.
