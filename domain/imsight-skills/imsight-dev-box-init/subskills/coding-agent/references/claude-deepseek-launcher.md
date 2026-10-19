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

# Claude-DeepSeek Launcher Setup

Use this reference when the user wants a local `claude-deepseek` or `claude-deepseek-<suffix>` launcher that runs Claude Code through DeepSeek's official Anthropic-compatible API. One launcher offers Flash and Pro, with Flash selected on startup.

## Workflow

1. Inspect the installed Claude Code version/help, host OS and shell, existing launcher, and current official documentation under **Authoritative Sources** without changing persistent state.
2. Obtain the DeepSeek key under **Required Input** and resolve the optional suffix under **Launcher Name and Suffix Contract**.
3. Derive candidate endpoint, model mappings, context settings, and effort behavior from current documentation and **Model Selection**; treat the recorded values as a snapshot.
4. Complete **Claude Code Compatibility Test** for Flash and Pro with temporary process-scoped settings before creating or replacing persistent setup.
5. Implement **Launcher Design Principles** using the native host shell. Use **Reference Unix Implementation** only when its assumptions match the verified client and provider behavior.
6. Store the key with restrictive permissions and put the launcher directory on PATH for fresh shells after compatibility succeeds.
7. Complete **Verification**, including Flash as the default, selectable Pro, and the actual effort sent by the installed client.
8. Report the launcher and key-file locations, permission mode, selected models, effort policy, and validation results without displaying credentials.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's inputs, launcher contract, effort mappings, verification rules, and user constraints, then execute the plan without exposing credentials.

## Launcher Name and Suffix Contract

Use `claude-deepseek` when no suffix is provided. A user-provided suffix such as `work` produces `claude-deepseek-work`. Apply the parent subskill's naming policy; do not ask for a suffix when none was requested.

Use `deepseek-api-key` for the unsuffixed launcher and `deepseek-api-key-<suffix>` for a suffixed variant. The suffix distinguishes launcher and credential-file names only; it does not select a model, account, endpoint, pricing tier, or permission mode. Keep Flash and Pro selectable in the same launcher rather than creating separate per-model launchers unless the user requests them.

## Required Input

Use a DeepSeek API key supplied for this setup, an existing protected DeepSeek key file authorized by the user, or a process-scoped `DEEPSEEK_API_KEY` the user wants to use. If no credential is available, request it before persistent setup. Do not write a placeholder launcher and report it as configured.

Store the key outside the repository. On Unix, the default is `$HOME/.local/bin/<key-file-name>` with mode `600`; the launcher has mode `700`. Read the key without displaying it, reject an empty or whitespace-containing value, and pass it only through the child environment. Never put a real key into this reference, shell history, command-line arguments, or verification output.

## Launcher Design Principles

- Use `https://api.deepseek.com/anthropic` as the current Claude Code endpoint and `ANTHROPIC_AUTH_TOKEN` as the authentication lane. Clear competing `ANTHROPIC_API_KEY` and `CLAUDE_CODE_OAUTH_TOKEN` values for the launched process.
- Keep provider settings in the launcher environment. Do not rewrite shared Claude JSON files, copy OAuth credentials, or change plain `claude` to install this route.
- Start on Flash even if another launcher left a saved model selection. Expose Pro through Claude Code's model picker and `--model`; do not implement a separate model-selection parser in the wrapper.
- Make effort behavior explicit. The default below follows DeepSeek's `max` recommendation and preserves a caller-supplied `CLAUDE_CODE_EFFORT_LEVEL`. It is a process-wide override, not a default that the picker necessarily supersedes; see **Thinking Levels and Precedence**.
- Use native process semantics: a Unix wrapper exports variables and `exec`s Claude; a Windows PowerShell implementation saves and restores changed environment values in `finally`, forwards an argument array, and preserves the child exit code. Use a protected user-local key file and the native profile/PATH mechanism on Windows rather than installing a compatibility shell for the Bash example.
- Apply the shared permissive-launcher policy: prepend `--dangerously-skip-permissions` unless the initial request explicitly opted into permission prompts. Forward every caller argument unchanged and preserve Claude Code's exit code.
- Discover the actual installed Claude executable. Adapt the example's search order to the host, and never assume that a historical Node, Bun, or nvm path still exists.

## Claude Code Compatibility Test

Before writing a launcher, credential file, or PATH/profile change:

1. Read the installed CLI's help and choose a supported non-interactive minimal-turn command.
2. Apply the candidate endpoint, credential, mappings, and effort setting only to a disposable Claude Code process. Use isolated temporary working/configuration state as supported by that client; disable unrelated tools, hooks, MCP servers, and session persistence for the smoke test.
3. Run a minimal real turn with the Flash startup mapping, then another with `--model fable` resolving to Pro. Confirm the model through Claude Code's own response metadata or status surface.
4. Check `/model` when interactive selection matters: Flash and Pro must be selectable, and `Default` must resolve to Flash. Do not equate a displayed model name with a successful provider turn.
5. Verify effort precedence using the actual CLI. A local request capture with a dummy credential may inspect only `model`, `thinking`, and `output_config.effort`; it supplements the real turns and must never record real credentials or private prompts.
6. Stop without persistent setup if either required model fails. Report the client-visible failure and consult current documentation; do not substitute handcrafted provider `/models` or `/messages` probes.

For documentation-only maintenance, reuse identified evidence for the unchanged client/provider path and validate the edited examples; do not reinstall the user's launcher merely to document it.

## Model Selection

The following mapping was verified with Claude Code `2.1.301` on 2026-10-18. Re-check names and support before later installations.

| Role | Environment variable | Verified value |
| --- | --- | --- |
| Startup model | `ANTHROPIC_MODEL` | `deepseek-flash[1m]` |
| Picker's `Default` model | `ANTHROPIC_DEFAULT_MODEL` | `deepseek-flash[1m]` |
| Pro selection through `fable` | `ANTHROPIC_DEFAULT_FABLE_MODEL` | `deepseek-v4-pro[1m]` |
| Opus selection | `ANTHROPIC_DEFAULT_OPUS_MODEL` | `deepseek-flash[1m]` |
| Flash selection through `sonnet` | `ANTHROPIC_DEFAULT_SONNET_MODEL` | `deepseek-flash[1m]` |
| Small/background model | `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `deepseek-flash` |
| Subagent model | `CLAUDE_CODE_SUBAGENT_MODEL` | `deepseek-flash` |

Set the Fable and Sonnet `*_NAME` and `*_DESCRIPTION` variables as in the template so the picker labels those rows `DeepSeek Pro` and `DeepSeek Flash`; confirm the installed client honors the pair for the fable row. Other built-in rows, including Opus, also resolve to Flash; do not claim that the picker contains exactly two rows.

The `[1m]` suffix requests Claude Code's 1M context handling; the observed outgoing model IDs were `deepseek-flash` and `deepseek-v4-pro`. The template uses `CLAUDE_CODE_AUTO_COMPACT_WINDOW=786432`, following DeepSeek's current Claude Code guide. These context settings do not determine reasoning effort or guarantee a particular response length.

```bash
claude-deepseek                    # Flash on a fresh start
claude-deepseek --model sonnet     # Flash explicitly
claude-deepseek --model fable      # Pro explicitly
```

Inside Claude Code, use `/model` to select the named row, `/model sonnet` for Flash, or `/model fable` for Pro. Use the picker's session-only selection when available to avoid writing a provider-specific default into shared user settings. With `ANTHROPIC_MODEL` set by this launcher, the next fresh launch starts on Flash regardless of a saved pick; explicit startup `--model` still takes precedence. Subagents remain on Flash unless their mapping is deliberately changed and verified.

DeepSeek's vendor example maps every main alias to Flash. This guide deliberately maps Fable, the client's top model tier, to Pro and maps every other alias to Flash, offering both models in one launcher. Use explicit verified DeepSeek IDs: the provider can map an unsupported model name back to Flash, so a successful request alone does not prove Pro selection.

## Thinking Levels and Precedence

DeepSeek's Anthropic-compatible API accepts effort through `output_config.effort`. Its current documented mapping applies to both models:

| Requested effort | Actual DeepSeek effort |
| --- | --- |
| `low` | `low` |
| `medium` | `high` |
| `high` | `high` |
| `xhigh` | `high` |
| `max` | `max` |

The provider also maps `minimal` to `low` and `ultra` to `max`; these provider aliases are not necessarily valid Claude Code CLI choices. Use the levels supported by the installed CLI.

`medium`, `high`, and `xhigh` therefore select the same DeepSeek effort. Higher actual effort can spend more reasoning tokens and time; it is not a guarantee of a better answer. `low` still enables thinking. Turning thinking off is a separate control, and DeepSeek ignores Anthropic's `thinking.budget_tokens`, so these levels do not specify fixed thinking-token budgets.

The reference launcher exports `CLAUDE_CODE_EFFORT_LEVEL="${CLAUDE_CODE_EFFORT_LEVEL:-max}"`. On the verified Claude Code version, this environment variable takes precedence over `--effort` and session settings. Local captures showed that all five `--effort` choices still sent `output_config.effort="max"` while that override was set. The model picker could display `high` even though the request sent `max`; the picker label alone was not evidence of effective effort.

Set the environment value before invoking the launcher to change the effective effort:

```bash
CLAUDE_CODE_EFFORT_LEVEL=low claude-deepseek
CLAUDE_CODE_EFFORT_LEVEL=high claude-deepseek --model fable
CLAUDE_CODE_EFFORT_LEVEL=max claude-deepseek --model fable
```

For a Windows native launcher with the same fallback policy, set `$env:CLAUDE_CODE_EFFORT_LEVEL = 'high'` before invocation; preserve and restore any previous value when this should apply to one call only.

If the user instead wants `--effort`, `/effort`, or the picker to control effort normally, omit the launcher's fallback export and keep `CLAUDE_CODE_EFFORT_LEVEL` unset in that session, then re-verify the installed client's behavior. Merely running `env -u CLAUDE_CODE_EFFORT_LEVEL claude-deepseek` is insufficient with the default template: the launcher immediately restores `max`.

## Reference Unix Implementation

Use this Bash template only after the compatibility test succeeds. Replace `<launcher-name>` and `<key-file-name>` with the resolved names. The template contains no credential; create its protected key file separately from the supplied key. It does not modify shared Claude JSON files.

```bash
#!/usr/bin/env bash
set -euo pipefail

launcher_name='<launcher-name>'
key_file="$HOME/.local/bin/<key-file-name>"
deepseek_key="${DEEPSEEK_API_KEY:-}"
if [[ -z "$deepseek_key" && -r "$key_file" ]]; then
  deepseek_key="$(cat -- "$key_file")"
fi
if [[ -z "$deepseek_key" || "$deepseek_key" =~ [[:space:][:cntrl:]] ]]; then
  echo "$launcher_name: set DEEPSEEK_API_KEY or store one valid key in $key_file" >&2
  exit 2
fi

export ANTHROPIC_AUTH_TOKEN="$deepseek_key"
export ANTHROPIC_BASE_URL='https://api.deepseek.com/anthropic'
unset ANTHROPIC_API_KEY CLAUDE_CODE_OAUTH_TOKEN

export ANTHROPIC_MODEL='deepseek-flash[1m]'
export ANTHROPIC_DEFAULT_MODEL="$ANTHROPIC_MODEL"
export ANTHROPIC_DEFAULT_FABLE_MODEL='deepseek-v4-pro[1m]'
export ANTHROPIC_DEFAULT_FABLE_MODEL_NAME='DeepSeek Pro'
export ANTHROPIC_DEFAULT_FABLE_MODEL_DESCRIPTION='DeepSeek V4 Pro with 1M context'
export ANTHROPIC_DEFAULT_OPUS_MODEL="$ANTHROPIC_MODEL"
export ANTHROPIC_DEFAULT_SONNET_MODEL="$ANTHROPIC_MODEL"
export ANTHROPIC_DEFAULT_SONNET_MODEL_NAME='DeepSeek Flash'
export ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION='DeepSeek Flash with 1M context (default)'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='deepseek-flash'
export CLAUDE_CODE_SUBAGENT_MODEL='deepseek-flash'
export CLAUDE_CODE_EFFORT_LEVEL="${CLAUDE_CODE_EFFORT_LEVEL:-max}"
export CLAUDE_CODE_AUTO_COMPACT_WINDOW="${CLAUDE_CODE_AUTO_COMPACT_WINDOW:-786432}"
export API_TIMEOUT_MS="${API_TIMEOUT_MS:-600000}"

# Local maintenance policy, not a DeepSeek API requirement: update deliberately.
export DISABLE_AUTOUPDATER="${DISABLE_AUTOUPDATER:-1}"

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

exec "$claude_bin" --dangerously-skip-permissions "$@"
```

The timeout is a local operational default, and the updater setting follows the neighboring launcher guides' policy of deliberate updates. Neither is required by the DeepSeek protocol. For an explicit permission-prompting opt-out, omit `--dangerously-skip-permissions` from the final invocation.

## Verification

After persistence, check the resolved launcher name, executable mode, protected key file, and PATH in a fresh native shell. On Unix, adapt these commands to the resolved names:

```bash
bash -n "$HOME/.local/bin/claude-deepseek"
command -v claude-deepseek
bash -ic 'command -v claude-deepseek'
test -x "$HOME/.local/bin/claude-deepseek"
test -r "$HOME/.local/bin/deepseek-api-key"
claude-deepseek --version
```

Inspect only non-secret assignments or use redaction when reviewing an existing launcher. Do not print the key file. Confirm restrictive permissions with the platform's native metadata tools.

Run the minimal actual-Claude turns again through the installed launcher: the default must report Flash and `--model fable` must report Pro. Inspect `/status` for the DeepSeek Anthropic endpoint and `/model` for both labels and the Flash `Default` row. Verify one caller-selected effort on each model using the client and, when necessary, dummy-credential local request capture. Verify argument forwarding and exit-code preservation without exposing credentials.

Record the client version, verification date, exact model IDs, effective effort, and any unsupported behavior. The 2026-10-18 evidence used Claude Code `2.1.301`: both live model turns succeeded; local request captures confirmed `max` by default, environment-selected `low`/`high`, and the environment override of CLI effort. Local capture proves request construction, not DeepSeek's internal reasoning or answer quality.

## Authoritative Sources

- [DeepSeek: Integrate with Claude Code](https://api-docs.deepseek.com/quick_start/agent_integrations/claude_code) — endpoint, authentication, vendor model mappings, context, and recommended effort settings.
- [DeepSeek: Your First API Call](https://api-docs.deepseek.com/) — current model IDs and API endpoints.
- [DeepSeek: Thinking Mode](https://api-docs.deepseek.com/guides/thinking_mode) — effort mappings and thinking controls.
- [DeepSeek: Using the Anthropic API](https://api-docs.deepseek.com/guides/anthropic_api) — compatible request fields and ignored thinking-token budgets.
- [Claude Code: Model configuration](https://code.claude.com/docs/en/model-config) — model aliases, picker names, context suffixes, startup selection, and effort controls.

## Guardrails

- DO NOT write credentials into skill sources, tracked files, command arguments, logs, or final responses.
- DO NOT create or replace persistent launcher, key-file, PATH, or profile state before the actual Claude Code compatibility test succeeds.
- DO NOT replace the target-client test with direct provider model or inference probes.
- DO NOT remove Pro from the shared launcher or change its Flash startup default without an explicit request.
- DO NOT present `medium`, `high`, and `xhigh` as distinct DeepSeek effort tiers or equate `low` with disabled thinking.
- DO NOT claim that the picker or `--effort` overrides a process-level effort pin without checking the installed client's outgoing setting.
- DO NOT change shared Claude JSON files, plain `claude`, or unrelated provider launchers as part of this setup.
- DO NOT omit the permissive flag unless the initial launcher request explicitly opts into permission prompts.
