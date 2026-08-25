# Verify Hermes, Kimi, and Hindsight

Verify non-secret configuration and optionally exercise Kimi-backed memory end to end.

## Workflow

1. Run the non-mutating stack verifier.
2. Inspect failed checks without printing credentials.
3. When API use and a disposable test bank are acceptable, run the retain/recall smoke test.
4. Confirm the smoke-test bank was deleted.
5. Report every checked component and any cleanup warning.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step verification plan from the configured endpoints, container, volume, Hermes provider, memory plugin, and user constraints, then execute the plan.

## Non-Mutating Verification

Resolve `<hermes-mgr-subskill-dir>` to the parent subskill directory:

```bash
<hermes-mgr-subskill-dir>/scripts/verify-hermes-hindsight.sh
```

It verifies:

- required commands;
- Hindsight health and database connectivity;
- UI response;
- container running state, restart policy, and loopback-only bindings;
- persistent volume;
- Hermes `kimi-coding/k3-256k` route;
- Hermes Hindsight provider availability;
- Hermes gateway status.

The verifier does not read or print API-key values.

## End-to-End Smoke Test

The smoke test creates a uniquely named bank, retains a non-sensitive random marker, recalls it, and deletes the entire disposable bank in a `finally` cleanup:

```bash
<hermes-mgr-subskill-dir>/scripts/smoke-test-hindsight.py
```

This test calls the configured Kimi API through Hindsight and therefore consumes a small amount of quota. Run it only when an external API request and temporary memory mutation are in scope.

If cleanup reports a warning, resolve the exact printed disposable bank ID and delete only that bank:

```bash
curl -fsS -X DELETE \
  http://127.0.0.1:18888/v1/default/banks/<disposable-bank-id>
```

## Additional Boot Checks

```bash
systemctl is-enabled docker
systemctl --user is-enabled hermes-gateway.service
systemctl --user is-active hermes-gateway.service
```

Expected: Docker is enabled, and the Hermes user gateway is enabled and active.

## Guardrails

- DO NOT run the mutating smoke test when external API use or temporary memory writes are outside the user's request.
- DO NOT leave a disposable test bank behind after verification.
- DO NOT expose environment files or rendered Compose secrets while diagnosing failures.
