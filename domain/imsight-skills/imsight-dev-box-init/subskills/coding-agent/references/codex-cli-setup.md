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

# Codex CLI Setup

Use this reference for Imsight-preferred Codex CLI configuration tasks.

## Workflow

1. Select a child command from **Subcommands**.
2. Follow that operation's configuration procedure while preserving unrelated settings.
3. Run its **Verification** checks.
4. Report changed configuration and any remaining user action.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the declared child commands, constraints, and user request, then execute the plan without inventing unrelated Codex settings.

## Subcommands

Terminal invocation of `imsight-dev-box-init->coding-agent->codex-cli-setup()` lists these child commands. For example, invoke `imsight-dev-box-init->coding-agent->codex-cli-setup()->disable-codex-apps()` to disable Codex apps globally.

| Subcommand | Use For | Detail |
| --- | --- | --- |
| `configure-context-window` | Inspect and adjust Codex CLI context and auto-compaction limits globally, by profile, or for one invocation | [Subcommand: configure-context-window](#subcommand-configure-context-window) |
| `disable-codex-apps` | Disable Codex CLI apps and app/MCP exposure globally, then clear app metadata caches | [Subcommand: disable-codex-apps](#subcommand-disable-codex-apps) |
| `disable-codex-plugins` | Disable Codex CLI plugin loading globally and optionally remove requested marketplace plugins | [Subcommand: disable-codex-plugins](#subcommand-disable-codex-plugins) |
| `install-skip-all-launcher` | Install `codex-skip-all` and `codex-skip-all-large-ctx` full-trust launchers with `CODEX_HOME`-aware credential isolation | [Subcommand: install-skip-all-launcher](#subcommand-install-skip-all-launcher) |

## Subcommand: configure-context-window

Use this subcommand to inspect or change the context budget that Codex CLI assigns to an active model. Treat the setting as client-side budgeting metadata; it does not increase the capacity accepted by the model API.

## Version Snapshot and Recording Requirement

These instructions were created and verified on 2026-08-26 with `codex-cli 0.148.0`. Context limits, profile loading, model catalogs, and compaction behavior are version-sensitive.

Run this before applying or revising the instructions:

```bash
codex --version
```

Record the exact output and verification date in the final setup report and in any new instruction artifact derived from this procedure. If the installed version differs from the snapshot above, re-check the official Codex configuration reference at `https://developers.openai.com/codex/config-reference/` and the active model catalog before reusing numeric examples.

## Inspect the Active Model Limits

Inspect the authenticated or provider-backed catalog used by the current Codex installation:

```bash
codex debug models | jq '.models[] | {slug, context_window, max_context_window, effective_context_window_percent}'
```

Use `codex debug models --bundled` only to inspect the offline fallback catalog. The bundled and authenticated catalogs can differ, so the bundled maximum is not decisive for an authenticated session.

Interpret the fields as follows:

- `context_window` is the catalog's default raw context setting.
- `max_context_window` is the largest raw override that the active catalog advertises for that model.
- `effective_context_window_percent` reserves client headroom and reduces the model-visible effective capacity.

Provider and account entitlements can change these values. For third-party providers, also verify the API's documented context limit because the Codex catalog may not know the provider's true maximum.

## Choose the Configuration Scope

Set a global override with a top-level key in `~/.codex/config.toml`:

```toml
model_context_window = 372000
```

This global value follows the Codex process when the user switches models. Models with smaller advertised maxima clamp it.

For a named profile on Codex CLI 0.134.0 or later, create `~/.codex/large-ctx.config.toml` with top-level keys:

```toml
model_context_window = 372000
```

Launch it with:

```bash
codex --profile large-ctx
```

A profile is a process-wide configuration layer rather than a model-conditional block. Switching models inside that process keeps the override active. Use a separate Codex session without the profile when another model should use its catalog default.

For one invocation, use a CLI override:

```bash
codex -m gpt-5.6-sol -c model_context_window=372000
```

## Behavior Above the Accepted API Limit

Increasing `model_context_window` does not enlarge the server-side model. In the first-party catalog observed with Codex CLI 0.148.0, Codex clamps the configured raw value to `max_context_window`, then applies `effective_context_window_percent` to obtain the effective capacity:

```text
observed effective capacity = min(configured raw window, catalog maximum) * effective percentage / 100
```

For GPT-5.6 Sol on the account used for the 2026-08-26 verification, the active catalog advertised a 272,000-token default, an 872,000-token maximum, and a 95% effective percentage. A 372,000 override produced a 353,400-token effective window after the first request. A 1,000,000 override was capped at 872,000 and produced an 828,400-token effective window.

Treat those numbers as dated evidence, not universal constants. When a custom provider or stale catalog advertises more capacity than the API accepts, Codex cannot prevent the provider from rejecting an oversized request. Provider-side truncation is provider-specific and must not be assumed.

## Auto-Compaction Behavior

`model_auto_compact_token_limit` controls the token threshold that triggers automatic history compaction. When it is unset, Codex uses the active model's default. The official configuration contract does not define one universal percentage or promise that a model-owned default will move to a user-selected threshold. Increasing only `model_context_window` therefore does not guarantee that automatic compaction waits until a proportional point in the larger window.

Set the threshold explicitly when the larger context must remain available until a predictable point. Keep it below the effective capacity and leave enough room for model output, tool results, and compaction work. For the dated 372,000 raw and 353,400 effective example, a conservative explicit threshold is:

```toml
model_context_window = 372000
model_auto_compact_token_limit = 330000
model_auto_compact_token_limit_scope = "total"
```

The default scope is `total`, which counts the full active context. `body_after_prefix` counts only growth after the carried compaction-window prefix and should be selected only when that behavior is intentional.

If an explicit compaction threshold exceeds the resolved effective or API-accepted capacity, the request can reach the full-context limit before automatic compaction protects the session. Recompute the threshold after changing the model, provider, account, catalog, or raw context override.

## Context-Window Verification

Validate the base configuration and inspect the model metadata:

```bash
codex --strict-config doctor --summary --no-color
codex debug models | jq '.models[] | select(.slug == "gpt-5.6-sol") | {slug, context_window, max_context_window, effective_context_window_percent}'
```

Validate a named profile through a profile-aware runtime path:

```bash
codex --profile large-ctx debug prompt-input "profile validation" >/dev/null
```

Then run one small request and inspect `/status` after the first response. Checking only the startup display is insufficient because the active catalog or API handshake can reduce the initial configured value.

## Context-Window Guardrails

- DO NOT describe `model_context_window` as a way to expand the model API's server-side capacity.
- DO NOT use a numeric catalog maximum, effective percentage, or compaction threshold without recording the Codex CLI version and verification date.
- DO NOT assume the bundled catalog, authenticated catalog, and third-party provider advertise the same limit.
- DO NOT set an explicit auto-compaction threshold at or above the resolved effective capacity.

## Subcommand: install-skip-all-launcher

Use this subcommand to install full-trust Codex launchers at
`/home/huangzhe/.local/bin/codex-skip-all` and
`/home/huangzhe/.local/bin/codex-skip-all-large-ctx`.

The launchers grant Codex unrestricted host access. Install or use them only
when the user explicitly requests approval-free, unsandboxed operation. They
do not bypass hook trust; enabled hooks still prompt separately.

These instructions were verified on 2026-09-03 with `codex-cli 0.150.1`.
Record the installed version and verification date in the setup report when
reusing them.

## Codex Home Isolation

Both launchers honor the `CODEX_HOME` environment variable. When it is set,
for example to a project-local `.codex/` directory, Codex reads and writes
credentials (`auth.json`), configuration, and session state there instead of
`~/.codex`, so a project-scoped `codex login` does not disturb the global
login. Codex refuses to start when `CODEX_HOME` points to a missing
directory, so each launcher creates the directory before exec'ing Codex.

Launch with a project-local Codex home like this:

```bash
CODEX_HOME="$PWD/.codex" codex-skip-all login
CODEX_HOME="$PWD/.codex" codex-skip-all
```

Add `.codex/` to the project's ignore rules before logging in so that
credentials are never committed.

## Install The Launchers

Create `/home/huangzhe/.local/bin/codex-skip-all` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

codex_bin="$(command -v codex || true)"
if [[ -z "$codex_bin" ]]; then
  echo "codex-skip-all: codex binary not found" >&2
  exit 127
fi

# Honor CODEX_HOME (e.g. a project-local .codex/ for isolated credentials).
# Codex exits if CODEX_HOME points to a missing directory, so create it first.
if [[ -n "${CODEX_HOME:-}" ]]; then
  mkdir -p "$CODEX_HOME"
fi

# Runtime args belong to Codex; the launcher only injects its fixed defaults.
exec "$codex_bin" --dangerously-bypass-approvals-and-sandbox --search "$@"
```

Create `/home/huangzhe/.local/bin/codex-skip-all-large-ctx` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

codex_bin="$(command -v codex || true)"
if [[ -z "$codex_bin" ]]; then
  echo "codex-skip-all-large-ctx: codex binary not found" >&2
  exit 127
fi

# Honor CODEX_HOME (e.g. a project-local .codex/ for isolated credentials).
# Codex exits if CODEX_HOME points to a missing directory, so create it first.
codex_home="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$codex_home"

# The large-ctx profile is layered from $CODEX_HOME/<profile>.config.toml.
# Ensure it exists in whichever Codex home is active. Never overwrite an
# existing same-name file silently: identical content is left alone, and
# differing content requires interactive confirmation.
profile_file="$codex_home/large-ctx.config.toml"
profile_content='model_context_window = 372000
model = "gpt-5.6-sol"
model_reasoning_effort = "max"
service_tier = "default"
'

if [[ -f "$profile_file" ]]; then
  if ! printf '%s' "$profile_content" | cmp -s - "$profile_file"; then
    if [[ ! -t 0 ]]; then
      echo "codex-skip-all-large-ctx: $profile_file exists with different content; cannot prompt without a terminal, leaving it untouched" >&2
      exit 2
    fi
    echo "codex-skip-all-large-ctx: $profile_file already exists with different content (- default, + existing):" >&2
    diff -u <(printf '%s' "$profile_content") "$profile_file" >&2 || true
    read -r -p "Overwrite with the default large-ctx profile? [y/N] " answer
    case "$answer" in
      y|Y|yes|YES)
        printf '%s' "$profile_content" > "$profile_file"
        ;;
      *)
        echo "codex-skip-all-large-ctx: keeping existing $profile_file" >&2
        ;;
    esac
  fi
else
  printf '%s' "$profile_content" > "$profile_file"
fi

# Runtime args belong to Codex; the launcher only injects its fixed defaults.
exec "$codex_bin" --profile large-ctx --dangerously-bypass-approvals-and-sandbox --search "$@"
```

The `large-ctx` variant activates the `large-ctx` profile, which Codex CLI
0.134.0 or later layers from `<codex-home>/large-ctx.config.toml` on top of
the base configuration. The launcher ensures the profile file exists in the
active Codex home, whether that is `~/.codex` or a redirected `CODEX_HOME`:

- A missing profile file is created with the default large-context settings.
- An identical existing file is left untouched.
- An existing file with different content is never overwritten silently; the
  launcher shows a diff and prompts before overwriting. Answering no keeps
  the existing file and continues the launch. Without an interactive
  terminal, the launcher exits with status 2 instead of choosing.

The embedded profile defaults are dated values captured on 2026-09-03; see
`configure-context-window` for how to re-derive `model_context_window` from
the active model catalog.

Make both launchers executable:

```bash
chmod 0700 /home/huangzhe/.local/bin/codex-skip-all \
           /home/huangzhe/.local/bin/codex-skip-all-large-ctx
```

The wrappers preserve the current working directory and forward prompts,
subcommands, and other CLI arguments unchanged.

`/home/huangzhe/.local/bin` must be present in `PATH` to invoke the launchers
by name.

## Skip-All Verification

Validate the scripts and executable modes:

```bash
bash -n /home/huangzhe/.local/bin/codex-skip-all
bash -n /home/huangzhe/.local/bin/codex-skip-all-large-ctx
test -x /home/huangzhe/.local/bin/codex-skip-all
test -x /home/huangzhe/.local/bin/codex-skip-all-large-ctx
command -v codex-skip-all
command -v codex-skip-all-large-ctx
codex-skip-all --version
```

Validate the profile bootstrap with a temporary Codex home:

```bash
tmp_home="$(mktemp -d)"
CODEX_HOME="$tmp_home" codex-skip-all-large-ctx --version
test -f "$tmp_home/large-ctx.config.toml"
rm -rf "$tmp_home"
```

Expected results:

- Shell syntax validation succeeds for both scripts.
- `command -v` resolves both names under `/home/huangzhe/.local/bin`.
- The launchers print the installed Codex CLI version without requesting
  approval.
- The `large-ctx` launcher creates `large-ctx.config.toml` in a fresh
  `CODEX_HOME` before starting Codex.

## Skip-All Guardrails

- DO NOT make `codex-skip-all` or `codex-skip-all-large-ctx` the default
  `codex` command or silently alias `codex` to them.
- DO NOT use the launchers in an untrusted repository or with untrusted hooks.
- DO NOT use the launchers unless unrestricted host access is acceptable; they
  disable command approvals and Codex sandboxing.
- DO NOT overwrite an existing divergent `large-ctx.config.toml`
  non-interactively; the launcher must prompt first or exit.
- DO NOT commit a project-local `.codex/` directory; it holds credentials.

## Subcommand: disable-codex-apps

Use this subcommand to disable Codex CLI apps and app/MCP exposure globally.
It must not change plugin configuration or remove installed plugins.

This subcommand is based on the local note `notes/disable-codex-apps.md` dated 2026-05-27.

## Disable Apps

Update the global Codex config:

```toml
# ~/.codex/config.toml
[features]
apps = false
```

If using shell commands, preserve the rest of the existing config and only
set `features.apps`.

Clear stale app metadata caches:

```bash
rm -rf "$HOME/.codex/cache/codex_apps_tools" \
       "$HOME/.codex/cache/codex_app_directory"
```

## Disable-Apps Verification

Check feature state:

```bash
codex features list | rg '^(apps|enable_mcp_apps)\s'
```

Expected state:

```text
apps             stable             false
enable_mcp_apps  under development  false
```

Check MCP configuration:

```bash
codex mcp list
```

Expected state: app-provided MCP exposure is disabled. Independently
configured MCP servers may remain and must not be removed by this subcommand.

## Disable-Apps Notes

These changes apply globally for new Codex CLI sessions. A currently running
session may still show app tools injected when that session started. Restart
Codex CLI after changing the config or clearing caches.

## Disable-Apps Guardrails

- DO NOT change `features.plugins`.
- DO NOT remove plugins or plugin marketplaces.
- DO NOT remove independently configured MCP servers.
- DO NOT overwrite unrelated Codex settings while changing
  `features.apps`.

## Subcommand: disable-codex-plugins

Use this subcommand to disable Codex CLI plugin loading and plugin-provided
skills globally. It must not change app configuration or clear app caches.

This subcommand implements the plugin-specific portion of the local note
`notes/disable-codex-apps.md` dated 2026-05-27.

## Disable Plugins

Update the global Codex config:

```toml
# ~/.codex/config.toml
[features]
plugins = false
```

If using shell commands, preserve the rest of the existing config and only
set `features.plugins`.

Inspect marketplace plugins:

```bash
codex plugin list
```

If removal is explicitly included in the request, remove only the named
plugin:

```bash
codex plugin remove github@openai-curated
```

`github@openai-curated` is the known plugin from the original Imsight note.
Disabling the feature does not require uninstalling plugins; installed
plugins can remain dormant.

## Disable-Plugins Verification

Check feature state:

```bash
codex features list | rg '^plugins\s'
```

Expected state:

```text
plugins          stable             false
```

Check marketplace plugin state:

```bash
codex plugin list
```

If plugin removal was included, verify the named plugin is no longer
installed. Otherwise, installed entries may remain but must not be loaded
into new Codex sessions while `features.plugins=false`.

## Disable-Plugins Notes

The feature change applies globally for new Codex CLI sessions. A currently
running session may retain plugin tools or skills injected at startup.
Restart Codex CLI after changing the feature or removing a plugin.

## Disable-Plugins Guardrails

- DO NOT change `features.apps`.
- DO NOT clear app metadata caches.
- DO NOT remove a plugin unless removal is explicitly requested or confirmed.
- DO NOT remove plugin marketplaces when the request only concerns a plugin.
- DO NOT overwrite unrelated Codex settings while changing
  `features.plugins`.
