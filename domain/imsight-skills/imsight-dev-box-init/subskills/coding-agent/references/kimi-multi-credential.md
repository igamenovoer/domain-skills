# Kimi Multi-Credential Launcher Setup

Use this reference when the user wants one or more Kimi Code CLI launchers named `kimi-<suffix>`, each with an isolated data home under `~/kimi-homes/`, so multiple Kimi OAuth credentials or configurations can coexist on one host without touching the default `~/.kimi-code`.

## Workflow

1. Resolve the launcher name and data home under **Required Input**.
2. Check the installed `kimi` binary under **Prerequisite: Kimi Code CLI**.
3. Complete **No-Write Compatibility Preflight**. This launcher has no third-party provider key to probe before login, so verify the installed CLI and target isolation contract without creating the home, launcher, PATH entry, or shell startup block.
4. Implement the launcher from **Launcher Contract**, applying **Defaults** for unspecified values and disabling auto mode only when the initial request explicitly opts out. Use the bundled script as a Unix reference implementation when its assumptions match.
5. Put the launcher directory on PATH for new shells under **Ensure Launcher Directory On PATH**; skipping this leaves `kimi-<suffix>` unresolvable in fresh terminals.
6. Trigger the OAuth device-code login under **OAuth Login** when the user wants the new credential authorized now.
7. Run every applicable check in **Verification**.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's inputs, defaults, launcher contract, verification rules, and user constraints, then execute the plan without exposing credentials.

## Launcher Contract

- Give each launcher one stable name and one isolated `KIMI_CODE_HOME`; sharing a home means intentionally sharing credentials, configuration, sessions, and logs.
- Resolve the installed Kimi executable without recursively selecting the wrapper itself. Adapt the search order to the host's installation method and OS.
- Prepend Kimi's current most-permissive supported mode by default (`--auto` for the documented version), unless the initial request explicitly opts out, then forward all caller arguments unchanged.
- Keep login interactive and scoped to the isolated home. Creating a launcher must not silently copy or authorize credentials.
- Use an OS-native launcher and path-registration mechanism. The bundled script is a Bash example; a Windows implementation should express the same home isolation, argument-array forwarding, and exit-code behavior in PowerShell.
- Verify isolation, executable resolution in a fresh shell, permission mode, argument forwarding, and post-login credential location.

## Required Input

- Launcher name: `kimi-<suffix>`, where `<suffix>` is lowercase letters, digits, or hyphens and identifies the credential slot (for example a port-like tag such as `3180`). Ask the user when no suffix is given.
- Data home: the directory the launcher's `KIMI_CODE_HOME` points to. The user may specify it explicitly; otherwise apply **Defaults**.
- Startup mode: permissive `--auto` mode unless the user's initial launcher request explicitly asks for no-auto mode.

```text
Please provide the launcher suffix (kimi-<suffix>) and, optionally, a custom data home directory.
```

## Prerequisite: Kimi Code CLI

The launcher wraps an installed `kimi` binary; it does not install Kimi Code. Confirm one exists before generating:

```bash
command -v kimi || ls "$HOME/.kimi-code/bin/kimi"
```

At runtime the generated launcher resolves the binary in this order: the `--kimi-bin` path when pinned at generation time, `$HOME/.kimi-code/bin/kimi`, `$HOME/.local/bin/kimi`, then `command -v kimi`. If no binary is available, install Kimi Code CLI first.

## No-Write Compatibility Preflight

This workflow wraps Kimi Code's own interactive OAuth route, so a provider API-key probe is not applicable before setup. Before running the generator:

1. Run `kimi --version` and inspect `kimi --help` plus `kimi login --help` without setting `KIMI_CODE_HOME` to a new path.
2. Confirm the installed version still supports the intended permissive mode (`--auto` for the recorded version), device-code login, and the documented `KIMI_CODE_HOME` isolation variable.
3. Resolve the proposed launcher path and data-home path and confirm they do not collide with the default home, another launcher, or an unrelated existing file. Read existing state when needed, but do not create directories or files yet.
4. Stop without running the generator when the CLI, flags, login flow, or isolation variable no longer matches the contract. Do not infer compatibility from the bundled script.

## Defaults

- Launcher path: `$HOME/.local/bin/kimi-<suffix>`
- Data home: `$HOME/kimi-homes/kimi-<suffix>` — the home directory name matches the launcher name, so each launcher owns exactly one isolated home
- Runtime home override: `KIMI_HOME_OVERRIDE` environment variable, honored by the generated launcher ahead of its baked-in default
- Startup arguments: `--auto` is prepended by default so Kimi starts in Never Ask mode; `--no-auto` is a generation-time opt-out used only when the initial request explicitly rejects permissive mode
- Auth: Kimi Code OAuth via the device-code flow (`kimi login`); the credential lands in the isolated home, not in `~/.kimi-code`

`KIMI_CODE_HOME` relocates the config file, sessions, logs, and OAuth credentials. Multiple `kimi` instances sharing one home share config and credentials, so give each launcher its own home unless the user explicitly wants shared state. See the official environment-variable docs: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/env-vars.html`.

## Reference Unix Implementation

The bundled script demonstrates the contract for the currently documented Kimi Code CLI on Unix. Resolve `<coding-agent-subskill-dir>` to the `subskills/coding-agent/` directory whose `references/` folder contains this page. Inspect the script during the read-only phase, but run it only after **No-Write Compatibility Preflight** succeeds and only when its flags, paths, and executable-discovery assumptions match the host. Otherwise adapt the implementation and preserve the contract above.

```bash
<coding-agent-subskill-dir>/scripts/create-kimi-credential-launcher.sh --name kimi-<suffix>
```

With a user-specified home or output directory:

```bash
<coding-agent-subskill-dir>/scripts/create-kimi-credential-launcher.sh \
  --name kimi-<suffix> --home /path/to/custom/home --output "$HOME/.local/bin"
```

The example script also accepts `--kimi-bin` to pin a specific `kimi` binary. If the installed skill copy lost the script's execute bit, invoke the example through the interpreter: `bash <coding-agent-subskill-dir>/scripts/create-kimi-credential-launcher.sh ...`.

When the user's initial launcher request explicitly requests no-auto mode, generate the launcher with `--no-auto`:

```bash
<coding-agent-subskill-dir>/scripts/create-kimi-credential-launcher.sh \
  --name kimi-<suffix> --no-auto
```

The generated launcher derives nothing from its own filename at runtime; the name and home are baked in at generation time, and `KIMI_HOME_OVERRIDE` remains available as a runtime escape hatch. To make another credential slot, rerun the script with a new `--name`.

## Ensure Launcher Directory On PATH

A launcher that is not on PATH fails with `command not found` in new terminals. `~/.profile` typically adds `$HOME/.local/bin` for login shells only, so check a fresh interactive non-login shell first:

```bash
bash -ic 'command -v kimi-<suffix>'   # zsh: zsh -ic 'command -v kimi-<suffix>'
```

If the check fails, append a guarded block to the matching rc file (`~/.bashrc`, or `~/.zshrc` for zsh):

```bash
# User-local launchers (e.g. kimi-<suffix>)
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) [ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH" ;;
esac
```

If the launcher was written to a non-default `--output` directory, substitute that directory. Already-open terminals pick up the change only after `source ~/.bashrc` or a new window.

## OAuth Login

Authorization is a deliberate, per-launcher step; creating the launcher does not sign it in. Trigger the device-code flow against the isolated home:

```bash
kimi-<suffix> login
```

The CLI prints a URL and user code and waits for authorization. Relay both to the user verbatim; the user completes authorization in a browser. On a headless host, run the login in the background and relay the printed URL and code from its output. Success prints `Logged in to managed:kimi-code.` and writes `credentials`, `config.toml`, and `device_id` under the launcher's home. Add `--region mainland-cn` or `--region global` when the user's account region differs from the default.

## Verification

```bash
command -v kimi-<suffix>
bash -ic 'command -v kimi-<suffix>'   # must also resolve in a fresh non-login terminal
test -x "$HOME/.local/bin/kimi-<suffix>"
kimi-<suffix> --version               # resolves the real kimi binary through the launcher
ls "$HOME/kimi-homes/kimi-<suffix>"   # after login: credentials, config.toml, device_id
```

Confirm isolation and the startup default by inspecting the generated launcher with redaction-safe patterns:

```bash
rg -n 'KIMI_CODE_HOME|KIMI_HOME_OVERRIDE|default_kimi_args|exec' "$HOME/.local/bin/kimi-<suffix>"
```

The launcher's home must differ from `~/.kimi-code` and from every other generated launcher's home, unless the user explicitly asked to share one.

## Notes

- This launcher is for Kimi Code CLI's own OAuth identity. For Claude Code backed by Kimi keys, use `claude-kimi-launcher` instead.
- Keep reference launcher implementations in `<coding-agent-subskill-dir>/scripts/`; keep the durable launcher contract in this reference.
- Launcher runtime arguments are Kimi Code CLI arguments. The generated launcher prepends its generation-time default (`--auto` or no default arguments), then passes every runtime argument through unchanged; it must not consume, rename, reorder, or reinterpret `kimi` flags.
- Existing sessions, skills, and config under `~/.kimi-code` are not copied into a new home; migrate intentionally when the user wants a slot seeded from the default home.

## Guardrails

- DO NOT print, hard-code, or commit OAuth tokens or credential file contents handled by this workflow.
- DO NOT run the launcher generator or create its data home, PATH entry, or shell-profile block before the no-write CLI compatibility preflight succeeds.
- DO NOT point two launchers at the same data home unless the user explicitly asks for shared state.
- DO NOT overwrite or reuse the default `~/.kimi-code` home for a generated launcher.
- DO NOT omit the default `--auto` mode unless the user's initial launcher request explicitly opts out; select no-auto behavior with the generator's `--no-auto` option.
- DO NOT add launcher-specific runtime flags that collide with `kimi`'s own CLI flags.
