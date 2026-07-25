# Codex CLI Setup

Use this reference for Imsight-preferred Codex CLI configuration tasks.

## Workflow

1. Select a second-level subcommand from **Second-Level Subcommands**.
2. Follow that operation's configuration procedure while preserving unrelated settings.
3. Run its **Verification** checks.
4. Report changed configuration and any remaining user action.

If the task does not map cleanly to these steps, plan only from the existing second-level subcommands and their constraints; do not invent or apply unrelated Codex settings.

## Second-Level Subcommands

Use these subcommands under `codex-cli-setup`, for example: `$imsight-dev-box-init use codex-cli-setup disable-codex-apps to disable Codex apps globally`.

| Subcommand | Use For | Load |
| --- | --- | --- |
| `disable-codex-apps` | Disable Codex CLI apps and app/MCP exposure globally, then clear app metadata caches | This page |
| `disable-codex-plugins` | Disable Codex CLI plugin loading globally and optionally remove requested marketplace plugins | This page |
| `install-skip-all-launcher` | Install a `codex-skip-all` launcher that disables approval, sandbox, and hook-trust prompts | This page |

## Subcommand: install-skip-all-launcher

Use this subcommand to install a full-trust Codex launcher at
`/home/huangzhe/.local/bin/codex-skip-all`.

The launcher grants Codex unrestricted host access. Install or use it only
when the user explicitly requests approval-free, unsandboxed operation.

## Install The Launcher

Create `/home/huangzhe/.local/bin/codex-skip-all` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Full-trust Codex launcher: no approval prompts, no sandbox, and no
# separate trust prompt for enabled hooks. All arguments are passed through.
exec codex \
  --dangerously-bypass-approvals-and-sandbox \
  --dangerously-bypass-hook-trust \
  "$@"
```

Make it executable:

```bash
chmod 0755 /home/huangzhe/.local/bin/codex-skip-all
```

The wrapper preserves the current working directory and forwards prompts,
subcommands, and other CLI arguments unchanged.

`/home/huangzhe/.local/bin` must be present in `PATH` to invoke the launcher
by name.

## Skip-All Verification

Validate the script and executable mode:

```bash
bash -n /home/huangzhe/.local/bin/codex-skip-all
test -x /home/huangzhe/.local/bin/codex-skip-all
command -v codex-skip-all
codex-skip-all --version
```

Expected results:

- Shell syntax validation succeeds.
- `command -v` resolves to
  `/home/huangzhe/.local/bin/codex-skip-all`.
- The launcher prints the installed Codex CLI version without requesting
  approval.

## Skip-All Guardrails

- DO NOT make `codex-skip-all` the default `codex` command or silently alias
  `codex` to it.
- DO NOT use the launcher in an untrusted repository or with untrusted hooks.
- The launcher disables both command approvals and Codex sandboxing; commands
  can read, modify, or delete any host data permitted to the invoking user.

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
