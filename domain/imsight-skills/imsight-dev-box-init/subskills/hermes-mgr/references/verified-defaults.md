# Verified Hermes, Kimi, and Hindsight Defaults

Use this reference for shared provider contracts, versions, paths, and security decisions.

## Workflow

1. Confirm the requested lane is Kimi Coding Plan rather than a Moonshot Platform API key.
2. Apply the separate Hermes and Hindsight endpoint forms below.
3. Keep secrets in the protected Hermes environment file and non-secret behavior in normal configuration.
4. Re-check the official sources before changing the pinned versions or endpoint contract.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from these verified contracts and the user request, then execute the plan without weakening credential or network isolation.

## Maintained Snapshot

This snapshot was verified on 2026-07-28:

- Hermes Agent release: `v2026.7.20` (`hermes` package version `0.19.0`)
- Hindsight release and image: `v0.8.5` / `ghcr.io/vectorize-io/hindsight:0.8.5`
- Hindsight Python client: `0.8.5` in the working deployment
- Kimi Coding Plan key variable shared by this stack: `KIMI_CODING_API_KEY`
- Default model for Hermes and Hindsight: `k3-256k`

Use a newer release only after reviewing its migration notes and testing the full verification workflow. Do not silently replace the pinned Hindsight image with `latest`.

## Endpoint Split

The same Kimi Coding Plan account exposes two compatible surfaces:

| Consumer | Base URL | Why |
| --- | --- | --- |
| Hermes Agent | `https://api.kimi.com/coding` | Hermes uses the Anthropic Messages-compatible surface and appends its message path. |
| Hindsight | `https://api.kimi.com/coding/v1` | Hindsight's `openai` provider uses Kimi's OpenAI-compatible surface. |

Do not append `/v1` to Hermes' configured base URL; it would produce a duplicated message path. Do include `/v1` for Hindsight.

## Hermes Kimi Contract

Hermes accepts both `KIMI_API_KEY` and `KIMI_CODING_API_KEY` for provider `kimi-coding`. Prefer the explicit coding-plan name for this stack so Docker Compose can reuse it without copying the secret.

Coding Plan keys normally start with `sk-kimi-`. Hermes' model wizard recognizes that prefix and routes it to `https://api.kimi.com/coding`.

Use:

```yaml
model:
  provider: kimi-coding
  default: k3-256k
  base_url: https://api.kimi.com/coding

agent:
  reasoning_effort: high
```

`high` is the maintained balanced setting. Change it only when the requested Kimi model and installed Hermes release support the chosen effort.

## Hindsight Kimi Contract

Use these environment variables in the Hindsight container:

```text
HINDSIGHT_API_LLM_PROVIDER=openai
HINDSIGHT_API_LLM_BASE_URL=https://api.kimi.com/coding/v1
HINDSIGHT_API_LLM_MODEL=k3-256k
HINDSIGHT_API_LLM_API_KEY=${KIMI_CODING_API_KEY}
HINDSIGHT_API_LLM_TEMPERATURE=none
```

Kimi Coding models reject Hindsight's operation-specific temperature defaults, so the maintained deployment omits temperature. The template also leaves `HINDSIGHT_API_LLM_REASONING_EFFORT` unset: K3 then uses its provider default, currently `high`, without assuming that Hindsight's generic OpenAI field maps to every Kimi-specific thinking contract.

The full Hindsight image runs embeddings and reranking locally. Only its LLM operations call Kimi; no local generative model is deployed.

## Persistence and Exposure

- Bind container ports `8888` and `9999` to host loopback ports `18888` and `19999`.
- Store embedded PostgreSQL data in the named volume `hermes-hindsight-data`.
- Use `restart: unless-stopped`; it restarts the container when the Docker daemon starts.
- Keep the Hindsight API unauthenticated only because it is loopback-bound.
- Use `hermes-{profile}-{platform}-{user}` to isolate messaging-platform users while retaining a stable fallback.

## Authoritative Sources

- Hermes provider documentation: `https://github.com/NousResearch/hermes-agent/blob/main/website/docs/integrations/providers.md`
- Hermes environment variables: `https://github.com/NousResearch/hermes-agent/blob/main/website/docs/reference/environment-variables.md`
- Hermes Hindsight plugin: `https://github.com/NousResearch/hermes-agent/blob/main/plugins/memory/hindsight/README.md`
- Hindsight repository and Docker quick start: `https://github.com/vectorize-io/hindsight`
- Hindsight environment template: `https://github.com/vectorize-io/hindsight/blob/main/.env.example`
- Hindsight `v0.8.5` release: `https://github.com/vectorize-io/hindsight/releases/tag/v0.8.5`

## Guardrails

- DO NOT treat the Hermes and Hindsight Kimi base URLs as interchangeable.
- DO NOT add a Kimi key directly to tracked YAML or Markdown.
- DO NOT enable a generic reasoning-effort field for Hindsight without verifying the pinned client's emitted Kimi request shape.
