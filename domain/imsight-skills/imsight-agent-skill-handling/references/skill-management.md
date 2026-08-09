# Manage Skills with asm

## Workflow

Use this reference to install, link, inventory, and uninstall agent skills with `asm` (the `agent-skill-manager` CLI).

1. **Select the operation** from the **Operations** table based on the user's task.
2. **Resolve the skill source** when the operation installs or links. See **Skill Sources**.
3. **Resolve the target provider and scope**. See **Providers and Scopes**. Ask the user when neither the request nor the context identifies a provider.
4. **Run the asm command** with non-interactive flags (`--yes`, `--json` where supported). See **Command Form**. When the task exceeds what this page covers, consult **Upstream Reference**.
5. **Verify the result**. See **Verification**.
6. **Report the outcome** following **Output Contract**.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the operations, sources, and provider constraints in this reference, then execute the plan.

## Command Form

Run every command through `npx -y agent-skill-manager`, which needs no prior installation and requires Node.js 18+:

```bash
npx -y agent-skill-manager <command> [options]
```

When a host already provides an `asm` binary on `PATH` (check with `which asm`), the shorter `asm <command>` form is equivalent; prefer it to avoid repeated `npx` downloads.

## Upstream Reference

The authoritative source for asm is its repository: https://github.com/luongnv89/asm

This page covers the common operations, but asm evolves. When in doubt — an unfamiliar flag, an error this page does not explain, a provider not listed here, or a command that behaves differently than described — consult the repository README and `docs/` before improvising, and prefer `npx -y agent-skill-manager <command> --help` for the exact CLI contract of the installed version.

## Operations

| Operation | Use For | Command Shape |
| --- | --- | --- |
| Install from registry | Install a published skill by name | `install <skill-name>` |
| Install from remote repo | Install from a GitHub repository | `install github:<user>/<repo>` |
| Install from local repo | Copy a local skill into a provider | `install <local-path>` |
| Link for development | Symlink a local skill so edits apply immediately | `link <local-path>` |
| Inventory | List or inspect installed skills | `list`, `inspect <skill-name>` |
| Uninstall | Remove an installed skill | `uninstall <skill-name>` |

Common flags:

- `-p, --tool <name>` — target provider; see **Providers and Scopes**.
- `-s, --scope <scope>` — `global`, `project`, or `both` (default `both`).
- `-y, --yes` — skip confirmations; always use it in agent-driven runs.
- `-f, --force` — overwrite an existing install at the target.
- `--json` — machine-readable output on `list`, `search`, `inspect`, and `install`.

## Skill Sources

Registry (published skills):

```bash
npx -y agent-skill-manager install <skill-name> -p <provider> --yes
```

Remote GitHub repository:

```bash
# whole repo (root SKILL.md) or pin a ref
npx -y agent-skill-manager install github:<user>/<repo> -p <provider> --yes
npx -y agent-skill-manager install github:<user>/<repo>#v1.0.0 -p <provider> --yes

# multi-skill repo: one subdirectory, or every skill in the repo
npx -y agent-skill-manager install github:<user>/<repo> --path <subdir> -p <provider> --yes
npx -y agent-skill-manager install github:<user>/<repo> --all -p <provider> --yes

# private repo over SSH
npx -y agent-skill-manager install github:<user>/<repo> --transport ssh -p <provider> --yes
```

Local repository (copy install):

```bash
npx -y agent-skill-manager install ./path/to/skill -p <provider> --yes
```

Local repository (symlink for development):

```bash
# single skill: the directory itself contains SKILL.md
npx -y agent-skill-manager link ./path/to/skill -p <provider>

# folder of skills: no root SKILL.md, subdirectories each contain one;
# all discovered skills are linked in a single invocation
npx -y agent-skill-manager link ./path/to/skills-folder -p <provider> --force
```

Choose `link` over `install` for local checkouts the user actively develops: the provider entry is a symlink, so edits in the source repo take effect without reinstalling. Choose `install` (copy) when the skill must survive deletion or relocation of the source checkout. Use `--force` when replacing an existing copied install with a symlink.

## Providers and Scopes

Each provider maps to a global and a project skill directory. Common providers:

| Provider | Global Path | Project Path |
| --- | --- | --- |
| `claude` | `~/.claude/skills/` | `.claude/skills/` |
| `codex` | `~/.codex/skills/` | `.codex/skills/` |
| `agents` | `~/.agents/skills/` | `.agents/skills/` |
| `cursor` | `~/.cursor/rules/` | `.cursor/rules/` |

More providers (`opencode`, `gemini`, `amp`, `windsurf`, and others) are enabled by default; run `npx -y agent-skill-manager config show` for the full list.

- Omit `-s` or pass `-s global` to install into the user-level directory.
- Pass `-s project` and run from the project root to install into the project-local directory.

## Uninstall

```bash
npx -y agent-skill-manager uninstall <skill-name> --yes
npx -y agent-skill-manager uninstall <skill-name> -p <provider> -s project --yes
```

Uninstall removes the provider entry. For a linked skill this removes only the symlink and leaves the source checkout intact.

## Verification

After any operation, confirm the resulting state:

```bash
# inventory for one provider, machine-readable
npx -y agent-skill-manager list -p <provider> --json

# metadata and install location of one skill
npx -y agent-skill-manager inspect <skill-name> --json

# confirm a development link is a real symlink to the source repo
ls -la <provider-skill-dir>/<skill-name>
```

## Guardrails

- DO NOT uninstall or overwrite (`--force`) a skill the user did not name or clearly imply.
- DO NOT pass `--transport ssh` or target private repositories unless the user requested that source.
- DO NOT treat `asm link` as a backup; never delete the source checkout of a linked skill without relinking or reinstalling first.
- DO NOT run `asm` mutations outside provider skill directories; asm manages only its configured provider paths.

## Output Contract

Return a brief chat summary containing:

- the operation performed and the exact command run;
- the skill source and the resolved provider and scope;
- the verification result (inventory entry, inspect output, or symlink target);
- any skipped or failed items with their cause.
