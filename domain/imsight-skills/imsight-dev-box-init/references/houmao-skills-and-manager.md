# Houmao Skills and Manager Setup

Use this reference to install Houmao itself, verify `houmao-mgr`, and install Houmao system skills into supported agent homes.

## Workflow

1. Check **Prerequisites**.
2. Install or verify Houmao and `houmao-mgr` using the maintained commands.
3. Install the requested system skills using the preferred path or documented alternate installer.
4. Apply **Home Resolution Notes** and run **Verification**.

If the task does not map cleanly to these steps, plan only from the existing install paths, agent homes, and verification rules; do not invent an unsupported destination.

## Prerequisites

- `uv` for installing Houmao as a global tool.
- `tmux` available in `PATH`; Houmao managed agents run in tmux sessions.
- Network access to GitHub and npm if using the `npx skills add` path.

## Install Houmao and houmao-mgr

Install Houmao:

```bash
uv tool install houmao
```

Verify the required commands:

```bash
command -v houmao
command -v houmao-mgr
command -v tmux
houmao-mgr --help
```

`houmao-mgr` is installed with the `houmao` tool package. If it is missing after install, refresh the uv tool shims:

```bash
uv tool update-shell
```

Open a new shell if the command still is not found.

## Install Houmao System Skills

Preferred path through Houmao's manager:

```bash
houmao-mgr system-skills install --tool codex
```

Install for several supported tools in one command:

```bash
houmao-mgr system-skills install --tool claude,codex,gemini
```

Use an explicit Codex home when the default discovery is not desired:

```bash
houmao-mgr system-skills install --tool codex --home ~/.codex
```

Install only the core automation/control skills:

```bash
houmao-mgr system-skills install --tool codex --skill-set core
```

Install all packaged system skills:

```bash
houmao-mgr system-skills install --tool codex --skill-set all
```

Install one specific skill:

```bash
houmao-mgr system-skills install --tool codex --skill houmao-agent-definition
```

Use symlinks while developing or editing the Houmao skill sources:

```bash
houmao-mgr system-skills install --tool codex --symlink
```

## Alternate npx Installer

When the Skills CLI is available through npm, install from the Houmao repository path:

```bash
npx skills add https://github.com/igamenovoer/houmao/tree/main/src/houmao/agents/assets/system_skills/
```

Use this when an interactive skill selection flow is preferred.

## Home Resolution Notes

If `--home` is omitted, let `houmao-mgr` resolve each tool home. For Codex this usually means `CODEX_HOME` when set, then the standard Codex home such as `~/.codex`.

For multi-tool installs, omit `--home` unless intentionally forcing a single destination. Each tool should resolve to its own native home.

## Verification

Check installed skill directories:

```bash
find ~/.codex/skills -maxdepth 2 -name SKILL.md | sort
```

In a supported agent, test that skills are visible by invoking a Houmao system skill help prompt, for example:

```text
$houmao-touring help
$houmao-agent-email-comms help
```

## Source References

- Houmao repository: `https://github.com/igamenovoer/houmao/tree/main`
- System skills source: `https://github.com/igamenovoer/houmao/tree/main/src/houmao/agents/assets/system_skills/`
- System skills overview: `https://github.com/igamenovoer/houmao/blob/main/docs/getting-started/system-skills-overview.md`
