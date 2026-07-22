# Houmao Claude-Kimi Specialist Setup

Use this reference when the user wants a Houmao specialist that launches Claude Code with Kimi Code credentials.

## Workflow

1. Resolve the Kimi credential under **Required Input** without printing it.
2. Ask the existing proxy-environment question when the user has not answered it.
3. Apply **Defaults**, **Preconditions**, and the Claude onboarding configuration.
4. Create the specialist and run every applicable check in **Verification**.

If the task does not map cleanly to these steps, plan only from this page's credential, proxy, specialist, and verification rules; ask for required input rather than weakening secret handling.

## Required Input

You need a Kimi API key. Prefer `KIMI_API_KEY` or `ANTHROPIC_API_KEY` when already set by the user. If a `claude-kimi` launcher already exists from `references/claude-kimi-launcher.md`, prefer reading the shared `kimi-api-key` file next to that launcher. Never print the key.

On Windows, check `%LOCALAPPDATA%\Programs\kimi-launchers\kimi-api-key`. On Unix, check `$HOME/.local/bin/kimi-api-key`.

If there is no usable key and no explicit key in the environment, ask:

```text
Please provide your Kimi API key for the Houmao Claude+Kimi specialist.
```

Do not print the key. Do not include it in final responses. Avoid echoing full commands that contain the key.

## Optional Proxy Env Prompt

If the user did not already say whether to include proxy settings, ask before creating the specialist:

```text
Do you want this Houmao specialist to inherit the current shell's proxy-related environment variables?
```

Explain that this copies only currently set proxy env records such as `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`, `NO_PROXY`, and lowercase variants into the specialist's durable launch env. If the user says no, omit proxy env records.

## Defaults

- Specialist name: use the user's requested name, otherwise ask. A common default is `generic-kimi`.
- Tool lane: `claude`
- Credential name: `<specialist-name>-creds`
- System prompt: omit unless the user requests one.
- Default lane: **Using Kimi Platform API** with model `kimi-k3`. Use **Using Kimi Coding Plan** when the user has a Kimi membership and asks for the coding-plan endpoint, or when the user wants help choosing between the lanes.

These defaults keep the Kimi key in Houmao's Claude credential bundle while matching the lane configuration in `references/claude-kimi-launcher.md`.

## Using Kimi Platform API

This is the default lane, following the Kimi API Platform guide "Use Kimi in Claude Code".

- Base URL: `https://api.moonshot.ai/anthropic`
- Model: `kimi-k3` (thinking on by default, 1M context)
- Auth: the Houmao credential bundle materializes the key as `ANTHROPIC_API_KEY`, while the platform guide documents `ANTHROPIC_AUTH_TOKEN`. Create this key on Kimi Open Platform. If launches return 401 on this lane, ask the user before storing `ANTHROPIC_AUTH_TOKEN` with the same key as a specialist env record.
- Env records: `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1048576`, `ENABLE_TOOL_SEARCH=false`, and `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, `CLAUDE_CODE_SUBAGENT_MODEL` all set to the model.

Model alternates on this lane, when the user asks for one or wants help choosing: `kimi-k2.7-code` (thinking always on; keep Thinking enabled in Claude Code; window `262144`), `kimi-k2.7-code-highspeed` (about 5-6x output speed, same thinking requirement and window), and `kimi-k2.6` (thinking optional; suited to latency-sensitive simple tasks). When switching models, update every model env record and match `CLAUDE_CODE_AUTO_COMPACT_WINDOW` to the model.

## Using Kimi Coding Plan

Use this lane when the user has a Kimi membership with Kimi Code benefits and asks for the coding-plan endpoint, or wants help choosing between the lanes. It follows the Kimi Code third-party coding-agent guide.

- Base URL: `https://api.kimi.com/coding/`
- Auth: the credential bundle's `ANTHROPIC_API_KEY` is exactly the auth variable this lane expects. Create this key in the Kimi Code Console (membership).
- Env records: `ANTHROPIC_DEFAULT_FABLE_MODEL`, `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, and `CLAUDE_CODE_SUBAGENT_MODEL` all set to the model, plus `CLAUDE_CODE_AUTO_COMPACT_WINDOW` and `CLAUDE_CODE_MAX_CONTEXT_TOKENS` matching the model's context, and `CLAUDE_CODE_EFFORT_LEVEL=max` only for K3 models.
- Pick the model by membership tier: Andante uses `kimi-for-coding` (window `262144`); Moderato uses `k3` or `kimi-for-coding` (`262144`); Allegretto and above uses `k3[1m]` (`1048576`), `kimi-for-coding`, or `kimi-for-coding-highspeed` (`262144`).
- Thinking: K3 models think by default. `kimi-for-coding` (K2.7 Code) requires Thinking enabled in Claude Code (Option+T on macOS, Alt+T on Windows/Linux); without it, requests fall back to K2.6.

For this lane, replace the base URL, model, and env records in the create command per the tier list, for example Allegretto and above:

```bash
  --base-url 'https://api.kimi.com/coding/' \
  --model 'k3[1m]' \
  --env-set CLAUDE_CODE_AUTO_COMPACT_WINDOW=1048576 \
  --env-set CLAUDE_CODE_MAX_CONTEXT_TOKENS=1048576 \
  --env-set CLAUDE_CODE_EFFORT_LEVEL=max \
  --env-set ANTHROPIC_DEFAULT_FABLE_MODEL='k3[1m]' \
  --env-set ANTHROPIC_DEFAULT_OPUS_MODEL='k3[1m]' \
  --env-set ANTHROPIC_DEFAULT_SONNET_MODEL='k3[1m]' \
  --env-set ANTHROPIC_DEFAULT_HAIKU_MODEL='k3[1m]' \
  --env-set CLAUDE_CODE_SUBAGENT_MODEL='k3[1m]' \
```

Drop `CLAUDE_CODE_EFFORT_LEVEL` and use `262144` for non-K3 models. Tell the user to clean stale `ANTHROPIC_*` model entries from the `env` field of `~/.claude/settings.json` before first launch (the coding guide's pre-launch Node script removes them and also sets `penguinModeOrgEnabled`).

## Official Kimi References

- Kimi API Platform guide "Use Kimi in Claude Code": `https://platform.kimi.ai/docs/guide/claude-code-kimi`
  - Relevant Claude Code settings: `ANTHROPIC_BASE_URL=https://api.moonshot.ai/anthropic`, `ANTHROPIC_AUTH_TOKEN=<key>`, every model variable set to the chosen model, `ENABLE_TOOL_SEARCH=false`, and `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1048576` for `kimi-k3` (262144 for `kimi-k2.7-code`).
  - Default model `kimi-k3` thinks by default and works out of the box. `/status` in Claude Code should show the Moonshot base URL and `kimi-k3`.
- Kimi Code official third-party coding-agent guide: `https://www.kimi.com/code/docs/en/third-party-tools/other-coding-agents.html`
  - The **Using Kimi Coding Plan** lane: `ANTHROPIC_BASE_URL=https://api.kimi.com/coding/`, `ANTHROPIC_API_KEY=<key>`, every model variable set to the tier's model, `CLAUDE_CODE_MAX_CONTEXT_TOKENS`, and `CLAUDE_CODE_EFFORT_LEVEL=max` for K3 models.
  - The guide says `/status` should show the Kimi base URL after launch; model names may still appear Claude-like even though calls go to Kimi.
- Kimi Code provider docs: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/providers.html`
  - Confirms the Kimi-native provider endpoint `https://api.kimi.com/coding/v1`; for Claude Code, use the Anthropic-compatible endpoint from the platform guide instead.

## Preconditions

Verify `houmao-mgr` and a Houmao project overlay:

```bash
command -v houmao-mgr
houmao-mgr project status
```

If no project overlay exists and the user wants to create the specialist in the current directory, initialize one:

```bash
houmao-mgr project init
```

## Configure Claude Global Onboarding State

Before creating or launching the specialist, configure Claude Code's global settings for the same Unix user that will run `houmao-mgr`. This mirrors the `claude-kimi` launcher and prevents Houmao-launched Claude Code sessions from stopping at Anthropic's default onboarding/login flow.

Prefer Node when available:

```bash
node --eval "
  const fs = require('fs');
  const os = require('os');
  const path = require('path');
  const filePath = path.join(os.homedir(), '.claude.json');
  if (fs.existsSync(filePath)) {
    const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
    fs.writeFileSync(
      filePath,
      JSON.stringify({ ...content, hasCompletedOnboarding: true }, null, 2),
      'utf-8'
    );
  } else {
    fs.writeFileSync(
      filePath,
      JSON.stringify({ hasCompletedOnboarding: true }, null, 2),
      'utf-8'
    );
  }
"
```

If Node is unavailable, update `~/.claude.json` with another JSON-aware tool. Preserve existing keys and set only:

```json
{
  "hasCompletedOnboarding": true
}
```

## Create The Specialist

If the key is not already in `ANTHROPIC_API_KEY`, recover it from the shared Unix Kimi key file when available:

```bash
if [ -z "${ANTHROPIC_API_KEY:-}" ] && [ -r "$HOME/.local/bin/kimi-api-key" ]; then
  IFS= read -r ANTHROPIC_API_KEY < "$HOME/.local/bin/kimi-api-key"
fi
```

Then create the specialist. Start with the **Using Kimi Platform API** settings; for **Using Kimi Coding Plan**, substitute the base URL, model, and env records from that section:

```bash
houmao-mgr project specialist create \
  --name "$SPECIALIST_NAME" \
  --tool claude \
  --credential "$SPECIALIST_NAME-creds" \
  --api-key "$ANTHROPIC_API_KEY" \
  --base-url 'https://api.moonshot.ai/anthropic' \
  --model 'kimi-k3' \
  --env-set CLAUDE_CODE_AUTO_COMPACT_WINDOW=1048576 \
  --env-set ENABLE_TOOL_SEARCH=false \
  --env-set ANTHROPIC_DEFAULT_OPUS_MODEL=kimi-k3 \
  --env-set ANTHROPIC_DEFAULT_SONNET_MODEL=kimi-k3 \
  --env-set ANTHROPIC_DEFAULT_HAIKU_MODEL=kimi-k3 \
  --env-set CLAUDE_CODE_SUBAGENT_MODEL=kimi-k3 \
  --env-set CLAUDE_CODE_SKIP_BEDROCK_AUTH=1 \
  --env-set CLAUDE_CODE_SKIP_VERTEX_AUTH=1 \
  --env-set DISABLE_TELEMETRY=1 \
  --env-set DISABLE_ERROR_REPORTING=1
```

If the user opted into proxy envs, append every currently set proxy variable to the create command. Build the argument list so unset variables are skipped:

```bash
args=(
  houmao-mgr project specialist create
  --name "$SPECIALIST_NAME"
  --tool claude
  --credential "$SPECIALIST_NAME-creds"
  --api-key "$ANTHROPIC_API_KEY"
  --base-url 'https://api.moonshot.ai/anthropic'
  --model 'kimi-k3'
  --env-set CLAUDE_CODE_AUTO_COMPACT_WINDOW=1048576
  --env-set ENABLE_TOOL_SEARCH=false
  --env-set ANTHROPIC_DEFAULT_OPUS_MODEL=kimi-k3
  --env-set ANTHROPIC_DEFAULT_SONNET_MODEL=kimi-k3
  --env-set ANTHROPIC_DEFAULT_HAIKU_MODEL=kimi-k3
  --env-set CLAUDE_CODE_SUBAGENT_MODEL=kimi-k3
  --env-set CLAUDE_CODE_SKIP_BEDROCK_AUTH=1
  --env-set CLAUDE_CODE_SKIP_VERTEX_AUTH=1
  --env-set DISABLE_TELEMETRY=1
  --env-set DISABLE_ERROR_REPORTING=1
)
for key in HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY http_proxy https_proxy all_proxy no_proxy; do
  if [ -n "${!key+x}" ]; then
    args+=(--env-set "$key=${!key}")
  fi
done
"${args[@]}"
```

When replacing an existing specialist intentionally, add `--yes` to the create command only after confirming overwrite with the user.

## Verification

Check the specialist and Claude credential registration:

```bash
houmao-mgr project specialist get --name "$SPECIALIST_NAME"
houmao-mgr project credentials claude list
```

Check materialized non-secret launcher settings without revealing the key:

```bash
rg -n 'kimi-k3|CLAUDE_CODE_AUTO_COMPACT_WINDOW|ENABLE_TOOL_SEARCH|ANTHROPIC_DEFAULT_|CLAUDE_CODE_SUBAGENT_MODEL|CLAUDE_CODE_SKIP|DISABLE_TELEMETRY|DISABLE_ERROR_REPORTING|ANTHROPIC_BASE_URL' .houmao
rg -n 'ANTHROPIC_API_KEY' .houmao | sed -E 's/(ANTHROPIC_API_KEY[=:] ?).*/\1<redacted>/'
```

Verify Claude's global onboarding state without exposing unrelated settings:

```bash
node --eval "
  const fs = require('fs');
  const os = require('os');
  const path = require('path');
  const filePath = path.join(os.homedir(), '.claude.json');
  const content = fs.existsSync(filePath)
    ? JSON.parse(fs.readFileSync(filePath, 'utf-8'))
    : {};
  console.log('hasCompletedOnboarding=' + String(content.hasCompletedOnboarding === true));
"
```

## Notes

- Store the Kimi key and `ANTHROPIC_BASE_URL` in the Houmao credential bundle, not as specialist `--env-set` records.
- Store launcher behavior flags such as `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1048576` and `ENABLE_TOOL_SEARCH=false` as specialist env records so launched agents inherit the same Kimi-oriented Claude Code posture.
- Claude's global `hasCompletedOnboarding` setting is host-user state, not Houmao specialist metadata. Configure it before launch for the same account that starts Houmao agents.
- Use the same lane and model as the `claude-kimi` launcher unless the user explicitly asks otherwise; see **Using Kimi Platform API** and **Using Kimi Coding Plan**.
- Proxy envs are optional because `--env-set` makes them durable specialist launch defaults. Ask when the user's preference is unknown.
