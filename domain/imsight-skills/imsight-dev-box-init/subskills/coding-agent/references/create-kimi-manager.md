# Kimi Account Manager Setup

Use this reference when the user wants to deploy or repair the Kimi Code account manager: `kimi-project.py`, a self-contained Python 3 tool that deploys OAuth auth sessions from long-lived account homes ("slots": `~/.kimi-code` plus `~/kimi-homes/*`, typically created by `kimi-multi-credential`) into project-scope data homes (`<project>/.kimi-code/`). An **auth session** is one independent login, identified by `(user_id, device_id)` read from the refresh-token JWT — two logins of the same account are distinct, separately deployable sessions. Slots are **self-declaring**: whatever session a slot currently holds IS its identity — there is no registration and no drift detection; re-logging a slot simply makes the new login its truth, and copies deployed elsewhere are owned by their projects. The manager binds aliases to sessions, marks slots private, keeps a single-entry `.backup/` of each home's auth state for `backup`/`restore`, ranks per-session credential freshness across slots and logged deploy targets, rescues fresher copies back into slots holding the same session, collects the freshest copy back to a seat on demand, returns sessions home on `undeploy`, and logs deployments so later audits know where credentials live. `kimi-project.sh` is only a thin launcher that execs `python3` on the sibling `kimi-project.py`; all logic lives in the Python script, which needs nothing beyond the standard library.

## Workflow

1. Resolve the install path and initialization choices under **Required Input**.
2. Check the host under **Prerequisite: Account Homes and Host Tools**.
3. Complete **No-Write Deployment Preflight**: read-only dependency, syntax, and collision checks. Do not install files or write state yet.
4. Install the script pair and companion per **Deployment Contract**.
5. Initialize state per **State Initialization**: bind aliases, mark private slots.
6. Run every applicable check in **Verification**, including one disposable end-to-end deploy when the user permits a real model turn.
7. Report the installed paths, state files, initialized aliases, and any remaining user action.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's inputs, contracts, verification rules, and user constraints, then execute the plan without exposing credentials.

## Manager Contract

Apply these durable principles regardless of script version:

- The manager never logs accounts in. OAuth login stays with the per-slot launchers (`kimi-multi-credential`) or with an in-project `kimi login` against an empty project home. The manager only copies, tracks, and audits auth state.
- Identity is the **auth session**: `(user_id, device_id)` read from the refresh-token JWT. The `device_id` claim is stable per login grant and survives refreshes; independent logins of the same account are distinct sessions. Sessions of one account are never mixed or freshness-ranked together.
- A slot's identity is read live from its own credentials — the tool never records which session a slot "should" hold. A re-logged slot is simply its new session; nothing is flagged or re-registered, and deployed copies elsewhere are unaffected (they belong to their projects).
- A deployment plants the source home's auth state into the deploy target — `--project DIR`, else `$KIMI_CODE_HOME`, else the current directory's `.kimi-code/` — with `credentials/` copied wholesale and `config.toml` merged key-wise: source keys win conflicts, target-only keys survive, so project-scoped settings are preserved. A missing target is created; an empty directory, or one holding only non-auth content, is filled without flags (its `config.toml` is then a byte-for-byte copy). Other project-local content under `.kimi-code/` (`skills/`, `mcp.json`, `local.toml`) is project configuration, not a data home, and is never touched. A target "has a home" only when `config.toml` or `credentials/` exists there. An excluded (private) home is refused as a deploy target.
- Aliases bind to sessions, never to slots or bare accounts. Deploy selectors resolve as exact alias, then slot name, then unique `device_id` or `user_id` prefix — a prefix matching several sessions is refused as ambiguous. Session-based deploys always source the freshest known copy of that session across slots and logged projects, so refresh-token rotation cannot strand a deployment on a dead copy. Whenever the freshest source copy lives outside the slots holding that session, deploy first rescues the newer credential into every such non-excluded slot that is older (logged as `rescue`).
- Freshness is ranked live: every command that compares copies traces all non-excluded slots plus every deploy-target home still present in the deployment log. A logged target whose directory no longer exists is silently skipped; prune its entries with `forget --dead`.
- `collect <slot>` writes the freshest known copy of the slot's current session back into its seat dir (logged as `collect`); `collect all` does this for every seat. If a slot is literally named `all`, `collect all` is ambiguous and must prompt: "every seats" or "the seat named all".
- Exclusion is per slot. An excluded slot's credentials are never read, scanned, or deployed by any subcommand; `include` lifts the flag.
- Each home carries a single-entry backup at `<home>/.backup/`: `backup` copies the home's `config.toml`/`credentials/` there (overwriting any previous entry), `restore` writes them back over the live auth (the backup is kept, so restores are repeatable), and `deploy`/`undeploy --force-with-backup` write it before overwriting. `backup`/`restore` target `--project DIR`, else `$KIMI_CODE_HOME`, else `~/.kimi-code`. Backup contents are never freshness-ranked or scanned.
- `deploy` refuses an occupied home (one holding `config.toml` or `credentials/`) by default. `--force` overwrites the live auth with no backup; `--force-with-backup` backs the home up to `.backup/` first (whole-file), and implies `--force` everywhere. An overwrite clears `credentials/` before copying but keeps the target's `config.toml` for the key-wise merge — source keys win conflicts, target-only keys survive; a source home without `config.toml` leaves the target's file untouched. The merge needs `tomllib` (Python 3.11+); older interpreters fall back to wholesale `config.toml` replacement with a warning. Before clearing, a doomed copy that is newer than the slots holding its session is rescued into them (logged as `rescue`); the freshest-known warning fires only when nothing could be rescued.
- `undeploy [--project DIR] [--force|--force-with-backup]` returns a project's auth: it rescues the project's session copy back into slots holding the same session when fresher, then removes the project's `config.toml` and `credentials/` and logs `undeploy`. It refuses to remove the session's freshest copy when no slot holds an equally fresh copy, unless `--force` (discard) or `--force-with-backup` (keep in `.backup/`). Target resolution is the same as `deploy`.
- Runtime state lives only under `~/kimi-homes/` (`manifest.json`, `deployments.jsonl`) and in per-home `.backup/` directories; the manifest and log never live inside a repository, a slot home, or the skill tree. No token material is ever written to state files or printed.
- The deployment log is caller-managed: `forget PATH ...` drops entries matching a home or its project directory, and `forget --dead` drops every entry whose home no longer exists. `forget` rewrites the log atomically and never touches deployed homes — removing files is the caller's concern.

## Required Input

- Install path: default `$HOME/` (the pair `kimi-project.py` + `kimi-project.sh` side by side). Ask when the user wants another location; do not install inside `~/.kimi-code`, a slot home, or a Git-tracked path. The launcher resolves the Python script next to itself, so the pair must always be installed together.
- Aliases to bind: ask the user for account names (for example `work`, `personal`) and which slot currently holds each.
- Slots to exclude as private: default none.

```text
Please provide the install directory (default ~), account alias names and their current slots, and any slots to mark private.
```

## Prerequisite: Account Homes and Host Tools

- An installed `kimi` binary and at least one logged-in account home: the default `~/.kimi-code`, or `~/kimi-homes/<name>` from `kimi-multi-credential`. Without a logged-in home there is nothing to manage.
- Host tools: `python3` (3.9+, standard library only; 3.11+ recommended — the settings-preserving config merge uses `tomllib`, and 3.9–3.10 fall back to wholesale `config.toml` replacement on forced deploys) and a POSIX `sh` for the launcher. No `jq`, no `awk` dependency.
- The bundled pair: `<coding-agent-subskill-dir>/scripts/kimi-project.py` and `<coding-agent-subskill-dir>/scripts/kimi-project.sh`, plus the companion `<coding-agent-subskill-dir>/scripts/set-kimi-home-as-pwd.sh`. Resolve `<coding-agent-subskill-dir>` to the `subskills/coding-agent/` directory whose `references/` folder contains this page.

## No-Write Deployment Preflight

Run these read-only checks before installing anything:

1. `python3 -c "import ast; ast.parse(open('<coding-agent-subskill-dir>/scripts/kimi-project.py').read())"` and `sh -n <coding-agent-subskill-dir>/scripts/kimi-project.sh`; confirm `python3 --version` is 3.9 or newer, and note when it is older than 3.11 (the settings-preserving config merge will be unavailable).
2. Exercise the tool without installing: run the bundled launcher's read-only `list` subcommand in place. It parses credentials and exits without writing state.
3. Confirm the install path does not collide with existing files the user did not ask to replace, and list which slots currently hold credentials (`~/.kimi-code/credentials/*.json`, `~/kimi-homes/*/credentials/*.json`).
4. Stop without installing when dependencies, the bundled pair, or a logged-in home are missing. Do not compensate by editing the script.

## Deployment Contract

- Install `kimi-project.py` and `kimi-project.sh` byte-for-byte at the resolved directory, side by side, and `chmod +x` both; verify each with `cmp`. Never edit per-host values into them: the script derives everything from `$HOME` at runtime, so one unmodified copy serves every host user.
- Install the companion `set-kimi-home-as-pwd.sh` at `$HOME/set-kimi-home-as-pwd.sh` when the user wants project activation in the current shell. A project home only takes effect with `KIMI_CODE_HOME` pointed at it; `deploy` prints the reminder (`source ~/set-kimi-home-as-pwd.sh`).
- Upgrades replace both files with the newer bundled copies and re-run the preflight; `manifest.json` and `deployments.jsonl` carry over unchanged.
- Repairs reinstall from the bundled copies and re-verify `list` and `scan` read-only before declaring success.

## State Layout

- `~/kimi-homes/manifest.json` (mode 600, schema version 3): all configurable state — session aliases (`name → "user_id:device_id"`) and, per slot, only `path`, `flags` (the exclusion flag), and `updated_at`. Rewritten atomically on every mutation. Older manifests are migrated on the first mutating command: expected-session fields and the sessions cache are dropped.
- `~/kimi-homes/deployments.jsonl` (mode 600): append-only deployment log (`deploy`, `undeploy`, `rescue`, `collect`, `backup`, `restore` events with account id, device id, source, target home, and credential issue time). This is what later tells freshness tracing where credentials were planted. Prune it with `forget`; entries are only ever dropped, never edited. Legacy entries without `device_id` still render and match any session of their account.
- `<home>/.backup/`: single-entry backup of a home's `config.toml`/`credentials/`, written by `backup` and by `deploy`/`undeploy --force-with-backup`, read by `restore`; a new backup run replaces the previous entry.
- Slot homes themselves stay where they are; the manager never moves or rewrites them except to converge a session's freshest copy into them (`rescue`, `collect`, `undeploy`).

## State Initialization

After installing, bind each user-named alias to the session currently in a slot, and mark private slots:

```bash
~/kimi-project.sh alias <name> default        # or: alias <name> kimi-<suffix>
~/kimi-project.sh exclude <slot>              # mark private slots, when requested
```

No registration step exists: a slot's session is read live from its credentials, so `list` is fully accurate from the first run.

## Daily Operations

Read-only: `list` (slot info — slot, alias, session, seat dir — plus per-slot deployment and freshness: last live deploy target, and the freshest credential file of the slot's session across slots and logged projects), `status [--project DIR]` (one project's session, deployment record, staleness), `log [COUNT]` (deployment history), `scan [PATH ...]` (per-session freshness ranking over slots, logged projects, and optional extra roots).

Mutating: `deploy <selector> [--from SLOT] [--force|--force-with-backup] [--project DIR]`, `undeploy [--force|--force-with-backup] [--project DIR]`, `collect <slot>|all`, `backup`, `restore`, `alias`, `unalias`, `exclude`, `include`, `forget [--dead | PATH ...]`. `deploy`/`undeploy` target `--project DIR`, else `$KIMI_CODE_HOME`, else the current directory's `.kimi-code/`; `backup`/`restore` target `--project DIR`, else `$KIMI_CODE_HOME`, else `~/.kimi-code`. Typical flows:

```bash
cd <project> && ~/kimi-project.sh deploy work   # plant session "work" in this project
source ~/set-kimi-home-as-pwd.sh && kimi        # activate and run
~/kimi-project.sh deploy --force-with-backup personal   # swap sessions (old auth lands in .backup/)
~/kimi-project.sh restore                       # undo the swap: put the backed-up auth back
cd <project> && ~/kimi-project.sh undeploy      # done: return the session home, de-auth the project
source ~/set-kimi-home-as-pwd.sh && kimi login  # or log a fresh account straight into the project home
~/kimi-project.sh collect all                   # converge every seat to its session's freshest copy
~/kimi-project.sh scan                          # audit: per-session freshness
```

Refusals are guardrails, not failures: occupied project home (`--force` overwrites, `--force-with-backup` backs up first), stale `--from` slot (`--force` overrides deliberately), ambiguous selector matching several sessions (use an alias or slot name), undeploy of a session's freshest copy with no equally fresh slot home (`--force` or `--force-with-backup`), and any access to an excluded slot (`include` lifts).

## Verification

```bash
cmp <coding-agent-subskill-dir>/scripts/kimi-project.py ~/kimi-project.py    # byte-identical install
cmp <coding-agent-subskill-dir>/scripts/kimi-project.sh ~/kimi-project.sh    # byte-identical launcher
~/kimi-project.sh list     # every slot shows its live session and seat dir
~/kimi-project.sh scan     # per-session freshness table
```

Prove the deploy/undeploy cycle in a disposable project, then clean it up:

```bash
tmp=$(mktemp -d)
~/kimi-project.sh deploy <alias> --project "$tmp"
~/kimi-project.sh status --project "$tmp"
~/kimi-project.sh undeploy --project "$tmp"   # session rescued home; project de-authed
rm -rf "$tmp"
```

When the user also permits one real model turn, insert `KIMI_CODE_HOME="$tmp/.kimi-code" kimi -p "Reply with exactly the word: ok"` between the deploy and the undeploy.

`~/kimi-project.sh log` must show the `deploy`/`undeploy` and any `rescue`/`collect`/`backup`/`restore` events from these checks.

## Notes

- Relationship to `kimi-multi-credential`: the launcher reference creates and logs in isolated account homes; each login there is one auth session, and this reference deploys those sessions into projects and audits the fleet. Set up launchers first when no isolated home exists yet.
- Why sessions and not accounts: the refresh-token JWT's `device_id` claim is stable per login grant (it survives refreshes, and deployed copies of one login keep it), while independent logins of the same account get distinct device ids. Keying on `(user_id, device_id)` keeps same-account logins apart — each is borrowable on its own — while copies of one login stay linked.
- Copies of a session diverge silently: each home refreshes its own credential independently, so a project copy often becomes fresher than its origin slot. Live freshness tracing in `list`/`scan`/`status`, per-session freshest-copy sourcing in `deploy`, the rescue-back step, `undeploy`'s return-home step, and on-demand `collect` exist for exactly this reason.
- Earlier versions were a self-contained Bash script with an embedded JSON.awk parser, a `register` command declaring each slot's expected session, drift detection comparing live credentials against that expectation, and a sessions cache in the manifest. The Python rewrite replaced all of it: slots are self-declaring (no registration, no drift), freshness is computed live instead of cached, and `kimi-project.sh` survives only as the launcher. Manifest schema v3 drops the expected-session fields and the sessions cache on the first mutating command; the deployment log format is unchanged. Retired earlier still: `adopt`, `reset`, and `new` — forced `deploy` and `undeploy` cover their roles, and historical `reset` entries in `deployments.jsonl` still render in `log`. Forced `deploy` also replaced the target's `config.toml` wholesale at first; it now merges key-wise (source wins conflicts, target-only keys survive) so project-scoped settings are no longer lost on session swaps.

## Guardrails

- DO NOT print, hard-code, or commit OAuth token contents; the manager reads only claim metadata (`user_id`, `device_id`, `iat`, `exp`) and never logs token material.
- DO NOT edit per-host paths or account values into the installed scripts; they self-configure from `$HOME`.
- DO NOT install only one of the pair: `kimi-project.sh` without its sibling `kimi-project.py` cannot run.
- DO NOT delete a project home's `config.toml` or `credentials/` by hand to force a swap or removal; use `deploy --force-with-backup` or `undeploy` so the auth state is preserved in the home's `.backup/` or rescued home. Manual removal is acceptable only when intentionally de-authing a project.
- DO NOT read, scan, or deploy from an excluded slot, and do not lift an exclusion without the user's explicit request.
- DO NOT install the scripts, their state, or test deployments inside a Git-tracked path.
- DO NOT skip the preflight dependency and collision checks before installing or upgrading.
