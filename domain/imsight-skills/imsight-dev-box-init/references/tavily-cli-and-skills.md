# Tavily CLI and Skills Setup

Use this reference to install Tavily CLI (`tvly`), authenticate it, and install Tavily skills for the requested coding agent. Keep install mechanics in the skill-owned scripts; this reference chooses the right path and handles credentials.

## Workflow

1. Check **Prerequisites** and existing `tvly` status.
2. Install the CLI using the preferred or documented fallback path.
3. Authenticate without exposing the API key.
4. Resolve the requested agent home and install Tavily skills using the maintained method.
5. Run **Verify** and **Test**, applying **Pitfalls** when needed.

If the task does not map cleanly to these steps, plan only from the documented install, authentication, agent-path, and verification choices; keep credentials private.

## Prerequisites

- `uv` for the preferred Tavily CLI install path.
- `curl` for the Tavily CLI fallback installer.
- `npx` for the preferred non-interactive Skills CLI install path.
- `git` for the manual skill-install fallback when `npx` is unavailable.
- A Tavily API key, usually starting with `tvly-`.
- Network access to Tavily, npm, and GitHub.

## Install Tavily CLI

Check first:

```bash
command -v tvly && tvly --status
```

Prefer `uv`:

```bash
uv tool install tavily-cli
```

If `uv` is unavailable:

```bash
curl -fsSL https://cli.tavily.com/install.sh | bash
```

Do not use `pip install tavily-cli` unless the user explicitly asks for pip.

## Authenticate

Prefer `TAVILY_API_KEY` when already set. If no key is available, ask:

```text
Please provide your Tavily API key.
```

Authenticate and verify:

```bash
tvly login --api-key "$TAVILY_API_KEY"
tvly --status
```

Do not print API keys in final responses or logs.

## Agent Paths

Official Skills CLI paths for the Imsight-supported coding agents:

| Target | `--agent` | Project path | Global path |
| --- | --- | --- | --- |
| Claude Code | `claude-code` | `.claude/skills/` | `~/.claude/skills/` |
| Codex CLI | `codex` | `.agents/skills/` | `~/.codex/skills/` |
| Gemini CLI | `gemini-cli` | `.agents/skills/` | `~/.gemini/skills/` |
| Kimi Code CLI | `kimi-cli` | `.agents/skills/` | `~/.config/agents/skills/` |

Project scope is the default for `npx skills add`. Codex CLI, Gemini CLI, and Kimi Code CLI all respect `.agents/skills/` in project scope, so do not copy or symlink those project skills into tool-specific project dirs. Claude Code uses `.claude/skills/`.

For global scope, use each agent's official global path. Do not assume `.agents/skills/` is a global path.

## Install Tavily Skills

Use the bundled script so the install logic stays consistent. Resolve `<skill-root>` to the `imsight-dev-box-init` skill directory that contains this reference.

```bash
<skill-root>/scripts/install-tavily-skills.sh --agent codex --scope project
```

Common examples:

```bash
<skill-root>/scripts/install-tavily-skills.sh --agent claude-code --scope project
<skill-root>/scripts/install-tavily-skills.sh --agent gemini-cli --scope project
<skill-root>/scripts/install-tavily-skills.sh --agent kimi-cli --scope project
<skill-root>/scripts/install-tavily-skills.sh --agent codex --scope global
```

If the user asks for a subset, repeat `--skill`:

```bash
<skill-root>/scripts/install-tavily-skills.sh --agent codex --scope project --skill tavily-search --skill tavily-extract
```

The script prefers:

```bash
npx skills add https://github.com/tavily-ai/skills --agent <agent> --skill '*' --yes
```

When `npx` is unavailable, the script falls back to a temporary git clone and copies individual `tavily-*` skill directories into the correct target root. You can force that fallback with `--manual`.

## Verify

For installs performed through `npx skills`, verify with Skills CLI metadata:

```bash
<skill-root>/scripts/verify-tavily-skills.sh --agent codex --scope project
```

For manual fallback installs only, verify filesystem content:

```bash
<skill-root>/scripts/verify-tavily-skills.sh --agent codex --scope project --manual
```

Expected skill names include:

- `tavily-cli`
- `tavily-search`
- `tavily-extract`
- `tavily-crawl`
- `tavily-map`
- `tavily-research`
- `tavily-dynamic-search`
- `tavily-best-practices`

## Test

Run a small search:

```bash
tvly search "tavily cli test" --json | head -20
```

## Pitfalls

- `tvly login` requires the key immediately; do not defer authentication if the user asked for complete setup.
- Prefer the script over hand-written `npx skills add` commands for install and verification.
- Verify `npx skills` installs with `npx skills list`, not manual directory inspection.
- Use manual filesystem checks only for manual fallback installs.
- For project installs on Codex CLI, Gemini CLI, and Kimi Code CLI, `.agents/skills/` is the install. Do not create extra project-scope copies or symlinks under tool-specific dirs.
- Use global scope only when the user explicitly wants user-level skills across projects.

## Source References

- Tavily skills repository: `https://github.com/tavily-ai/skills`
- Skills CLI reference: `https://skills.sh/docs/cli`
- Skills CLI supported-agent paths: `https://github.com/vercel-labs/skills`
- Tavily CLI docs: `https://docs.tavily.com/documentation/tavily-cli`
- Tavily site: `https://tavily.com`
