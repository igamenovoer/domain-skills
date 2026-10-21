# Part 1: Proxy Tools

## Role of the Proxy

A coding CLI usually authenticates a human through a browser, stores an OAuth credential on the local machine, and speaks a provider-specific protocol. A CLI-to-API proxy inserts itself between an API client and that credential: it authenticates the downstream client, translates a standard protocol into the provider's request shape, selects an upstream credential, refreshes it when necessary, and streams the response back.

The proxy does not create provider quota. It reuses the quota, plan, and terms of the upstream account. Treat every proxy deployment as a credential-bearing service, not as a stateless converter.

## Request Path

1. The API client sends a request to a base URL with a proxy client key.
2. The proxy authenticates the client key and selects an eligible upstream credential.
3. The proxy translates the request into the provider's native protocol or a compatible variant.
4. The upstream provider applies the account's quota and returns a response.
5. The proxy translates the response, including streaming events and usage, back to the client protocol.

Failures at each step look different: 401 means client authentication, an empty model list means credential or catalog loading, 404 on a model call means routing or model ID, and timeouts usually mean upstream egress.

## Tool Categories

| Category | What it does | Good fit | Limits |
| --- | --- | --- | --- |
| Multi-provider OAuth proxy | Stores several providers' OAuth credentials and exposes OpenAI, Gemini, Anthropic, or Codex-style surfaces from one process | Several providers or several accounts, mixed clients, centralized key management | Larger configuration surface; provider support varies by release |
| Single-provider OAuth bridge | Wraps one CLI or subscription and exposes one or two compatible protocols | One provider, one account, minimal deployment | Usually no multi-provider routing; may depend on one maintainer |
| API-key gateway | Aggregates upstream API keys and exposes a unified endpoint with routing, quotas, and logging | Upstream credentials are already API keys | Does not perform CLI OAuth login or token refresh |
| Client-side router | Switches models or providers inside an existing CLI | Improving one CLI's model choice | Not necessarily an API server for other clients |

Verified examples to use as starting points, not endorsements:

- **CLIProxyAPI** (`router-for-me/CLIProxyAPI`): multi-provider OAuth proxy for Antigravity, Codex, Claude Code, Kimi, xAI, Devin, Meta, and related accounts; exposes OpenAI-, Gemini-, Anthropic-, and Codex-compatible surfaces. This is the first worked example below.
- **copilot-api** (`ericc-ch/copilot-api`): reverse-engineered GitHub Copilot proxy exposing OpenAI and Anthropic compatible endpoints. It is not supported by GitHub and may break; use only within the account's terms.
- **gemini-cli-openai** (`GewoonJaap/gemini-cli-openai`): exposes Gemini CLI endpoints as an OpenAI-compatible API through Cloudflare Workers. Verify the current direction of translation and maintenance status before adopting.
- **LiteLLM**: API-key gateway and Python SDK for many providers. It is useful in front of a CLI-to-API proxy or for API-key-only upstreams, but it is not a CLI OAuth login tool.
- **one-api** and **new-api**: API-key aggregation gateways with key management and quota features. Same limitation: they front API keys rather than CLI logins.

Community tools change quickly. Check the current README, release history, license, and supported protocols before relying on a name from a search result.

## Selection Checklist

- **Provider coverage**: does the tool support the exact account type, not only the provider's public API?
- **Protocol coverage**: does it expose the protocol your client speaks, including streaming, tools, images, and thinking fields?
- **Credential model**: where are OAuth tokens stored, how are they refreshed, and what permissions protect them?
- **Multi-account behavior**: can several accounts coexist, and how does the tool choose among them?
- **Reload behavior**: does it pick up a new credential without a restart?
- **Deployment footprint**: single binary, container, Python service, or serverless worker; what does the host need?
- **Egress requirements**: does token exchange or upstream traffic need an outbound proxy, VPN, or special DNS?
- **Security controls**: client keys, TLS, bind address, management API, log redaction, and auditability.
- **Maintenance**: recent releases, issue responsiveness, and a clear license.

## CLIProxyAPI Worked Example

CLIProxyAPI is used here because it demonstrates the full pattern: one binary, a YAML configuration, provider login commands, a credential directory, protocol translation, and hot reload.

### Install and Inspect

Choose the upstream-documented installation path for the target platform: release archive, package manager, container image, or build from source. After installation, confirm the version and the flags actually present in that build:

```bash
<install-dir>/cli-proxy-api -h
```

Provider flags and configuration keys change between major versions. Treat the help output and the release's `config.example.yaml` as authoritative for the installed build.

### Minimal Configuration

The v8 configuration layout nests downstream client authentication under `access`. Older releases used a root `api-keys` list. Start from the shipped example instead of copying a snippet from a different version.

```yaml
server:
  host: "127.0.0.1"
  port: <api-port>

access:
  api-keys:
    - "<client-key-1>"
    - "<client-key-2>"
```

Operational choices:

- **Bind address**: use `127.0.0.1` for local clients. Use a private interface or a reverse proxy with TLS for remote clients; never expose an unauthenticated port.
- **API port**: choose a free port. The provider callback port is a separate setting and does not need to match the API port.
- **Client keys**: these are proxy keys, not upstream provider keys. Store them in the config file or a secret-mounted equivalent, with restrictive file permissions.
- **Auth directory**: the default is commonly `~/.cli-proxy-api`; set `auth-dir` when the version supports it or when credentials should live on a dedicated volume. Keep it outside the repository.
- **Outbound proxy**: prefer `HTTP_PROXY`, `HTTPS_PROXY`, and `NO_PROXY` so child login commands and the long-running process inherit the same route. Some releases also support an explicit `proxy-url` setting for all outbound requests or per provider entry.

### Provider Login Commands

A recent v8 build exposes these OAuth flags (verify your build):

| Provider | Flag | Notes |
| --- | --- | --- |
| Antigravity | `-antigravity-login` | Loopback callback defaults to port `51121` |
| Claude Code | `-claude-login` | Anthropic account OAuth |
| Codex | `-codex-login` or `-codex-device-login` | Device flow is useful on headless hosts |
| Kimi | `-kimi-login` or `-kimi-ai-login` | Two account domains |
| xAI | `-xai-login` | Grok account OAuth |
| Devin | `-devin-login` | Devin account OAuth |
| Meta | `-meta-login` | Meta account OAuth |
| Vertex | `-vertex-import <file>` | Service-account JSON import |
| Gemini API key | configuration entry | Usually `gemini-api-key`, not an OAuth flag |

Other releases may add, rename, or remove flags. Run `-h` before scripting a login, and do not assume a flag from an older tutorial still exists.

### Run the Proxy

```bash
HTTP_PROXY=<proxy-url> \
HTTPS_PROXY=<proxy-url> \
NO_PROXY=localhost,127.0.0.1 \
<install-dir>/cli-proxy-api -config <config-path>
```

Supervise the process with the host's service manager, a terminal multiplexer, or a container restart policy. Whichever mechanism you choose, make sure the long-running process inherits the outbound proxy variables; a login command that succeeds in one shell does not prove the server can reach the provider later.

### Headless OAuth Pattern

Providers that use a loopback redirect require the browser and the callback listener to meet on the same host and port. On a remote or headless host, use one of these patterns:

1. **SSH local forward**: from the client machine, run `ssh -L <callback-port>:127.0.0.1:<callback-port> <user>@<proxy-host>`, then open the printed auth URL in the local browser. The provider redirects to the forwarded port and the login completes without manual copying.
2. **Manual callback paste**: open the auth URL on any machine, approve, then copy the complete `http://localhost:<callback-port>/...` callback URL from the address bar and paste it into the waiting login prompt. The URL must include both `code` and `state`; a bare code is rejected when state validation is enabled.
3. **Device flow**: when the provider and proxy support it, prefer the device-code login. It avoids a loopback listener entirely.

Operational details that commonly cause failures:

- The login process has a finite timeout, often around five minutes. A stale auth URL from an earlier attempt will not match the new state; always use the URL printed by the current process.
- Do not probe the callback path with `curl`. The callback handler is one-shot; an empty request can be consumed as the OAuth callback and abort the login.
- A `404` on the callback server's root path is normal when only the callback path is registered; it is not evidence that the tunnel is broken.
- If the provider OAuth client pins a redirect URI, an overridden callback port can produce `redirect_uri_mismatch`. Fall back to the provider's default port.
- Multiple accounts are supported by running the login again. Each credential is stored as a separate file in the auth directory.

### Credential Storage and Reload

Antigravity credentials, for example, are stored as `antigravity-<account>.json` in the auth directory with mode `600`. The running process watches the configuration and auth directory and reloads new files without a restart in recent versions. Confirm the reload in the logs before concluding that a login failed.

Back up the auth directory only with encryption and access controls. Never copy it into a repository, a ticket, or a chat transcript.

### Protocol Surface

Routes vary by release. A recent v8 build exposes:

| Protocol | Method and path | Typical use |
| --- | --- | --- |
| OpenAI Chat Completions | `POST /v1/chat/completions` | Most OpenAI-compatible clients |
| OpenAI Responses | `POST /v1/responses` | Codex-style and Responses clients |
| OpenAI models | `GET /v1/models` | Unified model discovery |
| Gemini models | `GET /v1beta/models` | Gemini-native model discovery |
| Gemini generate | `POST /v1beta/models/<model-id>:generateContent` | Gemini-native generation |
| Gemini stream | `POST /v1beta/models/<model-id>:streamGenerateContent?alt=sse` | Gemini-native streaming |
| Gemini interactions | `POST /v1beta/interactions` | Interaction-style Gemini clients when supported |
| Anthropic Messages | `POST /v1/messages` | Claude-compatible clients |
| Anthropic count tokens | `POST /v1/messages/count_tokens` | Claude-compatible token counting |

Client authentication accepts the tool's configured key through several headers, commonly `Authorization: Bearer <client-key>`, `x-api-key: <client-key>`, `x-goog-api-key: <client-key>`, or a `?key=<client-key>` query parameter. Use the header that belongs to the client protocol; do not send an upstream provider key as a downstream client key.

### Verification Commands

```bash
# Rejection without a key (expect 401 or the documented equivalent)
curl -s -o /dev/null -w '%{http_code}\n' \
  http://<proxy-host>:<api-port>/v1/models

# Authorized model list
curl -s -H "Authorization: Bearer <client-key>" \
  http://<proxy-host>:<api-port>/v1/models

# Gemini-native model list
curl -s -H "x-goog-api-key: <client-key>" \
  http://<proxy-host>:<api-port>/v1beta/models
```

A model list proves authentication and catalog loading, not generation. Always follow it with a real request and, when the client depends on them, a streaming request and a tool-call or structured-output request.

### Operations

- Pin the proxy version and keep the install directory separate from the auth directory and configuration.
- Rotate downstream client keys independently from upstream credentials.
- Run behind a reverse proxy with TLS when clients are remote; terminate TLS outside the proxy or configure the proxy's own TLS support.
- Restrict the management or panel interface to trusted networks.
- Check logs for credential paths and provider errors, but redact tokens and account identifiers before sharing logs.
- Restart the proxy after changing listener, TLS, or outbound proxy settings; credential files themselves usually reload automatically.

## Security and Compliance

- Downstream client keys and upstream provider credentials are different trust domains. Do not reuse one as the other.
- A proxy concentrates many credentials in one process. Protect the auth directory, configuration, environment, and backups with least privilege.
- Account sharing, quota circumvention, and resale may violate provider terms even when the proxy works technically. Confirm the account owner's plan permits the intended use.
- Reverse-engineered single-provider bridges can break or trigger account restrictions. Prefer tools and flows that the provider tolerates, and disclose the risk to the user.

## Troubleshooting

- **Listener conflict**: change the proxy API port, not the provider callback port, when the API port is occupied. Use `-oauth-callback-port` when the callback port is occupied or blocked.
- **Empty model list with a valid key**: confirm the auth directory path, file ownership and permissions, and the reload log; restart the process if the file arrived after the watcher stopped.
- **401 from the proxy**: verify the client key against the configured list and the header style expected by the protocol; check for whitespace or a copied provider key.
- **404 on generation**: verify the model ID against the model list and use the protocol route that exposes it. A model listed for one protocol is not necessarily routable through another.
- **Timeouts only for upstream calls**: confirm the long-running process, not only the login shell, has the outbound proxy environment and that `NO_PROXY` covers local health checks.
- **Callback mismatch after changing ports**: re-open the auth URL printed by the current login process; state and redirect URI are tied to that process.
