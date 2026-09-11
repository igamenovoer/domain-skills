---
metadata:
  skill_invocation_notation: >
    Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
    SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
    accepted only as legacy input when SKILL-MAIN.md is absent.
    Skill and subskill entrypoints use bare object paths: `X` invokes skill X and
    `X->Y->Z` invokes subskill Z. Subcommands use parenthesized components:
    `X->cmd()` invokes a direct subcommand, `X->Y->cmd()` invokes a subcommand of
    subskill Y, and `X->parent()->child()` invokes child subcommand child exposed
    by parent subcommand parent. Intermediate subcommands act as object generators.
    Forms such as `X()` and `X->Y()` are invalid for skill or subskill entrypoints.
---

# Claude-OpenLux Launcher Setup

Use this reference when the user wants a local `claude-openlux` launcher that runs Claude Code against the OpenLux relay (`https://api.openlux.ai`). OpenLux replaces the retired Yunwu relay (`yunwu.ai` no longer serves); migrate any `claude-yunwu` launcher to this guide.

## Workflow

1. Resolve API-key handling under **Required Input** without printing the key.
2. Resolve the launcher's name, paths, and endpoint under **Defaults**.
3. Create the launcher from the template in **Create The Launcher**, preserving **Runtime Argument Contract**.
4. Put the launcher directory on PATH for new shells, following the PATH section in `claude-kimi-launcher.md`.
5. Run every applicable check in **Verification**.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's inputs, defaults, launcher contract, verification rules, and user constraints, then execute the plan without exposing credentials.

## Required Input

You can provide an OpenLux API key during setup, or let the generated launcher fail with a clear message until the key file exists. Prefer an existing `OPENLUX_API_KEY` only when the user explicitly wants to seed the shared key file during setup.

```text
Please provide your OpenLux API key for the shared OpenLux launcher key file, or confirm that you will create the key file yourself.
```

The generated launcher must not hard-code the API key. It reads the shared key file directly at runtime and assigns `ANTHROPIC_AUTH_TOKEN` for the launched Claude process only. Embed the key in the launcher script itself only when the user explicitly requests that layout; in that case the launcher file must be `chmod 700` and must never be committed or shared.

## Defaults

- Unix launcher path: `$HOME/.local/bin/claude-openlux`. Omit provider pricing or discount suffixes (such as token-group names like `0.5x`) from launcher and key-file names by default; they encode the provider's billing tiers, go stale when the plan changes, and leak account details into shell history. Add a suffix only when the user explicitly runs several OpenLux keys side by side, and then choose a neutral descriptor such as `claude-openlux-b` rather than the provider's group name.
- Unix shared key file: `$HOME/.local/bin/openlux-api-key` (one file per box; a second key gets a neutral sibling name such as `openlux-api-key-b`).
- Base URL: `https://api.openlux.ai`
- Auth: `ANTHROPIC_AUTH_TOKEN` with a key from the OpenLux console; the launcher clears `ANTHROPIC_API_KEY` and `CLAUDE_CODE_OAUTH_TOKEN` so Claude Code does not choose an older auth lane.
- `API_TIMEOUT_MS=300000` and `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`, both overridable by the caller. These follow the OpenLux tutorial recommendation.
- `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1`, overridable by the caller. Without it, the `/model` picker shows only Claude Code's built-in five-row lineup (verified on Claude Code v2.1.268); with it, the picker additionally lists the relay's advertised models such as Fable 5 and Fable 5.1 with gateway-supplied descriptions.
- Official OpenLux Claude Code tutorial: `https://doc.openlux.ai/tutorials/plugins-7010249`.

Imsight's local launcher runs Claude Code with `--dangerously-skip-permissions` by default.

## Create The Launcher

Resolve `<coding-agent-subskill-dir>` to the `subskills/coding-agent/` directory whose `references/` folder contains this page. Write the following template to the resolved launcher path and `chmod 700` the result:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Claude Code launcher for the OpenLux relay.
# Config is injected via environment only; settings.json is left untouched.
# Ref: https://doc.openlux.ai/tutorials/plugins-7010249

key_file="$HOME/.local/bin/openlux-api-key"
if [[ ! -f "$key_file" ]]; then
  echo "claude-openlux: key file $key_file missing; store your OpenLux key there" >&2
  exit 1
fi

export ANTHROPIC_AUTH_TOKEN="$(tr -d '[:space:]' < "$key_file")"
export ANTHROPIC_BASE_URL="https://api.openlux.ai"
unset ANTHROPIC_API_KEY CLAUDE_CODE_OAUTH_TOKEN

# Recommended by the OpenLux tutorial: 300s timeout, disable experimental betas.
export API_TIMEOUT_MS="${API_TIMEOUT_MS:-300000}"
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS="${CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS:-1}"

# List the relay's advertised models (Fable 5, Fable 5.1, ...) in the /model
# picker; without this the picker shows only the built-in lineup.
export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="${CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY:-1}"

# Do not pin model names: the relay serves whatever the key's plan provides.
# Clear any ambient model overrides so they cannot leak into this session.
unset ANTHROPIC_MODEL \
      ANTHROPIC_DEFAULT_OPUS_MODEL \
      ANTHROPIC_DEFAULT_SONNET_MODEL \
      ANTHROPIC_DEFAULT_HAIKU_MODEL \
      ANTHROPIC_DEFAULT_FABLE_MODEL \
      CLAUDE_CODE_SUBAGENT_MODEL

if command -v node >/dev/null 2>&1; then
  node --eval "
    const fs = require('fs');
    const os = require('os');
    const path = require('path');
    const filePath = path.join(os.homedir(), '.claude.json');
    const content = fs.existsSync(filePath)
      ? JSON.parse(fs.readFileSync(filePath, 'utf-8'))
      : {};
    fs.writeFileSync(
      filePath,
      JSON.stringify({ ...content, hasCompletedOnboarding: true }, null, 2),
      'utf-8'
    );
  "
fi

claude_bin=''
for candidate in "$HOME"/.nvm/versions/node/*/bin/claude "$HOME"/.bun/bin/claude "$HOME"/.local/bin/claude; do
  if [[ -x "$candidate" ]]; then
    claude_bin="$candidate"
    break
  fi
done
if [[ -z "$claude_bin" ]]; then
  claude_bin="$(command -v claude || true)"
fi
if [[ -z "$claude_bin" ]]; then
  echo "claude-openlux: claude binary not found" >&2
  exit 127
fi

# No --model injection: model selection is left to the relay unless the
# caller passes one explicitly.
exec "$claude_bin" --dangerously-skip-permissions "$@"
```

The candidate loop covers nvm, bun, and `~/.local/bin` installs before falling back to `command -v claude`, so prefer the most specific install over an ambient one.

## Runtime Argument Contract

`claude-openlux` runtime arguments are Claude Code arguments. The launcher passes every argument through unchanged and injects no `--model` default; model selection is left to the relay unless the caller passes `--model` explicitly. It must not consume, rename, reorder, or reinterpret underlying Claude CLI arguments.

## Verification

Verify the launcher exists and resolves in fresh shells:

```bash
command -v claude-openlux
bash -ic 'command -v claude-openlux'   # must also resolve in a fresh non-login terminal
test -x "$HOME/.local/bin/claude-openlux"
test -f "$HOME/.local/bin/openlux-api-key" || echo "key file still needed"
```

Inspect the generated launcher and key file only with redaction:

```bash
rg -n 'openlux-api-key|ANTHROPIC_AUTH_TOKEN|ANTHROPIC_BASE_URL|API_TIMEOUT_MS|DISABLE_EXPERIMENTAL_BETAS|GATEWAY_MODEL_DISCOVERY|dangerously-skip-permissions' "$HOME/.local/bin/claude-openlux"
test -f "$HOME/.local/bin/openlux-api-key" && sed 's/.*/<redacted>/' "$HOME/.local/bin/openlux-api-key"
```

Verify the relay exposes the official Anthropic API surface. Every model id must start with `claude-`:

```bash
curl -s --max-time 20 https://api.openlux.ai/v1/models \
  -H "x-api-key: $(tr -d '[:space:]' < "$HOME/.local/bin/openlux-api-key")" \
  -H "anthropic-version: 2023-06-01" \
  | python3 -c "import json,sys; ids=[m['id'] for m in json.load(sys.stdin)['data']]; print('\n'.join(ids)); assert ids and all(i.startswith('claude-') for i in ids), 'relay exposes non-official model ids'"
```

Inside Claude Code, `/status` should show Base URL `https://api.openlux.ai`, and the `/model` picker should list official names such as Opus and Fable 5 rather than upstream ids. The generated launcher must still invoke `claude` with `--dangerously-skip-permissions`.

## Notes

- Store the OpenLux key in the shared `openlux-api-key` file next to the launcher, not in the launcher script itself. The key file must be `chmod 600`.
- OpenLux mimics the official Anthropic API: `/v1/models` returns official ids such as `claude-fable-5`, and `/v1/messages` echoes the requested official model name back. The launcher clears every `ANTHROPIC_*` model variable so Claude Code's built-in lineup (Opus, Sonnet, Fable, Haiku) passes through to the relay unchanged. Pinning a model name client-side breaks when the relay changes its lineup.
- End-to-end verified on 2026-09-11 with Claude Code v2.1.268 in a scrubbed environment (`env -i`, no inherited variables): the launcher starts on the default `Opus 5 (1M context)`, `/model claude-fable-5` switches the session to Fable 5, and a prompt returns a normal completion through the relay. With gateway model discovery enabled, the picker lists relay rows (Fable 5.1, Fable 5, Opus 5, Opus 4.8, Opus 4.5, and more) with gateway-supplied descriptions.
- `/model <name>` saves the pick as the default for new sessions by writing `model` to `~/.claude/settings.json`; that saved default then leaks into every Claude Code launcher on the box. Revert by choosing the picker's `Default (recommended)` row or by removing the `model` key from `settings.json`.
- If `/model` or `/status` shows an upstream id such as `k3[1m]`, restart the session first. Usage history under `projects.<path>.lastModelUsage` in `~/.claude.json` keeps old upstream names and is cosmetic. A selectable picker row with a non-`claude-` id after a restart means the relay's `/v1/models` is leaking upstream names; confirm with the check in **Verification** and report it to the relay operator, not to the launcher.
- If `claude` prints `Error: claude native binary not installed`, the Claude Code package's postinstall did not run; repair it with `node <npm-global-root>/node_modules/@anthropic-ai/claude-code/install.cjs` and re-verify `claude --version`.
- If first launch gets stuck in Claude Code onboarding, the template's embedded Node script already sets `hasCompletedOnboarding` in `~/.claude.json`; confirm the file is writable.
- Retire any leftover `claude-yunwu` launcher and `YUNWU_*` env vars; `yunwu.ai` no longer serves.

## Guardrails

- DO NOT print, hard-code, or echo the OpenLux API key in commands, responses, or the generated launcher, except inside the launcher file itself when the user explicitly requests an embedded key with `chmod 700`.
- DO NOT name generated launchers or key files after OpenLux pricing, discount, or token-group names (such as `0.5x`) unless the user explicitly asks for that name.
- DO NOT pin model names or export `ANTHROPIC_DEFAULT_*_MODEL` variables in the generated launcher.
- DO NOT remove the `--dangerously-skip-permissions` flag from the generated launcher unless the user explicitly asks for a permission-prompting launcher.
