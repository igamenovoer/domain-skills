# Operate the Hindsight Stack

Manage the deployed Hindsight service without losing its named volume.

## Workflow

1. Resolve the exact Compose file used for deployment.
2. Select the requested lifecycle operation below.
3. Preserve the named volume unless permanent deletion is explicitly authorized.
4. Re-run health and Hermes memory status after state-changing operations.
5. Report service, restart, and persistence state.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step operation plan from the Compose file, container, volume, and user request, then execute the plan without broad deletion.

## Command Prefix

Use the protected Hermes environment for every Compose operation:

```bash
docker compose \
  --env-file "$HOME/.hermes/.env" \
  -f <compose-file> \
  <operation>
```

## Operations

Start or reconcile:

```bash
docker compose --env-file "$HOME/.hermes/.env" -f <compose-file> up -d
```

Inspect:

```bash
docker compose --env-file "$HOME/.hermes/.env" -f <compose-file> ps
docker compose --env-file "$HOME/.hermes/.env" -f <compose-file> logs --tail 100
```

Restart:

```bash
docker compose --env-file "$HOME/.hermes/.env" -f <compose-file> restart
```

Stop without deleting data:

```bash
docker compose --env-file "$HOME/.hermes/.env" -f <compose-file> down
```

After starting or restarting:

```bash
curl -fsS http://127.0.0.1:18888/health
hermes memory status
```

## Deliberate Upgrade

Before changing the image pin:

1. Review the target Hindsight release and migration notes.
2. Record the current image, volume, health response, and client version.
3. Update only the image tag in the Compose file.
4. Pull and recreate the container without `--volumes`.
5. Run full verification and a disposable-bank smoke test.
6. Roll back the tag if verification fails.

## Guardrails

- DO NOT add `--volumes` to `docker compose down` during ordinary operations.
- DO NOT remove `hermes-hindsight-data` as part of an image upgrade.
- DO NOT print fully rendered Compose configuration containing the Kimi key.
- DO NOT follow container logs with unlimited history when a bounded tail is sufficient.
