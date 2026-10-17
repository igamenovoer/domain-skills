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

Use this reference to create or repair `reasonix-skip-all`, a launcher around an already configured Reasonix installation. It defaults sessions to YOLO and discards Reasonix stderr. It reuses the existing provider, credentials, model selection, and Reasonix home.

## Workflow

1. Inspect the host shell, installed Reasonix version/help, existing launcher, and current provider configuration without displaying credentials.
2. Resolve the launcher name under **Name and Installation** and apply **Stderr Policy**; discard stderr unless the user explicitly says "keep stderr".
3. Apply the parent subskill's **Custom Launcher Compatibility Policy** with the actual Reasonix client and temporary state before installing or replacing persistent setup.
4. Implement **Runtime Contract** using the native host shell; adapt **Reference Unix Implementation** only after checking the installed CLI's supported flags.
5. Install the launcher in the user-local executable directory and complete the CLI's one-time YOLO acknowledgement within the authorized setup.
6. Run **Verification**, including the active permission mode, slash menus, stderr behavior, argument forwarding, and exit status.
7. Report the launcher path, permission mode, stderr policy, and version-specific findings without displaying credentials or retaining discarded warning text.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's runtime contract, stderr policy, compatibility requirements, and user constraints, then execute the plan.

## Name and Installation

Use `reasonix-skip-all` when no suffix is requested. Apply the parent naming policy to an explicit suffix, producing `reasonix-skip-all-<suffix>` without assigning any provider or permission meaning to the suffix. On Unix, use `$HOME/.local/bin/<launcher-name>` with mode `700` and verify it is available on PATH in a fresh shell.

Locate the installed `reasonix` with the native command lookup; do not hardcode a historical Bun, npm, or binary path. Keep plain `reasonix` unchanged. This wrapper does not install Reasonix or configure a provider: if those prerequisites are missing, resolve them under a separately authorized setup rather than embedding credentials in the launcher.

## Runtime Contract

- Default interactive sessions, explicit `tui`, and `run` to the installed CLI's YOLO mode. In verified v2.43.0, `--yolo` is an alias for `--permission-mode bypassPermissions`.
- Reasonix YOLO skips approval prompts; the sandbox, network policy, and deny rules still apply. The name's similarity to `codex-skip-all` does not mean their sandbox behavior is identical.
- Preserve caller arguments, including quoting, model choices, reasoning effort, continuation, and explicit permission opt-outs. Do not inject a session-only flag into utility commands such as `version`, `doctor`, or `config`.
- Keep help/version invocations usable. The reference distinguishes them because Reasonix v2.43.0 does not treat every session flag as a global flag accepted by all commands.
- Reuse the current Reasonix provider and home. A DeepSeek-configured installation continues using its configured Flash/Pro models; this wrapper does not change endpoints, keys, model aliases, or effort mappings.
- Preserve stdin, stdout, and the child exit code. Use `exec` on Unix; on Windows, use native PowerShell argument arrays and propagate the native process exit code.
- Complete only the expected one-time YOLO acknowledgement when the setup request already authorizes that mode. Do not feed an unbounded stream of `yes` responses or manufacture acknowledgement files. Do not add a recurring confirmation prompt to the wrapper.

## Stderr Policy

The default is to discard the Reasonix child process's entire stderr stream using `2>/dev/null` on Unix or `2>$null` in PowerShell. Do not write a warning log, use `tee`, or retain copies of the discarded output. This also discards errors written to stderr; stdout and the exit code remain available.

When the user explicitly says **"keep stderr"** during launcher setup or repair, omit the stderr redirection entirely. Inherit the caller's stderr normally; do not interpret "keep" as a request to save a log. Preserve this explicit preference when repairing or regenerating the launcher. It changes only stderr handling, not the YOLO default.

"Keep stderr" is a setup preference, not a Reasonix CLI option. Do not invent or forward `--keep-stderr`. Do not ask which policy to use when the user has not requested an exception. The default remains discard even if a later Reasonix version fixes the bug below; a bug fix alone does not authorize changing the user's launcher policy.

## Verified v2.43.0 Warning and Menu Bug

Observed on 2026-10-18 with Reasonix `v2.43.0`, commit `2b3b7c4d0c828d90c7e88842d2509befb2893dab`, on Linux in tmux:

- Skill discovery descends into `~/.agents/skills/_shared/` and parses shared Markdown references, including `common.md` and `decay-risks.md`, as candidate skills. The six local reference documents lack skill descriptions, producing repeated missing-description warnings.
- The scanner skips directories such as `references` and `scripts` but does not skip `_shared`. A reference document need not be a standalone skill; adding artificial descriptions to shared files is not the launcher fix.
- Typing a slash command refreshes the completion catalogue and rescans skills. The warnings are written directly to stderr while the terminal renderer is drawing, moving the cursor and overwriting menu, input, and status text.
- This is local skill discovery and terminal output handling, not a DeepSeek authentication or model failure. The displayed command text is corrupted; the warning does not establish that command parsing itself failed.
- A temporary project override of `[skills] suppress_warnings = true` did not clear the warning in the recorded setup. Do not present that setting as a verified replacement for redirection on this build.
- Redirecting child stderr to the null device kept `/`, `/model`, and `/help` displays clean with YOLO and `deepseek-flash` active.

These observations establish the affected build only. Recheck newer versions instead of claiming the defect affects all releases. Keep the default stderr policy regardless; when "keep stderr" is requested, explain that the affected build may display the corruption again without silently overriding that choice.

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

# Discard diagnostics so they cannot overwrite the terminal interface.
exec "$reasonix_bin" "$@" 2>/dev/null
```

For an explicit "keep stderr" request, replace only the final invocation with:

```bash
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

Start a dedicated temporary tmux session or native terminal. Confirm the status shows `YOLO` and the expected configured model. Open `/`, `/model`, and `/help` without submitting a task; with default stderr handling, no warning text should overwrite the interface. Close only the test session afterward.

Use a disposable fake `reasonix` executable earlier on PATH to verify argument boundaries and exit-code preservation independently of inference. Have it emit one diagnostic to stderr and return a known nonzero status. The default template must discard that diagnostic; the "keep stderr" variant must pass it through. Verify no-argument startup, a quoted argument, explicit `run` and `tui`, help/version, a utility command, and an explicit permission override. Neither variant should create a stderr log.

The recorded v2.43.0 evidence includes actual tmux startup in YOLO with clean slash menus, version reporting, and an explicit `--yolo=false --permission-mode ask` launch showing `Ask`. Both template variants passed eight stub cases each covering argument forwarding, stderr handling, and exit status without creating logs. This does not by itself establish provider inference success or a clean menu when stderr is retained. Record those conclusions separately and do not extend a terminal-only pass to an untested provider turn.

## Authoritative Sources

- [Reasonix v2.43.0 TUI flags](https://github.com/esengine/DeepSeek-Reasonix/blob/v2.43.0/internal/frontend/cli/tui_flags.go) — YOLO aliases and permission flag interaction.
- [Reasonix v2.43.0 initial permission mode](https://github.com/esengine/DeepSeek-Reasonix/blob/v2.43.0/internal/frontend/cli/tui_posture.go) — one-time acknowledgement and remaining policy enforcement.
- [Reasonix v2.43.0 skill scanner](https://github.com/esengine/DeepSeek-Reasonix/blob/v2.43.0/internal/ext/skill/skill.go) — repeated discovery and direct stderr warnings.
- [Reasonix v2.43.0 skipped directories](https://github.com/esengine/DeepSeek-Reasonix/blob/v2.43.0/internal/ext/skill/scan_helpers.go) — directory exclusions that omit `_shared`.
- [Reasonix v2.43.0 completion catalogue](https://github.com/esengine/DeepSeek-Reasonix/blob/v2.43.0/internal/session/control/slash_catalog.go) — skill discovery for slash completion.

## Guardrails

- DO NOT keep stderr, redirect it to a log, or add a logging pipeline by default.
- DO NOT redirect stderr when the user explicitly requests "keep stderr".
- DO NOT silently restore stderr because a later release fixes the recorded bug.
- DO NOT rewrite shared skill references or Reasonix provider settings to hide the terminal warning.
- DO NOT claim Reasonix YOLO disables its sandbox, network policy, or deny rules.
- DO NOT inject session-only flags into utility commands or alter caller argument boundaries.
- DO NOT report menu verification as proof of a successful provider turn.
