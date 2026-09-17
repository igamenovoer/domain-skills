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

Use this reference only for a `claude-gac` or `claude-gac-<suffix>` launcher that targets `https://gaccode.com/claudecode`. The endpoint and user-provided GAC API key are embedded directly in the generated Linux launcher or Windows PowerShell profile block. Claude Code JSON files remain unchanged.

## Workflow

1. Identify the installed Claude Code version, the host OS and shell, and whether the initial request explicitly opted out of permissive mode.
2. Resolve the optional suffix under **Launcher Name and Suffix Contract**.
3. Re-check Claude Code's current environment-variable and permission-flag behavior plus GAC's current endpoint and model-discovery behavior. Treat the contract below as authoritative for this skill, but adapt version-sensitive syntax when current evidence requires it.
4. Obtain the GAC API key under **Required Input**; stop instead of generating a placeholder or partial launcher when the key is unavailable.
5. Implement every invariant in **GAC Launcher Contract** using an OS-native launcher. The bundled scripts under **Reference Implementations** are worked examples, not mandatory entrypoints.
6. Run **Verification** against the resulting launcher, including environment scoping, argument forwarding, model discovery, permission mode, and exit-code preservation.
7. Report the launcher location, implementation choices, and validation results without printing the key.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's GAC-only contract, platform lanes, reference implementations, and user constraints, then execute the plan without loading or imitating sibling-provider configuration.

## Launcher Name and Suffix Contract

Use `claude-gac` when no suffix is provided. When the user provides a suffix such as `work`, use `claude-gac-work`. Accept lowercase letters, digits, and internal hyphens; omit the separator when the suffix is absent.

The suffix is only a user-friendly launcher and managed-block label. It does not select a GAC account, endpoint, model, routing mode, price tier, permission mode, or credential behavior. Do not ask for a suffix when the user does not provide one.

## GAC Launcher Contract

Every generated launcher must satisfy all of these invariants:

| Concern | Required GAC Behavior |
| --- | --- |
| Endpoint | Embed the literal `https://gaccode.com/claudecode` directly in the launcher. |
| Credential | Embed the provided GAC API key directly in the launcher or managed PowerShell profile block. |
| Suffix | Use it only in the resolved launcher name, path, and managed-block marker. Do not derive runtime behavior from it. |
| Auth lane | Set `ANTHROPIC_API_KEY`; clear `ANTHROPIC_AUTH_TOKEN` and `CLAUDE_CODE_OAUTH_TOKEN` only for the launched process. |
| Model discovery | Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` unconditionally. |
| Arguments | Forward every Claude Code argument unchanged. |
| Permissions | Inject `--dangerously-skip-permissions` by default. Omit it only when the user's initial request explicitly asks for permission prompts. |
| Side files | Do not create or read a key file, token file, endpoint file, or `GAC_BASE_URL`. |
| Claude configuration | Do not modify `settings.json`, `config.json`, `.claude.json`, or model mappings. |

The endpoint, authentication, discovery, and side-file rules are provider-specific. The permissive launcher default comes from the shared custom-launcher policy in `SKILL-MAIN.md`; it is not copied from another provider's credential or model configuration.

## Platform Lanes

| Lane | Native Shape | Reference Example |
| --- | --- | --- |
| Linux | An executable launcher exports the GAC variables in its child process and replaces itself with Claude Code. | `scripts/create-claude-gac-launcher.sh` |
| Windows | A PowerShell function saves the caller's variables, applies the GAC variables while Claude runs, restores them in `finally`, and preserves `$LASTEXITCODE`. | `scripts/create-claude-gac-launcher.ps1` |

Use the host's native lane. Do not install a compatibility shell solely for this launcher.

## Required Input

The user must provide a GAC API key issued by `gaccode.com`. A compliant implementation may read an existing process-scoped `GAC_API_KEY` or prompt securely when interactive. If neither is available, it must fail without writing a launcher. The reference generators implement that behavior.

The generated launcher contains the key in plaintext. Tell the user this before generation when they have not already requested embedded credentials. Never print the key, include it in verification output, commit the generated launcher, or reuse it outside the user's requested host.

## Defaults

Linux:

- Launcher path: `$HOME/.local/bin/<launcher-name>`, where the name is `claude-gac` or `claude-gac-<suffix>`.
- Launcher mode: `700` because it contains the API key.

Windows:

- PowerShell profile: `$PROFILE.CurrentUserCurrentHost`, normally `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` under PowerShell 7.
- Managed block: the generator owns only the text delimited by `# >>> <launcher-name> launcher >>>` and `# <<< <launcher-name> launcher <<<`.
- The current-user profile contains the API key in plaintext after generation.

## Reference Implementations

Resolve `<coding-agent-subskill-dir>` to the `subskills/coding-agent/` directory whose `references/` folder contains this page.

The scripts below demonstrate the contract for the currently recorded Claude Code and GAC behavior. Inspect them before use. Run them unchanged only when the installed CLI and OS match their assumptions; otherwise adapt their environment setup, executable discovery, and invocation syntax while preserving the contract and verification requirements.

### Linux

```bash
bash <coding-agent-subskill-dir>/scripts/create-claude-gac-launcher.sh
```

This example prompts for the key when `GAC_API_KEY` is unset, embeds it, writes the launcher with mode `700`, and prints no credential value. An equivalent hand-written launcher is valid when it satisfies the same invariants. Add `$HOME/.local/bin` to the authoritative startup file only when it is not already on PATH.

For a suffixed variant, pass the neutral label at generation time:

```bash
bash <coding-agent-subskill-dir>/scripts/create-claude-gac-launcher.sh --suffix work
```

If the user's initial request explicitly asks to keep Claude Code permission prompts, generate the opt-out form:

```bash
bash <coding-agent-subskill-dir>/scripts/create-claude-gac-launcher.sh --require-permission-prompts
```

### Windows

```powershell
& '<coding-agent-subskill-dir>\scripts\create-claude-gac-launcher.ps1'
. $PROFILE
Get-Command claude-gac -CommandType Function
```

This example prompts securely when `GAC_API_KEY` is unset, embeds the key in its managed profile block, and preserves every unrelated profile line. An equivalent PowerShell function or script is valid when it applies and restores the same process environment and exit code.

For a suffixed variant, use `-Suffix work` and verify `Get-Command claude-gac-work -CommandType Function`.

If the user's initial request explicitly asks to keep Claude Code permission prompts, generate the opt-out form:

```powershell
& '<coding-agent-subskill-dir>\scripts\create-claude-gac-launcher.ps1' -RequirePermissionPrompts
```

### Unattended Setup

When unattended setup is explicitly requested, set `GAC_API_KEY` only in the generator process and clear it immediately afterward. Do not put the key in a command-line argument or log.

## Runtime Argument Contract

`<launcher-name>` runtime arguments are Claude Code arguments. Both lanes prepend `--dangerously-skip-permissions` by default, inject no model or updater defaults, and then pass every user-supplied argument through unchanged. The generation-time suffix selects only the command name; the permission-prompting option omits only the permissive flag.

The Linux launcher is a separate process, so its exported variables disappear when Claude exits. The Windows function saves the caller's values for the five variables it changes, applies the GAC contract only while Claude runs, and restores every prior value in a `finally` block. It preserves Claude's native exit code in `$LASTEXITCODE`.

## Verification

### Linux

```bash
bash -n <coding-agent-subskill-dir>/scripts/create-claude-gac-launcher.sh
bash -n "$HOME/.local/bin/<launcher-name>"
test "$(stat -c '%a' "$HOME/.local/bin/<launcher-name>")" = 700
grep -q '^export ANTHROPIC_BASE_URL=https://gaccode.com/claudecode$' "$HOME/.local/bin/<launcher-name>"
grep -q '^export ANTHROPIC_API_KEY=' "$HOME/.local/bin/<launcher-name>"
grep -q "^export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY='1'$" "$HOME/.local/bin/<launcher-name>"
grep -q -- '--dangerously-skip-permissions' "$HOME/.local/bin/<launcher-name>"
! grep -Eq 'gac-api-key|claude-gac-token|GAC_BASE_URL|claude-gac-base-url' "$HOME/.local/bin/<launcher-name>"
<launcher-name> --version
```

Use only boolean or redacted checks for the embedded API-key assignment. Do not display the matching line.

### Windows

```powershell
$profileText = Get-Content -Raw -LiteralPath $PROFILE
([regex]::Matches($profileText, '(?m)^# >>> <launcher-name> launcher >>>\r?$')).Count
$profileText -match "`$env:ANTHROPIC_BASE_URL = 'https://gaccode.com/claudecode'"
$profileText -match "`$env:ANTHROPIC_API_KEY = '[^']+'"
$profileText -match "`$env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = '1'"
$profileText -match '--dangerously-skip-permissions'
$profileText -notmatch 'gac-api-key|claude-gac-token|GAC_BASE_URL|claude-gac-base-url'
. $PROFILE
<launcher-name> --version
```

The managed-block count must be `1`, and every following expression must return `True` for the default permissive launcher. For an explicit permission-prompting opt-out, the permission-flag check must instead confirm absence. Do not print the profile block because it contains the key.

### Gateway Models

Start a fresh `<launcher-name>` session and inspect `/status` and `/model`. The base URL must be `https://gaccode.com/claudecode`, and gateway-discovered rows should include `claude-fable-5` when the provided key's plan exposes it.

If Fable 5 is absent, test the gateway's `/v1/models` endpoint with an `x-api-key` header without printing the embedded key. If the endpoint advertises `claude-fable-5`, verify the discovery variable and restart Claude Code. If the endpoint omits it, the key or plan lacks server-side access.

## Troubleshooting

- If a launcher refers to `ANTHROPIC_AUTH_TOKEN`, a token file, an endpoint file, or `GAC_BASE_URL`, it violates the GAC contract; repair or regenerate it from the principles above.
- If a default launcher lacks `--dangerously-skip-permissions`, regenerate it. Keep the flag absent only when the initial launcher request explicitly opted into permission prompts.
- If Linux cannot find `<launcher-name>`, confirm the generated file is executable and `$HOME/.local/bin` is on PATH.
- If Windows cannot find `<launcher-name>`, reload the exact profile modified by the generator and compare `$PROFILE.CurrentUserCurrentHost` with the reported path.
- If generation fails without writing a launcher, supply the GAC key interactively or through a process-scoped `GAC_API_KEY`.

## Guardrails

- DO NOT load, copy, or generalize from the Kimi or OpenLux launcher references while handling `claude-gac`.
- DO NOT externalize the GAC endpoint or API key into side files or runtime configuration variables.
- DO NOT use `ANTHROPIC_AUTH_TOKEN` for GAC.
- DO NOT omit `--dangerously-skip-permissions` from the default launcher; omit it only for an explicit permission-prompting request made at the beginning.
- DO NOT inject updater policy, model remapping, or another provider's credential defaults.
- DO NOT print, commit, or expose the embedded API key during generation or verification.
- DO NOT modify Claude Code JSON settings.
- DO NOT assign endpoint, account, model, routing, pricing, credential, or permission semantics to the optional suffix.
