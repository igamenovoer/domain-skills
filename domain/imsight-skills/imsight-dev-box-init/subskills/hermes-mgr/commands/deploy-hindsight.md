# Deploy Local Hindsight With Kimi

Deploy Hindsight locally while using Kimi Coding Plan for Hindsight's generative LLM operations.

## Workflow

1. Require completed Kimi credential setup and read `../references/verified-defaults.md`.
2. Resolve a deployment directory under the parent skill's output contract.
3. Copy or reconcile the maintained Compose asset without overwriting an unrelated file.
4. Validate and start the stack with the protected Hermes environment file.
5. Verify health, persistence, loopback exposure, and boot behavior.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the Compose asset, persistence rules, endpoint contract, and user request, then execute the plan without deploying a local LLM or exposing Hindsight remotely.

## Prerequisites

- Docker Engine and the Compose plugin are installed.
- `~/.hermes/.env` contains a non-empty `KIMI_CODING_API_KEY`.
- The required ports are free:

```bash
docker version
docker compose version
grep -q '^KIMI_CODING_API_KEY=.' "$HOME/.hermes/.env"
ss -ltn | rg ':(18888|19999)\b' || true
```

The `grep` check must not print the matching line.

## Resolve the Compose File

Resolve `<hermes-mgr-subskill-dir>` to the directory containing the parent `SKILL-MAIN.md`. Use the user's explicit deployment path, or default to:

```text
<project-dir>/.imsight-arts/dev-box-init/hermes-mgr/hindsight.compose.yaml
```

Create its parent directory, then install the maintained asset only when the destination is new:

```bash
install -D -m 0644 \
  <hermes-mgr-subskill-dir>/assets/hindsight.compose.yaml \
  <compose-file>
```

If `<compose-file>` already exists, inspect and reconcile it rather than overwriting it. Preserve intentional version pins, port choices, volume names, and unrelated services unless the user requests their replacement.

## Maintained Compose Contract

The asset provides:

- `ghcr.io/vectorize-io/hindsight:0.8.5`
- API mapping `127.0.0.1:18888:8888`
- UI mapping `127.0.0.1:19999:9999`
- Kimi OpenAI-compatible endpoint `https://api.kimi.com/coding/v1`
- model `k3-256k`
- omitted temperature via `HINDSIGHT_API_LLM_TEMPERATURE=none`
- persistent volume `hermes-hindsight-data`
- restart policy `unless-stopped`

It references `${KIMI_CODING_API_KEY}` and never contains the key itself.

## Start the Stack

Validate without rendering secrets to stdout:

```bash
docker compose \
  --env-file "$HOME/.hermes/.env" \
  -f <compose-file> \
  config --quiet
```

Start:

```bash
docker compose \
  --env-file "$HOME/.hermes/.env" \
  -f <compose-file> \
  up -d
```

Wait for:

```bash
curl -fsS http://127.0.0.1:18888/health
```

Expected JSON contains `"status":"healthy"` and `"database":"connected"`.

## Boot Behavior

`restart: unless-stopped` restarts Hindsight whenever the Docker daemon starts. Verify Docker itself starts at boot:

```bash
systemctl is-enabled docker
docker inspect hermes-hindsight --format '{{.HostConfig.RestartPolicy.Name}}'
```

Enabling a disabled system Docker daemon normally requires sudo. Obtain the required authority before running:

```bash
sudo systemctl enable --now docker
```

## Verification

```bash
docker ps --filter name=hermes-hindsight
docker volume inspect hermes-hindsight-data
docker port hermes-hindsight
curl -fsS http://127.0.0.1:18888/health
curl -fsS -o /dev/null http://127.0.0.1:19999
```

Both published ports must show host IP `127.0.0.1`.

## Guardrails

- DO NOT run `docker compose config` without `--quiet` when secret interpolation could appear in output.
- DO NOT replace the pinned image with `latest` without reviewing and testing the release.
- DO NOT publish ports `18888` or `19999` on `0.0.0.0`.
- DO NOT delete the named volume during ordinary stop, restart, or upgrade operations.
