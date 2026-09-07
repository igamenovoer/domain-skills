# Install Ponytail

Use this reference to install Ponytail for a coding agent. Install the six canonical skills only by default. Install lifecycle hooks only when the user explicitly requests the full plugin.

## Workflow

1. Check **Prerequisites** and inspect existing Ponytail installations.
2. Select a mode from **Installation Modes**. Use `skill-only-asm` when the user does not request a mode.
3. Resolve the target agent and scope under **Target Paths**.
4. Follow the selected installation procedure without overwriting an existing installation.
5. Run **Verification** and report the mode, target, scope, Ponytail revision, and any restart or new-session action.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the modes, target paths, collision rules, and user request, then execute the plan without adding hooks unless full plugin mode was explicitly requested.

## Installation Modes

| Mode | Use For | Hooks |
| --- | --- | --- |
| `skill-only-asm` | Default. Install canonical skills into the ASM library and activate provider symlinks. | No |
| `skill-only-copy` | Copy canonical skill directories directly when ASM or symlinks are unsuitable. | No |
| `full-plugin` | Install Ponytail through the supported Claude Code or Codex plugin path. | Yes |

Skill-only mode provides `ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, and `ponytail-help`. It does not provide always-on session activation, mode tracking, or subagent injection.

## Prerequisites

- `git` and network access to `https://github.com/DietrichGebert/ponytail`.
- Node.js 22 or newer for the current `agent-skill-manager` CLI.
- `node` on the non-interactive shell's `PATH` for full Claude Code or Codex hook operation.

Check versions and record the current Ponytail revision:

```bash
git --version
node --version
npx -y agent-skill-manager --version
git ls-remote https://github.com/DietrichGebert/ponytail.git refs/heads/main
```

These instructions were verified on 2026-09-07 with `agent-skill-manager` 2.18.0 and Ponytail 4.9.0. Re-check the current CLI help and upstream install section when either version changes.

Before installing, inspect existing copies and plugin state for the selected host:

```bash
npx -y agent-skill-manager search ponytail --flat --json
codex plugin list 2>/dev/null || true
```

Use the host's plugin browser for Claude Code. Do not install the same skill names from both skill-only and plugin sources into one host.

## Target Paths

Use global scope by default for dev-box setup. Use project scope when the user requests repository-local activation.

| ASM tool | Global skill root | Project skill root |
| --- | --- | --- |
| `agents` | `~/.agents/skills/` | `.agents/skills/` |
| `codex` | `~/.codex/skills/` | `.codex/skills/` |
| `claude` | `~/.claude/skills/` | `.claude/skills/` |

Prefer `agents` for a shared standards-compatible installation. Use `codex` for Codex-only isolation and `claude` for Claude Code, which does not use the shared Agents path.

For another ASM-supported host, read its configured provider id and paths with `npx -y agent-skill-manager config show`; do not guess its skill root.

## Skill-Only Installation with ASM Symlinks

Set `tool` and `scope` from **Target Paths**, then install each canonical directory into ASM's neutral library and activate it by symlink:

```bash
tool=agents
scope=global
case "$tool:$scope" in
  agents:global) skill_root="$HOME/.agents/skills" ;;
  agents:project) skill_root="$PWD/.agents/skills" ;;
  codex:global) skill_root="$HOME/.codex/skills" ;;
  codex:project) skill_root="$PWD/.codex/skills" ;;
  claude:global) skill_root="$HOME/.claude/skills" ;;
  claude:project) skill_root="$PWD/.claude/skills" ;;
  *) printf 'unsupported tool or scope: %s %s\n' "$tool" "$scope" >&2; exit 2 ;;
esac
skills=(
  ponytail
  ponytail-review
  ponytail-audit
  ponytail-debt
  ponytail-gain
  ponytail-help
)

for skill in "${skills[@]}"; do
  npx -y agent-skill-manager install github:DietrichGebert/ponytail \
    --path "skills/$skill" --library --yes --json
  npx -y agent-skill-manager activate "$skill" \
    --tool "$tool" --scope "$scope" --json
done
```

Ponytail also contains generated OpenClaw copies under `.openclaw/skills/`. Do not use `--all`; install the canonical `skills/<name>` paths explicitly so duplicate names are not selected.

If a target already exists, inspect it and stop. Use `--force` only when the user explicitly authorizes replacing that exact activation.

## Skill-Only Installation by Direct Copy

Resolve `skill_root` from **Target Paths**. Clone into a unique temporary directory, refuse collisions, then copy only the six canonical skill directories:

```bash
skill_root="$HOME/.agents/skills"
source_root="$(mktemp -d)"
git clone --depth 1 https://github.com/DietrichGebert/ponytail.git \
  "$source_root/ponytail"

skills=(
  ponytail
  ponytail-review
  ponytail-audit
  ponytail-debt
  ponytail-gain
  ponytail-help
)

for skill in "${skills[@]}"; do
  if [ -e "$skill_root/$skill" ]; then
    printf 'existing Ponytail target: %s\n' "$skill_root/$skill" >&2
    exit 2
  fi
done

mkdir -p "$skill_root"
for skill in "${skills[@]}"; do
  cp -a "$source_root/ponytail/skills/$skill" "$skill_root/$skill"
done

git -C "$source_root/ponytail" rev-parse HEAD
```

Remove the unique temporary directory after verification. Direct copies do not update automatically; repeat the collision check and replace only explicitly approved copies when updating.

## Full Plugin Installation with Hooks

Use this mode only when the user explicitly requests always-on activation and hook-backed mode tracking or subagent injection. If ASM symlinks are active for the same host, deactivate those exact links first:

```bash
tool=codex
scope=global
for skill in ponytail ponytail-review ponytail-audit ponytail-debt ponytail-gain ponytail-help; do
  npx -y agent-skill-manager deactivate "$skill" \
    --tool "$tool" --scope "$scope" --json
done
```

Move direct-copy installations outside the host's skill root before installing the plugin. Preserve them until plugin verification succeeds.

For Claude Code, send these as two separate interactive prompts:

```text
/plugin marketplace add DietrichGebert/ponytail
```

```text
/plugin install ponytail@ponytail
```

For Codex, run:

```bash
codex plugin marketplace add DietrichGebert/ponytail
codex plugin add ponytail@ponytail
```

Then start Codex, open `/hooks`, review and trust Ponytail's lifecycle hooks, and start a new thread. Restart the Codex desktop app after installation. Do not run the hook scripts manually.

## Verification

For an ASM installation, confirm that all six skills are listed and each target is a symlink:

```bash
npx -y agent-skill-manager list --tool "$tool" --scope "$scope" --flat --json
for skill in ponytail ponytail-review ponytail-audit ponytail-debt ponytail-gain ponytail-help; do
  test -L "$skill_root/$skill"
  test -f "$skill_root/$skill/SKILL.md"
done
```

For a direct copy, use the same loop with `test -d` in place of `test -L`.

For a full plugin installation, confirm that the host lists `ponytail`, start a new session, and invoke `ponytail-help`. In Codex, also confirm `/hooks` shows the trusted Ponytail hooks. A full installation is incomplete until the new session loads the plugin.

## Guardrails

- DO NOT install hooks unless the user explicitly requests `full-plugin` behavior.
- DO NOT use ASM `--all` against the Ponytail repository; select the six canonical `skills/<name>` paths.
- DO NOT overwrite, force-activate, or delete an existing same-name skill without resolving its source and obtaining explicit authorization.
- DO NOT keep plugin-provided and skill-only copies of the same Ponytail skills active in one host.
- DO NOT claim that skill-only mode provides always-on activation, mode persistence, or hook-based subagent injection.
- DO NOT run Ponytail's hook scripts directly or trust hooks without reviewing them in the host.

## Source References

- Ponytail repository and install instructions: `https://github.com/DietrichGebert/ponytail`
- Ponytail Claude Code and Codex hooks: `https://github.com/DietrichGebert/ponytail/blob/main/hooks/claude-codex-hooks.json`
- Agent Skill Manager repository and provider paths: `https://github.com/luongnv89/asm`
