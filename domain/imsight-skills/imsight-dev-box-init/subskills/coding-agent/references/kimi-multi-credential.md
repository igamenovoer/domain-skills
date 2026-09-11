# Kimi Multi-Credential Launcher Setup

Use this reference when the user wants one or more Kimi Code CLI launchers named `kimi-<suffix>`, each with an isolated data home under `~/kimi-homes/`, so multiple Kimi OAuth credentials or configurations can coexist on one host without touching the default `~/.kimi-code`.

## Workflow

1. Resolve the launcher name and data home under **Required Input**.
2. Check the installed `kimi` binary under **Prerequisite: Kimi Code CLI**.
3. Generate the launcher with the bundled script under **Create The Launcher**, applying **Defaults** for any value the user did not specify and disabling auto mode only when the user explicitly requests it.
4. Put the launcher directory on PATH for new shells under **Ensure Launcher Directory On PATH**; skipping this leaves `kimi-<suffix>` unresolvable in fresh terminals.
5. Trigger the OAuth device-code login under **OAuth Login** when the user wants the new credential authorized now.
6. Run every applicable check in **Verification**.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's inputs, defaults, launcher contract, verification rules, and user constraints, then execute the plan without exposing credentials.

## Required Input

- Launcher name: `kimi-<suffix>`, where `<suffix>` is lowercase letters, digits, or hyphens and identifies the credential slot (for example a port-like tag such as `3180`). Ask the user when no suffix is given.
- Data home: the directory the launcher's `KIMI_CODE_HOME` points to. The user may specify it explicitly; otherwise apply **Defaults**.
- Startup mode: auto mode unless the user explicitly asks for no-auto mode.

```text
Please provide the launcher suffix (kimi-<suffix>) and, optionally, a custom data home directory.
```

## Prerequisite: Kimi Code CLI

The launcher wraps an installed `kimi` binary; it does not install Kimi Code. Confirm one exists before generating:

```bash
command -v kimi || ls "$HOME/.kimi-code/bin/kimi"
```

At runtime the generated launcher resolves the binary in this order: the `--kimi-bin` path when pinned at generation time, `$HOME/.kimi-code/bin/kimi`, `$HOME/.local/bin/kimi`, then `command -v kimi`. If no binary is available, install Kimi Code CLI first.

## Defaults

- Launcher path: `$HOME/.local/bin/kimi-<suffix>`
- Data home: `$HOME/kimi-homes/kimi-<suffix>` — the home directory name matches the launcher name, so each launcher owns exactly one isolated home
- Runtime home override: `KIMI_HOME_OVERRIDE` environment variable, honored by the generated launcher ahead of its baked-in default
- Startup arguments: `--auto` is prepended by default so Kimi starts in Never Ask mode
- Auth: Kimi Code OAuth via the device-code flow (`kimi login`); the credential lands in the isolated home, not in `~/.kimi-code`

`KIMI_CODE_HOME` relocates the config file, sessions, logs, and OAuth credentials. Multiple `kimi` instances sharing one home share config and credentials, so give each launcher its own home unless the user explicitly wants shared state. See the official environment-variable docs: `https://www.kimi.com/code/docs/en/kimi-code-cli/configuration/env-vars.html`.

## Create The Launcher

Use the bundled script from this subskill. Resolve `<coding-agent-subskill-dir>` to the `subskills/coding-agent/` directory whose `references/` folder contains this page.

```bash
<coding-agent-subskill-dir>/scripts/create-kimi-credential-launcher.sh --name kimi-<suffix>
```

With a user-specified home or output directory:

```bash
<coding-agent-subskill-dir>/scripts/create-kimi-credential-launcher.sh \
  --name kimi-<suffix> --home /path/to/custom/home --output "$HOME/.local/bin"
```

The script also accepts `--kimi-bin` to pin a specific `kimi` binary. If the installed skill copy lost the script's execute bit, invoke it through the interpreter: `bash <coding-agent-subskill-dir>/scripts/create-kimi-credential-launcher.sh ...`.

When the user explicitly requests no-auto mode, generate the launcher with `--no-auto`:

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
- Keep launcher generator scripts in `<coding-agent-subskill-dir>/scripts/`; do not place generated helper scripts in `references/`.
- Launcher runtime arguments are Kimi Code CLI arguments. The generated launcher prepends its generation-time default (`--auto` or no default arguments), then passes every runtime argument through unchanged; it must not consume, rename, reorder, or reinterpret `kimi` flags.
- Existing sessions, skills, and config under `~/.kimi-code` are not copied into a new home; migrate intentionally when the user wants a slot seeded from the default home.

## Guardrails

- DO NOT print, hard-code, or commit OAuth tokens or credential file contents handled by this workflow.
- DO NOT point two launchers at the same data home unless the user explicitly asks for shared state.
- DO NOT overwrite or reuse the default `~/.kimi-code` home for a generated launcher.
- DO NOT add launcher-specific runtime flags that collide with `kimi`'s own CLI flags; select no-auto behavior with the generator's `--no-auto` option.
