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

Use this reference when the user wants a local `claude-openlux` or `claude-openlux-<suffix>` launcher that runs Claude Code against the OpenLux relay (`https://api.openlux.ai`). OpenLux replaces the retired Yunwu relay (`yunwu.ai` no longer serves); migrate any `claude-yunwu` launcher to this guide.

## Workflow

1. Identify the installed Claude Code version, host OS and shell, current OpenLux API guidance, and whether the initial request opts out of permissive mode using read-only inspection.
2. Obtain the OpenLux key under **Required Input**; stop without changing any file when it is unavailable.
3. Complete **No-Write Provider Preflight** against OpenLux's Anthropic-compatible model and Messages APIs before creating a key file, launcher, temporary config, response dump, log, PATH entry, or shell-profile block.
4. Resolve the optional suffix, authentication lane, and credential placement only after the live provider route succeeds.
5. Implement the launcher from **Launcher Design Principles** and **Runtime Argument Contract**. Treat the inline script as a Unix reference implementation rather than mandatory machinery.
6. Put the launcher directory on PATH for new shells using the host's native startup mechanism.
7. Run **Verification**, including redaction-safe inspection, argument and permission checks, and comparison with the preflight model catalog.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's inputs, defaults, launcher contract, verification rules, and user constraints, then execute the plan without exposing credentials.

## Launcher Name and Suffix Contract

Use `claude-openlux` when no suffix is provided. When the user provides a suffix such as `work`, use `claude-openlux-work`. Accept lowercase letters, digits, and internal hyphens; omit the separator when the suffix is absent.

The suffix is a user-facing launcher and credential-file namespace only. It does not select an OpenLux account, token group, endpoint, model, automatic-routing mode, price tier, or permission mode. Use `openlux-api-key` for the unsuffixed launcher and `openlux-api-key-<suffix>` for a suffixed variant so side-by-side launchers do not accidentally share credentials. In examples, `<key-file-name>` means the corresponding resolved filename. Do not ask for a suffix when the user does not provide one.

## Required Input

The user must provide an OpenLux API key during setup so the no-write provider preflight can run before any launcher or key file is created. Prefer an existing process-scoped `OPENLUX_API_KEY` only when the user explicitly wants to use it for this setup. If no key is available, stop without writing a placeholder launcher.

```text
Please provide your OpenLux API key so I can verify the live Anthropic-compatible API before creating the launcher.
```

The generated launcher must not hard-code the API key. It reads its resolved key file directly at runtime and assigns `ANTHROPIC_AUTH_TOKEN` for the launched Claude process only. Embed the key in the launcher script itself only when the user explicitly requests that layout; in that case the launcher file must be `chmod 700` and must never be committed or shared.

## No-Write Provider Preflight

Complete this phase while keeping the key process-scoped and all API responses in memory:

1. Request `GET https://api.openlux.ai/v1/models` with the current key using OpenLux's documented Anthropic-compatible headers.
2. Require a nonempty catalog whose ids match the current Claude-compatible namespace advertised by the provider. Do not require a particular historical model family or id.
3. Select one currently advertised id only for the probe and send a minimal `POST https://api.openlux.ai/v1/messages` request through the same authentication lane Claude Code will use.
4. Stop without modifying the filesystem when model discovery, authentication, or the Messages request fails. Report the failing layer without printing headers or the key.

The launcher intentionally does not persist a model pin. The probe model proves only that the current key, endpoint, protocol, and at least one advertised model work together. A user-requested pin requires a fresh catalog check and direct probe of that exact id.

## Launcher Design Principles

- Treat Claude Code, OpenLux, and the host shell as separate compatibility surfaces. Re-check current Claude flags and environment variables, OpenLux's endpoint and authentication requirements, and the host's executable-resolution rules before implementation.
- Scope OpenLux variables to the launched Claude process and clear conflicting auth and model variables so ambient configuration cannot select another provider.
- Use the resolved full launcher name and matching key-file namespace consistently; never derive provider behavior from the optional suffix.
- Keep the relay's advertised model catalog authoritative; do not hard-code model mappings merely because an older example did.
- Use native process semantics: a Unix wrapper can export then `exec`; a Windows implementation should use PowerShell-native argument arrays and restore any caller environment it mutates.
- Apply the shared permissive default, forward caller arguments exactly, preserve the exit code, and verify the effective endpoint and model catalog.

## Defaults

- Unix launcher path: `$HOME/.local/bin/<launcher-name>`, resolving to `claude-openlux` or `claude-openlux-<suffix>`.
- Unix key file: `$HOME/.local/bin/openlux-api-key` without a suffix, or `$HOME/.local/bin/openlux-api-key-<suffix>` with one.
- Base URL: `https://api.openlux.ai`
- Auth: `ANTHROPIC_AUTH_TOKEN` with a key from the OpenLux console; the launcher clears `ANTHROPIC_API_KEY` and `CLAUDE_CODE_OAUTH_TOKEN` so Claude Code does not choose an older auth lane.
- `API_TIMEOUT_MS=300000` and `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`, both overridable by the caller. These follow the OpenLux tutorial recommendation.
- `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1`, overridable by the caller. Without it, the `/model` picker shows only Claude Code's built-in lineup; with it, the picker can additionally list the relay's currently advertised models with gateway-supplied descriptions.
- `DISABLE_AUTOUPDATER=1`, overridable by the caller. Claude Code's background auto-updater reinstalls the npm package mid-session; an interrupted install leaves the placeholder `claude` shim behind and breaks every launcher on the box (see **Notes**). Updates become deliberate: `npm update -g @anthropic-ai/claude-code`.
- Official OpenLux Claude Code tutorial: `https://doc.openlux.ai/tutorials/plugins-7010249`.

Imsight's local launcher runs Claude Code with `--dangerously-skip-permissions` by default. If the user's initial launcher request explicitly opts into permission prompts, omit that flag from the final `exec` line; do not infer an opt-out from silence or ask the user to reconfirm the default.

## Reference Unix Implementation

The following Bash template illustrates the current contract after **No-Write Provider Preflight** succeeds. Compare it with the installed Claude Code version and current OpenLux documentation before using it. Adapt executable discovery, paths, or OS-specific process handling as needed; do not discard the principles above merely because this exact script stops matching a future version. Write an adapted Unix launcher to the selected launcher path and `chmod 700` the result:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Claude Code launcher for the OpenLux relay.
# Config is injected via environment only; settings.json is left untouched.
# Ref: https://doc.openlux.ai/tutorials/plugins-7010249

launcher_name='<launcher-name>'
key_file="$HOME/.local/bin/<key-file-name>"
if [[ ! -f "$key_file" ]]; then
  echo "$launcher_name: key file $key_file missing; store your OpenLux key there" >&2
  exit 1
fi

export ANTHROPIC_AUTH_TOKEN="$(tr -d '[:space:]' < "$key_file")"
export ANTHROPIC_BASE_URL="https://api.openlux.ai"
unset ANTHROPIC_API_KEY CLAUDE_CODE_OAUTH_TOKEN

# Recommended by the OpenLux tutorial: 300s timeout, disable experimental betas.
export API_TIMEOUT_MS="${API_TIMEOUT_MS:-300000}"
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS="${CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS:-1}"

# List the relay's currently advertised models in the /model
# picker; without this the picker shows only the built-in lineup.
export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="${CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY:-1}"

# Claude Code's background auto-updater reinstalls the npm package mid-session;
# an install interrupted between extraction and postinstall leaves the placeholder
# bin shim and every launcher fails with "claude native binary not installed".
# Update deliberately instead: npm update -g @anthropic-ai/claude-code
export DISABLE_AUTOUPDATER="${DISABLE_AUTOUPDATER:-1}"

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
  echo "$launcher_name: claude binary not found" >&2
  exit 127
fi

# No --model injection: model selection is left to the relay unless the
# caller passes one explicitly.
exec "$claude_bin" --dangerously-skip-permissions "$@"
```

The example candidate loop covers nvm, bun, and `~/.local/bin` installs before falling back to `command -v claude`. Change that discovery order when the actual installation or OS differs.

## Runtime Argument Contract

`<launcher-name>` runtime arguments are Claude Code arguments. The launcher prepends `--dangerously-skip-permissions` by default, passes every user-supplied argument through unchanged, and injects no `--model` default; model selection is left to the relay unless the caller passes `--model` explicitly. The setup-time suffix is never forwarded. An explicit permission-prompting opt-out changes only the final `exec` line to `exec "$claude_bin" "$@"`.

## Verification

Verify the launcher exists and resolves in fresh shells:

```bash
command -v <launcher-name>
bash -ic 'command -v <launcher-name>'   # must also resolve in a fresh non-login terminal
test -x "$HOME/.local/bin/<launcher-name>"
test -f "$HOME/.local/bin/<key-file-name>" || echo "key file still needed"
```

Inspect the generated launcher and key file only with redaction:

```bash
rg -n 'openlux-api-key|ANTHROPIC_AUTH_TOKEN|ANTHROPIC_BASE_URL|API_TIMEOUT_MS|DISABLE_EXPERIMENTAL_BETAS|GATEWAY_MODEL_DISCOVERY|DISABLE_AUTOUPDATER|dangerously-skip-permissions' "$HOME/.local/bin/<launcher-name>"
test -f "$HOME/.local/bin/<key-file-name>" && sed 's/.*/<redacted>/' "$HOME/.local/bin/<key-file-name>"
```

Repeat the relay model check and compare it with the catalog recorded during preflight:

```bash
curl -s --max-time 20 https://api.openlux.ai/v1/models \
  -H "x-api-key: $(tr -d '[:space:]' < "$HOME/.local/bin/<key-file-name>")" \
  -H "anthropic-version: 2023-06-01" \
  | python3 -c "import json,sys; ids=[m['id'] for m in json.load(sys.stdin)['data']]; print('\n'.join(ids)); assert ids and all(i.startswith('claude-') for i in ids), 'relay exposes non-official model ids'"
```

Inside Claude Code, `/status` should show Base URL `https://api.openlux.ai`, and the `/model` picker should agree with the current relay catalog rather than expose unrelated upstream ids. The default launcher must invoke `claude` with `--dangerously-skip-permissions`; an explicit permission-prompting opt-out must omit it.

## Notes

- Store the OpenLux key in the resolved `openlux-api-key[-<suffix>]` file next to the launcher, not in the launcher script itself. The key file must be `chmod 600`.
- OpenLux exposes Anthropic-compatible `/v1/models` and `/v1/messages` surfaces. The launcher clears every `ANTHROPIC_*` model variable so Claude Code and gateway discovery use the current relay lineup unchanged. Pinning a historical model name client-side breaks when the relay changes its catalog.
- End-to-end compatibility was verified on 2026-09-11 with Claude Code v2.1.268 in a scrubbed environment. Historical model ids are intentionally omitted; repeat the live catalog and Messages checks instead of reusing that snapshot.
- `/model <name>` saves the pick as the default for new sessions by writing `model` to `~/.claude/settings.json`; that saved default then leaks into every Claude Code launcher on the box. Revert by choosing the picker's `Default (recommended)` row or by removing the `model` key from `settings.json`.
- If `/model` or `/status` shows an upstream id such as `k3[1m]`, restart the session first. Usage history under `projects.<path>.lastModelUsage` in `~/.claude.json` keeps old upstream names and is cosmetic. A selectable picker row with a non-`claude-` id after a restart means the relay's `/v1/models` is leaking upstream names; confirm with the check in **Verification** and report it to the relay operator, not to the launcher.
- If `claude` prints `Error: claude native binary not installed`, the Claude Code package's postinstall did not run; repair it with `node <npm-global-root>/node_modules/@anthropic-ai/claude-code/install.cjs` and re-verify `claude --version`. The usual cause is the background auto-updater: it reinstalls the npm package mid-session, and an install interrupted between package extraction and postinstall leaves the placeholder shim as the `claude` entrypoint. The template prevents recurrence by exporting `DISABLE_AUTOUPDATER=1`; update deliberately with `npm update -g @anthropic-ai/claude-code` instead.
- If first launch gets stuck in Claude Code onboarding, the template's embedded Node script already sets `hasCompletedOnboarding` in `~/.claude.json`; confirm the file is writable.
- Retire any leftover `claude-yunwu` launcher and `YUNWU_*` env vars; `yunwu.ai` no longer serves.

## Guardrails

- DO NOT print, hard-code, or echo the OpenLux API key in commands, responses, or the generated launcher, except inside the launcher file itself when the user explicitly requests an embedded key with `chmod 700`.
- DO NOT create a key file, launcher, temporary config, PATH entry, or shell-profile block before the current model catalog and a direct Messages request succeed.
- DO NOT require or pin a model merely because it appeared in a historical guide, verification snapshot, or previous launcher.
- DO NOT name generated launchers or key files after OpenLux pricing, discount, or token-group names (such as `0.5x`) unless the user explicitly asks for that name.
- DO NOT pin model names or export `ANTHROPIC_DEFAULT_*_MODEL` variables in the generated launcher.
- DO NOT remove the `--dangerously-skip-permissions` flag from the generated launcher unless the user's initial launcher request explicitly asks for permission prompts.
- DO NOT assign endpoint, account, model, routing, pricing, credential, or permission semantics to the optional suffix.
