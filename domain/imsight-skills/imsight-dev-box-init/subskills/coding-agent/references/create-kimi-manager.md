# Kimi Account Manager Setup

Use this reference when the user wants to deploy or repair the Kimi Code account manager `kimi-project.sh`: a self-contained Bash tool that deploys OAuth account state from long-lived account homes ("slots": `~/.kimi-code` plus `~/kimi-homes/*`, typically created by `kimi-multi-credential`) into project-scope data homes (`<project>/.kimi-code/`), binds aliases to accounts, detects slots re-logged into the wrong account, marks slots private, and logs deployments so later audits know where credentials live. It needs no python and no jq binary; JSON parsing comes from an embedded JSON.awk copy.

## Workflow

1. Resolve the install path and initialization choices under **Required Input**.
2. Check the host under **Prerequisite: Account Homes and Host Tools**.
3. Complete **No-Write Deployment Preflight**: read-only dependency, syntax, parser, and collision checks. Do not install files or write state yet.
4. Install the script and companion per **Deployment Contract**.
5. Initialize state per **State Initialization**: adopt slots, bind aliases, mark private slots.
6. Run every applicable check in **Verification**, including one disposable end-to-end deploy when the user permits a real model turn.
7. Report the installed paths, state files, initialized slots and aliases, and any remaining user action.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's inputs, contracts, verification rules, and user constraints, then execute the plan without exposing credentials.

## Manager Contract

Apply these durable principles regardless of script version:

- The manager never logs accounts in. OAuth login stays with the per-slot launchers (`kimi-multi-credential`) or with an in-project `kimi login` against an empty project home. The manager only copies, tracks, and audits account state.
- A deployment copies exactly `config.toml` and `credentials/` from a source home. Other project-local content under `.kimi-code/` (`skills/`, `mcp.json`, `local.toml`) is project configuration, not a data home, and is never touched. A project "has a home" only when `config.toml` or `credentials/` exists there.
- Aliases bind to accounts (OAuth `user_id`), never to slots. Deploy selectors resolve as exact alias, then slot name, then unique account-id prefix. Account-based deploys always source the freshest known credential copy across slots and logged projects, so refresh-token rotation cannot strand a deployment on a dead copy.
- Exclusion is per slot. An excluded slot's credentials are never read, scanned, or deployed by any subcommand; `include` lifts the flag.
- `reset` never deletes: it moves project `config.toml`/`credentials/` to a timestamped backup under `~/kimi-homes/.backups/`.
- Runtime state lives only under `~/kimi-homes/` (`manifest.json`, `deployments.jsonl`, `.backups/`) and never inside a repository, a slot home, or the skill tree. No token material is ever written to state files or printed.

## Required Input

- Install path: default `$HOME/kimi-project.sh`. Ask when the user wants another location; do not install inside `~/.kimi-code`, a slot home, or a Git-tracked path.
- Slots to adopt at install time: default is every discovered slot that holds credentials.
- Aliases to bind: ask the user for account names (for example `work`, `personal`) and which slot currently holds each.
- Slots to exclude as private: default none.

```text
Please provide the install path (default ~/kimi-project.sh), account alias names and their current slots, and any slots to mark private.
```

## Prerequisite: Account Homes and Host Tools

- An installed `kimi` binary and at least one logged-in account home: the default `~/.kimi-code`, or `~/kimi-homes/<name>` from `kimi-multi-credential`. Without a logged-in home there is nothing to manage.
- Host tools: `bash`, any POSIX `awk` (gawk, mawk, or busybox awk), `sed`, and GNU coreutils (`base64`, `date`, `sort`). No python, no `jq` binary. Linux-only for now (`sed -r`, `date -d`).
- The bundled script: `<coding-agent-subskill-dir>/scripts/kimi-project.sh`, and the companion `<coding-agent-subskill-dir>/scripts/set-kimi-home-as-pwd.sh`. Resolve `<coding-agent-subskill-dir>` to the `subskills/coding-agent/` directory whose `references/` folder contains this page.

## No-Write Deployment Preflight

Run these read-only checks before installing anything:

1. `bash -n <coding-agent-subskill-dir>/scripts/kimi-project.sh` and confirm the dependencies above with `command -v`.
2. Exercise the embedded parser without installing: run the bundled script's read-only `list` subcommand in place. It materializes JSON.awk to a temp file, parses credentials, and exits without writing state; existing slots appear as `untracked`.
3. Confirm the install path does not collide with an existing file the user did not ask to replace, and list which slots currently hold credentials (`~/.kimi-code/credentials/*.json`, `~/kimi-homes/*/credentials/*.json`).
4. Stop without installing when dependencies, the bundled script, or a logged-in home are missing. Do not compensate by editing the script.

## Deployment Contract

- Install the bundled script byte-for-byte at the resolved path and `chmod +x`; verify with `cmp`. Never edit per-host values into it: the script derives everything from `$HOME` at runtime, so one unmodified copy serves every host user.
- Install the companion `set-kimi-home-as-pwd.sh` at `$HOME/set-kimi-home-as-pwd.sh` when the user wants project activation in the current shell. A project home only takes effect with `KIMI_CODE_HOME` pointed at it; `deploy` prints the reminder (`source ~/set-kimi-home-as-pwd.sh`).
- Upgrades replace the whole file with the newer bundled copy and re-run the preflight; `manifest.json` and `deployments.jsonl` carry over unchanged.
- Repairs reinstall from the bundled copy and re-verify `list` and `scan` read-only before declaring success.

## State Layout

- `~/kimi-homes/manifest.json` (mode 600): all configurable state — account aliases and each slot's expected account, exclusion flag, and path. Regenerated atomically on every mutation.
- `~/kimi-homes/deployments.jsonl` (mode 600): append-only deployment log (`deploy`, `new`, `reset` events with account id, source, project, and credential issue time). This is what later tells `scan` where credentials were planted.
- `~/kimi-homes/.backups/`: timestamped `reset` backups.
- Slot homes themselves stay where they are; the manager never moves or rewrites them.

## State Initialization

After installing, initialize the manifest from the live host:

```bash
~/kimi-project.sh adopt default            # record ~/.kimi-code's current account as expected
~/kimi-project.sh adopt kimi-<suffix>      # repeat per launcher home with credentials
~/kimi-project.sh alias <name> default     # bind each user-named alias to its slot
~/kimi-project.sh exclude <slot>           # mark private slots, when requested
```

`list` should then show every slot `ok` with its alias, and `scan` should report `no drift detected`.

## Daily Operations

Read-only: `list` (slots, aliases, drift), `status [--project DIR]` (one project's account, deployment record, staleness), `log [COUNT]` (deployment history), `scan [PATH ...]` (account freshness ranking plus drift audit over slots, logged projects, and optional extra roots).

Mutating: `deploy <selector> [--from SLOT] [--force] [--project DIR]`, `new`, `reset`, `adopt`, `alias`, `unalias`, `exclude`, `include`. Typical flows:

```bash
cd <project> && ~/kimi-project.sh deploy work   # plant account "work" in this project
source ~/set-kimi-home-as-pwd.sh && kimi        # activate and run
~/kimi-project.sh reset && ~/kimi-project.sh deploy personal   # swap accounts
~/kimi-project.sh scan                          # audit: freshest copy per account + drift
```

Refusals are guardrails, not failures: existing project home (run `reset`), drifted or stale `--from` slot (`--force` overrides deliberately), and any access to an excluded slot (`include` lifts).

## Verification

```bash
cmp <coding-agent-subskill-dir>/scripts/kimi-project.sh ~/kimi-project.sh   # byte-identical install
~/kimi-project.sh list     # all adopted slots ok, aliases bound
~/kimi-project.sh scan     # account freshness table; no drift detected
```

When the user permits one real model turn, prove a deployment end to end in a disposable project, then clean it up:

```bash
tmp=$(mktemp -d) && cd "$tmp"
~/kimi-project.sh deploy <alias>
KIMI_CODE_HOME="$tmp/.kimi-code" kimi -p "Reply with exactly the word: ok"
cd / && rm -rf "$tmp"
```

`~/kimi-project.sh log` must show the `deploy` and any `reset` events from these checks.

## Notes

- Relationship to `kimi-multi-credential`: the launcher reference creates and logs in isolated account homes; this reference deploys those homes into projects and audits the fleet. Set up launchers first when no isolated home exists yet.
- Copies diverge silently: each home refreshes its own credential independently, so a project copy often becomes fresher than its origin slot. Freshest-copy sourcing in `deploy` and the `scan` freshness table exist for exactly this reason.
- The script embeds JSON.awk v1.4.2 (MIT or Apache 2). Keep its copyright header intact when updating the embedded parser, and re-run the full verification after any parser swap.
- `manifest.json` replaces earlier TSV state; when a host still has `aliases.tsv`/`slots.tsv`, migrate by running the equivalent `adopt`/`alias`/`exclude` commands against the new install, then remove the old files.

## Guardrails

- DO NOT print, hard-code, or commit OAuth token contents; the manager reads only claim metadata (`user_id`, `iat`, `exp`) and never logs token material.
- DO NOT edit per-host paths or account values into the installed script; it self-configures from `$HOME`.
- DO NOT delete a project home's `config.toml` or `credentials/` by hand to force a swap; use `reset` so the freshest copy of an account is always preserved in a backup.
- DO NOT read, scan, or deploy from an excluded slot, and do not lift an exclusion without the user's explicit request.
- DO NOT install the script, its state, or test deployments inside a Git-tracked path.
- DO NOT skip the preflight dependency and collision checks before installing or upgrading.
