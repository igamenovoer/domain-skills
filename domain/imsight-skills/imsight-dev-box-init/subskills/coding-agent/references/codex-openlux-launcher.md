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

# Codex-OpenLux Launcher Setup

Use this reference only for a `codex-openlux` or `codex-openlux-<suffix>` launcher that targets OpenLux's Codex-compatible endpoint while preserving plain `codex` as the user's existing official OpenAI route. Keep provider configuration in a dedicated Codex profile file, embed the user-provided OpenLux key only in the local credential-bearing launcher, and leave the base Codex config and official authentication unchanged.

Terminal invocation of `imsight-dev-box-init->coding-agent->codex-openlux-launcher()` follows this page.

## Workflow

1. Inspect the installed Codex version and help, the host OS and shell, OpenLux's current Codex endpoint and model guidance, and whether the initial request explicitly opted out of permissive mode.
2. Resolve the optional suffix and launcher/profile names under **Launcher Name and Suffix Contract**.
3. Obtain an OpenLux key entitled for the Codex-compatible Responses route; stop instead of writing a placeholder launcher when the key is unavailable.
4. Pass **Compatibility Gate** before persisting the dedicated profile or credential-bearing launcher.
5. Implement **Codex-OpenLux Contract** with the installed version's profile layout and an OS-native launcher. Treat **Reference Implementations** as worked examples rather than mandatory machinery.
6. Run **Verification**, including profile loading, scoped authentication, argument forwarding, permission mode, one OpenLux completion, and a non-billable check that plain `codex` remains unchanged.
7. Report the profile and launcher locations, Codex version, selected model, permission mode, validation results, and any model-metadata warning without printing the key.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's OpenLux-only contract, compatibility evidence, platform examples, and user constraints, then execute the plan without changing the base Codex configuration or borrowing another OpenLux product's authentication conventions.

## Launcher Name and Suffix Contract

Use `codex-openlux` when the user provides no suffix. When the user provides a suffix such as `work`, use `codex-openlux-work` and the matching Codex profile name `openlux-work`. Accept lowercase letters, digits, and internal hyphens. Omit the separator when the suffix is absent.

The suffix is a user-facing label only. It does not select an OpenLux token group, account, endpoint, model, automatic-routing mode, price tier, permission mode, or credential behavior. Use it only to keep the launcher, managed block, and dedicated profile file distinct. In particular, `codex-openlux-auto` must not inject an `auto` model or routing option unless separately established by current provider evidence and explicitly requested.

## Codex-OpenLux Contract

Every generated setup must satisfy these invariants:

| Concern | Required behavior |
| --- | --- |
| Ordinary Codex | Leave plain `codex` on its existing provider, base config, and authentication route. |
| Provider isolation | Put OpenLux selection and provider settings in the resolved dedicated profile (`openlux` or `openlux-<suffix>`), not in the base `config.toml`. |
| Endpoint | Put OpenLux's currently verified Codex base URL in the dedicated profile; the verified example is `https://api.openlux.ai/v1`. |
| Protocol | Use the Responses wire API unless current OpenLux and Codex evidence establishes a replacement. |
| Authentication | Configure the provider to read `OPENLUX_API_KEY` and not require OpenAI authentication. |
| Credential placement | Embed the user-provided key directly in the local launcher or managed PowerShell profile block; never put it in the tracked skill or Codex TOML. |
| Suffix | Use it only as the optional launcher/profile namespace defined above. Do not derive runtime behavior from its text. |
| Environment scope | Expose `OPENLUX_API_KEY` only to the launched Codex process. A PowerShell function must restore the caller's previous value. |
| Model | Pin a model confirmed by both the current OpenLux key and a real Codex turn; do not infer model validity only from `/models`. |
| Arguments | Forward every caller argument to Codex unchanged after the fixed profile and permission defaults. |
| Permissions | Inject Codex's strongest current approval-free, sandbox-bypass mode by default. Omit it only when the user's initial request explicitly asks to retain approvals or sandboxing. |
| Executable | Resolve the real installed Codex command without replacing or recursing into plain `codex`. |
| Exit status | Preserve Codex's exit status. |

The provider endpoint, token entitlement, and model route come from OpenLux. The permissive launcher default comes from the coding-agent subskill's shared policy and does not authorize unrelated host changes.

## Required Input

The setup requires an OpenLux API key that is entitled to the provider's Codex-compatible Responses route. Keep it in memory while generating the launcher and represent it as `<OPENLUX_API_KEY>` in documentation, diffs, logs, commands, and examples.

The generated Unix launcher or Windows PowerShell profile block contains the key in plaintext by design. Do not commit the generated launcher. Restrict a Unix launcher to mode `0700`; on Windows, write only to the user's own PowerShell profile and never display the managed block after inserting the key.

The suffix is optional. Do not ask for one when the user requests `codex-openlux` or gives no reason to distinguish variants.

## Version and Profile Compatibility

Before implementation, inspect the installed CLI rather than assuming the recorded syntax remains current:

```text
codex --version
codex --help
codex exec --help
```

The official Codex configuration reference currently places profile files beside the base config as `$CODEX_HOME/<profile-name>.config.toml` and selects them with `--profile <profile-name>`: `https://developers.openai.com/codex/config-reference/`. It also documents custom-provider `base_url`, `env_key`, `requires_openai_auth`, and the Responses-only `wire_api` value.

This procedure was verified on 2026-09-17 with `codex-cli 0.154.0`. That version loaded `openlux.config.toml` from an isolated `CODEX_HOME` with `--profile openlux`; it did not require or use a legacy `[profiles.openlux]` table in the base `config.toml`.

Treat installed help, current official Codex documentation, and an isolated profile-loading probe as the compatibility authority. OpenLux documentation is provider evidence, not authority for Codex's profile syntax. Do not silently migrate or delete legacy profile tables; preserve unrelated configuration and report conflicts.

## Compatibility Gate

Pass all applicable checks before writing persistent configuration:

1. Confirm the installed Codex supports `--profile` and its strongest current approval/sandbox bypass flag. On the verified version that flag was `--dangerously-bypass-approvals-and-sandbox`.
2. Request `GET https://api.openlux.ai/v1/models` with the supplied key and record only model ids, not credentials or full headers.
3. Request one minimal `POST https://api.openlux.ai/v1/responses` with a candidate model, `store: false`, and a deterministic short response.
4. Create an isolated temporary `CODEX_HOME`, write the candidate profile there, and run one minimal `codex --profile <profile-name> exec --skip-git-repo-check ...` turn with the key scoped only to that process.
5. Treat the Codex turn as decisive. A successful `/models` or direct Responses request alone does not prove Codex compatibility because agent requests include streaming, tools, instructions, and reasoning metadata.
6. Remove the isolated test profile after the gate. Persist the real profile and launcher only when the Codex turn succeeds.

Stop and report the failing layer when key entitlement, endpoint, model, Responses behavior, or the Codex request fails. Do not compensate for an incompatible key by trying it against OpenLux's Claude or Gemini routes.

Verified snapshot, not a permanent guarantee: on 2026-09-17, OpenLux returned HTTP 200 from `/v1/responses` for `gpt-5-codex`, and Codex CLI 0.154.0 completed an isolated turn through provider `openlux` with exit code 0. Re-run the gate instead of treating those observations as permanent.

## Dedicated Provider Profile

Resolve the active Codex home from `CODEX_HOME` when intentionally set; otherwise use `~/.codex`. Resolve `<profile-name>` to `openlux` or `openlux-<suffix>`, then create `<codex-home>/<profile-name>.config.toml` without changing `<codex-home>/config.toml` or `<codex-home>/auth.json`:

```toml
model_provider = "openlux"
model = "gpt-5-codex"
model_reasoning_effort = "high"
disable_response_storage = true

[model_providers.openlux]
name = "OpenLux"
base_url = "https://api.openlux.ai/v1"
env_key = "OPENLUX_API_KEY"
wire_api = "responses"
requires_openai_auth = false
request_max_retries = 1
stream_max_retries = 1
stream_idle_timeout_ms = 120000
```

This is a verified provider example, not a timeless vendor script. Re-check the endpoint, model, retry policy, and timeout against current OpenLux behavior and the user's needs. Keep the model explicit because a model listed by the provider can still lack Codex-local metadata or reject Codex's richer request shape.

The profile contains no credential. Its purpose is provider selection, endpoint, protocol, authentication variable name, and model defaults. The launcher supplies the secret and activates the profile.

## Platform Lanes

| Host | Launcher | Secret scope | Profile |
| --- | --- | --- | --- |
| Linux or macOS | Executable `~/.local/bin/<launcher-name>` Bash script | Exported only in the child launcher process | `~/.codex/<profile-name>.config.toml`, or the intentionally selected `CODEX_HOME` |
| Windows PowerShell | Managed `<launcher-name>` function in `$PROFILE.CurrentUserCurrentHost` | Saved, set for invocation, then restored in `finally` | `$HOME\.codex\<profile-name>.config.toml`, or the intentionally selected `CODEX_HOME` |

Use the shell the user actually launches. Do not install a compatibility shell solely for this launcher. PowerShell 7 and Windows PowerShell can have different profile paths; modify the exact `$PROFILE.CurrentUserCurrentHost` reported by the target shell. Preserve all unrelated profile content and keep exactly one managed launcher block.

## Reference Implementations

These examples implement the verified contract. Re-check exact flags, profile behavior, executable resolution, endpoint, and model against the installed CLI and current OpenLux guidance before copying them. Substitute the real key only in the user's local credential-bearing file.

### Linux or macOS

Resolve `<launcher-name>` and `<profile-name>` first, then create `~/.local/bin/<launcher-name>`:

```bash
#!/usr/bin/env bash
set -euo pipefail

export OPENLUX_API_KEY='<OPENLUX_API_KEY>'
launcher_name='<launcher-name>'
profile_name='<profile-name>'

codex_bin="$(command -v codex || true)"
if [[ -z "$codex_bin" ]]; then
  echo "$launcher_name: codex binary not found" >&2
  exit 127
fi

exec "$codex_bin" --profile "$profile_name" --dangerously-bypass-approvals-and-sandbox "$@"
```

Restrict the credential-bearing file and ensure its directory is on the user's `PATH`:

```bash
chmod 0700 "$HOME/.local/bin/<launcher-name>"
```

If the initial request explicitly retains approvals or sandboxing, omit only `--dangerously-bypass-approvals-and-sandbox`; keep every other contract item unchanged.

### Windows PowerShell

Add one managed block to `$PROFILE.CurrentUserCurrentHost`, substituting the real key only while writing the local profile:

```powershell
# >>> <launcher-name> launcher >>>
function <launcher-name> {
    $previousKeyExists = Test-Path Env:OPENLUX_API_KEY
    $previousKey = $env:OPENLUX_API_KEY
    $codexExitCode = $null

    try {
        $env:OPENLUX_API_KEY = '<OPENLUX_API_KEY>'

        $codexCommand = Get-Command codex -CommandType Application,ExternalScript -ErrorAction Stop | Select-Object -First 1
        & $codexCommand.Source --profile '<profile-name>' --dangerously-bypass-approvals-and-sandbox @args
        $codexExitCode = $LASTEXITCODE
    }
    finally {
        if ($previousKeyExists) {
            $env:OPENLUX_API_KEY = $previousKey
        }
        else {
            Remove-Item Env:OPENLUX_API_KEY -ErrorAction SilentlyContinue
        }
    }

    if ($null -ne $codexExitCode) {
        $global:LASTEXITCODE = $codexExitCode
    }
}
# <<< <launcher-name> launcher <<<
```

Create the Codex profile file first, preserve unrelated PowerShell profile content, replace an existing matching managed block instead of appending a duplicate, parse the profile before loading it, and then dot-source the exact profile:

```powershell
. $PROFILE.CurrentUserCurrentHost
```

For an explicit opt-out, remove only `--dangerously-bypass-approvals-and-sandbox` from the function.

## Runtime Argument Contract

The launcher's fixed arguments select the OpenLux profile and default permission mode. Every runtime argument belongs to Codex and must follow those defaults without being parsed, renamed, reordered, or consumed by the launcher.

Examples that must remain valid include `<launcher-name>`, `<launcher-name> exec "Reply with exactly: OPENLUX_OK"`, `<launcher-name> --version`, and any current Codex subcommand or option supported by the installed version. The optional suffix is resolved at setup time and is never forwarded to Codex.

## Verification

Verify structure without displaying the key.

### Linux or macOS

```bash
codex_home="${CODEX_HOME:-$HOME/.codex}"
bash -n "$HOME/.local/bin/<launcher-name>"
test -x "$HOME/.local/bin/<launcher-name>"
test "$(stat -c '%a' "$HOME/.local/bin/<launcher-name>")" = 700
rg -n 'model_provider|model =|base_url|wire_api|env_key|requires_openai_auth' "$codex_home/<profile-name>.config.toml"
rg -q 'OPENLUX_API_KEY=' "$HOME/.local/bin/<launcher-name>"
rg -q -F "profile_name='<profile-name>'" "$HOME/.local/bin/<launcher-name>"
rg -q -F -- '--profile "$profile_name"' "$HOME/.local/bin/<launcher-name>"
rg -q -- '--dangerously-bypass-approvals-and-sandbox' "$HOME/.local/bin/<launcher-name>"
command -v <launcher-name>
```

Use `stat -f '%Lp'` instead of `stat -c '%a'` on macOS. Confirm only the presence of the key assignment; never print the matching line.

### Windows PowerShell

```powershell
$profilePath = $PROFILE.CurrentUserCurrentHost
$profileText = Get-Content -Raw -LiteralPath $profilePath
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
$providerProfile = Join-Path $codexHome '<profile-name>.config.toml'
([regex]::Matches($profileText, [regex]::Escape('# >>> <launcher-name> launcher >>>'))).Count -eq 1
([regex]::Matches($profileText, [regex]::Escape('# <<< <launcher-name> launcher <<<'))).Count -eq 1
$profileText.Contains("--profile '<profile-name>'")
$profileText.Contains('--dangerously-bypass-approvals-and-sandbox')
$profileText.Contains('OPENLUX_API_KEY')
Get-Command <launcher-name> -CommandType Function
Select-String -LiteralPath $providerProfile -Pattern 'model_provider|model =|base_url|wire_api|env_key|requires_openai_auth'
```

Do not output `$profileText`, the function definition, or matching key-assignment lines after the real key has been inserted. For an explicit permission opt-out, the permission-flag check must confirm absence instead.

### End-to-End Route Checks

1. Record whether `OPENLUX_API_KEY` exists in the caller and, when present, compare its restored value without printing it.
2. Run `<launcher-name> exec --skip-git-repo-check "Reply with exactly: OPENLUX_OK"` in a disposable directory when needed.
3. Confirm the run reports provider `openlux`, the selected model, approval mode `never`, and full host access for the default launcher, then returns `OPENLUX_OK` with exit code 0.
4. Confirm the caller's `OPENLUX_API_KEY` presence and value are unchanged after the process.
5. Inspect plain `codex` resolution, base config, and auth state to confirm the launcher did not alter them. Do not issue a billable official-provider completion solely for this check unless the user requests it.

Record token usage for billable probes when Codex reports it.

## Model Metadata and Catalog Compatibility

On 2026-09-17, Codex CLI 0.154.0 completed an OpenLux `gpt-5-codex` request but warned that the model was unknown locally and fallback model metadata would be used. Treat that warning as a Codex-local model-catalog limitation when the explicit completion succeeds. It is not evidence that the key, profile, endpoint, or Responses route failed.

Fallback metadata can still degrade model-specific defaults, context sizing, or other behavior. Report the warning, keep the explicitly tested model, and re-check newer Codex versions or a provider model that Codex recognizes. Do not silence the warning by inventing a local model catalog unless the user explicitly asks for and validates one.

## Troubleshooting

- If `--profile <profile-name>` reports legacy profile configuration, move only the OpenLux layer out of `[profiles.<profile-name>]` and into the installed version's separate profile file after preserving unrelated settings.
- If plain `codex` uses OpenLux, remove accidental top-level OpenLux provider selection from the base config; the selection belongs only in the dedicated profile layer.
- If Codex asks for official login through the custom launcher, verify `requires_openai_auth = false`, `env_key = "OPENLUX_API_KEY"`, and the launcher's scoped key assignment.
- If `/models` succeeds but `/responses` fails, diagnose key product entitlement, model id, endpoint, and request schema before creating a launcher.
- If direct `/responses` succeeds but Codex fails, inspect streaming, tool calls, reasoning metadata, storage flags, and Codex/OpenLux version compatibility.
- If the run succeeds with an unknown-model warning, report the fallback-metadata limitation separately from provider connectivity.
- If Windows cannot find the launcher, reload the exact PowerShell profile that was edited and compare its path with `$PROFILE.CurrentUserCurrentHost`.
- If Unix cannot find the launcher, confirm mode `0700` and that `~/.local/bin` is on `PATH`.

## Guardrails

- DO NOT put the OpenLux key in this skill, the Codex TOML profile, a git-tracked file, command history, logs, or validation output.
- DO NOT use an OpenLux key from a Claude- or Gemini-only product route as evidence of Codex compatibility.
- DO NOT modify the base Codex `config.toml` or `auth.json` for the dedicated OpenLux route.
- DO NOT use a legacy `[profiles.<profile-name>]` table when the installed Codex version requires profile files.
- DO NOT replace, alias, or wrap the plain `codex` command with OpenLux behavior.
- DO NOT assign endpoint, account, token-group, model, routing, pricing, credential, or permission semantics to the optional suffix.
- DO NOT omit the default `--dangerously-bypass-approvals-and-sandbox` mode unless the initial request explicitly opts out.
- DO NOT treat `/models` success as proof that OpenLux can execute a Codex agent request.
- DO NOT treat a local model-metadata warning as provider failure when the pinned-model completion succeeds.
- DO NOT print, commit, or expose the embedded key while creating, inspecting, testing, or reporting the launcher.
