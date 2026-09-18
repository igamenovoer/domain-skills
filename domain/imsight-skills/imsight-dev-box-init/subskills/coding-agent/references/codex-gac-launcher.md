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

# Codex-GAC Launcher Setup

Use this reference only for a `codex-gac` or `codex-gac-<suffix>` launcher that targets GAC's Codex endpoint while preserving plain `codex` as the official OpenAI route. Put GAC configuration in a separate profile inside the user's normal `CODEX_HOME`, embed the user-provided GAC API key in the local launcher, and leave the base config and cached official authentication unchanged.

Terminal invocation of `imsight-dev-box-init->coding-agent->codex-gac-launcher()` follows this page.

## Workflow

1. Inspect the installed Codex version and help, the host OS and shell, GAC's current Codex endpoint guidance, and whether the initial request explicitly opted out of permissive mode. These are read-only checks.
2. Obtain the GAC API key under **Required Input**; stop without changing any file when the key is unavailable.
3. Resolve the current endpoint, authentication lane, and a model candidate from the user's request plus current Codex and GAC documentation. Do not call GAC APIs directly as a preflight.
4. Resolve the optional suffix and launcher/profile names, then complete **Phase A: Shared-Home Codex Test** using a uniquely named temporary profile in the normal Codex home when the installed CLI requires a file. Let Codex itself validate the request path and coexistence with cached OAuth state.
5. Only after the target-CLI test succeeds, select the installed Codex version's profile layout and implement every invariant in **Codex-GAC Contract** as **Phase B: Persistent Setup**. Treat **Reference Implementations** as worked examples rather than mandatory machinery.
6. Run **Verification**, including profile loading, background model-catalog behavior, scoped environment restoration, argument forwarding, permission mode, GAC completion, and the unchanged plain Codex route.
7. Report the profile and launcher locations, Codex version, client-verified model, permission mode, validation results, and whether the normal shared home was retained without printing the key.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's GAC-only contract, version evidence, platform examples, and user constraints, then execute the plan without changing the base Codex configuration or borrowing another provider's authentication conventions.

## Launcher Name and Suffix Contract

Use `codex-gac` when the user provides no suffix, with profile `gac`. When the user provides a suffix such as `work`, use `codex-gac-work` and profile `gac-work`. Store either profile beside the user's normal Codex config as `$CODEX_HOME/<profile-name>.config.toml`. Accept lowercase letters, digits, and internal hyphens. Omit the separator when the suffix is absent.

The suffix is a user-facing label only. It does not select a GAC account, endpoint, model, routing mode, price tier, permission mode, or API-key behavior. Use it only to keep the launcher, managed block, and provider profile file distinct. In particular, a launcher such as `codex-gac-auto` must not inject an `auto` model or routing option.

## Codex-GAC Contract

Every generated setup must satisfy these invariants:

| Concern | Required behavior |
| --- | --- |
| Ordinary Codex | Leave plain `codex` on its existing official OpenAI provider, base config, authentication, and normal `CODEX_HOME`. |
| Provider profile | Put GAC settings only in `$CODEX_HOME/<profile-name>.config.toml`; do not select GAC in the base `config.toml`. |
| OAuth coexistence | Do not modify, remove, copy, or suppress `auth.json` or the configured credential store. Use `env_key` with `requires_openai_auth = false` so the selected custom profile uses the scoped GAC key while plain `codex` keeps OAuth. |
| Endpoint | Put the literal GAC Codex base URL `https://gaccode.com/codex/v1` in the provider profile. |
| Protocol | Use the Responses wire API unless current GAC and Codex evidence establishes a replacement. |
| Authentication | Configure the provider to read `GAC_API_KEY` and not require OpenAI authentication. |
| Credential placement | Embed the user-provided GAC key directly in the local launcher or managed PowerShell profile block; never put it in the tracked skill or Codex TOML. |
| Credential integrity | Require the actual launcher value to be non-empty visible ASCII on one physical line. Reject whitespace or control characters instead of trimming them, and validate without printing the key. |
| Suffix | Use it only as the optional launcher/profile namespace defined above. Do not derive runtime behavior from its text. |
| Environment scope | Expose `GAC_API_KEY` only to the launched Codex process. Do not set `CODEX_HOME` in the normal launcher. A PowerShell function must restore the caller's key variable. |
| Model | Pin `<verified-gac-model>`, selected from the user's request, current documentation, or Codex's own discovery surface and confirmed by a shared-home Codex turn. Never seed selection from this guide's historical notes. |
| Arguments | Forward every caller argument to Codex unchanged after the fixed profile and permission defaults. |
| Permissions | Inject Codex's strongest approval-free, sandbox-bypass mode by default. Omit it only when the user's initial request explicitly asks to retain approvals or sandboxing. |
| Exit status | Preserve Codex's exit status. |

The provider-specific endpoint and authentication lane come from GAC. The permissive launcher default comes from this subskill's shared policy and does not authorize unrelated setup work.

## Required Input

The setup requires a GAC API key from the GAC site's API-key field. Keep it in memory while generating the launcher and represent it as `<GAC_API_KEY>` in documentation, diffs, logs, and examples. Before testing or writing it, require every character to be visible ASCII (`33..126`) and reject empty, multiline, whitespace-padded, or control-character-bearing input instead of trimming it.

Do not commit the generated launcher. It contains a live credential by design. Restrict a Unix launcher to mode `0700`; on Windows, write only to the user's own PowerShell profile and avoid displaying the managed block after inserting the key.

The suffix is optional. Do not ask for one when the user requests `codex-gac` or gives no reason to distinguish variants.

## Version and Profile Compatibility

This procedure was verified on 2026-09-17 with `codex-cli 0.154.0`. Before reusing it, inspect the installed CLI:

```text
codex --version
codex --help
```

On Codex CLI 0.154.0, `--profile <profile-name>` loads `$CODEX_HOME/<profile-name>.config.toml`. For this launcher, the unsuffixed default is `--profile gac` with `$CODEX_HOME/gac.config.toml`; a `work` suffix uses `--profile gac-work` with `$CODEX_HOME/gac-work.config.toml`. The same version rejects legacy `[profiles.<name>]` content in `config.toml` and instructs the user to move it to the separate profile file.

Treat the installed CLI's help and behavior as authoritative when another version differs. The official Codex configuration reference documents profile files at `$CODEX_HOME/profile-name.config.toml`: `https://developers.openai.com/codex/config-reference/`. GAC's vendor page is provider evidence and an implementation example, not authority for Codex profile syntax: `https://www.yuque.com/beihu-iq2oo/zlyf06/wtqgna1pvscqxbe4`.

Do not silently migrate or delete legacy profile tables. If the existing setup uses a different profile format, show the conflict and adapt only after preserving unrelated configuration.

## Compatibility Gate

The gate has two ordered phases. Do not use standalone `/models` or `/responses` calls as an earlier gate; the installed Codex client's actual end-to-end request is the compatibility authority because its protocol, discovery, authentication, and request shape can change between versions.

### Phase A: Shared-Home Codex Test

1. Inspect `codex --version`, current help, and the current profile/provider documentation without changing persistent state.
2. Choose a candidate from the user's explicit request, current GAC guidance, or Codex's own model/status surface. When no documented provider default exists and several materially different candidates remain, ask the user instead of guessing from model names.
3. Resolve the user's normal `CODEX_HOME` without changing it. Write a uniquely named temporary provider profile beside the normal config, or use current CLI-only overrides when they can express the full provider shape. Never overwrite an existing profile or modify `config.toml` or `auth.json`; keep the key process-scoped.
4. Run one minimal `codex --profile <profile-name> exec --skip-git-repo-check ...` turn. If the user requested a model, pass that exact id through Codex and require the real turn to succeed; otherwise use the documented/default candidate and record the model Codex reports.
5. Inspect combined client output in memory. A catalog-schema warning may be reported separately, but an authentication `401` or `403` from any client request fails the gate.
6. Remove the temporary profile afterward and confirm the base config and OAuth credential store are unchanged. If the Codex turn or background authentication fails, stop without modifying the persistent profile or shell profile; do not substitute a handcrafted API probe.

Set `<verified-gac-model>` to the exact id proven by that shared-home Codex turn. Temporary configuration is allowed only to exercise the target CLI safely; it must not become the persistent profile until the complete turn succeeds.

### Phase B: Persistent Setup

Only after the shared-home Codex turn succeeds may the workflow write the persistent profile and credential-bearing launcher below.

## Provider Profile

Resolve `<codex-home>` to the user's normal active `CODEX_HOME` (normally `$HOME/.codex`) and `<profile-name>` to `gac` or `gac-<suffix>`. Preserve the base config and authentication state, then create `<codex-home>/<profile-name>.config.toml` with mode `0600` on Unix. Refuse to overwrite an unrelated existing profile:

```toml
model_provider = "gac"
model = "<verified-gac-model>"
model_reasoning_effort = "high"
disable_response_storage = true

[model_providers.gac]
name = "GAC"
base_url = "https://gaccode.com/codex/v1"
wire_api = "responses"
env_key = "GAC_API_KEY"
requires_openai_auth = false
```

The placeholder must be replaced with the exact model verified by the target Codex client during the current shared-home Compatibility Gate; a profile that still contains it is incomplete and must not be installed. Keep the model explicit when the installed client requires it because a provider catalog can remain incompatible with Codex's own model-catalog decoder.

The profile contains no credential. Its purpose is provider selection, endpoint, wire protocol, authentication variable name, and model defaults. The launcher supplies the secret and activates the profile.

## Platform Lanes

| Host | Launcher | Secret scope | Profile |
| --- | --- | --- | --- |
| Linux or macOS | Executable `~/.local/bin/<launcher-name>` Bash script | Exported only in the launcher process | `$CODEX_HOME/<profile-name>.config.toml` (normally `$HOME/.codex/...`) |
| Windows PowerShell | Managed `<launcher-name>` function in `$PROFILE.CurrentUserCurrentHost` | Saved, set for invocation, then restored in `finally` | `$CODEX_HOME\<profile-name>.config.toml` (normally `$HOME\.codex\...`) |

Use the shell the user actually launches. PowerShell 7 and Windows PowerShell can have different profile paths; modify the exact `$PROFILE.CurrentUserCurrentHost` reported by the target shell. Preserve all unrelated profile content and keep exactly one managed launcher block.

## Reference Implementations

These examples implement the contract for the verified Codex version. Re-check exact flags, profile behavior, executable resolution, endpoint, and model against the installed CLI and current GAC guidance before copying them.

### Linux or macOS

Resolve `<launcher-name>` and `<profile-name>` first, then create `~/.local/bin/<launcher-name>` with the real key substituted only in the local file:

```bash
#!/usr/bin/env bash
set -euo pipefail

export GAC_API_KEY='<GAC_API_KEY>'
credential_pattern='^[!-~]+$'
if ! (LC_ALL=C; [[ $GAC_API_KEY =~ $credential_pattern ]]); then
  echo '<launcher-name>: GAC_API_KEY must be one line of visible ASCII' >&2
  exit 2
fi
launcher_name='<launcher-name>'
profile_name='<profile-name>'

codex_bin="$(command -v codex || true)"
if [[ -z "$codex_bin" ]]; then
  echo "$launcher_name: codex binary not found" >&2
  exit 127
fi

exec "$codex_bin" --profile "$profile_name" --dangerously-bypass-approvals-and-sandbox "$@"
```

Then restrict the credential-bearing file and make sure its directory is on `PATH`:

```bash
chmod 0700 "$HOME/.local/bin/<launcher-name>"
```

If the initial request explicitly retains approvals or sandboxing, omit `--dangerously-bypass-approvals-and-sandbox`; keep every other contract item unchanged.

### Windows PowerShell

Add one managed block to `$PROFILE.CurrentUserCurrentHost`, substituting the real key only while writing the local profile:

```powershell
# >>> <launcher-name> launcher >>>
function <launcher-name> {
    $previousKeyExists = Test-Path Env:GAC_API_KEY
    $previousKey = $env:GAC_API_KEY
    $codexExitCode = $null

    try {
        $env:GAC_API_KEY = '<GAC_API_KEY>'
        if ([string]::IsNullOrEmpty($env:GAC_API_KEY) -or $env:GAC_API_KEY -notmatch '\A[!-~]+\z') {
            throw '<launcher-name>: GAC_API_KEY must be one line of visible ASCII'
        }

        $codexCommand = Get-Command codex -ErrorAction Stop | Select-Object -First 1
        & $codexCommand --profile '<profile-name>' --dangerously-bypass-approvals-and-sandbox @args
        $codexExitCode = $LASTEXITCODE
    }
    finally {
        if ($previousKeyExists) {
            $env:GAC_API_KEY = $previousKey
        }
        else {
            Remove-Item Env:GAC_API_KEY -ErrorAction SilentlyContinue
        }

    }

    if ($null -ne $codexExitCode) {
        $global:LASTEXITCODE = $codexExitCode
    }
}
# <<< <launcher-name> launcher <<<
```

Create the profile file first if necessary, preserve unrelated PowerShell profile content, replace an existing managed block instead of appending a duplicate, and dot-source the exact profile after editing:

```powershell
. $PROFILE.CurrentUserCurrentHost
```

For an explicit opt-out, remove only `--dangerously-bypass-approvals-and-sandbox` from the function.

## Runtime Argument Contract

The launcher's fixed arguments select the GAC profile and default permission mode. Every runtime argument belongs to Codex and must follow those defaults without being parsed, renamed, reordered, or consumed by the launcher.

Examples that must continue to work include `<launcher-name>`, `<launcher-name> exec "Reply with exactly: GAC_OK"`, `<launcher-name> --version`, and any current Codex subcommand or option supported by the installed version. The optional suffix is resolved at setup time and is never forwarded to Codex.

## Verification

Verify structure without displaying the key.

### Linux or macOS

```bash
codex_home="${CODEX_HOME:-$HOME/.codex}"
bash -n "$HOME/.local/bin/<launcher-name>"
test -x "$HOME/.local/bin/<launcher-name>"
test "$(stat -c '%a' "$HOME/.local/bin/<launcher-name>")" = 700
test -d "$codex_home"
test "$(stat -c '%a' "$codex_home/<profile-name>.config.toml")" = 600
rg -n 'model_provider|model =|base_url|wire_api|env_key|requires_openai_auth' "$codex_home/<profile-name>.config.toml"
test "$(rg -c '^export GAC_API_KEY=' "$HOME/.local/bin/<launcher-name>")" = 1
LC_ALL=C rg -q "^export GAC_API_KEY='[!-&(-~]+'$" "$HOME/.local/bin/<launcher-name>"
! rg -q 'CODEX_HOME=' "$HOME/.local/bin/<launcher-name>"
rg -q -F "profile_name='<profile-name>'" "$HOME/.local/bin/<launcher-name>"
rg -q -F -- '--profile "$profile_name"' "$HOME/.local/bin/<launcher-name>"
rg -q -- '--dangerously-bypass-approvals-and-sandbox' "$HOME/.local/bin/<launcher-name>"
command -v <launcher-name>
```

Use the platform's equivalent of `stat` on macOS when needed. Confirm only the presence of the key assignment; never print the matching line.

### Windows PowerShell

```powershell
$profilePath = $PROFILE.CurrentUserCurrentHost
$profileText = Get-Content -Raw -LiteralPath $profilePath
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
$providerProfile = Join-Path $codexHome '<profile-name>.config.toml'
$keyAssignmentPattern = '(?m)^[ \t]*\$env:GAC_API_KEY = ''[!-&(-~]+''[ \t]*$'
([regex]::Matches($profileText, [regex]::Escape('# >>> <launcher-name> launcher >>>'))).Count -eq 1
([regex]::Matches($profileText, [regex]::Escape('# <<< <launcher-name> launcher <<<'))).Count -eq 1
$profileText.Contains("--profile '<profile-name>'")
$profileText.Contains("--dangerously-bypass-approvals-and-sandbox")
([regex]::Matches($profileText, $keyAssignmentPattern)).Count -eq 1
!$profileText.Contains("CODEX_HOME")
Test-Path -LiteralPath $codexHome -PathType Container
Get-Command <launcher-name> -CommandType Function
Select-String -LiteralPath $providerProfile -Pattern 'model_provider|model =|base_url|wire_api|env_key|requires_openai_auth'
```

The exact assignment checks above reject multiline values and non-visible bytes without displaying the key. Do not output `$profileText`, the function definition, or matching key-assignment lines after the real key has been inserted. For an explicit permission opt-out, the permission-flag check must confirm absence instead.

### End-to-End Route Checks

Before launching, confirm the persistent profile contains the exact `<verified-gac-model>` proven by the shared-home Codex turn and contains no unresolved placeholder.

Run one small request through the custom launcher:

```text
<launcher-name> exec "Reply with exactly: GAC_OK"
```

The GAC run must report provider `gac`, the selected GAC model, approval mode `never`, and full host access for the default launcher, then return `GAC_OK`. Inspect plain `codex` resolution, its normal home, base config, and auth state to confirm they remain unchanged; do not issue a billable official-provider completion solely for this coexistence check unless the user requests it.

If a Windows function previously had `GAC_API_KEY` set in the caller, verify that the same value is restored after the command. If it was absent, verify that it remains absent. Also confirm the base config and OAuth credential store retain their pre-run fingerprints or modification times.

## Optional Separate-Home Fallback

Do not select a separate `CODEX_HOME` merely because `auth.json` exists. Offer this fallback only when the installed Codex version repeatedly fails the correctly configured shared-home target-CLI test with a state or authentication collision, the same request succeeds from a clean disposable home, and the user accepts that another `CODEX_HOME` also isolates base config, sessions, logs, skills, and package metadata.

When selected, create a launcher-owned home, do not copy `auth.json`, and copy or link no other ordinary-home state without explicit user authorization. Record this as a version-specific compatibility workaround and keep the shared-home layout as the default for future regeneration.

## GAC Model-Catalog Compatibility

On 2026-09-17, Codex CLI 0.154.0 warned `failed to decode models response: missing field models` while an explicitly pinned model still completed successfully through the same target client. The historical model id and raw catalog payload are intentionally omitted so they cannot become a future default or a substitute for the current target-CLI test.

Treat that warning as an endpoint catalog-schema compatibility issue when the pinned-model completion succeeds. It is not evidence that the launcher, profile, endpoint, or key is wrong. If the completion itself fails, diagnose the HTTP status, provider entitlement, model id, endpoint, and authentication separately.

## Troubleshooting

- If `--profile <profile-name>` reports legacy profile configuration, move the GAC keys out of `[profiles.<profile-name>]` and into the version-appropriate separate profile file without changing unrelated base settings.
- If plain `codex` uses GAC, remove accidental top-level `model_provider = "gac"` or provider selection from the base config; the selection belongs only in the GAC profile layer.
- If Codex asks for official login during `<launcher-name>`, verify `requires_openai_auth = false`, `env_key = "GAC_API_KEY"`, and the launcher's scoped key assignment.
- If GAC reports `401`, `403`, or throttling while the request is absent from provider-side key activity, validate the launcher's actual `GAC_API_KEY` shape first without printing it. A CR/LF-contaminated `env_key` value can prevent Authorization header construction. Then verify `requires_openai_auth = false` and whether the installed Codex version requires a provider-documented `env_http_headers` mapping. Do not blame or modify `auth.json` without a controlled target-CLI comparison; follow **Optional Separate-Home Fallback** only when its evidence threshold is met.
- If model refresh warns about `missing field models` but the explicit completion succeeds, report the catalog-schema mismatch and keep the pinned model.
- If Linux cannot find `<launcher-name>`, confirm mode `0700` and that `~/.local/bin` is on `PATH`.
- If Windows cannot find `<launcher-name>`, reload the same PowerShell profile that was edited and compare its path with `$PROFILE.CurrentUserCurrentHost`.

## Guardrails

- DO NOT put the GAC API key in this skill, the Codex TOML profile, a git-tracked file, command history, logs, or validation output.
- DO NOT require, recommend, or use direct GAC `/models` or `/responses` calls as launcher compatibility evidence.
- DO NOT choose a model from a historical note, vendor example, generator default, or previous launcher without a current target-CLI verification.
- DO NOT create the real profile or launcher until the shared-home Codex turn succeeds with the exact client-verified model.
- DO NOT serialize the GAC key across lines, accept whitespace or control characters, silently trim it, or verify only that the variable name appears in the launcher.
- DO NOT set or replace `CODEX_HOME` in the normal launcher, modify `auth.json`, or select GAC in the base `config.toml`.
- DO NOT create a separate Codex home solely because cached OAuth credentials exist; require the controlled failure evidence and user choice defined in **Optional Separate-Home Fallback**.
- DO NOT modify the base Codex `config.toml` or `auth.json` for the GAC profile route.
- DO NOT use a legacy `[profiles.<profile-name>]` table when the installed Codex version requires profile-v2 files.
- DO NOT replace, alias, or wrap the plain `codex` command with GAC behavior.
- DO NOT assign endpoint, account, model, routing, pricing, credential, or permission semantics to the optional suffix.
- DO NOT omit the default `--dangerously-bypass-approvals-and-sandbox` mode unless the initial request explicitly opts out.
- DO NOT treat a model-catalog decoding warning as a failed provider route when the explicit pinned-model completion succeeds.
- DO NOT print, commit, or expose the embedded key while creating, inspecting, or testing the launcher.
