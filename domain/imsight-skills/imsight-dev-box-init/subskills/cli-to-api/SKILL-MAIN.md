---
name: cli-to-api
description: Use when a coding CLI subscription or OAuth account must be exposed as an OpenAI-, Gemini-, or Anthropic-compatible API through a proxy such as CLIProxyAPI, including headless login, model discovery, endpoint verification, or adding a Gemini/Antigravity account.
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

# CLI-to-API Proxy Setup

## Overview

Convert a coding CLI subscription or OAuth account into a network API by treating the work as two layers: a proxy tool that speaks the client protocol and stores credentials, and a provider-specific integration that supplies the upstream account, model catalog, and quota.

## When to Use

Use this subskill when the task involves any of the following:

- Calling a coding CLI subscription from an API client or SDK, such as Claude Code, Codex, Antigravity/Gemini, Kimi, GitHub Copilot, xAI, Devin, or Meta.
- Installing, configuring, supervising, or securing a local or remote CLI-to-API proxy.
- Exposing an OpenAI-, Gemini-, or Anthropic-compatible endpoint from an account that only ships a CLI or IDE login.
- Adding a provider account, completing OAuth on a headless host, discovering model IDs, or verifying generation through the proxy.
- Diagnosing an empty model list, a 401 from the proxy, a callback that never arrives, or a protocol mismatch.

Do not use this subskill when:

- The user only needs to point an existing client at an endpoint that is already configured and verified.
- An official provider API key already satisfies the requirement and no CLI subscription or OAuth account is involved.
- The request is to bypass provider quotas, share accounts against provider terms, or use credentials the user does not own.
- The task is ordinary SSH tunnel or firewall work unrelated to an OAuth callback; route it to the network skill instead.

## Workflow

1. **Define the API contract.** Identify the client protocol (OpenAI Chat Completions or Responses, Gemini `generateContent`, or Anthropic Messages), the required model IDs and capabilities, whether the endpoint is local or remote, and which upstream account type will supply quota. If the user has not chosen, propose the smallest surface that satisfies the client.
2. **Choose the proxy tool.** Read **Part 1** and `references/proxy-tools.md`. Prefer a multi-provider OAuth proxy such as CLIProxyAPI when several providers or accounts are needed; use a single-provider bridge for one narrow integration; use an API-key gateway only when upstream credentials are already API keys.
3. **Plan the deployment and security boundary.** Decide the bind address, API port, client-key storage, TLS or reverse-proxy termination, process supervision, and whether the host needs an outbound HTTP proxy. Keep the bind on loopback unless remote access is intended, and never publish the port without client authentication.
4. **Prepare provider access.** Read **Part 2** and `references/provider-apis.md`. For a Gemini or Antigravity account, follow `references/provider-gemini.md`. Complete OAuth on a machine that can reach the provider, using a device flow when the provider supports it or a loopback callback tunnel otherwise.
5. **Launch and authenticate.** Start the proxy with the required environment, including `HTTP_PROXY` and `HTTPS_PROXY` when outbound traffic is mediated. Run the provider login, confirm the credential lands in the proxy's auth store, and confirm the running process reloads it.
6. **Discover models.** Query the proxy's model-list endpoints instead of assuming upstream IDs. Record the exact IDs, display names, and capabilities the account exposes.
7. **Verify end-to-end.** Check unauthorized rejection, authorized model listing, a real generation, streaming, and at least one tool or structured-output path the client will use. Exercise the same protocol the client will use, not only the model list.
8. **Hand off operations.** Report the base URL, where the client key lives, the model IDs, the restart command, the auth-store backup location, the proxy-environment dependency, and the quota or terms caveats.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the two parts, the linked references, the user's client protocol, and the provider account type, then execute the plan.

## Two-Part Structure

| Part | Question it answers | Detailed guide |
| --- | --- | --- |
| Part 1: The proxy tool | Which tool should expose the CLI account, how should it be deployed, and what protocol surface does it provide? | `references/proxy-tools.md` |
| Part 2: Provider API creation | Which account and auth flow supply the upstream API, which models become available, and how are they verified? | `references/provider-apis.md` and `references/provider-gemini.md` |

## Part 1: The Proxy Tool

The proxy is the protocol and credential boundary. It authenticates the downstream client with a proxy-issued key, translates the requested protocol, selects an upstream credential, and forwards the request using the provider's OAuth or API-key flow. Keep that boundary explicit: downstream client keys are not upstream provider keys.

CLIProxyAPI is the first worked example because one process can front multiple OAuth providers and expose OpenAI, Gemini, Anthropic, and Codex-style surfaces. A minimal setup has four decisions:

- **Installation**: release binary, package manager, container, or build from source. Verify the installed version's flags because provider support changes between releases.
- **Listener**: bind host and API port, normally loopback plus a non-default port when another service already uses the default.
- **Client authentication**: at least one proxy client key, stored in the config file or a secret-mounted equivalent, never in source control.
- **Provider credentials**: an auth directory outside the repository, populated by the tool's login commands or API-key configuration.

For the CLIProxyAPI installation checklist, protocol routing table, headless OAuth pattern, service supervision, tool comparison, and operations guidance, read `references/proxy-tools.md`.

## Part 2: Provider API Creation

The provider layer answers a different question: which upstream account, authenticated by which flow, supplies which models at which quota. Treat each provider as a small integration contract rather than a copy of a command line.

- **Auth pattern**: loopback OAuth, device code, API key, service account, or session token.
- **Credential store**: the proxy's per-provider auth file or upstream key list, with restrictive permissions.
- **Model catalog**: discovered dynamically from the running proxy; IDs, display names, and input/output modalities can differ from the provider's public API.
- **Protocol translation**: whether the client protocol maps cleanly to the provider's native shape, especially for tools, images, thinking, and streaming.
- **Quota and terms**: whether the account's plan permits API-style use and what limits apply.

For the cross-provider auth matrix, model discovery, verification matrix, and secret-handling rules, read `references/provider-apis.md`. For the Gemini worked case, including Antigravity OAuth, Gemini API keys, Vertex import, Gemini-native calls, and SDK configuration, read `references/provider-gemini.md`.

## Placeholder Convention

Every host-specific value in this subskill is a placeholder. Replace placeholders locally and never commit the replaced values.

| Placeholder | Meaning |
| --- | --- |
| `<proxy-host>` | Hostname or IP where the proxy listens, for example `127.0.0.1` for a local client |
| `<api-port>` | Proxy listener port; many tools default to `8317` |
| `<client-key>` | Downstream proxy key issued by the proxy configuration |
| `<callback-port>` | OAuth loopback callback port used by the provider login |
| `<model-id>` | Exact model ID returned by the proxy's model-list endpoint |
| `<auth-dir>` | Directory where the proxy stores provider credentials |
| `<config-path>` | Proxy configuration file path |
| `<install-dir>` | Proxy installation directory |
| `<proxy-url>` | Outbound HTTP or SOCKS proxy URL when direct egress is blocked |
| `<account>` | Upstream account identifier used only in local file names, never in skill sources |

## Verification Checklist

- Unauthorized request to the model-list endpoint returns 401 or the tool's documented rejection.
- Authorized model listing returns a non-empty list and matches the account's expected providers.
- A real generation returns content and a stop or finish reason, not only a model list.
- Streaming returns incremental chunks and terminates cleanly.
- Tool, structured-output, image, or thinking paths work when the client depends on them.
- Restarting the proxy preserves provider credentials and still applies the outbound proxy environment.
- Logs and tracked files contain no tokens, account emails, client keys, or host-specific endpoints.

## Troubleshooting Guide

- **OAuth callback never arrives.**
  - If the browser shows a connection error after approval, then verify that the tunnel targets the same callback port as the login process and that the login process is still running; open the current auth URL rather than a stale one from a previous attempt.
- **Login rejects the pasted callback.**
  - If the proxy validates OAuth state, then paste the complete callback URL including `code` and `state`, not a bare authorization code; restart the login when its timeout has expired.
- **Token exchange times out.**
  - If direct egress is blocked, then export `HTTP_PROXY`, `HTTPS_PROXY`, and the appropriate `NO_PROXY` values before launching both the login command and the long-running proxy, and confirm each process inherited them.
- **Model list is empty.**
  - If the provider login reported success but no models appear, then check the auth directory, file permissions, and reload log; restart the proxy when hot reload did not pick up the credential.
- **Generation returns 404.**
  - If the protocol route exists but the model call fails, then use an exact ID from the model-list response and the route that exposes it; do not assume an upstream model name is routable.
- **Proxy returns 401.**
  - If the client sends a provider API key, then replace it with a configured proxy client key; upstream provider keys belong in the proxy's upstream configuration.
- **Works locally but not remotely.**
  - If the listener is bound to loopback, then use a tunnel or deliberately change the bind and add client-key and TLS or reverse-proxy controls.

## Guardrails

- DO NOT write host names, IP addresses, account emails, tokens, client keys, callback ports, or other host-specific values into this subskill or its examples; use the placeholder convention.
- DO NOT copy a coding CLI's stored credential file into the proxy's auth store as a shortcut; use the proxy's supported login flow.
- DO NOT expose the proxy on a public interface without client keys plus TLS or a trusted reverse proxy.
- DO NOT hardcode model IDs or assume upstream model names are exposed; discover them from the running proxy.
- DO NOT claim the endpoint is verified from a model list alone; a real generation must succeed.
- DO NOT help bypass provider quotas, share accounts against provider terms, or use credentials the user does not own.
