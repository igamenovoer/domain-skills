---
name: coding-agent
description: Use when an Imsight dev-box task configures Codex CLI, third-party Codex providers, Claude Code launchers for Kimi, GAC, or OpenLux, Antigravity CLI launchers for OpenLux, or Kimi Code CLI multi-credential launchers with an isolated KIMI_CODE_HOME.
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

# Coding Agent Setup

## Overview

Use this subskill for coding-agent configuration owned by Imsight dev-box setup.

## Workflow

1. Select the applicable command from **Subcommands**.
2. Load its linked reference and resolve any nested command there.
3. Follow the reference's prerequisites, configuration procedure, and verification steps.
4. Report the configured agent route and any remaining user action.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this subskill's commands, resources, constraints, and user request, then execute the plan.

## Invocation Contract

- Invoke `imsight-dev-box-init->coding-agent` to summarize this subskill.
- Invoke a command as `imsight-dev-box-init->coding-agent-><subcommand>()`.
- Invoke `imsight-dev-box-init->coding-agent->help()` to list the commands below.

## Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `codex-cli-setup` | Configure Imsight-preferred Codex CLI behavior. | `references/codex-cli-setup.md` |
| `codex-cli-3rd-party` | Configure Codex CLI for third-party OpenAI-compatible APIs. | `references/codex-cli-3rd-party.md` |
| `codex-gac-launcher` | Create or repair `codex-gac` or `codex-gac-<suffix>` with a separate GAC profile in the normal Codex home and an embedded key while leaving plain `codex` official. | `references/codex-gac-launcher.md` |
| `codex-openlux-launcher` | Create or repair `codex-openlux` or `codex-openlux-<suffix>` with a separate OpenLux profile in the normal Codex home and an embedded key while leaving plain `codex` official. | `references/codex-openlux-launcher.md` |
| `claude-kimi-launcher` | Create or repair `claude-kimi` or `claude-kimi-<suffix>`, including Kimi Coding Plan thinking effort. | `references/claude-kimi-launcher.md` |
| `claude-gac-launcher` | Create or repair `claude-gac` or `claude-gac-<suffix>` with the endpoint and key embedded, without Claude JSON changes. | `references/claude-gac-launcher.md` |
| `claude-openlux-launcher` | Create or repair `claude-openlux` or `claude-openlux-<suffix>`, replacing the retired Yunwu relay. | `references/claude-openlux-launcher.md` |
| `agy-openlux-launcher` | Create or repair a Windows, Linux, or macOS Antigravity launcher named `agy-openlux` or `agy-openlux-<suffix>` that uses OpenLux without changing plain `agy`. | `references/agy-openlux-launcher.md` |
| `kimi-multi-credential` | Create Kimi Code CLI launchers named `kimi-<suffix>`, each with an isolated OAuth credential home and `--auto` startup default unless no-auto mode is explicitly requested. | `references/kimi-multi-credential.md` |
| `help` | Explain this subskill and list its commands. | This entrypoint |

## Resource Ownership

This subskill owns its Codex, Codex-GAC, Codex-OpenLux, Claude-Kimi, Claude-GAC, Claude-OpenLux, Antigravity-OpenLux, and Kimi multi-credential references, the cross-platform Claude-Kimi and Claude-GAC launcher generators, and the Unix Kimi Code credential launcher generator under `scripts/`.

## Custom Launcher Compatibility Policy

Apply this policy before creating, repairing, or regenerating every custom launcher owned by this subskill:

1. Start with read-only inspection of the installed target CLI's version/help, current CLI and provider documentation, existing relevant state, and the user's requested endpoint/auth behavior. Do not create the persistent launcher, profile, credential store, PATH entry, or shell startup block yet.
2. Resolve version-sensitive endpoint, authentication, model, alias, context, and routing candidates from the user's explicit choices plus current documentation. Never seed them solely from a historical example or generator default.
3. Do **not** require or use handcrafted HTTP calls to provider model, discovery, or inference endpoints as a compatibility gate. The provider protocol and the target CLI can evolve together; a standalone probe can validate the wrong request shape, auth path, or model semantics.
4. Test the actual target CLI end to end with the supplied credential and disposable isolated state. Temporary files and directories are allowed when the CLI requires configuration, but keep them outside persistent user state and remove them after the test. Prefer the target CLI's own model/status/discovery surfaces when available.
5. If the target CLI cannot complete a minimal real turn, stop without running a launcher generator or writing persistent setup. Report the client-visible failure instead of compensating with a successful raw API call.
6. Persistent launcher, profile, key-file, PATH, or shell-profile changes are allowed only after the target CLI test succeeds. Re-run the same client path after persistence.
7. For an isolated OAuth credential-home wrapper, use read-only CLI compatibility checks before creation, then complete its documented interactive authorization boundary and verify the resulting launcher with the target CLI itself.

Reading existing files is allowed during inspection. Keep credentials out of command arguments and logs, and do not retain disposable test state after the compatibility decision.

## Codex Third-Party Profile Coexistence

Apply these additional invariants whenever a custom Codex launcher must preserve plain `codex` as the official route:

- Default to the user's normal `CODEX_HOME` (normally `~/.codex`). Put the provider in a separate `$CODEX_HOME/<profile-name>.config.toml` file and select it with `--profile <profile-name>`. Do not set or replace `CODEX_HOME` in the launcher merely to separate endpoint credentials.
- Leave `config.toml`, `auth.json`, and the configured credential store unchanged. A custom provider that uses `env_key` with `requires_openai_auth = false` can coexist with cached ChatGPT/OpenAI authentication; plain `codex` keeps its normal provider while the custom launcher selects the provider profile.
- Test the target Codex client through the same shared-home profile topology intended for persistence. A uniquely named temporary profile may be created and removed for the test when the installed CLI requires a file. Confirm the custom turn, background requests, plain-Codex configuration, and cached OAuth state remain correct.
- Use a separate `CODEX_HOME` only as an explicit compatibility fallback after the installed target client reproducibly fails with the shared profile because of a state or authentication collision and succeeds with a clean home. Report that `CODEX_HOME` also isolates config, sessions, logs, skills, and package metadata, and obtain the user's choice before adopting that broader isolation.
- When the installed Codex version needs an explicit header for background provider discovery, use the documented `env_http_headers` mapping with a separate process-scoped environment variable containing the complete header value. Keep `env_key` for ordinary provider authentication and never put the credential in TOML.
- Treat values consumed by `env_key` or `env_http_headers` as exact HTTP credential material. Before the temporary Codex test and again through the generated launcher, require the provider key to be non-empty, on one physical line, and free of whitespace or control characters; for the currently covered bearer keys, require visible ASCII bytes `33..126`. Reject malformed input instead of trimming or normalizing it, derive any complete Authorization value only after this check, and never print the value while validating it. A successful test with a separately exported clean value does not validate how the persistent launcher serialized or loaded that value.
- Preserve Codex's documented retry defaults unless current provider evidence justifies an override. Do not lower retries merely to make an example shorter, and do not respond to throttling with repeated launcher invocations that create another request burst.
- Treat every provider-key replacement as a new compatibility run: repeat the shared-home target-Codex test before updating the persistent launcher or its pinned model.

## Codex Profile Bootstrap for Redirected Homes

Apply this pattern whenever a custom Codex launcher selects `--profile <profile-name>` and must also work when the caller redirects `CODEX_HOME`. The launcher may embed the already-verified, non-secret TOML profile as a string and materialize it in the active Codex home at runtime. This keeps provider settings portable across homes without copying the user's base configuration or credentials.

- Resolve the destination at invocation time as `${CODEX_HOME:-$HOME/.codex}` on Unix or the equivalent `$env:CODEX_HOME` fallback on PowerShell. Do not assign or replace `CODEX_HOME` in the launcher.
- Derive the profile path from that destination and the resolved profile name. The embedded content must contain only the tested provider configuration; never put an API key or other credential in it.
- If the profile exists and exactly matches the embedded content, continue without rewriting it.
- If the profile is missing, explain the path and ask the user whether to create it and continue. On confirmation, create the destination directory and profile with restrictive permissions, preferably by writing a temporary file in the same directory and renaming it into place. Recheck the path after the prompt so a concurrent creator is never overwritten.
- If the profile is missing and the launcher has no interactive input, exit with a clear status-2 message instead of silently creating persistent state. Do not add an automatic creation escape hatch unless the user explicitly requests one and the launcher documents it.
- If an existing profile differs from the embedded content, stop and report the conflict. Do not overwrite or merge it during an ordinary launch; use an explicit repair/setup workflow after inspecting the user's file and re-running the compatibility checks if the provider or model changes.
- Do not copy `config.toml`, `auth.json`, sessions, skills, logs, or package metadata into a redirected home. The selected profile is the only file this bootstrap owns.
- Run the same target-Codex verification once with the default home and once with a disposable redirected home when this behavior is implemented or changed. Verify the prompt/decline path, creation path, exact-content path, mismatch path, argument forwarding, and exit-code preservation without printing credentials.

This bootstrap is a runtime convenience, not a compatibility gate. The profile content and pinned model must first be proven with the target Codex client under the current installed version; runtime materialization only reproduces that known-good content in the selected home.

The Unix implementation should follow this shape: assign the verified TOML to a shell variable, resolve `codex_home` and `profile_file`, compare an existing regular file with `cmp`, and reject non-regular or divergent paths. For a missing file, require an interactive confirmation, create the home, write through a restrictive temporary file in that directory, and install it without clobbering a file that appeared after the prompt. A compact reference state machine is:

```bash
codex_home="${CODEX_HOME:-$HOME/.codex}"
profile_file="$codex_home/$profile_name.config.toml"
profile_content='...verified non-secret TOML...'
if [[ -e "$profile_file" && ! -f "$profile_file" ]]; then
  echo "$launcher_name: profile path is not a regular file: $profile_file" >&2
  exit 2
elif [[ -f "$profile_file" ]]; then
  if ! printf '%s' "$profile_content" | cmp -s - "$profile_file"; then
    echo "$launcher_name: existing profile differs: $profile_file" >&2
    exit 2
  fi
elif [[ ! -t 0 ]]; then
  echo "$launcher_name: missing profile; run interactively to approve creation: $profile_file" >&2
  exit 2
else
  read -r -p "$launcher_name: create $profile_file and continue? [y/N] " answer
  case "$answer" in y|Y|yes|YES) ;; *) exit 2 ;; esac
  mkdir -p -- "$codex_home"
  if [[ -e "$profile_file" ]]; then
    if [[ -f "$profile_file" ]] && printf '%s' "$profile_content" | cmp -s - "$profile_file"; then
      :
    else
      echo "$launcher_name: profile appeared or changed after confirmation: $profile_file" >&2
      exit 2
    fi
  else
    tmp_profile="$(mktemp "$codex_home/.${profile_name}.config.toml.XXXXXX")"
    chmod 600 "$tmp_profile"
    printf '%s' "$profile_content" >"$tmp_profile"
    if ! ln "$tmp_profile" "$profile_file" 2>/dev/null; then
      rm -f -- "$tmp_profile"
      echo "$launcher_name: profile appeared after confirmation: $profile_file" >&2
      exit 2
    fi
    rm -f -- "$tmp_profile"
  fi
fi
```

The hard-link install above reserves the destination without overwriting a file that appeared after confirmation; adapt the atomic-install details to the host shell while preserving the same state transitions and restrictive mode. PowerShell launchers should use the same state machine, an array or here-string for the non-secret template, `Test-Path`/`Get-Content -Raw` for comparison, and `finally` only for restoring caller environment variables. The bootstrap must run before the Codex child process starts and must not print credentials or the embedded template.

## Custom Launcher Permission Policy

Apply this policy to every custom launcher created or repaired by this subskill, including future agent CLIs:

- Default to the target CLI's most permissive documented execution mode. For the launchers currently covered here, that means `--dangerously-skip-permissions` for Claude Code and Antigravity CLI, `--dangerously-bypass-approvals-and-sandbox` for Codex CLI, and `--auto` for Kimi Code CLI.
- Treat permission prompts, approvals, or sandboxing as an opt-out. Use the less-permissive path only when the user's initial launcher request explicitly rejects the permissive mode. Silence is not an opt-out, and the agent must not ask the user to reconfirm the default.
- When the user opts out at the beginning, use the target launcher generator's permission-prompting option or omit the permissive flag from a hand-written launcher. Preserve that choice when repairing or regenerating the launcher.
- For a future agent CLI, inspect its current help or authoritative documentation and use its strongest supported approval-free or sandbox-bypass launcher option. Do not copy another CLI's flag by name when the target CLI does not support it.
- Report which permission mode the launcher uses. A permissive launcher changes the launched agent's runtime behavior; it does not expand the scope of the setup task or authorize unrelated changes.

## Custom Launcher Naming Policy

- Use the provider-family base name when the user gives no suffix: `codex-gac`, `codex-openlux`, `claude-gac`, `claude-kimi`, `claude-openlux`, or `agy-openlux`.
- When the user gives a suffix, append exactly one hyphen and the suffix: `<base-name>-<suffix>`. Accept lowercase letters, digits, and internal hyphens; ask for a portable replacement when the value contains uppercase letters, spaces, path separators, or shell metacharacters.
- Treat the suffix only as a friendly launcher/profile namespace for distinguishing variants. Do not infer endpoint, account, model, routing, pricing, permission, or credential behavior from its text.
- Use the resolved full launcher name consistently for the executable or function, managed-block marker, and isolated profile namespace. Use a matching credential-file namespace only when the provider guide stores credentials in side files.
- Omit the suffix and separator when the user does not provide one. Do not ask for a suffix merely because the guide supports it.
- Keep `kimi-<suffix>` suffix-required in the Kimi Code multi-credential workflow because the unsuffixed `kimi` name belongs to the upstream CLI; its suffix remains only a user-facing credential/profile label.

## Launcher Guide Authoring Contract

Write and apply custom-launcher guidance principle-first:

1. State the stable runtime contract before showing commands: target agent CLI, provider endpoint and authentication lane, credential placement, environment isolation, permission mode, executable discovery, argument forwarding, and exit-code behavior.
2. Separate durable principles from version-sensitive details such as CLI flags, model names, endpoint quirks, config keys, and install paths. Apply **Custom Launcher Compatibility Policy** and let the installed target CLI validate those details end to end.
3. Choose an OS-native implementation: Bash or another native shell on Linux/macOS, and PowerShell functions or scripts on Windows. Preserve the caller's environment when an in-process function temporarily changes variables.
4. Present bundled generators, vendor snippets, and inline templates as reference implementations. Use them unchanged only when their recorded assumptions match the current CLI version, provider behavior, OS, and user request; otherwise adapt the implementation while preserving the stated contract.
5. Verify observable behavior rather than merely confirming that a helper script ran: inspect the generated launcher safely, exercise argument forwarding and exit codes, and confirm the active endpoint, auth lane, model discovery, and permission mode.

Do not reduce a launcher guide to “run this script.” The guide must remain usable when the example script, CLI, operating system, or provider API changes.

## Guardrails

- DO NOT expose API keys while configuring a provider or launcher.
- DO NOT run a launcher generator or create, modify, or delete persistent setup files before the target CLI completes the applicable isolated compatibility test.
- DO NOT make a raw provider API probe a prerequisite for custom-launcher creation or treat it as stronger evidence than the target CLI's end-to-end result.
- DO NOT overwrite unrelated Codex, Claude Code, or Antigravity settings.
- DO NOT bypass a selected reference's compatibility checks.
- DO NOT silently generate a permission-prompting or sandboxed custom launcher when the initial request did not explicitly opt out of permissive mode.
