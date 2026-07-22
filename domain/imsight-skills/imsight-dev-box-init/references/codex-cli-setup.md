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
| `disable-codex-apps` | Disable Codex CLI apps and plugin-provided skills globally, then verify the disabled state | This page |

## Subcommand: disable-codex-apps

Use this subcommand to disable Codex CLI apps globally, including app/MCP exposure and plugin-provided skills.

This subcommand is based on the local note `notes/disable-codex-apps.md` dated 2026-05-27.

## Disable Apps And Plugins

Update the global Codex config:

```toml
# ~/.codex/config.toml
[features]
apps = false
plugins = false
```

If using shell commands, preserve the rest of the existing config and only set the feature keys. Do not overwrite unrelated Codex settings.

Remove installed marketplace plugins that may contribute app tools or plugin-provided skills:

```bash
codex plugin list
codex plugin remove github@openai-curated
```

Only remove plugins the user requests or confirms. `github@openai-curated` is the known plugin from the original Imsight note.

Clear stale app metadata caches:

```bash
rm -rf "$HOME/.codex/cache/codex_apps_tools" \
       "$HOME/.codex/cache/codex_app_directory"
```

## Verification

Check feature state:

```bash
codex features list | rg '^(apps|plugins|enable_mcp_apps)\s'
```

Expected state:

```text
apps             stable             false
enable_mcp_apps  under development  false
plugins          stable             false
```

Check MCP configuration:

```bash
codex mcp list
```

Expected state: no configured MCP servers unless the user intentionally keeps separate MCP configuration.

Check plugin state:

```bash
codex plugin list
```

Expected state for the original Imsight preference: no marketplace plugins found.

## Notes

These changes apply globally for new Codex CLI sessions. A currently running Codex session may still show tools or skills injected when that session started. Restart Codex CLI after changing the config, removing plugins, or clearing caches.
