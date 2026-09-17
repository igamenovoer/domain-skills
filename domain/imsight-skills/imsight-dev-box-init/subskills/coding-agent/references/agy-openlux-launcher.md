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

# Antigravity-OpenLux Launcher Setup

Use this reference when the user wants an Antigravity CLI launcher named `agy-openlux` or `agy-openlux-<suffix>` that sends Gemini-native requests to OpenLux at `https://api.openlux.ai` while leaving plain `agy` on its existing configuration and authentication route.

Terminal invocation of `imsight-dev-box-init->coding-agent->agy-openlux-launcher()` follows this page.

## Workflow

1. Inspect the installed `agy` version and help, the host OS and shell, current Antigravity custom-endpoint documentation, and whether the initial request explicitly opted out of permissive mode. These are read-only checks.
2. Obtain the OpenLux key under **Required Input**; stop without changing any file when the key is unavailable.
3. Resolve the current endpoint, authentication lane, and any requested model candidate from the user's request plus current Antigravity and OpenLux documentation. Do not call OpenLux APIs directly as a preflight.
4. Resolve the optional suffix and resulting launcher name, then complete **Phase A: Isolated Antigravity Test** using disposable state. Let `agy` itself exercise model discovery and a real completion end to end.
5. Only after that target-CLI test succeeds, create or merge the dedicated settings profile and implement every invariant in **Launcher Contract** as **Phase B: Persistent Setup**. Treat the inline templates as worked examples, not mandatory scripts.
6. Run **Verification**, including redaction-safe inspection, endpoint and model compatibility, argument forwarding, permissive mode, exit-code preservation, and the unchanged plain `agy` route.
7. Report the launcher name, profile location, Antigravity version, client-verified model evidence, permission mode, and validation results without printing the key.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's naming contract, compatibility gate, platform lanes, examples, and user constraints, then execute the plan without assigning provider behavior to the optional suffix or changing the ordinary Antigravity profile.

## Launcher Name and Suffix Contract

The suffix is optional and user-facing only:

| User choice | Launcher name | Dedicated profile namespace |
| --- | --- | --- |
| No suffix | `agy-openlux` | `agy-openlux` |
| Suffix `work` | `agy-openlux-work` | `agy-openlux-work` |
| Suffix `auto` | `agy-openlux-auto` | `agy-openlux-auto` |

When a suffix is provided, accept lowercase letters, digits, and internal hyphens. Omit the separator when the suffix is absent or empty. Ask for a portable replacement when the proposed suffix contains spaces, path separators, shell metacharacters, or uppercase characters.

The suffix has no provider or runtime meaning. It does not select a model, enable automatic model routing, identify an OpenLux token group, encode pricing, change permissions, or alter the endpoint. Use it only in the command name, managed-block marker, and dedicated profile directory so users can distinguish several launchers. For example, `agy-openlux-auto` does not send `model=auto`; provider-side routing must be configured and verified independently of the launcher name.

## Launcher Contract

Every generated launcher must satisfy these invariants:

| Concern | Required behavior |
| --- | --- |
| Ordinary Antigravity | Leave plain `agy`, its ordinary home, settings, cached login, and user-level environment unchanged. |
| Provider profile | Give the launcher a dedicated home containing `.gemini/antigravity-cli/settings.json` with `modelProvider` set to `gemini`. Preserve unrelated fields when repairing an existing dedicated profile. |
| Endpoint | Set `GOOGLE_GEMINI_BASE_URL=https://api.openlux.ai` only for the launched process. Do not use the legacy `GEMINI_BASE_URL` spelling. |
| Authentication | Set `GEMINI_API_KEY` to the supplied OpenLux key only for the launched process. |
| Credential placement | Embed the key in the local credential-bearing launcher or managed PowerShell block. Restrict Unix launchers to mode `0700`; never commit or display the generated launcher. |
| Suffix | Use it only as the optional name/profile label defined above. Do not derive configuration from its text. |
| Model | Do not inject `--model` by default. Let Antigravity select its normal Gemini API-key model unless the user explicitly requests a tested model. A provider-side router remains an OpenLux concern. |
| Arguments | Forward every caller argument to `agy` unchanged after the fixed permission default. |
| Permissions | Inject `--dangerously-skip-permissions` by default. Omit it only when the user's initial launcher request explicitly asks to retain permission prompts. |
| Executable | Resolve the real installed `agy` binary without selecting the wrapper itself. |
| Exit status | Preserve Antigravity's exit status. |

The endpoint and authentication lane are specific to OpenLux's Gemini-native API. The permissive launcher default comes from the coding-agent subskill's shared policy and does not authorize unrelated host changes.

## Required Input

The setup requires an OpenLux API key that can use the provider's Gemini-native API. Keep it in memory while generating the launcher and represent it as `<OPENLUX_API_KEY>` in documentation, diffs, logs, and examples.

The generated Unix launcher or Windows PowerShell profile block contains the key in plaintext by design. Tell the user before generation when they have not already requested embedded credentials. Never print the resulting credential assignment, commit the launcher, or reuse the key outside the requested host and launcher family.

The suffix is optional. Do not ask for one when the user requests `agy-openlux` or gives no reason to distinguish multiple settings. If the user supplies a suffix, apply only the naming behavior above.

## Version and Configuration Compatibility

Before implementation, inspect and update Antigravity when requested:

```text
agy --version
agy --help
agy update
```

The official installers currently use `https://antigravity.google/cli/install.sh` on Linux/macOS and `https://antigravity.google/cli/install.ps1` or `install.cmd` on Windows. Treat those vendor installers as version-specific examples: use the installed CLI's own updater when available, verify the resulting version, and do not assume a copied installer command remains current.

Antigravity's documented Gemini API-key route requires both of these elements:

```json
{
  "modelProvider": "gemini"
}
```

```text
GEMINI_API_KEY=<OPENLUX_API_KEY>
GOOGLE_GEMINI_BASE_URL=https://api.openlux.ai
```

Setting only `GEMINI_API_KEY` is insufficient. The documented settings path is `~/.gemini/antigravity-cli/settings.json`, and current Antigravity documentation does not expose a named-profile or settings-path flag. This guide therefore gives each launcher an isolated home. That isolation also affects home-relative paths seen by Antigravity and tools it starts; see **Isolated-Home Effects** before linking or copying any developer credentials into it.

Re-check the official Antigravity installation/authentication and settings pages before implementation:

- `https://antigravity.google/docs/cli-install`
- `https://antigravity.google/docs/cli/settings`
- `https://antigravity.google/docs/cli/headless`

Re-check OpenLux's current Gemini-native documentation rather than assuming its OpenAI- or Anthropic-compatible surfaces imply Antigravity compatibility:

- `https://doc.openlux.ai/`

## Compatibility Gate

The gate has two ordered phases. Do not require a handcrafted `/models` or `generateContent` request before the target client runs. Antigravity's own end-to-end result is the compatibility authority because client versions can change request shapes, authentication behavior, discovery, streaming, tools, and thinking metadata.

### Phase A: Isolated Antigravity Test

1. Confirm `agy --version` and inspect current help for the permission, model, non-interactive, and model-listing surfaces needed by the installed version.
2. Derive the endpoint, environment-variable names, provider setting, and any requested model candidate from current documentation and the user's request. Do not infer a model from the launcher suffix or a historical snapshot.
3. Create a disposable home with the minimal Antigravity settings required for the Gemini provider. Scope the supplied key and base URL only to this test process.
4. Use `agy models`, or the current client-equivalent discovery surface, when model selection needs inspection. Treat only models that the installed target CLI can actually use as candidates.
5. Run one minimal real `agy --print` turn through the disposable home. If the user requested a model pin, pass that exact candidate through `agy` and require the turn to succeed. Otherwise let Antigravity and the relay negotiate without inventing a pin.
6. If the requested behavior depends on OpenLux automatic routing, validate that behavior through the actual Antigravity turn and current provider-account documentation. A suffix such as `auto` is not evidence, and an unsupported literal `model=auto` must not be injected as a workaround.
7. Remove the disposable state afterward. If the target CLI fails, stop and report its client-visible authentication, model, or protocol failure; do not substitute a separate raw API probe.

Disposable settings are allowed because they make the real target client test possible. They must be isolated from the user's ordinary Antigravity home and must not become the persistent launcher profile unless the complete turn succeeds.

### Phase B: Persistent Setup

Only after the isolated Antigravity request succeeds may the workflow create or merge the dedicated settings profile and credential-bearing launcher below.

Verified snapshot, not a permanent guarantee: on 2026-09-17, Antigravity CLI 1.2.5 completed an isolated OpenLux turn through `https://api.openlux.ai` with no launcher-level model pin. A literal model id of `auto` was rejected by that installed client. Re-run the target-CLI gate instead of treating those observations as current forever.

## Dedicated Profile Layout

Use the full launcher name as the profile namespace:

| Platform | Dedicated home | Settings file |
| --- | --- | --- |
| Linux/macOS | `$REAL_HOME/.local/share/agy-profiles/<launcher-name>` | `<dedicated-home>/.gemini/antigravity-cli/settings.json` |
| Windows | `%LOCALAPPDATA%\agy\profiles\<launcher-name>` | `<dedicated-home>\.gemini\antigravity-cli\settings.json` |

For a new dedicated profile, start with:

```json
{
  "modelProvider": "gemini",
  "enableTelemetry": false
}
```

When repairing an existing dedicated profile, parse and merge this field instead of replacing the file. Do not copy the ordinary Antigravity settings wholesale because that can import a saved model, permission policy, provider state, or unrelated experiments into the OpenLux route.

## Platform Lanes

| Host | Native launcher | Environment behavior |
| --- | --- | --- |
| Linux | Executable Bash launcher, normally under `$REAL_HOME/.local/bin/` | Resolve `agy`, then export the dedicated `HOME`, key, and base URL before `exec`. |
| macOS | Executable Bash or Zsh-compatible launcher, normally under `$REAL_HOME/.local/bin/` | Use the same process contract as Linux; use macOS-native permission inspection during verification. |
| Windows PowerShell | Managed function in `$PROFILE.CurrentUserCurrentHost` | Resolve `agy.exe`, save the caller's variables, set the dedicated `HOME` and `USERPROFILE` plus provider variables, restore all values in `finally`, and preserve `$LASTEXITCODE`. |

Use the shell the user actually launches. Do not install a compatibility shell solely for this launcher. On Windows, PowerShell 7 and Windows PowerShell use different profile paths; edit the exact `$PROFILE.CurrentUserCurrentHost` reported by the target shell and keep one managed block per launcher name.

## Reference Implementations

These templates demonstrate the contract for the currently verified Antigravity and OpenLux behavior. Substitute the resolved launcher name and real key only in the user's local files. Re-check flags, environment variables, provider behavior, and paths before copying them.

### Linux and macOS

For `<launcher-name>` equal to `agy-openlux` or `agy-openlux-<suffix>`, create the dedicated settings file first, then write this credential-bearing launcher to `$REAL_HOME/.local/bin/<launcher-name>`:

```bash
#!/usr/bin/env bash
set -euo pipefail

real_home="${HOME:?HOME is required}"
launcher_name='<launcher-name>'
profile_home="$real_home/.local/share/agy-profiles/$launcher_name"

agy_bin="$(command -v agy || true)"
if [[ -z "$agy_bin" ]]; then
  echo "$launcher_name: agy binary not found" >&2
  exit 127
fi

export HOME="$profile_home"
export GEMINI_API_KEY='<OPENLUX_API_KEY>'
export GOOGLE_GEMINI_BASE_URL='https://api.openlux.ai'

exec "$agy_bin" --dangerously-skip-permissions "$@"
```

Apply mode `0700`. Put `$REAL_HOME/.local/bin` on PATH using the user's actual shell startup file only when a fresh interactive shell cannot resolve the launcher. For an explicit permission-prompting opt-out, omit only `--dangerously-skip-permissions` from the final `exec` line.

Do not turn `<suffix>` into a runtime variable. Resolve the complete launcher name at setup time and bake that neutral name/profile namespace into the local file.

### Windows PowerShell

Create the dedicated settings file under `%LOCALAPPDATA%\agy\profiles\<launcher-name>` and add one managed block to `$PROFILE.CurrentUserCurrentHost`. Replace `<launcher-name>` in the function name, marker, and profile directory before writing it:

```powershell
# >>> <launcher-name> launcher >>>
function <launcher-name> {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [object[]]$ForwardArgs
    )

    $agyCommand = Get-Command agy.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1
    $openLuxProfileRoot = Join-Path $env:LOCALAPPDATA 'agy\profiles\<launcher-name>'

    $previousHomeExists = Test-Path Env:HOME
    $previousUserProfileExists = Test-Path Env:USERPROFILE
    $previousKeyExists = Test-Path Env:GEMINI_API_KEY
    $previousBaseUrlExists = Test-Path Env:GOOGLE_GEMINI_BASE_URL
    $previousHome = $env:HOME
    $previousUserProfile = $env:USERPROFILE
    $previousKey = $env:GEMINI_API_KEY
    $previousBaseUrl = $env:GOOGLE_GEMINI_BASE_URL
    $agyExitCode = $null

    try {
        $env:HOME = $openLuxProfileRoot
        $env:USERPROFILE = $openLuxProfileRoot
        $env:GEMINI_API_KEY = '<OPENLUX_API_KEY>'
        $env:GOOGLE_GEMINI_BASE_URL = 'https://api.openlux.ai'

        & $agyCommand.Source --dangerously-skip-permissions @ForwardArgs
        $agyExitCode = $LASTEXITCODE
    }
    finally {
        if ($previousHomeExists) { $env:HOME = $previousHome } else { Remove-Item Env:HOME -ErrorAction SilentlyContinue }
        if ($previousUserProfileExists) { $env:USERPROFILE = $previousUserProfile } else { Remove-Item Env:USERPROFILE -ErrorAction SilentlyContinue }
        if ($previousKeyExists) { $env:GEMINI_API_KEY = $previousKey } else { Remove-Item Env:GEMINI_API_KEY -ErrorAction SilentlyContinue }
        if ($previousBaseUrlExists) { $env:GOOGLE_GEMINI_BASE_URL = $previousBaseUrl } else { Remove-Item Env:GOOGLE_GEMINI_BASE_URL -ErrorAction SilentlyContinue }
    }

    if ($null -ne $agyExitCode) {
        $global:LASTEXITCODE = $agyExitCode
    }
}
# <<< <launcher-name> launcher <<<
```

For an explicit permission-prompting opt-out, omit only `--dangerously-skip-permissions` from the invocation. Create the profile file first if needed, preserve all unrelated profile content, and replace an existing matching managed block instead of appending a duplicate.

## Runtime Argument Contract

Every argument supplied after the launcher name belongs to Antigravity. The wrapper prepends only the default permission flag and must not parse, rename, reorder, consume, or reinterpret `agy` arguments.

These forms must remain valid when supported by the installed version:

```text
agy-openlux
agy-openlux --version
agy-openlux --output-format json --print="Reply with exactly: OPENLUX_OK"
agy-openlux-work --model <tested-agy-model> --effort high
```

The optional launcher suffix is already resolved before runtime. The launcher must never forward it as a model, profile, agent, endpoint, or OpenLux routing option.

## Isolated-Home Effects

Antigravity currently reads provider selection from a home-relative settings file, so preserving plain `agy` requires the custom launcher to give Antigravity a dedicated home. Commands and tools started by that Antigravity process inherit the same home variables. They may therefore miss home-relative Git configuration, SSH keys, cloud credentials, shell files, or agent skills from the ordinary home.

Treat this as an explicit tradeoff, not an implementation accident. Keep the isolated `.gemini` tree private to the launcher. When the user needs selected ordinary-home resources, link or copy only the exact resource they authorize after resolving its security implications; do not merge the entire ordinary home or point the dedicated `.gemini` directory back at the default profile.

On Windows, the PowerShell function restores the caller's `HOME`, `USERPROFILE`, `GEMINI_API_KEY`, and `GOOGLE_GEMINI_BASE_URL` after `agy` exits. That restoration protects the caller but does not change the isolated home seen by tools during the Antigravity session.

## Verification

Verify structure without displaying the key.

### Linux

```bash
bash -n "$HOME/.local/bin/<launcher-name>"
test -x "$HOME/.local/bin/<launcher-name>"
test "$(stat -c '%a' "$HOME/.local/bin/<launcher-name>")" = 700
rg -q 'GEMINI_API_KEY=' "$HOME/.local/bin/<launcher-name>"
rg -q -F "GOOGLE_GEMINI_BASE_URL='https://api.openlux.ai'" "$HOME/.local/bin/<launcher-name>"
rg -q -- '--dangerously-skip-permissions' "$HOME/.local/bin/<launcher-name>"
command -v <launcher-name>
```

### macOS

Use the Linux checks except for the file-mode command:

```bash
test "$(stat -f '%Lp' "$HOME/.local/bin/<launcher-name>")" = 700
```

### Windows PowerShell

```powershell
$profilePath = $PROFILE.CurrentUserCurrentHost
$profileText = Get-Content -Raw -LiteralPath $profilePath
([regex]::Matches($profileText, [regex]::Escape('# >>> <launcher-name> launcher >>>'))).Count -eq 1
([regex]::Matches($profileText, [regex]::Escape('# <<< <launcher-name> launcher <<<'))).Count -eq 1
$profileText.Contains('GOOGLE_GEMINI_BASE_URL')
$profileText.Contains('--dangerously-skip-permissions')
Get-Command <launcher-name> -CommandType Function
```

Confirm only the presence of the key assignment; never output the function or matching key line after substitution. Parse the PowerShell profile before dot-sourcing it, then open a fresh shell and verify the function resolves.

For every platform:

1. Confirm the dedicated settings file parses and contains `modelProvider: gemini`.
2. Run `<launcher-name> models`, or the installed client's equivalent, and confirm that the client exposes at least one usable model or its normal unpinned route.
3. Run one small completion: `<launcher-name> --output-format json --print="Reply with exactly: AGY_OPENLUX_OK"`.
4. Confirm the process exits successfully, arguments arrive unchanged, and the default invocation includes `--dangerously-skip-permissions` unless the initial request opted out.
5. Confirm plain `agy` still uses its pre-existing settings and authentication route. Do not perform a billable official-provider completion unless the user requested it; inspect settings and environment first.
6. On Windows, confirm the four caller environment variables have the same presence and values after the launcher exits. On Unix, confirm the parent shell never received the launcher's exports.

Record token usage for billable probes when the CLI reports it.

## Troubleshooting

- If the launcher opens Google sign-in or ignores the key, verify the dedicated settings file contains exactly the recognized `modelProvider` value `gemini` and that the launcher exports `GEMINI_API_KEY`.
- If requests still go to Google, verify the variable name is `GOOGLE_GEMINI_BASE_URL`, not `GEMINI_BASE_URL`, and confirm the settings file is under the dedicated home actually passed to `agy`.
- If `agy` rejects a model locally, use a slug listed by the installed `agy models`; do not assume every OpenLux model id is accepted by Antigravity.
- If model discovery succeeds but the Antigravity turn fails, diagnose the client-visible request, streaming, tools, thinking metadata, model mapping, and token entitlement. Discovery success alone does not prove agent compatibility, and a raw provider call must not override the client failure.
- If the launcher suffix is `auto`, do not inject `model=auto`. Verify provider-side routing separately or explain that the suffix is only a friendly label.
- If ordinary Git, SSH, cloud, or skill discovery is missing inside the launcher, review **Isolated-Home Effects** and add only the user-authorized resources needed by that profile.
- If Windows cannot find the function, reload the exact profile modified during setup and compare its path with `$PROFILE.CurrentUserCurrentHost`.

## Guardrails

- DO NOT assign endpoint, model, routing, pricing, credential, or permission semantics to the optional suffix.
- DO NOT require, recommend, or use direct OpenLux `/models` or `generateContent` calls as launcher compatibility evidence.
- DO NOT create the real dedicated profile or launcher until an isolated Antigravity request succeeds.
- DO NOT choose a model from a historical note, suffix, or another client's model catalog.
- DO NOT replace or alias the plain `agy` command, modify its ordinary settings, or persist OpenLux variables at user or system scope.
- DO NOT use `GEMINI_BASE_URL` in place of `GOOGLE_GEMINI_BASE_URL`.
- DO NOT omit `modelProvider: gemini` from the dedicated settings profile.
- DO NOT pin a model by default or treat a provider model-list response as proof that Antigravity requests work.
- DO NOT omit `--dangerously-skip-permissions` unless the user's initial launcher request explicitly opts out of permissive mode.
- DO NOT print, commit, or expose the embedded OpenLux key during generation, inspection, testing, or reporting.
- DO NOT hide the home-isolation effect from the user or copy unrelated ordinary-home credentials into the dedicated profile.
