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

# Gemini CLI OpenLux Launcher Setup

Use this reference when the user wants a Gemini CLI launcher named `gemini-openlux` or `gemini-openlux-<suffix>` that sends Gemini-native requests to OpenLux at `https://api.openlux.ai` with an arbitrary model id — including models the relay serves but does not advertise — while leaving plain `gemini` on its existing configuration and authentication route.

Terminal invocation of `imsight-dev-box-init->coding-agent->gemini-openlux-launcher()` follows this page.

## Why Gemini CLI and Not Antigravity

Gemini CLI performs no client-side catalog validation on `--model` when running with `gemini-api-key` authentication: the model string is sent to the endpoint as-is. OpenLux serves models such as `gemini-4-argon` (and its `-high`/`-low` variants) on its Gemini-native API without listing them in the advertised catalog, so a Gemini CLI launcher can use such models immediately. Antigravity validates `--model` against the relay-advertised catalog and rejects unadvertised ids; treat that client as catalog-bound (see `agy-openlux-launcher.md`) and prefer Gemini CLI when the requested model is not advertised.

## Workflow

1. Inspect the installed `gemini` version and help, the host OS and shell, current Gemini CLI settings and custom-endpoint documentation, and whether the initial request explicitly opted out of permissive mode. These are read-only checks; see **Version and Configuration Compatibility** for known version-sensitive behavior.
2. Obtain the OpenLux key under **Required Input**; stop without changing any file when the key is unavailable.
3. Resolve the optional suffix and resulting launcher name under **Launcher Name and Suffix Contract**, and resolve the default model candidate from the user's request. The candidate may be any id the relay actually serves, advertised or not. The suffix never supplies the model.
4. Complete **Phase A: Isolated Gemini CLI Test** using disposable state. Let `gemini` itself exercise a real completion with the requested model end to end.
5. Only after that target-CLI test succeeds, create the dedicated settings profile and implement every invariant in **Launcher Contract** as **Phase B: Persistent Setup**. Treat the inline templates as worked examples, not mandatory scripts.
6. Run **Verification**, including redaction-safe inspection, the default-model turn, a caller-override turn, argument forwarding, permissive mode, exit-code preservation, and the unchanged plain `gemini` route.
7. Report the launcher name, profile location, Gemini CLI version, client-verified model evidence, permission mode, and validation results without printing the key.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's naming contract, compatibility gate, profile layout, platform lanes, examples, and user constraints, then execute the plan without assigning provider behavior to the optional suffix or changing the ordinary Gemini CLI profile.

## Launcher Name and Suffix Contract

The suffix is optional and user-facing only:

| User choice | Launcher name | Dedicated profile namespace |
| --- | --- | --- |
| No suffix | `gemini-openlux` | `gemini-openlux` |
| Suffix `work` | `gemini-openlux-work` | `gemini-openlux-work` |
| Suffix `auto` | `gemini-openlux-auto` | `gemini-openlux-auto` |

When a suffix is provided, accept lowercase letters, digits, and internal hyphens. Omit the separator when the suffix is absent or empty. Ask for a portable replacement when the proposed suffix contains spaces, path separators, shell metacharacters, or uppercase characters.

The suffix has no provider or runtime meaning. It does not select a model, routing mode, token group, pricing tier, permission level, or endpoint. Use it only in the command name, profile directory, and (when the side-file credential convention applies) the shared key-file namespace. For example, `gemini-openlux-auto` does not send `model=auto`; provider-side routing must be configured and verified independently of the launcher name.

## Launcher Contract

Every generated launcher must satisfy these invariants:

| Concern | Required behavior |
| --- | --- |
| Ordinary Gemini CLI | Leave plain `gemini`, its ordinary home, settings, cached OAuth login, and user-level environment unchanged. |
| Provider profile | Give the launcher a dedicated home containing `.gemini/settings.json` with `security.auth.selectedType` set to `gemini-api-key`. Preserve unrelated fields when repairing an existing dedicated profile. |
| Endpoint | Set `GOOGLE_GEMINI_BASE_URL=https://api.openlux.ai` only for the launched process. |
| Authentication | Set `GEMINI_API_KEY` to the supplied OpenLux key only for the launched process. |
| Credential placement | Either read the key from the shared side key file (for example `$REAL_HOME/.local/bin/openlux-api-key-<suffix>`, mode 0600) or embed it in the launcher; restrict an embedding launcher to mode `0700`. Never commit or display the key. |
| Suffix | Use it only as the optional name/profile label defined above. Do not derive configuration from its text. |
| Model | Inject the resolved default as `-m <default-model>` only when the caller did not pass a model flag. Gemini CLI (yargs) collapses duplicate `-m` flags into an array, which fails the request; see **Runtime Argument Contract**. |
| Thinking effort | Default the resolved model to `thinkingLevel: "HIGH"` in the dedicated profile's `modelConfigs.overrides`. Add a separate exact-match override for each additional served model id; never infer thinking behavior from the launcher suffix. |
| Arguments | Forward every caller argument to `gemini` unchanged after the fixed defaults. |
| Permissions | Inject `--approval-mode yolo` and `--skip-trust` by default. Omit them only when the user's initial launcher request explicitly asks to retain permission prompts. |
| Executable | Resolve the real installed `gemini` binary without selecting the wrapper itself. |
| Exit status | Preserve Gemini CLI's exit status (`exec` on Unix). |

The endpoint and authentication lane are specific to OpenLux's Gemini-native API. The permissive launcher default comes from the coding-agent subskill's shared policy and does not authorize unrelated host changes.

## Required Input

The setup requires an OpenLux API key that can use the provider's Gemini-native API. Keep it in memory while generating the launcher and represent it as `<OPENLUX_API_KEY>` in documentation, diffs, logs, and examples.

When the host already keeps OpenLux keys in side files next to the launchers (mode 0600), prefer reading that file at runtime and keep the launcher key-free. Otherwise embed the key in the launcher by design, tell the user before generation when they have not already requested embedded credentials, and restrict the file to mode `0700`. Never print the resulting credential assignment, commit it, or reuse the key outside the requested host and launcher family.

The suffix is optional. Do not ask for one when the user requests `gemini-openlux` or gives no reason to distinguish multiple launchers. If the user supplies a suffix, apply only the naming behavior above.

## Version and Configuration Compatibility

Before implementation, inspect and update Gemini CLI when requested:

```text
gemini --version
gemini --help
```

Install channels are npm and bun globals (`@google/gemini-cli`). A known failure mode: the bun global package is present but its bin shim is missing, so PATH falls through to a stale system copy (for example a root-owned npm install). Repair with `bun install -g @google/gemini-cli@<version>` and confirm `command -v gemini` resolves to the bun shim. Do not edit or remove a root-owned system copy; let PATH ordering shadow it.

Version-sensitive behavior verified on Gemini CLI 0.64.0 (2026-10-19, bun install):

- `--approval-mode yolo` is the permissive flag (older releases used `--yolo`); `-m/--model`, `-p/--prompt` are unchanged.
- A workspace-trust gate overrides the approval mode for headless runs in untrusted directories; `--skip-trust` disables that gate. Without it the launcher silently loses yolo outside trusted folders.
- The IDE companion integration auto-enables and writes `ide.enabled: true` plus `hasSeenIdeIntegrationNudge` back into the profile; it spams directory-mismatch errors when another workspace is open in the IDE. Disable it in the profile.
- Inline-mode TUI rendering corrupts the display on terminal/tmux resize (stale footer fragments, duplicated rows; upstream issues google-gemini/gemini-cli#17289 and #23242). `ui.useAlternateBuffer: true` in the profile eliminates it; with the alternate buffer the UI leaves no scrollback on exit and in-session scrolling belongs to the TUI.
- Duplicate `-m` flags collapse into an array value and the request fails with a generic client error; inject the default model conditionally.

Treat this snapshot as version-specific evidence, not a permanent guarantee; re-run the target-CLI gate when the installed version differs.

## Compatibility Gate

The gate has two ordered phases. Do not require a handcrafted `/models` or `generateContent` request before the target client runs, and do not treat the relay's advertised catalog as evidence either way: OpenLux may serve models it does not list. Gemini CLI's own end-to-end result is the compatibility authority.

### Phase A: Isolated Gemini CLI Test

1. Confirm `gemini --version` and inspect current help for the permission, trust, model, and non-interactive surfaces needed by the installed version.
2. Create a disposable home (for example `mktemp -d`) containing `.gemini/settings.json` with the exact profile body from **Dedicated Profile Layout**, substituting the requested model for `<resolved-default-model>`, so the test exercises the persisted settings verbatim.
3. Scope the supplied key and base URL only to this test process.
4. Run one minimal real turn with the requested model:

```bash
HOME="$tmp_home" \
GEMINI_API_KEY="$key" \
GOOGLE_GEMINI_BASE_URL='https://api.openlux.ai' \
gemini --approval-mode yolo --skip-trust -m <requested-model> \
  -p "Reply with exactly: GEMINI_OPENLUX_OK"
```

5. Require the marker in the response. When the requested model is unadvertised, this turn is the only accepted proof; a missing catalog entry is not a failure and a raw curl success is not a substitute.
6. Remove the disposable state afterward. If the target CLI fails, stop and report its client-visible authentication, trust, model, or protocol failure; do not write persistent setup.

Disposable settings are allowed because they make the real target client test possible. They must be isolated from the user's ordinary Gemini CLI home and must not become the persistent launcher profile unless the complete turn succeeds.

### Phase B: Persistent Setup

Only after the isolated Gemini CLI request succeeds may the workflow create or merge the dedicated settings profile and the launcher below.

## Dedicated Profile Layout

Use the full launcher name as the profile namespace:

| Platform | Dedicated home | Settings file |
| --- | --- | --- |
| Linux/macOS | `$REAL_HOME/.local/share/gemini-profiles/<launcher-name>` | `<dedicated-home>/.gemini/settings.json` |
| Windows | `%LOCALAPPDATA%\gemini-profiles\<launcher-name>` | `<dedicated-home>\.gemini\settings.json` |

For a new dedicated profile, start with:

```json
{
  "general": {
    "enableAutoUpdate": false
  },
  "ide": {
    "enabled": false
  },
  "security": {
    "auth": {
      "selectedType": "gemini-api-key"
    }
  },
  "ui": {
    "useAlternateBuffer": true
  },
  "modelConfigs": {
    "overrides": [
      {
        "match": {
          "model": "<resolved-default-model>"
        },
        "modelConfig": {
          "generateContentConfig": {
            "thinkingConfig": {
              "thinkingLevel": "HIGH"
            }
          }
        }
      }
    ]
  }
}
```

Field roles: the `selectedType` pin is mandatory — without it a user-level `oauth-personal` selection overrides `GEMINI_API_KEY` and the CLI goes down the Code Assist path, failing with a demand for `GOOGLE_CLOUD_PROJECT`. `ide.enabled` and `ui.useAlternateBuffer` counter the 0.64.0 behaviors listed above; `enableAutoUpdate: false` keeps updates deliberate. `modelConfigs.overrides` defaults the resolved model to high thinking: replace `<resolved-default-model>` with the actual default model id when creating the profile, and add another override for any other served id that should also use high thinking. The CLI forwards `thinkingConfig` with minimal validation; the endpoint remains the authority and may clamp or ignore it, so a successful turn is not proof of enforcement. When repairing an existing dedicated profile, parse and merge these fields instead of replacing the file; the CLI writes state (for example `hasSeenNudge`) back into the profile, so byte-exact comparison is wrong. Do not copy the ordinary Gemini CLI settings wholesale because that can import the OAuth pin, saved model, permission policy, or unrelated experiments into the OpenLux route.

## Platform Lanes

| Host | Native launcher | Environment behavior |
| --- | --- | --- |
| Linux | Executable Bash launcher, normally under `$REAL_HOME/.local/bin/` | Resolve `gemini`, then export the dedicated `HOME`, key, and base URL before `exec`. |
| macOS | Executable Bash or Zsh-compatible launcher, normally under `$REAL_HOME/.local/bin/` | Use the same process contract as Linux; use macOS-native permission inspection during verification. |
| Windows PowerShell | Managed function in `$PROFILE.CurrentUserCurrentHost` | Resolve `gemini`, save the caller's variables, set the dedicated `HOME` and `USERPROFILE` plus provider variables, restore all values in `finally`, and preserve `$LASTEXITCODE`. Follow the block shape in `agy-openlux-launcher.md`, substituting the Gemini profile root and variables. |

Use the shell the user actually launches. Do not install a compatibility shell solely for this launcher. The Linux lane is the verified one; verify the others against the installed client before relying on them.

## Reference Implementation (Linux and macOS)

For `<launcher-name>` equal to `gemini-openlux` or `gemini-openlux-<suffix>`, create the dedicated settings file first, then write this launcher to `$REAL_HOME/.local/bin/<launcher-name>`:

```bash
#!/usr/bin/env bash
set -euo pipefail

real_home="${HOME:?HOME is required}"
launcher_name='<launcher-name>'
profile_home="$real_home/.local/share/gemini-profiles/$launcher_name"
default_model='<resolved-default-model>'

key_file="$real_home/.local/bin/openlux-api-key-<suffix>"   # shared side key file, mode 0600
if [[ ! -f "$key_file" ]]; then
  echo "$launcher_name: key file $key_file missing; store your OpenLux key there" >&2
  exit 1
fi

gemini_bin="$(command -v gemini || true)"
if [[ -z "$gemini_bin" ]]; then
  echo "$launcher_name: gemini binary not found" >&2
  exit 127
fi

export HOME="$profile_home"
export GEMINI_API_KEY="$(tr -d '[:space:]' < "$key_file")"
export GOOGLE_GEMINI_BASE_URL='https://api.openlux.ai'

has_model=0
for arg in "$@"; do
  case "$arg" in
    -m|--model|--model=*|-m=*) has_model=1 ;;
  esac
done

default_args=(--approval-mode yolo --skip-trust)
if [[ "$has_model" -eq 0 ]]; then
  default_args+=(-m "$default_model")
fi

exec "$gemini_bin" "${default_args[@]}" "$@"
```

Apply mode `0775` when the launcher reads the side key file, or `0700` when it embeds the key (substitute `export GEMINI_API_KEY='<OPENLUX_API_KEY>'` and drop the `key_file` block). Put `$REAL_HOME/.local/bin` on PATH using the user's actual shell startup file only when a fresh interactive shell cannot resolve the launcher. For an explicit permission-prompting opt-out, omit only `--approval-mode yolo` and `--skip-trust`.

Do not turn `<suffix>` into a runtime variable. Resolve the complete launcher name and default model at setup time and bake that neutral name/profile namespace into the local file.

## Runtime Argument Contract

Every argument supplied after the launcher name belongs to Gemini CLI. The wrapper prepends only the permission defaults and, when absent from the caller's arguments, the default model; it must not parse, rename, reorder, consume, or reinterpret other `gemini` arguments.

The conditional `-m` injection exists because yargs merges repeated string flags into an array: an unconditional launcher `-m` plus a caller `-m` reaches the CLI as an invalid array model value and the turn fails with a generic client error. The launcher must detect `-m`, `--model`, `--model=*`, and `-m=*` in the caller's arguments and skip its own injection when present.

The optional launcher suffix is already resolved before runtime. The launcher must never forward it as a model, profile, endpoint, or routing option.

## Isolated-Home Effects

Gemini CLI reads provider selection and auth type from a home-relative settings file, so preserving plain `gemini` requires the custom launcher to give Gemini CLI a dedicated home. Commands and tools started by that Gemini CLI process inherit the same home variables. They may therefore miss home-relative Git configuration, SSH keys, cloud credentials, shell files, or agent skills from the ordinary home.

Treat this as an explicit tradeoff, not an implementation accident. Keep the isolated `.gemini` tree private to the launcher. When the user needs selected ordinary-home resources, link or copy only the exact resource they authorize after resolving its security implications; do not merge the entire ordinary home or point the dedicated `.gemini` directory back at the default profile.

## Verification

Verify structure without displaying the key.

```bash
bash -n "$HOME/.local/bin/<launcher-name>"
test -x "$HOME/.local/bin/<launcher-name>"
grep -q "GOOGLE_GEMINI_BASE_URL='https://api.openlux.ai'" "$HOME/.local/bin/<launcher-name>"
grep -q -- '--approval-mode yolo --skip-trust' "$HOME/.local/bin/<launcher-name>"
command -v <launcher-name>
```

Confirm only the presence of the key assignment or key-file read; never output the matching line after substitution. For an embedding launcher also require mode `0700`.

For every platform:

1. Confirm the dedicated settings file parses and contains `security.auth.selectedType: gemini-api-key` (plus the `ide`, `ui`, and `general` fields from the profile template) and a `modelConfigs.overrides` entry matching the default model with `thinkingConfig.thinkingLevel: "HIGH"`.
2. Run one small completion through the launcher: `<launcher-name> -p "Reply with exactly: GEMINI_OPENLUX_OK"`. Require the marker. This confirms the CLI accepts and forwards the configured override; the endpoint may still clamp or ignore it.
3. Run the caller-override path: `<launcher-name> -m <second-served-model> -p "Reply with exactly: OVERRIDE_OK"`. Require the marker; this proves the conditional injection does not corrupt the model argument.
4. Confirm the process exit status propagates and that the default invocation advertises yolo mode unless the initial request opted out.
5. Confirm plain `gemini` still uses its pre-existing settings and OAuth route. Do not perform a billable official-provider completion unless the user requested it; inspect settings (content and mtime) and environment instead.
6. Confirm the parent shell never received the launcher's exports.

Record token usage for billable probes when the CLI reports it.

## Troubleshooting

- If the turn fails demanding `GOOGLE_CLOUD_PROJECT` or lands in `code_assist`, the OAuth pin won: verify the dedicated settings file contains `security.auth.selectedType: gemini-api-key` and that the launcher exports the dedicated `HOME` before `exec`.
- If `gemini --version` reports an unexpected old version, check for the missing bun bin shim failure mode and repair with `bun install -g`; confirm `command -v gemini` resolves to the intended install.
- If headless runs warn about untrusted folders or lose auto-approval, the launcher is missing `--skip-trust` (0.64.0 and later).
- If the TUI scrambles on terminal or tmux resize, set `ui.useAlternateBuffer: true` in the dedicated profile.
- If a turn fails with a generic client error only when the caller passes `-m`, inspect the launcher's conditional model injection for a duplicate-flag array.
- If HIGH thinking is configured but response behavior does not change, the relay may clamp or ignore `thinkingConfig` for that model id. Confirm the override's `match.model` is the exact model string and treat enforcement as provider-side. For a model that accepts `thinkingBudget` instead of `thinkingLevel`, use an explicitly high numeric budget and record that choice.
- If the relay rejects a turn with a model-not-found or schema error (for example `Unknown name ... tools[0].function_declarations`), the failure is provider-side for that model or routing channel: the client passes any id through, and the endpoint decides. Verify the id with a fresh Phase A turn or pick another served id; do not treat a missing catalog entry as proof either way.
- If ordinary Git, SSH, cloud, or skill discovery is missing inside the launcher, review **Isolated-Home Effects** and add only the user-authorized resources needed by that profile.

## Guardrails

- DO NOT treat the relay's advertised model catalog as exhaustive or validate the requested model against it; the target-CLI turn is the compatibility authority.
- DO NOT replace or alias the plain `gemini` command, modify its ordinary settings or OAuth login, or persist OpenLux variables at user or system scope.
- DO NOT print, commit, or expose the OpenLux key during generation, inspection, testing, or reporting.
- DO NOT inject `-m` when the caller already passed a model flag.
- DO NOT assign endpoint, model, routing, pricing, credential, or permission semantics to the optional suffix.
- DO NOT omit `--approval-mode yolo` or `--skip-trust` unless the user's initial launcher request explicitly opts out of permissive mode.
- DO NOT require, recommend, or use direct OpenLux `/models` or `generateContent` calls as launcher compatibility evidence.
- DO NOT create the real dedicated profile or launcher until an isolated Gemini CLI request succeeds.
- DO NOT edit a root-owned system `gemini` install to fix version shadowing; repair the user-owned install and let PATH order resolve it.
