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

Use this reference only for a `codex-openlux` or `codex-openlux-<suffix>` launcher that targets OpenLux's Codex-compatible endpoint while preserving plain `codex` as the user's existing official OpenAI route. Give the launcher its own fixed, auth-free `CODEX_HOME`, keep provider configuration there, embed the user-provided OpenLux key only in the local credential-bearing launcher, and leave the ordinary Codex home and official authentication unchanged.

Terminal invocation of `imsight-dev-box-init->coding-agent->codex-openlux-launcher()` follows this page.

## Workflow

1. Inspect the installed Codex version and help, the host OS and shell, OpenLux's current Codex endpoint guidance, and whether the initial request explicitly opted out of permissive mode. These are read-only checks.
2. Obtain an OpenLux key entitled for the Codex-compatible Responses route; stop without changing any file when the key is unavailable.
3. Resolve the current endpoint, auth lane, and a model candidate from the user's request plus current Codex and OpenLux documentation. Do not call OpenLux APIs directly to preflight or discover them.
4. Resolve the optional suffix, launcher/profile names, and dedicated-home name under **Launcher Name and Suffix Contract**, then complete **Phase A: Isolated Codex Test** using a disposable auth-free home that matches the persistent topology. Let Codex itself validate the complete request path and use its own model/status surfaces when available.
5. Only after the isolated Codex test succeeds, implement **Codex-OpenLux Contract** as **Phase B: Persistent Setup**. Treat **Reference Implementations** as worked examples rather than mandatory machinery.
6. Run **Verification**, including profile loading, authenticated background model discovery, scoped environment restoration, argument forwarding, permission mode, one OpenLux completion, and a non-billable check that plain `codex` remains unchanged.
7. Report the dedicated home, profile and launcher locations, Codex version, client-verified model, permission mode, validation results, and any provider-throttle or model-metadata warning without printing the key.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's OpenLux-only contract, compatibility evidence, platform examples, and user constraints, then execute the plan without changing the base Codex configuration or borrowing another OpenLux product's authentication conventions.

## Launcher Name and Suffix Contract

Use `codex-openlux` when the user provides no suffix. Its default dedicated home is `$HOME/.codex-openlux` and its profile is `openlux`. When the user provides a suffix such as `work`, use `codex-openlux-work`, dedicated home `$HOME/.codex-openlux-work`, and profile `openlux-work`. Use the equivalent `$HOME` path on Windows. Accept lowercase letters, digits, and internal hyphens. Omit the separator when the suffix is absent.

The suffix is a user-facing label only. It does not select an OpenLux token group, account, endpoint, model, automatic-routing mode, price tier, permission mode, or credential behavior. Use it only to keep the launcher, managed block, and dedicated profile file distinct. In particular, `codex-openlux-auto` must not inject an `auto` model or routing option unless separately established by current provider evidence and explicitly requested.

## Codex-OpenLux Contract

Every generated setup must satisfy these invariants:

| Concern | Required behavior |
| --- | --- |
| Ordinary Codex | Leave plain `codex` on its existing provider, base config, authentication route, and ordinary `CODEX_HOME`. |
| Provider isolation | Put OpenLux state in a fixed launcher-owned `CODEX_HOME` named `.codex-openlux[-<suffix>]`; do not read or write the ordinary Codex home and do not honor an ambient `CODEX_HOME`. |
| Auth isolation | Keep the dedicated home free of `auth.json` and copied official login state. The launcher must work only from its embedded OpenLux credential and provider profile. |
| Endpoint | Put OpenLux's currently verified Codex base URL in the dedicated profile; the verified example is `https://api.openlux.ai/v1`. |
| Protocol | Use the Responses wire API unless current OpenLux and Codex evidence establishes a replacement. |
| Authentication | Configure normal provider auth from `OPENLUX_API_KEY`, background model-discovery auth from the full `Authorization` value in `OPENLUX_AUTHORIZATION`, and `requires_openai_auth = false`. |
| Credential placement | Embed the user-provided key directly in the local launcher or managed PowerShell profile block; never put it in the tracked skill or Codex TOML. |
| Suffix | Use it only as the optional launcher/profile namespace defined above. Do not derive runtime behavior from its text. |
| Environment scope | Expose `OPENLUX_API_KEY`, `OPENLUX_AUTHORIZATION`, and the dedicated `CODEX_HOME` only to the launched Codex process. A PowerShell function must restore all three caller values. |
| Model | Pin `<verified-openlux-model>`, selected from the user's choice or current provider guidance and confirmed by an isolated Codex turn. Prefer Codex's own model/status discovery when available; never seed selection solely from historical notes or examples. |
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

The official Codex configuration reference currently places profile files beside the base config as `$CODEX_HOME/<profile-name>.config.toml` and selects them with `--profile <profile-name>`: `https://developers.openai.com/codex/config-reference/`. It documents custom-provider `base_url`, `env_key`, `env_http_headers`, `requires_openai_auth`, and the Responses-only `wire_api` value. Values in `env_http_headers` are environment-variable names whose runtime values become the complete header values; they are not literal secrets and Codex does not add `Bearer ` to them.

This procedure was verified on 2026-09-17 with `codex-cli 0.154.0`. That version loaded `openlux.config.toml` from an isolated `CODEX_HOME` with `--profile openlux`; it did not require or use a legacy `[profiles.openlux]` table in `config.toml`. On that version, an OpenLux profile inside a normal home containing official `auth.json` caused unauthenticated background `/models` requests even though the main agent request used the custom key. The same profile in an auth-free home, with an explicit environment-backed Authorization header, eliminated those `401` responses. Treat this as a versioned compatibility observation and re-test newer clients, but retain the dedicated-home boundary because it also protects the official route.

Treat installed help, current official Codex documentation, and an isolated profile-loading probe as the compatibility authority. OpenLux documentation is provider evidence, not authority for Codex's profile syntax. Do not silently migrate or delete legacy profile tables; preserve unrelated configuration and report conflicts.

## Compatibility Gate

The gate has two ordered phases. Do not use a standalone `/models` or `/responses` call as an earlier gate; Codex's actual end-to-end request is the compatibility authority.

### Phase A: Isolated Codex Test

1. Confirm the installed Codex supports `--profile` and its strongest current approval/sandbox bypass flag. On the verified version that flag was `--dangerously-bypass-approvals-and-sandbox`.
2. Create a disposable isolated `CODEX_HOME` outside the real Codex home. Do not copy `config.toml`, `auth.json`, caches, sessions, or any official-login state into it.
3. Choose the model candidate from an explicit user choice, the current OpenLux Codex guide/account UI, or Codex's own model discovery. When no justified candidate is available and Codex cannot discover one, ask the user instead of querying the provider API manually.
4. Write the test profile using that candidate, `env_key = "OPENLUX_API_KEY"`, and `env_http_headers = { "Authorization" = "OPENLUX_AUTHORIZATION" }`.
5. Scope `OPENLUX_API_KEY` to the raw key and `OPENLUX_AUTHORIZATION` to the complete `Bearer <key>` value in the test process, then run one minimal `codex --profile <profile-name> exec --skip-git-repo-check ...` turn.
6. Treat the Codex result as decisive. If Codex rejects the model and exposes a current provider model list or actionable replacement, update the disposable profile and retry once through Codex; otherwise stop and ask for a model choice or updated provider guidance. Do not translate the failure into handcrafted HTTP probes.
7. Inspect combined output in memory: fail the gate if any background model request returns `401` or `403`, even when the turn itself succeeds. Remove the disposable state afterward. Do not retry against the ordinary authenticated home; on gateways that penalize invalid tokens, that comparison can lock the valid key.

Set `<verified-openlux-model>` to the exact id that completed this isolated Codex turn.

### Phase B: Persistent Setup

Only after the isolated Codex turn and background-auth check succeed, create a persistent launcher-owned, auth-free `CODEX_HOME`, then write the provider profile and credential-bearing launcher described below. Substitute the exact `<verified-openlux-model>` from the current run; a file that still contains the placeholder is incomplete and must not be installed.

Stop and report the client-visible failure when key entitlement, endpoint, model choice, or the Codex request fails. Do not compensate with a raw API probe or by trying the key against OpenLux's Claude or Gemini routes.

Historical compatibility evidence is diagnostic context only: one OpenLux model completed an isolated Codex CLI 0.154.0 turn on 2026-09-17. That historical id is intentionally omitted because it must not influence a future model choice.

## Dedicated Provider Profile

Resolve `<provider-codex-home>` at setup time to the absolute path for `$HOME/.codex-openlux[-<suffix>]`; never derive it from an ambient runtime `CODEX_HOME`. Resolve `<profile-name>` to `openlux` or `openlux-<suffix>`, create the dedicated home with user-only access, confirm it contains no `auth.json`, then create `<provider-codex-home>/<profile-name>.config.toml` with mode `0600` on Unix:

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

This is a provider-profile shape, not a source of model selection. Replace `<verified-openlux-model>` only with the exact id that completed the current isolated Codex test. `OPENLUX_AUTHORIZATION` must contain the complete `Bearer <key>` header value at runtime; keeping it separate avoids depending on undocumented header transformation. Omit `request_max_retries` and `stream_max_retries` so the installed Codex defaults apply. Override retries only from current provider and client evidence, never with values lower than the defaults merely because an older example did so. Re-check the endpoint and timeout against current guidance and the user's needs.

The profile contains no credential. Its purpose is provider selection, endpoint, protocol, authentication variable names, and model defaults. The launcher supplies the secret, complete background Authorization value, dedicated home, and selected profile.

## Platform Lanes

| Host | Launcher | Secret scope | Profile |
| --- | --- | --- | --- |
| Linux or macOS | Executable `~/.local/bin/<launcher-name>` Bash script | Exported only in the launcher process | `$HOME/.codex-openlux[-<suffix>]/<profile-name>.config.toml` |
| Windows PowerShell | Managed `<launcher-name>` function in `$PROFILE.CurrentUserCurrentHost` | Saved, set for invocation, then restored in `finally` | `$HOME\.codex-openlux[-<suffix>]\<profile-name>.config.toml` |

Use the shell the user actually launches. Do not install a compatibility shell solely for this launcher. PowerShell 7 and Windows PowerShell can have different profile paths; modify the exact `$PROFILE.CurrentUserCurrentHost` reported by the target shell. Preserve all unrelated profile content and keep exactly one managed launcher block.

## Reference Implementations

These examples implement the launcher contract after the compatibility gate has succeeded. They do not discover or select a model. Re-check exact flags, profile behavior, executable resolution, and endpoint against the installed CLI and current OpenLux guidance before copying them. Substitute the real key only in the user's local credential-bearing file.

### Linux or macOS

Resolve `<launcher-name>` and `<profile-name>` first, then create `~/.local/bin/<launcher-name>`:

```bash
#!/usr/bin/env bash
set -euo pipefail

export OPENLUX_API_KEY='<OPENLUX_API_KEY>'
export OPENLUX_AUTHORIZATION="Bearer ${OPENLUX_API_KEY}"
export CODEX_HOME='<absolute-provider-codex-home>'
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
    $previousAuthorizationExists = Test-Path Env:OPENLUX_AUTHORIZATION
    $previousAuthorization = $env:OPENLUX_AUTHORIZATION
    $previousCodexHomeExists = Test-Path Env:CODEX_HOME
    $previousCodexHome = $env:CODEX_HOME
    $codexExitCode = $null

    try {
        $env:OPENLUX_API_KEY = '<OPENLUX_API_KEY>'
        $env:OPENLUX_AUTHORIZATION = "Bearer $env:OPENLUX_API_KEY"
        $env:CODEX_HOME = '<absolute-provider-codex-home>'

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

        if ($previousCodexHomeExists) {
            $env:CODEX_HOME = $previousCodexHome
        }
        else {
            Remove-Item Env:CODEX_HOME -ErrorAction SilentlyContinue
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
provider_codex_home='<absolute-provider-codex-home>'
bash -n "$HOME/.local/bin/<launcher-name>"
test -x "$HOME/.local/bin/<launcher-name>"
test "$(stat -c '%a' "$HOME/.local/bin/<launcher-name>")" = 700
test -d "$provider_codex_home"
test "$(stat -c '%a' "$provider_codex_home")" = 700
test "$(stat -c '%a' "$provider_codex_home/<profile-name>.config.toml")" = 600
test ! -e "$provider_codex_home/auth.json"
rg -n 'model_provider|model =|base_url|wire_api|env_key|env_http_headers|requires_openai_auth' "$provider_codex_home/<profile-name>.config.toml"
rg -q 'OPENLUX_API_KEY=' "$HOME/.local/bin/<launcher-name>"
rg -q 'OPENLUX_AUTHORIZATION=' "$HOME/.local/bin/<launcher-name>"
rg -q 'CODEX_HOME=' "$HOME/.local/bin/<launcher-name>"
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
$providerCodexHome = '<absolute-provider-codex-home>'
$providerProfile = Join-Path $providerCodexHome '<profile-name>.config.toml'
([regex]::Matches($profileText, [regex]::Escape('# >>> <launcher-name> launcher >>>'))).Count -eq 1
([regex]::Matches($profileText, [regex]::Escape('# <<< <launcher-name> launcher <<<'))).Count -eq 1
$profileText.Contains("--profile '<profile-name>'")
$profileText.Contains('--dangerously-bypass-approvals-and-sandbox')
$profileText.Contains('OPENLUX_API_KEY')
$profileText.Contains('OPENLUX_AUTHORIZATION')
$profileText.Contains('CODEX_HOME')
Test-Path -LiteralPath $providerCodexHome -PathType Container
!(Test-Path -LiteralPath (Join-Path $providerCodexHome 'auth.json'))
Get-Command <launcher-name> -CommandType Function
Select-String -LiteralPath $providerProfile -Pattern 'model_provider|model =|base_url|wire_api|env_key|env_http_headers|requires_openai_auth'
```

Do not output `$profileText`, the function definition, or matching key-assignment lines after the real key has been inserted. For an explicit permission opt-out, the permission-flag check must confirm absence instead.

### End-to-End Route Checks

1. Record whether `OPENLUX_API_KEY`, `OPENLUX_AUTHORIZATION`, and `CODEX_HOME` exist in the caller and, when present, compare their restored values without printing them.
2. Confirm the persistent profile contains the exact `<verified-openlux-model>` selected during the current compatibility gate and contains no unresolved placeholder.
3. Avoid a burst immediately after the isolated compatibility run. Honor a provider-supplied `Retry-After` or explicit cooldown message; otherwise allow a quiet interval and make one end-to-end launcher request rather than repeatedly invoking the client.
4. Run `<launcher-name> exec --skip-git-repo-check "Reply with exactly: OPENLUX_OK"` in a disposable directory when needed, keeping combined output in memory instead of a log file.
5. Confirm the run reports provider `openlux`, the selected model, approval mode `never`, and full host access for the default launcher, then returns `OPENLUX_OK` with exit code 0. Also require zero `401` or `403` model-manager refresh errors.
6. Confirm all three caller environment variables have their original presence and values after the process.
7. Inspect plain `codex` resolution, ordinary home, base config, and auth state to confirm the launcher did not alter them. Do not issue a billable official-provider completion solely for this check unless the user requests it.

Record token usage for billable compatibility and verification turns when Codex reports it.

## Key Replacement

Treat a replacement key as a new compatibility run, not a text substitution:

1. Keep the existing launcher untouched while creating a new disposable auth-free home for the replacement key. Its entitlement or model choice may differ.
2. Repeat the isolated Codex turn with both credential environment variables. Use Codex's own model/status output or current provider guidance to resolve any changed model; do not query the raw provider API.
3. Only after the Codex turn passes, update the embedded key and the pinned model together when needed. `OPENLUX_AUTHORIZATION` remains derived at runtime from the new raw key.
4. Verify in memory that the old key is absent from the launcher and that neither key appears in output. Then perform one paced end-to-end request and the plain-Codex non-billable isolation check.

## Model Metadata and Catalog Compatibility

During the 2026-09-17 compatibility snapshot, Codex CLI 0.154.0 completed an explicitly pinned OpenLux model request but warned that the model was unknown locally and fallback model metadata would be used. Treat that warning as a Codex-local model-catalog limitation when the explicit client completion succeeds. It is not evidence that the key, profile, endpoint, or Responses route failed, and the historical model id must not be reused as a default.

Fallback metadata can still degrade model-specific defaults, context sizing, or other behavior. Report the warning, keep the explicitly tested model, and re-check newer Codex versions or a provider model that Codex recognizes. Do not silence the warning by inventing a local model catalog unless the user explicitly asks for and validates one.

## Troubleshooting

- If `--profile <profile-name>` reports legacy profile configuration, move only the OpenLux layer out of `[profiles.<profile-name>]` and into the installed version's separate profile file after preserving unrelated settings.
- If plain `codex` uses OpenLux, remove accidental top-level OpenLux provider selection from the base config; the selection belongs only in the dedicated profile layer.
- If Codex asks for official login through the custom launcher, verify `requires_openai_auth = false`, `env_key = "OPENLUX_API_KEY"`, and the launcher's scoped key assignment.
- If the background model manager reports `401 Token not provided`, verify the profile's `env_http_headers` maps `Authorization` to `OPENLUX_AUTHORIZATION`, that the latter contains the complete `Bearer <key>` value in the child process, and that the dedicated home has no `auth.json`. Do not test the same key repeatedly from the ordinary authenticated home.
- If OpenLux reports that invalid tokens require a cooldown, stop all probes for the full stated interval. Check for an unset or malformed auth variable without printing it; an empty extraction result is an authentication attempt, not a harmless diagnostic.
- If a paced Codex turn intermittently returns `429` or drops streams after a previous end-to-end success, preserve the known-good configuration and report provider/upstream throttling separately. Do not churn profiles, rotate models, run raw API comparisons, or create a burst of retries as a configuration fix.
- If Codex rejects the provider route, diagnose its reported authentication, model, streaming, tool, reasoning, and storage behavior through the target CLI. A standalone HTTP success must not override the Codex failure.
- If the run succeeds with an unknown-model warning, report the fallback-metadata limitation separately from provider connectivity.
- If Windows cannot find the launcher, reload the exact PowerShell profile that was edited and compare its path with `$PROFILE.CurrentUserCurrentHost`.
- If Unix cannot find the launcher, confirm mode `0700` and that `~/.local/bin` is on `PATH`.

## Guardrails

- DO NOT put the OpenLux key in this skill, the Codex TOML profile, a git-tracked file, command history, logs, or validation output.
- DO NOT create persistent setup before the isolated Codex turn succeeds for the current key.
- DO NOT require, recommend, or use direct OpenLux `/models` or `/responses` calls as a launcher compatibility gate.
- DO NOT choose or test a model merely because it appeared in this guide, a historical note, a previous launcher, or another user's setup.
- DO NOT create the real profile or launcher until the isolated Codex test succeeds with the exact client-verified model.
- DO NOT put the persistent profile in the ordinary Codex home, copy `auth.json` into the provider home, or let an ambient `CODEX_HOME` redirect the launcher.
- DO NOT omit the environment-backed Authorization header when the installed Codex version otherwise sends unauthenticated background model discovery.
- DO NOT lower Codex's request or stream retry defaults without current provider evidence.
- DO NOT repeatedly invoke the launcher while diagnosing `401`, `429`, or connection-drop responses; each launch may create multiple provider requests.
- DO NOT use an OpenLux key from a Claude- or Gemini-only product route as evidence of Codex compatibility.
- DO NOT modify the base Codex `config.toml` or `auth.json` for the dedicated OpenLux route.
- DO NOT use a legacy `[profiles.<profile-name>]` table when the installed Codex version requires profile files.
- DO NOT replace, alias, or wrap the plain `codex` command with OpenLux behavior.
- DO NOT assign endpoint, account, token-group, model, routing, pricing, credential, or permission semantics to the optional suffix.
- DO NOT omit the default `--dangerously-bypass-approvals-and-sandbox` mode unless the initial request explicitly opts out.
- DO NOT treat a standalone API success as proof that OpenLux can execute the installed Codex client's request shape.
- DO NOT treat a local model-metadata warning as provider failure when the pinned-model completion succeeds.
- DO NOT print, commit, or expose the embedded key while creating, inspecting, testing, or reporting the launcher.
