# Context7 CLI Setup

Use this reference to install the Context7 CLI (`ctx7`) and its agent skill. Do not set up the Context7 MCP server; the Imsight-preferred integration is the CLI plus the `context7-cli` skill.

## Workflow

1. Check **Prerequisites** and existing `ctx7` status.
2. Install or update the CLI.
3. Install the `context7-cli` skill for the requested agent.
4. Run **Verify**.

## Prerequisites

- Node.js 18+ and `npm` for the CLI install.
- `npx` for the Skills CLI skill install.
- Network access to npm, GitHub, and context7.com.

## Install Context7 CLI

Check first:

```bash
command -v ctx7 && ctx7 --version
```

Install or update:

```bash
npm install -g ctx7@latest
```

Without a global install, `npx ctx7@latest <command>` also works.

An API key from https://context7.com/dashboard raises rate limits but is not required.

## Install the context7-cli Skill

Use the same Skills CLI path and agent ids as the Tavily skills setup (see `tavily-cli-and-skills.md` for the agent path table; the Kimi Code CLI agent id is `kimi-code-cli`):

```bash
npx skills add https://github.com/upstash/context7 --skill context7-cli --agent kimi-code-cli --yes
```

Project scope is the default and lands in `.agents/skills/context7-cli/` for Kimi Code CLI, Codex CLI, and Gemini CLI.

## Verify

```bash
ctx7 library react "hooks"
```

Expect a numbered list of Context7-compatible library IDs.
