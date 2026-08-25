# Configure Hermes With Feishu

Configure or verify the Hermes Feishu gateway and repair the affected pairing-mode approval callback path without patching Hermes source.

## Workflow

1. Confirm the installed Hermes checkout is official and check whether an upstream update is available.
2. Inspect Feishu and gateway state without printing app secrets or paired user IDs.
3. When approval cards are visible but button clicks do not resume the agent, confirm the diagnostic signature in **Approval Callback Workaround**.
4. Run the bundled synchronizer in check mode, then apply it to the intended Hermes profile when the workaround is needed.
5. Restart the gateway so the Feishu adapter reloads the allowlist.
6. Run the harmless approval test in **Verification**, restore the previous approval mode, and report the result.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the installed Hermes version, Feishu connection mode, pairing state, gateway logs, profile scope, and user constraints, then execute the plan.

## Official Checkout and Update Check

Prefer a current official release before applying a compatibility workaround:

```bash
git -C "$HOME/.hermes/hermes-agent" remote get-url origin
hermes --version
hermes update --check
```

The expected upstream is `https://github.com/NousResearch/hermes-agent.git` or its SSH equivalent. If the checkout has another origin or local source changes, stop and resolve provenance before updating. Apply an available official update when the user's request includes updating Hermes; do not patch the vendor checkout for this callback symptom.

## Feishu State

```bash
hermes pairing list
hermes gateway status
rg -n "Connected in websocket mode|feishu connected|Unauthorized approval click|Feishu button resolved" \
  "$HOME/.hermes/logs/gateway.log" | tail -30
```

Do not copy user IDs from this output into reports or chat. Use the bundled synchronizer so IDs remain local.

## Approval Callback Workaround

Use this workaround only for the following signature:

- a paired Feishu user can chat with Hermes;
- Hermes sends an approval card for `execute_code` or another gated action;
- clicking an approval button does not resume the agent; and
- `gateway.log` records `Unauthorized approval click` for that click.

On affected Hermes/Feishu combinations, normal DM authorization includes the pairing store, while the interactive-card callback also consults the Feishu adapter's static operator allowlist. An empty `FEISHU_ALLOWED_USERS` can therefore admit the chat turn but reject the approval click before it resolves the pending action.

The compatibility workaround is to add every already-approved Feishu pairing ID to `FEISHU_ALLOWED_USERS`. Preserve existing allowlist entries, do not enable `FEISHU_ALLOW_ALL_USERS`, and do not replace the rest of `~/.hermes/.env`.

Resolve `<hermes-mgr-subskill-dir>` to the directory containing the parent `SKILL-MAIN.md`, then inspect the intended default profile:

```bash
python3 <hermes-mgr-subskill-dir>/scripts/sync-feishu-pairing-allowlist.py --check
```

The check prints counts and coverage only. If approved Feishu users are not covered, apply the merge and restart the gateway:

```bash
python3 <hermes-mgr-subskill-dir>/scripts/sync-feishu-pairing-allowlist.py --apply
hermes gateway restart
hermes gateway status
```

For a non-default Hermes profile, pass its exact home to both checks:

```bash
python3 <hermes-mgr-subskill-dir>/scripts/sync-feishu-pairing-allowlist.py \
  --hermes-home <profile-hermes-home> --check
python3 <hermes-mgr-subskill-dir>/scripts/sync-feishu-pairing-allowlist.py \
  --hermes-home <profile-hermes-home> --apply
```

The merge is intentionally additive. Pairing revocation remains a separate authorization operation; do not infer that this repair authorizes removing existing static allowlist entries.

## Verification

First repeat the non-secret coverage check. Expected: `paired_users_covered=yes`.

To force one harmless approval card even when smart approval would auto-approve simple code:

1. Record `hermes config get approvals.mode` and temporarily set it to `manual`.
2. In the Feishu DM, ask Hermes to use `execute_code` exactly once to create `/tmp/hermes-feishu-approval-test.txt` with non-sensitive test text.
3. Click **Allow Once** in Feishu.
4. Restore the recorded approval mode even if the test fails or times out.
5. Verify the file and callback log:

```bash
test -f /tmp/hermes-feishu-approval-test.txt
rg -n "Feishu button resolved|Unauthorized approval click" \
  "$HOME/.hermes/logs/gateway.log" | tail -20
```

Success requires a fresh `Feishu button resolved 1 approval(s)` entry, completion of the waiting tool call, and no fresh unauthorized-click entry for the test. A rendered card alone does not prove callback delivery.

## Guardrails

- DO NOT print, paste, or report Feishu app secrets, paired user IDs, or the full Hermes environment file.
- DO NOT set `FEISHU_ALLOW_ALL_USERS=true` or use `*` as a repair shortcut.
- DO NOT overwrite existing `FEISHU_ALLOWED_USERS`; merge approved paired users with its current entries.
- DO NOT leave `approvals.mode=manual` after a forced verification test unless that was the user's pre-existing setting.
- DO NOT claim success from the card rendering alone; require a resolved callback log and completed harmless tool call.
