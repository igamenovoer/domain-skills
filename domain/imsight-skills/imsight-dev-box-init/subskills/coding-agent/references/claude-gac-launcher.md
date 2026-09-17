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

# Claude-GAC Launcher Setup

Use this reference when the user wants a `claude-gac` launcher on Linux or Windows that runs Claude Code against the GAC Anthropic-compatible endpoint without changing Claude Code's `settings.json`, `config.json`, or `.claude.json` files.

## Workflow

1. Select the Linux or Windows lane from **Platform Lanes**.
2. Resolve API-key handling under **Required Input** without printing or hard-coding the key.
3. Confirm the lane's launcher and key-file paths under **Defaults**.
4. Run the matching generator under **Generate The Launcher**.
5. Make the launcher available in a fresh shell by updating PATH on Linux or reloading the PowerShell profile on Windows.
6. Run every applicable check in **Verification**, including gateway model discovery.
7. Report the launcher path, key-file path, Claude Code version, and visible gateway models without exposing the key.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's platform lanes, inputs, defaults, launcher contract, verification rules, and user constraints, then execute the plan without exposing credentials or changing Claude Code JSON settings.

## Platform Lanes

| Lane | Use When | Generator |
| --- | --- | --- |
| Linux | The host runs Bash or another shell that can invoke a Bash launcher. | `scripts/create-claude-gac-launcher.sh` |
| Windows | The host runs PowerShell and the launcher should be a function in the current-user profile. | `scripts/create-claude-gac-launcher.ps1` |

Use the host's native lane. Do not install PowerShell on Linux or a Unix compatibility layer on Windows solely for this launcher.

## Required Input

The launcher needs a GAC API key issued by `gaccode.com`. Do not place the key in a command line, chat response, committed file, test fixture, generated launcher, or PowerShell profile. Let `claude-gac` prompt on first use, or seed `GAC_API_KEY` only in the process that runs the generator when unattended setup is explicitly required.

Both lanes read the key from a user-local key file at runtime. If the user explicitly requires an embedded key, explain that the launcher or profile will contain plaintext credentials and obtain that specific instruction before deviating from the maintained generators.

## Defaults

Shared behavior:

- Launcher name: `claude-gac`.
- Base URL: `https://gaccode.com/claudecode`.
- Auth: `ANTHROPIC_API_KEY`.
- Gateway discovery: `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1`. Claude Code otherwise shows only its built-in picker rows even when GAC's `/v1/models` endpoint advertises models such as `claude-fable-5`.
- Claude JSON files: unchanged.
- Runtime arguments and permissions: unchanged. The launcher injects no model or permission flags.

Linux defaults:

- Launcher path: `$HOME/.local/bin/claude-gac`.
- Key file: `$HOME/.local/bin/gac-api-key`.
- File modes: launcher `700`, key file `600`.

Windows defaults:

- PowerShell profile: `$PROFILE.CurrentUserCurrentHost`, normally `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` under PowerShell 7.
- Key file: `%LOCALAPPDATA%\Programs\gac-launcher\gac-api-key`.
- Managed block: the generator owns only the text delimited by `# >>> claude-gac launcher >>>` and `# <<< claude-gac launcher <<<`.

## Generate The Launcher

Resolve `<coding-agent-subskill-dir>` to the `subskills/coding-agent/` directory whose `references/` folder contains this page.

### Linux

Run the Bash generator:

```bash
bash <coding-agent-subskill-dir>/scripts/create-claude-gac-launcher.sh
```

If `$HOME/.local/bin` is not on PATH, add it through the user's active shell startup file, then open a fresh shell. Do not edit an unrelated startup file merely because it exists.

```bash
export PATH="$HOME/.local/bin:$PATH"
command -v claude-gac
```

The exported PATH above affects only the current shell; persist the same entry in `.bashrc`, `.zshrc`, or another startup file only when that file is authoritative for the user's shell.

### Windows

Run the PowerShell generator:

```powershell
& '<coding-agent-subskill-dir>\scripts\create-claude-gac-launcher.ps1'
. $PROFILE
Get-Command claude-gac -CommandType Function
```

The generator creates or replaces its managed profile block and preserves every unrelated profile line.

### Unattended Setup

Prefer the first-run secure prompt. When unattended setup is explicitly requested, provide `GAC_API_KEY` only to the generator process and clear it immediately afterward. Never show the value in logs or command output.

## Runtime Argument Contract

`claude-gac` runtime arguments are Claude Code arguments. Both lanes pass every argument through unchanged and inject no `--model` or `--dangerously-skip-permissions` default. They must not consume, rename, reorder, or reinterpret Claude CLI arguments.

The Linux launcher is a separate process: it exports the GAC variables and then replaces itself with Claude via `exec`, so the caller's environment is unchanged. The Windows function saves the caller's process-level values for `ANTHROPIC_BASE_URL`, `ANTHROPIC_API_KEY`, and `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY`, sets the GAC values only while Claude runs, and restores the previous environment in a `finally` block. It also preserves Claude's native exit code in `$LASTEXITCODE`.

## Verification

### Linux

```bash
bash -n <coding-agent-subskill-dir>/scripts/create-claude-gac-launcher.sh
bash -n "$HOME/.local/bin/claude-gac"
command -v claude-gac
claude-gac --version
grep -q 'sk-ant-' "$HOME/.local/bin/claude-gac" && echo 'unexpected embedded key' >&2
```

Confirm the launcher and key file have restrictive modes with `stat`, and confirm the three GAC variables exist in the launched process but not in the caller after it exits.

### Windows

```powershell
$profileText = Get-Content -Raw -LiteralPath $PROFILE
([regex]::Matches($profileText, '(?m)^# >>> claude-gac launcher >>>\r?$')).Count
Select-String -LiteralPath $PROFILE -Pattern 'ANTHROPIC_BASE_URL|GATEWAY_MODEL_DISCOVERY|gac-api-key'
Select-String -LiteralPath $PROFILE -Pattern 'sk-ant-' -Quiet  # must return False
. $PROFILE
claude-gac --version
```

The managed-block count must be `1`. Validate environment scoping with a temporary mock `claude` function in a disposable PowerShell process; do not replace the user's real command persistently.

### Gateway Models

Probe `https://gaccode.com/claudecode/v1/models` with the key file and an `x-api-key` header, but never print the key. The endpoint should return `200` and at least one `claude-*` model. When the key's plan includes Fable 5, the response includes `claude-fable-5`.

Start a fresh `claude-gac` session and check `/model`. Gateway rows are loaded at startup, so an already-running session does not pick up a newly enabled discovery variable.

## Troubleshooting

- If Linux cannot find `claude-gac`, confirm the generated file is executable and its directory is on PATH in the active shell.
- If Windows cannot find `claude-gac`, reload the exact profile modified by the generator and compare `$PROFILE.CurrentUserCurrentHost` with the reported path.
- If `/model` omits Fable 5 but the endpoint advertises `claude-fable-5`, confirm `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` inside the launcher process and start a new Claude Code session.
- If the endpoint omits Fable 5, the key or GAC plan does not currently expose it; changing local Claude JSON settings will not add server-side access.
- If the launcher reports a missing or empty key, remove the empty key file and invoke `claude-gac` again to receive the secure prompt.
- If a pre-existing unmanaged Windows `claude-gac` function blocks generation, inspect it manually and migrate it into the managed block instead of overwriting unrelated profile content.

## Guardrails

- DO NOT print, commit, echo, or include the GAC API key in a generated launcher, PowerShell profile, or verification output.
- DO NOT modify Claude Code JSON settings to configure the GAC endpoint or model picker.
- DO NOT replace unrelated shell startup or PowerShell profile content while making the launcher discoverable.
- DO NOT let GAC environment variables leak back into the caller after Claude Code exits or fails.
- DO NOT describe `gaccode.com` as Anthropic's official API endpoint.
