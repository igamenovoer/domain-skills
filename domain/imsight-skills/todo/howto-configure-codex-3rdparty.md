# Configure Codex CLI with a Third-Party API Without CC Switch

This guide explains how to wire OpenAI Codex CLI to a third-party provider by editing `~/.codex/config.toml` and, when necessary, running a local protocol translator.

## The One Thing That Breaks Most Setups

Codex CLI 0.2+ speaks the **OpenAI Responses API** (`POST /v1/responses`).
Most Chinese aggregators — including **SiliconFlow** — only expose the **OpenAI Chat Completions API** (`POST /v1/chat/completions`).
If you point Codex directly at `https://api.siliconflow.cn/v1`, Codex hits `/v1/responses`, SiliconFlow returns 404, and nothing works.

So the manual setup has two jobs:

1. Tell Codex where to send Requests API calls.
2. Make sure that endpoint actually implements `/v1/responses`.

There are three ways to do that without CC Switch.

---

## Option A: Use a Provider That Already Supports Responses API (Simplest)

Some gateways already proxy `/v1/responses`. OpenRouter is the most common.

1. Get an OpenRouter key from <https://openrouter.ai>.
2. Edit `~/.codex/config.toml`:

```toml
model = "zai-org/GLM-5.2"
model_provider = "openrouter"

[model_providers.openrouter]
name = "OpenRouter"
base_url = "https://openrouter.ai/api/v1"
env_key = "OPENROUTER_API_KEY"
wire_api = "responses"
```

3. Export the key:

```bash
export OPENROUTER_API_KEY="sk-or-v1-..."
```

4. Test:

```bash
codex exec "Reply with exactly: pong"
```

If OpenRouter lists your model and supports Responses API, this is the least-effort path.

---

## Option B: Run codex-relay as a Local Responses-to-Chat Proxy

If you must use SiliconFlow directly, run a lightweight proxy that translates Codex's `/v1/responses` calls into upstream `/v1/chat/completions` calls.

> **Note:** LiteLLM Proxy is great for routing Chat Completions requests, but it does **not** translate the OpenAI Responses API into Chat Completions. When Codex sends `POST /v1/responses`, LiteLLM forwards it to `/v1/responses` on the upstream, which SiliconFlow does not implement. Use `codex-relay` (or another Responses→Chat translator) instead.

### 1. Install codex-relay

`codex-relay` is a Rust project distributed as a prebuilt binary via PyPI:

```bash
# with uv
uv tool install codex-relay

# or with pip in a venv
pip install codex-relay
```

### 2. Start the relay

```bash
export SILICONFLOW_API_KEY="sk-eawomngotjyeiqgesfsriuqeelxxsdnxwzqjkuyhqatcidbt"

CODEX_RELAY_UPSTREAM=https://api.siliconflow.cn/v1 \
CODEX_RELAY_API_KEY="$SILICONFLOW_API_KEY" \
CODEX_RELAY_PORT=4446 \
codex-relay
```

### 3. Point Codex at the relay

```toml
model = "zai-org/GLM-5.2"
model_provider = "siliconflow-relay"

[model_providers.siliconflow-relay]
name = "SiliconFlow"
base_url = "http://127.0.0.1:4446/v1"
env_key = "OPENAI_API_KEY"
wire_api = "responses"
```

`codex-relay` handles the upstream API key, so Codex only needs a placeholder:

```bash
export OPENAI_API_KEY="not-needed"
```

### 4. Test

```bash
codex exec "Reply with exactly: pong"
```

---

## Option C: Minimal Custom Proxy

If you do not want LiteLLM, a tiny Node/Python proxy is enough for basic text prompts. It must:

- Accept `POST /v1/responses`.
- Rewrite the path to `POST /v1/chat/completions`.
- Convert the Responses body to Chat Completions body.
- Convert the Chat response back to Responses shape.

Here is a minimal Python example using Flask and `requests`.

```python
import os
import json
import requests
from flask import Flask, request, Response

app = Flask(__name__)

UPSTREAM_BASE = "https://api.siliconflow.cn/v1"
UPSTREAM_KEY = os.environ["SILICONFLOW_API_KEY"]

@app.route("/v1/responses", methods=["POST"])
def responses():
    body = request.get_json()

    messages = []
    if instructions := body.get("instructions"):
        messages.append({"role": "system", "content": instructions})
    for item in body.get("input", []):
        role = "user" if item.get("role") == "user" else "assistant"
        messages.append({"role": role, "content": item.get("content", "")})

    chat_body = {
        "model": body.get("model", "zai-org/GLM-5.2"),
        "messages": messages,
        "stream": body.get("stream", False),
    }
    if max_tokens := body.get("max_output_tokens"):
        chat_body["max_tokens"] = max_tokens
    for key in ("temperature", "top_p"):
        if key in body:
            chat_body[key] = body[key]

    upstream = requests.post(
        f"{UPSTREAM_BASE}/chat/completions",
        headers={"Authorization": f"Bearer {UPSTREAM_KEY}", "Content-Type": "application/json"},
        json=chat_body,
        stream=False,
    )
    upstream.raise_for_status()
    chat = upstream.json()

    choice = chat["choices"][0]
    message = choice.get("message", {})
    text = message.get("content", "")

    resp_body = {
        "id": chat["id"],
        "object": "response",
        "status": "completed",
        "output": [{"type": "output_text", "text": text}],
        "usage": chat.get("usage", {}),
    }
    return Response(json.dumps(resp_body), mimetype="application/json")

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=15721)
```

Then point Codex at it exactly like Option B:

```toml
model = "zai-org/GLM-5.2"
model_provider = "local_proxy"

[model_providers.local_proxy]
name = "Local Custom Proxy"
base_url = "http://127.0.0.1:15721/v1"
env_key = "OPENAI_API_KEY"
wire_api = "responses"
```

This minimal proxy does not handle tools, streaming, or reasoning content; add those only if you need them.

---

## Config File Locations and Precedence

Codex reads configuration in this order, with later layers overriding earlier ones:

1. User config: `~/.codex/config.toml`
2. Profile config: `~/.codex/<profile-name>.config.toml` (activated with `--profile`)
3. Project config: `.codex/config.toml` in the repo root (only when trusted)
4. CLI flags: `codex -c model="..."`

Provider definitions must live in the user-level or profile config. Project configs cannot override providers for security reasons.

---

## Useful Environment Variables

| Variable | Purpose |
|----------|---------|
| `OPENAI_API_KEY` | Default key used by Codex when `env_key = "OPENAI_API_KEY"` |
| `CODEX_HOME` | Overrides `~/.codex` config directory |
| `SILICONFLOW_API_KEY` | Your SiliconFlow key, consumed by codex-relay or a custom proxy |

---

## Verification Steps

1. Confirm the provider endpoint supports `/v1/responses`:

```bash
curl -s https://api.siliconflow.cn/v1/responses \
  -H "Authorization: Bearer $SILICONFLOW_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"zai-org/GLM-5.2","input":[{"role":"user","content":"hi"}]}'
```

If you get 404, you need a proxy (Options B or C).

2. Confirm Codex can reach the relay or gateway:

```bash
curl -s http://127.0.0.1:4446/v1/models
```

3. Run a headless Codex prompt:

```bash
codex exec "Reply with exactly: pong"
```

If it answers, the chain is working.

---

## Quick Reference: SiliconFlow + codex-relay + Codex

```bash
# 1. start relay
export SILICONFLOW_API_KEY="sk-eawomngotjyeiqgesfsriuqeelxxsdnxwzqjkuyhqatcidbt"

CODEX_RELAY_UPSTREAM=https://api.siliconflow.cn/v1 \
CODEX_RELAY_API_KEY="$SILICONFLOW_API_KEY" \
CODEX_RELAY_PORT=4446 \
codex-relay

# 2. in another shell
export OPENAI_API_KEY="not-needed"
cat > ~/.codex/config.toml <<'EOF'
model = "zai-org/GLM-5.2"
model_provider = "siliconflow-relay"

[model_providers.siliconflow-relay]
name = "SiliconFlow"
base_url = "http://127.0.0.1:4446/v1"
env_key = "OPENAI_API_KEY"
wire_api = "responses"
EOF

# 3. test
codex exec "Say hello"
```

---

## SiliconFlow Reasoning Notes

SiliconFlow uses `enable_thinking: true` in the request body and returns reasoning content in `choices[0].message.reasoning_content`. If your proxy does not strip or forward this field, Codex will only see the final `content`. `codex-relay` maps reasoning content automatically; a custom proxy must map it explicitly if you want reasoning visible in Codex.
