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

Use this reference for a `codex-openlux` or `codex-openlux-<suffix>` launcher that targets OpenLux's Codex-compatible endpoint while preserving plain `codex` as the user's official OpenAI route. Put OpenLux configuration in a separate profile inside the user's normal `CODEX_HOME`, embed the user-provided OpenLux key only in the local credential-bearing launcher, and leave the base config and cached official authentication unchanged.

Terminal invocation of `imsight-dev-box-init->coding-agent->codex-openlux-launcher()` follows this page.

## Workflow

1. Inspect the installed Codex version and help, the host OS and shell, and whether the initial request explicitly opted out of permissive mode. These are read-only checks.
2. Obtain an OpenLux key entitled for the Codex-compatible Responses route and validate its shape under **Credential Requirements**. Stop without changing any file when the key is unavailable or malformed.
3. Resolve the model candidate under **Model Selection**.
4. Resolve the optional suffix and launcher/profile names under **Launcher Name and Suffix Contract**.
5. Run **Phase A: Shared-Home Codex Test**.
6. Only after Phase A succeeds, run **Phase B: Persistent Setup** and create the launcher from **Reference Implementations**.
7. Make the launcher use **Codex Profile Bootstrap for Redirected Homes** from `SKILL-MAIN.md`: embed the verified profile content without its key, resolve the active `CODEX_HOME` at runtime, ask before creating a missing profile, and refuse to overwrite a divergent one.
8. Run **Verification**, including one end-to-end completion in the default and redirected homes, the profile bootstrap decision paths, and a non-billable check that plain `codex` remains unchanged.
9. Report the profile and launcher locations, Codex version, verified model, permission mode, validation results, and any model-metadata warning without printing the key.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's contract, compatibility evidence, platform examples, and user constraints, then execute the plan without changing the base Codex configuration or borrowing another OpenLux product's authentication conventions.

## Launcher Name and Suffix Contract

Use `codex-openlux` with profile `openlux` when the user provides no suffix. With a suffix such as `work`, use `codex-openlux-work` and profile `openlux-work`. Store the profile beside the user's normal Codex config as `$CODEX_HOME/<profile-name>.config.toml`. Accept lowercase letters, digits, and internal hyphens. Omit the separator when the suffix is absent.

The suffix is a user-facing label only; it does not select an endpoint, account, model, routing mode, price tier, permission mode, or credential behavior.

## Codex-OpenLux Contract

| Concern | Required behavior |
| --- | --- |
| Ordinary Codex | Leave plain `codex` on its existing provider, base config, authentication route, and normal `CODEX_HOME`. |
| Provider profile | Put OpenLux settings only in `$CODEX_HOME/<profile-name>.config.toml`; never select OpenLux in the base `config.toml`. The launcher may materialize the verified profile from embedded non-secret content when the active home does not contain it. |
| OAuth coexistence | Do not modify, remove, copy, or suppress `auth.json` or the configured credential store. Plain `codex` keeps OAuth; the profile uses the scoped OpenLux key. |
| Endpoint | Put OpenLux's current Codex base URL in the provider profile; the verified example is `https://api.openlux.ai/v1`. |
| Protocol | Use the Responses wire API unless current OpenLux and Codex evidence establishes a replacement. |
| Authentication | Normal provider auth from `OPENLUX_API_KEY`; background model-discovery auth from the complete `Authorization` value in `OPENLUX_AUTHORIZATION`; `requires_openai_auth = false`. |
| Credential placement | Embed the key only in the local launcher or managed PowerShell block; never in the tracked skill or Codex TOML. |
| Credential integrity | The embedded value must be one line of visible ASCII; reject malformed input instead of trimming; derive `OPENLUX_AUTHORIZATION` only after validation. |
| Environment scope | Expose `OPENLUX_API_KEY` and `OPENLUX_AUTHORIZATION` only to the launched Codex process. Never set `CODEX_HOME` in the launcher. A PowerShell function must restore both credential variables. |
| Model | Pin `<verified-openlux-model>` from **Model Selection**, confirmed by a shared-home Codex turn. |
| Arguments | Forward every caller argument to Codex unchanged after the fixed profile and permission defaults. |
| Permissions | Inject Codex's strongest current approval-free, sandbox-bypass mode by default. Omit it only when the initial request explicitly opts out. |
| Executable | Resolve the real installed Codex command without replacing or recursing into plain `codex`. |
| Exit status | Preserve Codex's exit status. |

## Credential Requirements

The key must be a single line of visible ASCII (bytes 33-126). Reject empty, multiline, whitespace-padded, or control-character-bearing input instead of trimming it: Codex silently drops a header whose value is not valid HTTP header text, so a contaminated key produces unauthenticated requests with no client-side error. Validate without printing the key.

The generated Unix launcher or Windows PowerShell block contains the key in plaintext by design. Do not commit it. Restrict a Unix launcher to mode `0700`; on Windows, write only to the user's own PowerShell profile and never display the block after inserting the key.

## Model Selection

Get the model list from Codex itself, not from the provider API:

- `codex debug models` renders the effective model catalog as JSON; `codex debug models --bundled` lists the catalog compiled into the binary, offline. `--profile` does not apply to `debug models`; inspect a custom provider with `-c` overrides or through the gate turn.
- Each catalog entry exposes `supported_reasoning_levels` and `default_reasoning_level`. Reasoning-effort names are per-model and can change between Codex releases, so never hardcode one: read the candidate's levels from the catalog and use the lowest supported effort for probes.
- Third-party providers may implement `/models` incorrectly or not at all. When the response does not match Codex's catalog schema, Codex keeps its bundled catalog without an error. Never call provider `/models` or `/responses` endpoints directly for discovery or preflight.

Choose the candidate in this order: an explicit user choice, then current provider guidance (account UI or docs), then the latest model in Codex's catalog that fits the Codex coding route. A model appearing in any catalog or listing is not proof the provider accepts Codex's request shape; the shared-home turn in **Phase A** is decisive.

## Version and Profile Compatibility

Inspect the installed CLI rather than assuming recorded syntax remains current: `codex --version`, `codex --help`, `codex exec --help`.

Codex places profile files beside the base config as `$CODEX_HOME/<profile-name>.config.toml` and selects them with `--profile <profile-name>`. Custom-provider keys include `base_url`, `env_key`, `env_http_headers`, `requires_openai_auth`, and the Responses-only `wire_api`. Values in `env_http_headers` are environment-variable names whose runtime values become complete header values; Codex does not add `Bearer ` to them. Do not use a legacy `[profiles.<name>]` table in the base config.

Version-sensitive details on this page can drift. When anything about configuration goes wrong or disagrees with the installed client, consult the sources in **References** — the installed CLI, the official documentation, and the source code outrank this guide.

## Compatibility Gate

### Phase A: Shared-Home Codex Test

1. Confirm the installed Codex supports `--profile` and its strongest approval/sandbox bypass flag.
2. Resolve the user's normal `CODEX_HOME` without changing it. Record non-secret fingerprints (modification timestamp or hash) of the base config and credential store. Do not log out, move, rewrite, or copy `auth.json`.
3. Write a uniquely named temporary profile beside the normal config — never overwrite an existing profile — using the model candidate, `model_reasoning_effort` set to the candidate's lowest `supported_reasoning_levels` entry (queried from the catalog, not assumed) to keep the probe fast and cheap, `env_key = "OPENLUX_API_KEY"`, `env_http_headers = { "Authorization" = "OPENLUX_AUTHORIZATION" }`, and `requires_openai_auth = false`.
4. Scope `OPENLUX_API_KEY` to the raw key and `OPENLUX_AUTHORIZATION` to the complete `Bearer <key>` value in the test process, then run one minimal `codex --profile <profile-name> exec --skip-git-repo-check ...` turn.
5. Fail the gate if any background model request returns `401` or `403`, even when the turn succeeds. If Codex rejects the model and reports an actionable replacement, retry once with that model; otherwise stop and ask the user for a model choice or updated provider guidance.
6. Remove the temporary profile and confirm the base config and credential store fingerprints are unchanged. Pace any retries, because gateways may penalize repeated attempts.

Set `<verified-openlux-model>` to the exact id that completed this turn.

### Phase B: Persistent Setup

Only after Phase A succeeds, write the persistent provider profile beside the normal config (mode `0600`, refusing to overwrite an unrelated existing profile) with `<verified-openlux-model>` and the production reasoning effort, then create the launcher (mode `0700`) from **Reference Implementations** with the real key substituted only in the user's local credential-bearing file.

## Provider Profile

```toml
model_provider = "openlux"
model = "<verified-openlux-model>"
model_reasoning_effort = "high"
disable_response_storage = true

[model_providers.openlux]
name = "OpenLux"
base_url = "https://api.openlux.ai/v1"
env_key = "OPENLUX_API_KEY"
env_http_headers = { "Authorization" = "OPENLUX_AUTHORIZATION" }
wire_api = "responses"
requires_openai_auth = false
stream_idle_timeout_ms = 120000
```

The profile carries no credential. The gate turn used the candidate's lowest supported reasoning effort; the persistent profile defaults to `high` — adjust to the user's needs, choosing from the model's `supported_reasoning_levels`. Omit `request_max_retries` and `stream_max_retries` so Codex defaults apply; override them only from current provider and client evidence, never below defaults. Re-check the endpoint and timeout against current guidance.

### Runtime profile bootstrap

The launcher must resolve the active home at runtime rather than baking the normal home into its path. If `<profile-name>.config.toml` is absent there, prompt before creating it from the verified profile template above, then continue with the same `--profile` invocation. Leave an identical file untouched. If the file differs, or if the shell is noninteractive and the file is absent, stop without overwriting or silently creating state. Never copy the base config or `auth.json` into the redirected home.

## Platform Lanes

| Host | Launcher | Secret scope | Profile |
| --- | --- | --- | --- |
| Linux or macOS | Executable `~/.local/bin/<launcher-name>` Bash script | Exported only in the launcher process | `$CODEX_HOME/<profile-name>.config.toml` |
| Windows PowerShell | Managed `<launcher-name>` function in `$PROFILE.CurrentUserCurrentHost` | Saved, set for invocation, restored in `finally` | `$CODEX_HOME\<profile-name>.config.toml` |

Use the shell the user actually launches. PowerShell 7 and Windows PowerShell can have different profile paths; modify the exact `$PROFILE.CurrentUserCurrentHost` reported by the target shell, preserve unrelated content, and keep exactly one managed block.

## Reference Implementations

### Linux or macOS

```bash
#!/usr/bin/env bash
set -euo pipefail

export OPENLUX_API_KEY='<OPENLUX_API_KEY>'
credential_pattern='^[!-~]+$'
if ! (LC_ALL=C; [[ $OPENLUX_API_KEY =~ $credential_pattern ]]); then
  echo '<launcher-name>: OPENLUX_API_KEY must be one line of visible ASCII' >&2
  exit 2
fi
export OPENLUX_AUTHORIZATION="Bearer ${OPENLUX_API_KEY}"
launcher_name='<launcher-name>'
profile_name='<profile-name>'

# Before exec, apply the shared Codex Profile Bootstrap contract: resolve
# ${CODEX_HOME:-$HOME/.codex}, compare the embedded non-secret profile content,
# ask before creating a missing profile, and stop on a mismatch.

codex_bin="$(command -v codex || true)"
if [[ -z "$codex_bin" ]]; then
  echo "$launcher_name: codex binary not found" >&2
  exit 127
fi

exec "$codex_bin" --profile "$profile_name" --dangerously-bypass-approvals-and-sandbox "$@"
```

Restrict the file with `chmod 0700` and ensure `~/.local/bin` is on `PATH`. For an explicit permission opt-out, omit only `--dangerously-bypass-approvals-and-sandbox`.

### Windows PowerShell

```powershell
# >>> <launcher-name> launcher >>>
function <launcher-name> {
    $previousKeyExists = Test-Path Env:OPENLUX_API_KEY
    $previousKey = $env:OPENLUX_API_KEY
    $previousAuthorizationExists = Test-Path Env:OPENLUX_AUTHORIZATION
    $previousAuthorization = $env:OPENLUX_AUTHORIZATION
    $codexExitCode = $null

    try {
        $env:OPENLUX_API_KEY = '<OPENLUX_API_KEY>'
        if ([string]::IsNullOrEmpty($env:OPENLUX_API_KEY) -or $env:OPENLUX_API_KEY -notmatch '\A[!-~]+\z') {
            throw '<launcher-name>: OPENLUX_API_KEY must be one line of visible ASCII'
        }
        $env:OPENLUX_AUTHORIZATION = "Bearer $env:OPENLUX_API_KEY"

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

        if ($previousAuthorizationExists) {
            $env:OPENLUX_AUTHORIZATION = $previousAuthorization
        }
        else {
            Remove-Item Env:OPENLUX_AUTHORIZATION -ErrorAction SilentlyContinue
        }
    }

    if ($null -ne $codexExitCode) {
        $global:LASTEXITCODE = $codexExitCode
    }
}
# <<< <launcher-name> launcher <<<
```

Create the Codex profile first, preserve unrelated profile content, replace an existing matching managed block instead of appending a duplicate, then dot-source the exact edited profile.

## Runtime Argument Contract

The launcher's fixed arguments select the OpenLux profile and default permission mode. Every runtime argument belongs to Codex and must follow those defaults without being parsed, renamed, reordered, or consumed by the launcher. The suffix is resolved at setup time and is never forwarded to Codex.

## Verification

Verify structure without displaying the key.

### Linux or macOS

```bash
codex_home="${CODEX_HOME:-$HOME/.codex}"
bash -n "$HOME/.local/bin/<launcher-name>"
test -x "$HOME/.local/bin/<launcher-name>"
test "$(stat -c '%a' "$HOME/.local/bin/<launcher-name>")" = 700
test "$(stat -c '%a' "$codex_home/<profile-name>.config.toml")" = 600
rg -n 'model_provider|model =|base_url|wire_api|env_key|env_http_headers|requires_openai_auth' "$codex_home/<profile-name>.config.toml"
test "$(rg -c '^export OPENLUX_API_KEY=' "$HOME/.local/bin/<launcher-name>")" = 1
LC_ALL=C rg -q "^export OPENLUX_API_KEY='[!-&(-~]+'$" "$HOME/.local/bin/<launcher-name>"
rg -q 'OPENLUX_AUTHORIZATION=' "$HOME/.local/bin/<launcher-name>"
! rg -q 'CODEX_HOME=' "$HOME/.local/bin/<launcher-name>"
rg -q -F "profile_name='<profile-name>'" "$HOME/.local/bin/<launcher-name>"
rg -q -F -- '--profile "$profile_name"' "$HOME/.local/bin/<launcher-name>"
rg -q -- '--dangerously-bypass-approvals-and-sandbox' "$HOME/.local/bin/<launcher-name>"
command -v <launcher-name>
```

Use `stat -f '%Lp'` on macOS. The key-line check rejects multiline values and non-visible bytes without displaying the key.

### Windows PowerShell

```powershell
$profilePath = $PROFILE.CurrentUserCurrentHost
$profileText = Get-Content -Raw -LiteralPath $profilePath
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
$providerProfile = Join-Path $codexHome '<profile-name>.config.toml'
$keyAssignmentPattern = '(?m)^[ \t]*\$env:OPENLUX_API_KEY = ''[!-&(-~]+''[ \t]*$'
([regex]::Matches($profileText, [regex]::Escape('# >>> <launcher-name> launcher >>>'))).Count -eq 1
([regex]::Matches($profileText, [regex]::Escape('# <<< <launcher-name> launcher <<<'))).Count -eq 1
$profileText.Contains("--profile '<profile-name>'")
$profileText.Contains('--dangerously-bypass-approvals-and-sandbox')
([regex]::Matches($profileText, $keyAssignmentPattern)).Count -eq 1
$profileText.Contains('OPENLUX_AUTHORIZATION')
!$profileText.Contains('CODEX_HOME')
Get-Command <launcher-name> -CommandType Function
Select-String -LiteralPath $providerProfile -Pattern 'model_provider|model =|base_url|wire_api|env_key|env_http_headers|requires_openai_auth'
```

Do not output `$profileText`, the function definition, or matching key-assignment lines after the real key is inserted.

### End-to-End Route Checks

1. Record whether `OPENLUX_API_KEY` and `OPENLUX_AUTHORIZATION` exist in the caller, and a non-secret fingerprint of the OAuth credential store.
2. Confirm the persistent profile contains the exact `<verified-openlux-model>` and no unresolved placeholder.
3. Allow a quiet interval after the gate turn, then make one end-to-end request: `<launcher-name> exec --skip-git-repo-check "Reply with exactly: OPENLUX_OK"`. Require provider `openlux`, the verified model, approval mode `never`, full host access, `OPENLUX_OK`, exit code 0, and zero `401`/`403` background model-request errors.
4. Confirm the caller's credential variables are unchanged and the base config, credential store, and plain `codex` resolution are untouched. Do not issue a billable official-provider completion solely for this check.

## Key Replacement

Treat a replacement key as a new compatibility run, not a text substitution: keep the existing launcher untouched, repeat **Phase A** with both credential variables, and only then update the embedded key and the pinned model together when needed. Verify in memory that the old key is absent from the launcher and that neither key appears in output, then perform one paced end-to-end request and the plain-Codex coexistence check.

## Optional Separate-Home Fallback

Do not select a separate `CODEX_HOME` merely because `auth.json` exists. Offer it only when all of the following hold:

1. The shared-home test repeatedly fails with a state or authentication collision after the profile, credential shape, and `requires_openai_auth = false` are verified correct.
2. The same request succeeds from a clean disposable home.
3. The user accepts that another `CODEX_HOME` also isolates base config, sessions, logs, skills, and package metadata.

When selected, create a launcher-owned home, copy nothing from the ordinary home, and record it as a version-specific workaround while keeping the shared-home layout as the default.

## Model Metadata and Catalog Compatibility

Codex warns when the pinned model is absent from its bundled catalog (`codex debug models --bundled`) and falls back to default model metadata. The completion still succeeds; report the warning separately from provider connectivity, keep the tested model, and do not silence it by inventing a local model catalog unless the user explicitly asks for and validates one.

## Troubleshooting

- If `--profile <profile-name>` reports legacy profile configuration, move only the OpenLux layer into the separate profile file after preserving unrelated settings.
- If plain `codex` uses OpenLux, remove accidental top-level OpenLux selection from the base config; selection belongs only in the profile layer.
- If Codex asks for official login through the launcher, verify `requires_openai_auth = false`, `env_key = "OPENLUX_API_KEY"`, and the launcher's scoped key assignment.
- If the background model manager reports `401 Token not provided`, or the provider shows `429` with no key activity provider-side, validate the launcher's actual credential shape first without printing it — a CR/LF-contaminated value prevents Authorization header construction. Then verify the `env_http_headers` mapping and that `OPENLUX_AUTHORIZATION` holds the complete `Bearer <key>` value.
- If the provider reports an invalid-token cooldown, stop all probes for the full stated interval.
- If a paced turn intermittently returns `429` after a previous success, preserve the known-good configuration and report provider throttling separately; Codex aborts on the first 429, so do not churn profiles, rotate models, or fire retry bursts.
- If Codex rejects the provider route, diagnose through the target CLI; a standalone HTTP success must not override the Codex failure.
- If Unix cannot find the launcher, confirm mode `0700` and that `~/.local/bin` is on `PATH`. On Windows, reload the exact edited PowerShell profile.
- If none of these entries match the failure, check the sources in **References** before improvising.

## References

Treat these as the authority over this guide when they disagree; this page's version-sensitive details may be outdated:

- Codex source: `https://github.com/openai/codex` — the Rust CLI lives under `codex-rs/`; read the tag matching the installed version (`rust-v<version>`, e.g. from `codex --version`) because `main` moves ahead of releases.
- Codex configuration reference: `https://developers.openai.com/codex/config-reference/` — config keys, profile-file layout, and custom-provider fields.
- Codex documentation home: `https://developers.openai.com/codex/` — current CLI features and behavior.

## Guardrails

- DO NOT put the OpenLux key in this skill, the Codex TOML profile, a git-tracked file, command history, logs, or validation output.
- DO NOT serialize the key across lines, accept whitespace or control characters, silently trim it, derive `OPENLUX_AUTHORIZATION` before validation, or verify only that the variable name appears in the launcher.
- DO NOT call provider `/models` or `/responses` endpoints directly for discovery, preflight, or gating; use Codex's own surfaces and turns.
- DO NOT select a model from this guide, notes, or other launchers; follow **Model Selection**.
- DO NOT create persistent setup before the shared-home Codex turn succeeds with the exact client-verified model.
- DO NOT set `CODEX_HOME` in the launcher, modify `auth.json` or the base `config.toml`, or select OpenLux in the base config.
- DO NOT create a separate Codex home outside the conditions in **Optional Separate-Home Fallback**.
- DO NOT omit the environment-backed Authorization header.
- DO NOT lower Codex's request or stream retry defaults without current provider evidence.
- DO NOT repeatedly invoke the launcher while diagnosing `401`, `429`, or connection-drop responses; each launch may create multiple provider requests.
- DO NOT use an OpenLux key from a Claude- or Gemini-only product route as evidence of Codex compatibility.
- DO NOT replace, alias, or wrap the plain `codex` command with OpenLux behavior.
- DO NOT omit the default `--dangerously-bypass-approvals-and-sandbox` mode unless the initial request explicitly opts out.
- DO NOT treat a catalog listing or standalone API success as proof that the provider accepts Codex's request shape.
- DO NOT treat a local model-metadata warning as provider failure when the pinned-model completion succeeds.
