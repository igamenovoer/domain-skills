# Claude-Kimi Launcher Setup

Use this reference when the user wants a local `claude-kimi` launcher that runs Claude Code against a Kimi Anthropic-compatible endpoint.

## Workflow

1. Resolve API-key handling under **Required Input** without printing or hard-coding the key.
2. When an API key is available, determine its type and the matching lane under **Determine The Key's Lane**; the user's explicit lane choice overrides the detected lane.
3. Check the latest Kimi model lineup and configuration guidance online first, following **Check Latest Kimi Info First**; when the lineup changed, re-derive the tier mapping with **Mapping Rule: Map By Cost**. Only when online sources are unreachable, fall back to the embedded snapshot in **Fallback Model Knowledge**.
4. Apply the platform-specific paths in **Defaults** and the lane procedures from **Using Kimi Platform API** or **Using Kimi Coding Plan**.
5. Create the launcher and preserve **Runtime Argument Contract**.
6. Put the launcher directory on PATH for new shells under **Ensure Launcher Directory On PATH**; skipping this leaves `claude-kimi` unresolvable in fresh terminals.
7. Run every applicable check in **Verification**.

If the task does not map cleanly to these steps, plan only from this page's inputs, defaults, launcher contract, and verification rules; keep credentials out of commands and responses.

## Required Input

You can provide a Kimi API key during setup, or let the generated launcher prompt for it on first run. Prefer an existing `KIMI_API_KEY` or `ANTHROPIC_API_KEY` only when the user explicitly wants to seed the shared Kimi key file during setup. If no key is available, still create the launcher; the launcher will prompt interactively on first use. When a key is available during setup, identify its type under **Determine The Key's Lane** before choosing the lane.

```text
Please provide your Kimi API key for the shared Kimi launcher key file, or confirm that the launcher should prompt on first run.
```

The generated launcher must not hard-code the API key and must not rely on shell-specific automatic env loading. It reads the shared key file directly at runtime, assigns the lane's auth variable (`ANTHROPIC_AUTH_TOKEN` on the **Using Kimi Platform API** lane, `ANTHROPIC_API_KEY` on the **Using Kimi Coding Plan** lane) for the launched Claude process only, and prompts/writes the key file if the file is missing.

## Determine The Key's Lane

Kimi open-platform keys and Kimi Code (coding plan) keys come from different consoles and authenticate against different endpoints. When a key is available, identify its type before choosing the lane: the lane must match the key or every request fails with `401 Invalid Authentication`. Choose the lane that matches the detected key type unless the user explicitly asks for a different lane.

Prefix heuristic (fast, community-observed — treat as a hint, not proof):

- `sk-kimi-...` — Kimi Code Console key → **Using Kimi Coding Plan** lane.
- `sk-...` — Kimi Open Platform key → **Using Kimi Platform API** lane.

Endpoint probe (reliable): each key type works on exactly one endpoint. Probe `/v1/models` and pick the lane whose endpoint returns `200`:

```bash
key=$(cat ~/.local/bin/kimi-api-key)   # or read the provided key
for url in https://api.moonshot.ai/v1/models \
           https://api.moonshot.cn/v1/models \
           https://api.kimi.com/coding/v1/models; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 \
         -H "Authorization: Bearer $key" "$url")
  echo "$code  $url"
done
```

- `200` from `api.moonshot.ai` or `api.moonshot.cn` — open-platform key → **Using Kimi Platform API** lane.
- `200` from `api.kimi.com/coding/v1/models` — coding-plan key → **Using Kimi Coding Plan** lane.

If the probe fails on every endpoint (network blocked or invalid key), fall back to the prefix heuristic, then to asking the user which console issued the key.

## Defaults

- Unix launcher path: `$HOME/.local/bin/claude-kimi`
- Unix shared key file: `$HOME/.local/bin/kimi-api-key`
- Windows launcher path: `%LOCALAPPDATA%\Programs\kimi-launchers\claude-kimi.ps1`
- Windows command shim path: `%LOCALAPPDATA%\Programs\kimi-launchers\claude-kimi.cmd`
- Windows shared key file: `%LOCALAPPDATA%\Programs\kimi-launchers\kimi-api-key`
- Default lane: when a key is available, the lane matching the detected key type under **Determine The Key's Lane**; otherwise **Using Kimi Platform API**. Use **Using Kimi Coding Plan** when the key is a coding-plan key, or when the user has a Kimi membership and asks for the coding-plan endpoint, or when the user wants help choosing between the lanes. The user's explicit lane choice always wins.
- Default startup model: `opus` — the launcher starts Claude Code with `--model opus`, and the `opus` alias resolves through `ANTHROPIC_DEFAULT_OPUS_MODEL` to the lane's most capable Kimi model (`kimi-k3` on the Platform API lane, `k3` on the Coding Plan lane).

Imsight's local launcher runs Claude Code with `--dangerously-skip-permissions` by default. The generator derives the auth lane, the tier mapping, and the compact window from `--base-url` and the model options.

## Check Latest Kimi Info First

Kimi model names, lane endpoints, and Claude Code settings change over time — the whole `kimi-k2-*` family is already deprecated. Before generating or updating a launcher, look up the latest information online instead of relying on memory or on the snapshot in this page:

- Kimi API Platform model list: `https://platform.kimi.ai/docs/models` — canonical lineup for the Platform API lane, including deprecation and sunset notices.
- Kimi API Platform guide "Use Kimi in Claude Code": `https://platform.kimi.ai/docs/guide/claude-code-kimi` — the Platform API lane's official Claude Code configuration.
- Kimi Code third-party coding-agent guide: `https://www.kimi.com/code/docs/en/third-party-tools/other-coding-agents.html` — canonical Coding Plan lane configuration, model names, and membership-tier availability.
- Kimi Code provider docs: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/providers.html` — Kimi-native provider endpoint shape.
- Claude Code model configuration docs: `https://code.claude.com/docs/en/model-config` and `https://code.claude.com/docs/en/settings` — how `/model`, `--model`, `ANTHROPIC_DEFAULT_*_MODEL`, `availableModels`, and `modelOverrides` behave in the current Claude Code release.
- Live API query — lists the models the user's key can actually call right now:

  ```bash
  curl -s https://api.moonshot.ai/v1/models \
    -H "Authorization: Bearer $(cat ~/.local/bin/kimi-api-key)" | jq -r '.data[].id'
  ```

  For the Coding Plan lane, use `https://api.kimi.com/coding/v1/models` with the coding key. Never print the key itself.

Rule of thumb: the docs pages for the official lineup, configuration, and deprecation schedule; `/v1/models` for what is actually enabled on the user's key. When online sources disagree with this page, the online sources win — update launcher defaults accordingly.

## Fallback Model Knowledge

Use this embedded snapshot only when the online sources above are unreachable. It is dated 2026-07-25 and goes stale.

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
- Verify the literal provider model id with `/v1/models` before mapping. Claude Code's `X[1m]` suffix is its own 1M-context notation, not necessarily a provider id — the coding endpoint rejects `k3[1m]` and serves the 1M model as literal `k3`.

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

This is the fallback lane when no key is available or the key is an open-platform key, following the Kimi API Platform guide "Use Kimi in Claude Code".

- Base URL: `https://api.moonshot.ai/anthropic`
- Auth: `ANTHROPIC_AUTH_TOKEN` with a key created on Kimi Open Platform (the launcher clears `ANTHROPIC_API_KEY` and `CLAUDE_CODE_OAUTH_TOKEN`)
- Startup model: `opus` (resolves to `kimi-k3` by default — thinking on by default, 1M context)
- Tier mapping: the generated launcher exports `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, `ANTHROPIC_DEFAULT_FABLE_MODEL`, and `CLAUDE_CODE_SUBAGENT_MODEL`, derived with **Mapping Rule: Map By Cost** (see the **Default Tier Mapping** snapshot for dated examples)
- `ENABLE_TOOL_SEARCH=false` (the Kimi endpoint does not support Claude Code Tool Search)
- `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1048576` for K3-class resolved startup models; `262144` for K2-series

Generate for this lane with the defaults:

```bash
<skill-dir>/scripts/create-claude-kimi-launcher.sh
```

Or explicitly, with a custom tier mapping:

```bash
<skill-dir>/scripts/create-claude-kimi-launcher.sh \
  --base-url https://api.moonshot.ai/anthropic \
  --model opus --model-opus kimi-k3 --model-sonnet kimi-k2.7-code --model-haiku kimi-k2.6
```

Verify inside Claude Code with `/status`: Base URL `https://api.moonshot.ai/anthropic`, Model resolving to the opus tier (`kimi-k3` by default). `/model sonnet` should switch to the sonnet tier (`kimi-k2.7-code` by default).

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

Generate for this lane by passing the coding-plan endpoint, for example Allegretto and above:

```bash
<skill-dir>/scripts/create-claude-kimi-launcher.sh \
  --base-url https://api.kimi.com/coding/ --model opus --model-opus k3-256k --model-fable k3
```

The generator derives `ANTHROPIC_API_KEY` auth, the tier defaults, and the compact window from the endpoint. Verify inside Claude Code with `/status`: Base URL `https://api.kimi.com/coding/`; the model name may still appear Claude-like even though calls go to the Kimi Code API.

## Official Kimi References

- Kimi API Platform guide "Use Kimi in Claude Code": `https://platform.kimi.ai/docs/guide/claude-code-kimi`
  - Relevant Claude Code settings: `ANTHROPIC_BASE_URL=https://api.moonshot.ai/anthropic`, `ANTHROPIC_AUTH_TOKEN=<key>`, every model variable set to the chosen model, `ENABLE_TOOL_SEARCH=false`, and `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1048576` for `kimi-k3` (262144 for `kimi-k2.7-code`).
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

## Create The Launcher

Use the bundled scripts from this skill. Resolve `<skill-dir>` to the `imsight-dev-box-init` skill directory that contains this reference.

If the installed skill copy lost the script's execute bit, invoke it through the interpreter instead of failing on `Permission denied`: `bash <skill-dir>/scripts/create-claude-kimi-launcher.sh ...` (or `pwsh -File ...ps1` on Windows).

## Ensure Launcher Directory On PATH

A launcher that is not on PATH fails with `command not found` in new terminals. After creating the launcher, make its directory resolvable in the user's everyday shell, not only in login shells.

On Unix, `~/.profile` typically adds `$HOME/.local/bin` for login shells only. Most terminal emulators start non-login interactive shells that read `~/.bashrc` (bash) or `~/.zshrc` (zsh) and never see that entry, so `claude-kimi` is missing from fresh terminals until the rc file adds it. Check a fresh interactive shell first:

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

`claude-kimi` runtime arguments are Claude Code arguments by default. The launcher may observe arguments only to avoid injecting duplicate defaults, such as not adding its default `--model` when the user already passed `--model`. It must not consume, rename, reorder, or reinterpret underlying Claude CLI arguments.

If a future launcher needs its own runtime flags, use launcher-prefixed names such as `--claude-kimi-key-file` or `--claude-kimi-no-default-model`, and strip only those prefixed launcher flags before calling `claude`.

### Unix Or Linux Shell

Create the launcher and, when available, seed the shared key file:

```bash
<skill-dir>/scripts/create-claude-kimi-launcher.sh --api-key "$KIMI_API_KEY"
```

If no key is available during setup, omit `--api-key`; the generated launcher will prompt for the key the first time it runs:

```bash
<skill-dir>/scripts/create-claude-kimi-launcher.sh
```

The script also accepts `--output`, `--key-file`, `--base-url`, `--model`, `--model-opus`, `--model-sonnet`, `--model-haiku`, `--model-fable`, `--model-subagent`, `--compact-window`, and `--claude-bin` when the user wants non-default values.

### Windows PowerShell

The PowerShell script creates a `.ps1` launcher and adjacent `.cmd` shim in a common `kimi-launchers` directory. The `.cmd` shim lets users run `claude-kimi` from `cmd.exe`, PowerShell, or other launchers when the directory is on `PATH`.

```powershell
& <skill-dir>\scripts\create-claude-kimi-launcher.ps1 -ApiKey $env:KIMI_API_KEY
```

If no key is available during setup, omit `-ApiKey`; the generated launcher will prompt for the key the first time it runs:

```powershell
& <skill-dir>\scripts\create-claude-kimi-launcher.ps1
```

The script also accepts `-OutputPath`, `-KeyFilePath`, `-BaseUrl`, `-Model`, `-ModelOpus`, `-ModelSonnet`, `-ModelHaiku`, `-ModelFable`, `-ModelSubagent`, `-CompactWindow`, and `-ClaudeBin` for non-default values.

## Verification

Verify the Unix launcher exists:

```bash
command -v claude-kimi
bash -ic 'command -v claude-kimi'   # must also resolve in a fresh non-login terminal; fix PATH per **Ensure Launcher Directory On PATH** if not
test -x "$HOME/.local/bin/claude-kimi"
ls -l "$HOME/.local/bin/claude-kimi"
test -f "$HOME/.local/bin/kimi-api-key" || echo "key file will be created on first run"
```

Verify the Windows launcher exists:

```powershell
Test-Path "$env:LOCALAPPDATA\Programs\kimi-launchers\claude-kimi.ps1"
Test-Path "$env:LOCALAPPDATA\Programs\kimi-launchers\claude-kimi.cmd"
Test-Path "$env:LOCALAPPDATA\Programs\kimi-launchers\kimi-api-key"
```

Inspect generated launchers and key files only with redaction:

```bash
rg -n 'kimi-api-key|ANTHROPIC_BASE_URL|ANTHROPIC_DEFAULT_|CLAUDE_CODE_SUBAGENT_MODEL|ENABLE_TOOL_SEARCH|CLAUDE_CODE_AUTO_COMPACT_WINDOW|dangerously-skip-permissions' "$HOME/.local/bin/claude-kimi"
test -f "$HOME/.local/bin/kimi-api-key" && sed 's/.*/<redacted>/' "$HOME/.local/bin/kimi-api-key"
```

```powershell
Select-String -Path "$env:LOCALAPPDATA\Programs\kimi-launchers\claude-kimi.ps1" -Pattern 'kimi-api-key|ANTHROPIC_BASE_URL|ANTHROPIC_DEFAULT_|CLAUDE_CODE_SUBAGENT_MODEL|ENABLE_TOOL_SEARCH|CLAUDE_CODE_AUTO_COMPACT_WINDOW|dangerously-skip-permissions'
if (Test-Path "$env:LOCALAPPDATA\Programs\kimi-launchers\kimi-api-key") { '<redacted>' }
```

Inside Claude Code, `/status` should show Base URL `https://api.moonshot.ai/anthropic` on the **Using Kimi Platform API** lane or `https://api.kimi.com/coding/` on the **Using Kimi Coding Plan** lane, with the model resolving to the opus tier (`kimi-k3` or `k3` by default). The generated launcher must still invoke `claude` with `--dangerously-skip-permissions`.

## Notes

- Store the Kimi key in the shared `kimi-api-key` file next to the launcher, not in the launcher script itself.
- The shared key file is intentionally named generically so future launchers such as `codex-kimi` and `opencode-kimi` can live in the same directory and read the same file directly.
- Keep launcher generator scripts in `<skill-dir>/scripts/`; do not place generated helper scripts in `references/`.
- Prefer `ANTHROPIC_AUTH_TOKEN` on the **Using Kimi Platform API** lane and clear `ANTHROPIC_API_KEY` and `CLAUDE_CODE_OAUTH_TOKEN` so Claude Code does not choose an older auth lane. On the **Using Kimi Coding Plan** lane (`api.kimi.com`), the generated launcher uses `ANTHROPIC_API_KEY` instead and clears `ANTHROPIC_AUTH_TOKEN`.
- The default startup model is `opus`. Override it with `CLAUDE_KIMI_MODEL=<model> claude-kimi ...` or an explicit Claude Code `--model`; `CLAUDE_KIMI_MODEL` is the single knob that resets the startup model and every tier at once. Per-tier runtime overrides are `CLAUDE_KIMI_MODEL_OPUS`, `CLAUDE_KIMI_MODEL_SONNET`, `CLAUDE_KIMI_MODEL_HAIKU`, `CLAUDE_KIMI_MODEL_FABLE`, and `CLAUDE_KIMI_MODEL_SUBAGENT`.
- If `claude` is not on `PATH`, install Claude Code first before testing the launcher.
- If first launch gets stuck in Claude Code onboarding, run the official Kimi guide's Node onboarding-complete script before starting `claude-kimi`.

## Guardrails

- DO NOT print, hard-code, or echo the Kimi API key in commands, responses, or the generated launcher.
- DO NOT map Claude Code model aliases to highspeed Kimi variants (`kimi-k2.7-code-highspeed`, `kimi-for-coding-highspeed`) in launcher defaults; keep them selectable only by direct model name or `availableModels` picker entries.
- DO NOT remove the `--dangerously-skip-permissions` flag from the generated launcher unless the user explicitly asks for a permission-prompting launcher.
