# Part 2: Provider API Creation

## The Provider Contract

Each provider integration is a contract with five fields. Resolve all five before declaring the endpoint usable; omitting one produces a proxy that authenticates but fails in normal client use.

| Field | Question | Typical failure when unresolved |
| --- | --- | --- |
| Account | Which subscription, plan, or project supplies quota? | Login succeeds but calls return quota or entitlement errors |
| Authentication | OAuth loopback, device code, API key, or service account? | Callback never completes or token exchange times out |
| Credential store | Where does the proxy persist and refresh the credential? | Model list is empty after a successful login |
| Model catalog | Which IDs and modalities does this account expose? | 404 or a client requests a model the account cannot serve |
| Protocol mapping | How do tools, images, thinking, and streaming translate? | Basic text works but the client's real workload fails |

## Authentication Patterns

| Pattern | How it works | Best for | Operational notes |
| --- | --- | --- | --- |
| Loopback OAuth | Browser authorizes, provider redirects to `http://localhost:<callback-port>`, proxy captures the code | Desktop or interactive hosts, providers with no device flow | Browser and callback listener must meet; use a tunnel or full-URL paste on headless hosts; validate `state` |
| Device code | Proxy requests a code, user enters it on another device, proxy polls for completion | Headless servers, containers, SSH-only hosts | Preferred when the provider and proxy support it; no callback port or tunnel |
| API key | Static key is copied into the proxy's upstream configuration | Providers with official API keys, AI Studio, third-party compatible endpoints | Key is an upstream credential, not a downstream client key; use secret mounts and rotation |
| Service account | JSON key or workload identity supplies project-scoped credentials | Vertex AI, enterprise cloud projects | Mount read-only, restrict project and roles, monitor quota |
| Session token or cookie | Browser session material is replayed as an API credential | Last resort for providers with no supported API auth | Fragile, often against terms, and frequently expires; avoid unless the provider documents it |

## Provider Matrix

The flags below reflect a recent CLIProxyAPI v8 build and are examples of the integration shape, not a permanent API. Always confirm with `<proxy-binary> -h` and the release's configuration example.

| Provider | Account routes | Authentication | Proxy integration notes |
| --- | --- | --- | --- |
| Google Gemini | Antigravity account; Gemini API key; Vertex project; Gemini CLI account where the build exposes it | OAuth loopback, API key, or service account | Antigravity OAuth uses a loopback callback that defaults to `51121`; Gemini API keys are configured as upstream entries, not logged in |
| Anthropic Claude | Claude Code subscription; Anthropic API key | OAuth or API key | Claude Code OAuth uses a loopback callback; API-key upstreams are separate from downstream client keys |
| OpenAI | Codex/ChatGPT account; OpenAI API key | OAuth, device code, or API key | Codex device flow is the headless-friendly route; Responses and Chat Completions surfaces may differ |
| GitHub Copilot | GitHub Copilot subscription | OAuth or device flow through a Copilot-specific bridge | CLIProxyAPI does not necessarily cover Copilot; use a bridge such as `copilot-api` and verify GitHub's terms |
| Kimi | Kimi account domains | OAuth | Two login flags exist for different account domains in recent builds |
| xAI | Grok account | OAuth | Loopback callback; model IDs are account-dependent |
| Devin | Devin account | OAuth | Loopback callback; verify plan entitlement |
| Meta | Meta account | OAuth | Loopback callback; model availability is account-dependent |
| Vertex AI | Google Cloud project | Service-account JSON import | Project, region, and IAM roles determine quota and models |
| Qwen, iFlow, others | Community-documented accounts | Usually OAuth | Flags appear and disappear between releases; do not assume an older tutorial still applies |

## Choosing an OAuth Flow

1. **Prefer device code** when the provider and proxy support it. It removes the callback listener, tunnel, and paste steps.
2. **Use loopback with a tunnel** when device code is unavailable and the proxy runs on a remote host. Forward the exact callback port from the client machine to the proxy host before opening the auth URL.
3. **Use manual paste** when a tunnel is impossible. Paste the complete callback URL, including `code` and `state`, from the browser's address bar. A bare code fails in implementations that validate state.
4. **Restart the flow after a timeout.** OAuth state, redirect URI, and the printed URL belong to one process. A URL from an earlier attempt will not complete a new login.

Token exchange is a separate network hop from the browser flow. If the browser can reach the provider but the proxy cannot, the callback arrives and the exchange fails. Set the outbound proxy environment before starting both the login command and the long-running server, and verify the server process inherited it.

## API Keys and Compatible Upstreams

An API-key route is configured in the proxy, not in the downstream client. Common fields are:

```yaml
<provider>-api-key:
  - api-key: "<upstream-api-key>"
    base-url: "<provider-compatible-base-url>"   # optional
    headers:                                     # optional, endpoint-specific
      <Header-Name>: "<value>"
    proxy-url: "<proxy-url>"                     # optional, per-key egress
```

Only set `base-url` for a genuinely compatible endpoint. A provider's official API key usually needs no base URL. Per-key headers apply only to the overridden endpoint in some implementations; do not assume they are forwarded everywhere.

## Model Discovery

Query the running proxy rather than a provider's public documentation page. Account entitlements, proxy routing, and display aliases can change the catalog.

- `GET /v1/models` returns a unified OpenAI-shaped list with IDs and an `owned_by` or provider hint.
- `GET /v1beta/models` returns Gemini-shaped entries with `name`, `displayName`, `description`, and modality fields.
- Gemini names commonly carry a `models/` prefix; the routing layer often accepts both the prefixed name and the bare ID. Verify with the installed build.
- Model IDs are case-sensitive in many routers. Copy them exactly from the list.
- A display name is not a model ID. Do not substitute a human-readable label into a request.
- Capabilities matter: a model that accepts text may not accept images, audio, or tool calls, and a model listed for one protocol may not be routed through another.

Record the discovered IDs and capabilities in the handoff notes so the client configuration does not drift.

## Verification Matrix

| Check | Why it matters |
| --- | --- |
| Request without a client key returns 401 | Confirms downstream authentication is enforced |
| Request with a valid client key lists models | Confirms key, credential load, and catalog |
| Non-streaming generation returns content and a finish reason | Confirms upstream routing and response translation |
| Streaming returns incremental chunks and terminates | Confirms SSE or protocol-specific streaming |
| Tool calls or structured output round-trip | Confirms the client's real workload, not only chat |
| Image, audio, or thinking fields when required | Confirms modality translation |
| Second request after a restart | Confirms credential persistence and reload |
| Second account, when configured | Confirms routing and failover behavior |
| Error path, such as an invalid model or quota exhaustion | Confirms errors are surfaced rather than masked |

## Secrets and Compliance

- Keep upstream credentials in the proxy's auth directory or secret store, never in the client configuration, repository, logs, or chat.
- Set the auth directory and configuration to owner-only permissions. Backups must be encrypted.
- Rotate downstream client keys separately from upstream credentials. Revoke old keys when an account is removed.
- Do not log full request headers or token values. Redact account identifiers before sharing diagnostics.
- Confirm that the provider's plan and terms permit API-style access. A subscription intended for an interactive CLI may have different limits from an API plan.
- Do not help share accounts, evade quotas, or resell access. If the user's goal depends on circumventing provider controls, stop and explain the constraint.

## Troubleshooting

- **Login succeeds but the model list is empty**: check the auth directory, file mode, account entitlement, and reload log; restart the proxy if the credential arrived after the watcher stopped.
- **401 from the proxy with a valid-looking key**: confirm the key comes from the proxy's downstream key list, not from the provider; check the header style for the protocol.
- **404 on generation**: confirm the exact model ID from the list and the protocol route that exposes it. A model available through OpenAI-compatible routing is not automatically available through the Gemini route.
- **429 or quota errors**: the upstream plan or account quota is exhausted or the account is rate-limited; the proxy cannot create entitlement.
- **Protocol-specific failures**: if text works but tools, images, or thinking fail, inspect the proxy's translation support for that provider and protocol before changing the client.
- **Streaming stalls or truncates**: check upstream timeouts, proxy buffering, and reverse-proxy buffering; confirm the client requested the streaming route.
- **Credential refresh failures**: confirm the token refresh path has outbound access and that the account is still authorized; re-run the login when refresh tokens are revoked.
