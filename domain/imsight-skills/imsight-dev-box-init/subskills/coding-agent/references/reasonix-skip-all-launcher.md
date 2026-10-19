---
metadata:
  skill_invocation_notation: >
    Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
    SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
    accepted only as legacy input when SKILL-MAIN.md is absent.
    Skill and subskill entrypoints use bare object paths: `X` invokes skill X and
    `X->Y->Z` invokes subskill Z. Subcommands use parenthesized components:
    `X->cmd()` invokes a direct subcommand, `X->Y->cmd()` invokes a subcommand of
    subskill Y, and `X->parent()->child()` invokes child subcommand child exposed
    by parent subcommand parent. Intermediate subcommands act as object generators.
    Forms such as `X()` and `X->Y()` are invalid for skill or subskill entrypoints.
---

# Reasonix Skip-All Launcher Setup

Use this reference to create or repair `reasonix-skip-all`, a launcher around an already configured Reasonix installation. It defaults sessions to YOLO and inherits the caller's stderr. It reuses the existing provider, credentials, model selection, and Reasonix home.

## Workflow

1. Inspect the host shell, installed Reasonix version/help, existing launcher, and current provider configuration without displaying credentials.
2. Resolve the launcher name under **Name and Installation**.
3. Apply the parent subskill's **Custom Launcher Compatibility Policy** with the actual Reasonix client and temporary state before installing or replacing persistent setup.
4. Implement **Runtime Contract** using the native host shell; adapt **Reference Unix Implementation** only after checking the installed CLI's supported flags.
5. Install the launcher in the user-local executable directory and complete the CLI's one-time YOLO acknowledgement within the authorized setup.
6. Run **Verification**, including the active permission mode, slash menus, argument forwarding, and exit status.
7. Report the launcher path, permission mode, and version-specific findings without displaying credentials.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's runtime contract, compatibility requirements, and user constraints, then execute the plan.

## Name and Installation

Use `reasonix-skip-all` when no suffix is requested. Apply the parent naming policy to an explicit suffix, producing `reasonix-skip-all-<suffix>` without assigning any provider or permission meaning to the suffix. On Unix, use `$HOME/.local/bin/<launcher-name>` with mode `700` and verify it is available on PATH in a fresh shell.

Locate the installed `reasonix` with the native command lookup; do not hardcode a historical Bun, npm, or binary path. Keep plain `reasonix` unchanged. This wrapper does not install Reasonix or configure a provider: if those prerequisites are missing, resolve them under a separately authorized setup rather than embedding credentials in the launcher.

## Runtime Contract

- Default interactive sessions, explicit `tui`, and `run` to the installed CLI's YOLO mode. In verified v2.43.0, `--yolo` is an alias for `--permission-mode bypassPermissions`.
- Reasonix YOLO skips approval prompts; the sandbox, network policy, and deny rules still apply. The name's similarity to `codex-skip-all` does not mean their sandbox behavior is identical.
- Preserve caller arguments, including quoting, model choices, reasoning effort, continuation, and explicit permission opt-outs. Do not inject a session-only flag into utility commands such as `version`, `doctor`, or `config`.
- Keep help/version invocations usable. The reference distinguishes them because Reasonix v2.43.0 does not treat every session flag as a global flag accepted by all commands.
- Reuse the current Reasonix provider and home. A DeepSeek-configured installation continues using its configured Flash/Pro models; this wrapper does not change endpoints, keys, model aliases, or effort mappings.
- Preserve stdin, stdout, stderr, and the child exit code. Use `exec` on Unix; on Windows, use native PowerShell argument arrays and propagate the native process exit code.
- Inherit the caller's stderr normally. Do not add `2>/dev/null`, `2>$null`, `tee`, or a log pipeline; the v2.43.0 skill-discovery warning that once justified discarding stderr is fixed in current builds.
- Complete only the expected one-time YOLO acknowledgement when the setup request already authorizes that mode. Do not feed an unbounded stream of `yes` responses or manufacture acknowledgement files. Do not add a recurring confirmation prompt to the wrapper.

## Reference Unix Implementation

Use this Bash implementation after compatibility verification. It contains no credentials and matches the verified launcher behavior. For a suffixed name, update the executable filename and the missing-binary error prefix.

```bash
#!/usr/bin/env bash
set -euo pipefail

reasonix_bin="$(command -v reasonix || true)"
if [[ -z "$reasonix_bin" ]]; then
  echo "reasonix-skip-all: reasonix binary not found" >&2
  exit 127
fi

# YOLO applies to sessions; utility commands keep their own argument syntax.
case "${1:-}" in
  --version|-v|version|--help|-h|help) ;;
  tui|run)
    subcommand="$1"
    shift
    set -- "$subcommand" --yolo "$@"
    ;;
  ""|-*) set -- --yolo "$@" ;;
esac

exec "$reasonix_bin" "$@"
```

The injected `--yolo` is a default, not an extra parser for Reasonix arguments. On the verified client, a caller choosing `--permission-mode ask` must also pass `--yolo=false` to cancel the injected default; combining active `--yolo` with `--permission-mode` is rejected. If the initial setup request opts out of YOLO, omit the injection instead of installing a conflicting combination.

## Verification

For an actual installation or repair, complete the parent compatibility gate and repeat a minimal real Reasonix turn through the installed wrapper. Use the already configured provider; do not replace that check with a direct provider HTTP call. Documentation-only maintenance can reuse the identified terminal evidence below and validate the examples without reinstalling or altering the user's launcher.

On Unix, verify syntax, executable permission, version reporting, and command lookup in a fresh shell. Adapt the name for a suffix:

```bash
bash -n "$HOME/.local/bin/reasonix-skip-all"
test -x "$HOME/.local/bin/reasonix-skip-all"
reasonix-skip-all --version
bash -lc 'command -v reasonix-skip-all'
```

Start a dedicated temporary tmux session or native terminal. Confirm the status shows `YOLO` and the expected configured model. Open `/`, `/model`, and `/help` without submitting a task; the launcher inherits stderr, and current Reasonix builds render these menus cleanly without warning text overwriting the interface. Close only the test session afterward.

Use a disposable fake `reasonix` executable earlier on PATH to verify argument boundaries and exit-code preservation independently of inference. Have it emit one diagnostic to stderr and return a known nonzero status; the launcher must pass that diagnostic through to the caller's stderr. Verify no-argument startup, a quoted argument, explicit `run` and `tui`, help/version, a utility command, and an explicit permission override. The launcher must not create a stderr log.

The recorded v2.43.0 evidence includes actual tmux startup in YOLO, version reporting, and an explicit `--yolo=false --permission-mode ask` launch showing `Ask`; the stub cases covered argument forwarding, stderr handling, and exit status without creating logs. This does not by itself establish provider inference success. Record those conclusions separately and do not extend a terminal-only pass to an untested provider turn.

## Authoritative Sources

- [Reasonix v2.43.0 TUI flags](https://github.com/esengine/DeepSeek-Reasonix/blob/v2.43.0/internal/frontend/cli/tui_flags.go) — YOLO aliases and permission flag interaction.
- [Reasonix v2.43.0 initial permission mode](https://github.com/esengine/DeepSeek-Reasonix/blob/v2.43.0/internal/frontend/cli/tui_posture.go) — one-time acknowledgement and remaining policy enforcement.

## Guardrails

- DO NOT discard, redirect, or log the Reasonix child process's stderr; the launcher inherits the caller's stderr stream.
- DO NOT claim Reasonix YOLO disables its sandbox, network policy, or deny rules.
- DO NOT inject session-only flags into utility commands or alter caller argument boundaries.
- DO NOT report menu verification as proof of a successful provider turn.
