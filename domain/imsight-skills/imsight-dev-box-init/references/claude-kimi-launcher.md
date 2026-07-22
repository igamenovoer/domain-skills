# Claude-Kimi Launcher Setup

Use this reference when the user wants a local `claude-kimi` launcher that runs Claude Code against a Kimi Anthropic-compatible endpoint.

## Workflow

1. Resolve API-key handling under **Required Input** without printing or hard-coding the key.
2. Apply the platform-specific paths in **Defaults** and choose the lane from **Using Kimi Platform API** or **Using Kimi Coding Plan**.
3. Create the launcher and preserve **Runtime Argument Contract**.
4. Run every applicable check in **Verification**.

If the task does not map cleanly to these steps, plan only from this page's inputs, defaults, launcher contract, and verification rules; keep credentials out of commands and responses.

## Required Input

You can provide a Kimi API key during setup, or let the generated launcher prompt for it on first run. Prefer an existing `KIMI_API_KEY` or `ANTHROPIC_API_KEY` only when the user explicitly wants to seed the shared Kimi key file during setup. If no key is available, still create the launcher; the launcher will prompt interactively on first use.

```text
Please provide your Kimi API key for the shared Kimi launcher key file, or confirm that the launcher should prompt on first run.
```

Do not print the key. Do not include it in final responses. Avoid echoing full commands that contain the key.

The generated launcher must not hard-code the API key and must not rely on shell-specific automatic env loading. It reads the shared key file directly at runtime, assigns the lane's auth variable (`ANTHROPIC_AUTH_TOKEN` on the **Using Kimi Platform API** lane, `ANTHROPIC_API_KEY` on the **Using Kimi Coding Plan** lane) for the launched Claude process only, and prompts/writes the key file if the file is missing.

## Defaults

- Unix launcher path: `$HOME/.local/bin/claude-kimi`
- Unix shared key file: `$HOME/.local/bin/kimi-api-key`
- Windows launcher path: `%LOCALAPPDATA%\Programs\kimi-launchers\claude-kimi.ps1`
- Windows command shim path: `%LOCALAPPDATA%\Programs\kimi-launchers\claude-kimi.cmd`
- Windows shared key file: `%LOCALAPPDATA%\Programs\kimi-launchers\kimi-api-key`
- Default lane: **Using Kimi Platform API** with model `kimi-k3`. Use **Using Kimi Coding Plan** when the user has a Kimi membership and asks for the coding-plan endpoint, or when the user wants help choosing between the lanes.

Imsight's local launcher runs Claude Code with `--dangerously-skip-permissions` by default. The generator derives the auth lane and the compact window from `--base-url` and `--model`.

## Using Kimi Platform API

This is the default lane, following the Kimi API Platform guide "Use Kimi in Claude Code".

- Base URL: `https://api.moonshot.ai/anthropic`
- Auth: `ANTHROPIC_AUTH_TOKEN` with a key created on Kimi Open Platform (the launcher clears `ANTHROPIC_API_KEY` and `CLAUDE_CODE_OAUTH_TOKEN`)
- Default model: `kimi-k3` (thinking on by default, 1M context)
- Model variables: `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, and `CLAUDE_CODE_SUBAGENT_MODEL` all set to the resolved model
- `ENABLE_TOOL_SEARCH=false` (the Kimi endpoint does not support Claude Code Tool Search)
- `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1048576` for `kimi-k3`; `262144` for K2-series models

Model alternates on this lane, when the user asks for one or wants help choosing:

| Model | Notes |
| --- | --- |
| `kimi-k3` (default) | Thinking on by default; works out of the box; 1M context, window `1048576` |
| `kimi-k2.7-code` | Thinking always on — keep Thinking enabled in Claude Code or requests are rejected; window `262144` |
| `kimi-k2.7-code-highspeed` | About 5-6x output speed over `kimi-k2.7-code`; same thinking requirement and window |
| `kimi-k2.6` | Thinking optional; suited to latency-sensitive simple tasks |

Generate for this lane with the defaults, or explicitly:

```bash
<skill-dir>/scripts/create-claude-kimi-launcher.sh --base-url https://api.moonshot.ai/anthropic --model kimi-k3
```

Verify inside Claude Code with `/status`: Base URL `https://api.moonshot.ai/anthropic`, Model `kimi-k3`.

## Using Kimi Coding Plan

Use this lane when the user has a Kimi membership with Kimi Code benefits and asks for the coding-plan endpoint, or wants help choosing between the lanes. It follows the Kimi Code third-party coding-agent guide.

- Base URL: `https://api.kimi.com/coding/`
- Auth: `ANTHROPIC_API_KEY` with a key created in the Kimi Code Console (the launcher clears `ANTHROPIC_AUTH_TOKEN` and `CLAUDE_CODE_OAUTH_TOKEN`)
- Model variables: `ANTHROPIC_DEFAULT_FABLE_MODEL`, `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, and `CLAUDE_CODE_SUBAGENT_MODEL` all set to the resolved model
- `CLAUDE_CODE_MAX_CONTEXT_TOKENS` matches the derived window; the launcher exports `CLAUDE_CODE_EFFORT_LEVEL=max` only when the resolved model is K3 (`k3` or `k3[1m]`), because only K3 supports that field
- The launcher passes the model with Claude Code `--model` instead of exporting `ANTHROPIC_MODEL`; stale model entries in the `env` field of `~/.claude/settings.json` override launcher exports, so clean them before first launch (the coding guide's pre-launch Node script removes them and also sets `penguinModeOrgEnabled` alongside `hasCompletedOnboarding`)

Pick the model by membership tier:

| Plan | Available models | Window |
| --- | --- | --- |
| Andante | `kimi-for-coding` | `262144` |
| Moderato | `k3` or `kimi-for-coding` | `262144` |
| Allegretto and above | `k3[1m]`, `kimi-for-coding`, `kimi-for-coding-highspeed` | `1048576` for `k3[1m]`, `262144` for the K2.7 Code series |

Thinking: K3 models think by default. `kimi-for-coding` (K2.7 Code) requires Thinking enabled in Claude Code (Option+T on macOS, Alt+T on Windows/Linux); without it, requests fall back to K2.6.

Generate for this lane by passing the coding-plan endpoint and the tier's model, for example Allegretto and above:

```bash
<skill-dir>/scripts/create-claude-kimi-launcher.sh --base-url https://api.kimi.com/coding/ --model 'k3[1m]'
```

The generator derives `ANTHROPIC_API_KEY` auth and the compact window from the model. Verify inside Claude Code with `/status`: Base URL `https://api.kimi.com/coding/`; the model name may still appear Claude-like even though calls go to the Kimi Code API.

## Official Kimi References

- Kimi API Platform guide "Use Kimi in Claude Code": `https://platform.kimi.ai/docs/guide/claude-code-kimi`
  - Relevant Claude Code settings: `ANTHROPIC_BASE_URL=https://api.moonshot.ai/anthropic`, `ANTHROPIC_AUTH_TOKEN=<key>`, every model variable set to the chosen model, `ENABLE_TOOL_SEARCH=false`, and `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1048576` for `kimi-k3` (262144 for `kimi-k2.7-code`).
  - Default model `kimi-k3` thinks by default and works out of the box. `/status` in Claude Code should show the Moonshot base URL and `kimi-k3`.
- Kimi Code official third-party coding-agent guide: `https://www.kimi.com/code/docs/en/third-party-tools/other-coding-agents.html`
  - The **Using Kimi Coding Plan** lane: `ANTHROPIC_BASE_URL=https://api.kimi.com/coding/`, `ANTHROPIC_API_KEY=<key>`, every model variable set to the tier's model, `CLAUDE_CODE_MAX_CONTEXT_TOKENS`, and `CLAUDE_CODE_EFFORT_LEVEL=max` for K3 models.
  - The page also includes a pre-first-launch Node script that sets `penguinModeOrgEnabled` and `hasCompletedOnboarding` and removes stale model entries from `~/.claude/settings.json`.
- Kimi Code provider docs: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/providers.html`
  - Confirms Kimi Code's provider endpoint shape: `https://api.kimi.com/coding/v1` for Kimi-native provider configuration.
- Kimi Code environment variable docs: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/environment-variables.html`
  - Use for Kimi CLI's own `KIMI_*` variables. Do not substitute these for Claude Code's `ANTHROPIC_*` variables.

## Create The Launcher

Use the bundled scripts from this skill. Resolve `<skill-dir>` to the `imsight-dev-box-init` skill directory that contains this reference.

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

The script also accepts `--output`, `--key-file`, `--base-url`, `--model`, `--compact-window`, and `--claude-bin` when the user wants non-default values.

### Windows PowerShell

The PowerShell script creates a `.ps1` launcher and adjacent `.cmd` shim in a common `kimi-launchers` directory. The `.cmd` shim lets users run `claude-kimi` from `cmd.exe`, PowerShell, or other launchers when the directory is on `PATH`.

```powershell
& <skill-dir>\scripts\create-claude-kimi-launcher.ps1 -ApiKey $env:KIMI_API_KEY
```

If no key is available during setup, omit `-ApiKey`; the generated launcher will prompt for the key the first time it runs:

```powershell
& <skill-dir>\scripts\create-claude-kimi-launcher.ps1
```

## Verification

Verify the Unix launcher exists:

```bash
command -v claude-kimi
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
rg -n 'kimi-api-key|ANTHROPIC_BASE_URL|ANTHROPIC_DEFAULT_|CLAUDE_CODE_SUBAGENT_MODEL|ENABLE_TOOL_SEARCH|CLAUDE_CODE_AUTO_COMPACT_WINDOW' "$HOME/.local/bin/claude-kimi"
test -f "$HOME/.local/bin/kimi-api-key" && sed 's/.*/<redacted>/' "$HOME/.local/bin/kimi-api-key"
```

```powershell
Select-String -Path "$env:LOCALAPPDATA\Programs\kimi-launchers\claude-kimi.ps1" -Pattern 'kimi-api-key|ANTHROPIC_BASE_URL|ANTHROPIC_DEFAULT_|CLAUDE_CODE_SUBAGENT_MODEL|ENABLE_TOOL_SEARCH|CLAUDE_CODE_AUTO_COMPACT_WINDOW'
if (Test-Path "$env:LOCALAPPDATA\Programs\kimi-launchers\kimi-api-key") { '<redacted>' }
```

Inside Claude Code, `/status` should show Base URL `https://api.moonshot.ai/anthropic` and Model `kimi-k3` on the **Using Kimi Platform API** lane, or Base URL `https://api.kimi.com/coding/` on the **Using Kimi Coding Plan** lane.

## Notes

- Store the Kimi key in the shared `kimi-api-key` file next to the launcher, not in the launcher script itself.
- The shared key file is intentionally named generically so future launchers such as `codex-kimi` and `opencode-kimi` can live in the same directory and read the same file directly.
- Keep launcher generator scripts in `<skill-dir>/scripts/`; do not place generated helper scripts in `references/`.
- Prefer `ANTHROPIC_AUTH_TOKEN` on the **Using Kimi Platform API** lane and clear `ANTHROPIC_API_KEY` and `CLAUDE_CODE_OAUTH_TOKEN` so Claude Code does not choose an older auth lane. On the **Using Kimi Coding Plan** lane (`api.kimi.com`), the generated launcher uses `ANTHROPIC_API_KEY` instead and clears `ANTHROPIC_AUTH_TOKEN`.
- The default model is `kimi-k3`. Override it only when needed with `CLAUDE_KIMI_MODEL=<model> claude-kimi ...` or pass an explicit Claude Code `--model`; the `CLAUDE_KIMI_MODEL` override also drives every tier and subagent model variable.
- If `claude` is not on `PATH`, install Claude Code first before testing the launcher.
- If first launch gets stuck in Claude Code onboarding, run the official Kimi guide's Node onboarding-complete script before starting `claude-kimi`.
- The launcher intentionally uses `--dangerously-skip-permissions` as Imsight's default Claude Code posture. Remove that flag only when the user explicitly asks for a permission-prompting launcher.
