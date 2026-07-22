# Chrome Attach For Remote Control

Use this reference to attach a local Playwright client or CLI to a Chrome instance running on a remote host.

## Workflow

1. Choose the connection mode: native Playwright endpoint or raw Chrome CDP.
2. Prepare the remote browser host and open the tunnel.
3. Verify the endpoint from the local side.
4. Attach with `playwright-cli` or Playwright JS/Python.
5. Use the attached browser; detach when finished.

If the task does not map cleanly to these steps, plan from the documented modes and safety rules; ask for missing remote host, tunnel direction, or port details.

## Common Policy

- Keep the browser host and tunnel listener bound to `127.0.0.1` on both sides. Do not expose the endpoint directly through `0.0.0.0`.
- Treat the complete WebSocket endpoint, including its path, as a secret. Anyone who can reach it can control the browser.
- Match the remote browser host's Playwright engine to the engine embedded in the pinned `@playwright/cli` release when using native `browser.bind()`.
- Keep the remote browser host process alive for the lifetime of all local clients.
- Prefer `playwright-cli detach` over `close` when the remote browser and its other clients should remain alive.

## Mode A: Native Playwright Endpoint (Recommended)

Use this mode when Playwright fidelity matters and the remote host can run a small Node.js browser host.

### 1. Start a version-matched browser host on the remote machine

On the local machine, pick a fixed CLI version and inspect its embedded Playwright engine:

```bash
CLI_VERSION=<cli-version>
npm install -g "@playwright/cli@$CLI_VERSION"
npm view "@playwright/cli@$CLI_VERSION" dependencies.playwright
```

On the remote host, create a browser host project using that exact engine version:

```bash
ENGINE_VERSION=<engine-version>
mkdir -p <browser-host-dir>
cd <browser-host-dir>
npm init -y
npm install "playwright@$ENGINE_VERSION"
```

Create `browser-host.mjs`:

```javascript
import { chromium } from "playwright";

const browser = await chromium.launch({
  channel: "chrome",      // omit if using bundled Chromium
  headless: false,        // or true for headless remote browser
});

const { endpoint } = await browser.bind("<browser-host-name>", {
  host: "127.0.0.1",
  port: <bind-port>,
});

console.log(`Endpoint: ${endpoint}`);

process.on("SIGINT", async () => {
  await browser.close();
  process.exit(0);
});

await new Promise(() => {});
```

Start it:

```bash
node browser-host.mjs
```

The printed endpoint resembles:

```text
ws://127.0.0.1:<bind-port>/<endpoint-path>
```

Keep the complete endpoint, including its path. The path is part of the connection credential.

### 2. Open a reverse tunnel from the remote host

From the remote host, keep a reverse SSH tunnel running:

```bash
ssh -NT \
  -o ExitOnForwardFailure=yes \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=3 \
  -R 127.0.0.1:<bind-port>:127.0.0.1:<bind-port> \
  <remote-user>@<remote-host>
```

This makes the browser endpoint reachable on the local machine as:

```text
ws://127.0.0.1:<bind-port>/<endpoint-path>
```

### 3. Attach from the local machine

Attach `playwright-cli` to a named session:

```bash
playwright-cli -s=<session-name> attach \
  --endpoint="ws://127.0.0.1:<bind-port>/<endpoint-path>"
```

Subsequent commands use the same session name:

```bash
playwright-cli -s=<session-name> snapshot
playwright-cli -s=<session-name> goto <url>
playwright-cli -s=<session-name> click <ref>
playwright-cli -s=<session-name> screenshot
```

Open the dashboard to monitor and interact with active sessions:

```bash
playwright-cli show
```

When finished, detach without stopping the remote browser host:

```bash
playwright-cli -s=<session-name> detach
```

### 4. Alternative: direct Playwright client

Node.js:

```javascript
const { chromium } = require("playwright");

const browser = await chromium.connect(
  "ws://127.0.0.1:<bind-port>/<endpoint-path>"
);
const context = browser.contexts()[0] || await browser.newContext();
const page = context.pages()[0] || await context.newPage();
```

Python:

```python
from playwright.sync_api import sync_playwright

endpoint = "ws://127.0.0.1:<bind-port>/<endpoint-path>"

with sync_playwright() as playwright:
    browser = playwright.chromium.connect(endpoint)
    context = browser.new_context()
    page = context.new_page()
    page.goto("<url>")
    print(page.title())
    context.close()
    browser.close()
```

## Mode B: Raw Chrome CDP (Fallback)

Use this mode when the remote browser already exposes a Chrome DevTools port or when a Playwright `browser.bind()` host is unavailable.

### 1. Start Chrome on the remote host

Headless Chrome:

```bash
google-chrome \
  --headless \
  --no-sandbox \
  --remote-debugging-port=<debug-port> \
  --user-data-dir="<chrome-profile-dir>" \
  --window-size=1920,1080 \
  <url>
```

Headful Chrome on a desktop remote host can omit `--headless`. Run under `tmux`, `screen`, or a systemd user service so it survives disconnection.

### 2. Tunnel the CDP port to the local machine

From the local machine:

```bash
ssh -N -L 127.0.0.1:<debug-port>:127.0.0.1:<debug-port> \
  <remote-user>@<remote-host>
```

The remote CDP endpoint then appears locally at:

```text
http://127.0.0.1:<debug-port>
```

### 3. Attach from the local machine

```bash
playwright-cli -s=<session-name> attach \
  --cdp=http://127.0.0.1:<debug-port>
```

Direct Playwright JS:

```javascript
const { chromium } = require("playwright-core");
const browser = await chromium.connectOverCDP(
  "http://127.0.0.1:<debug-port>"
);
```

## Verification

For native endpoint mode:

```bash
curl -s -o /dev/null -w "%{http_code}\n" \
  http://127.0.0.1:<bind-port>/<endpoint-path>
# Expected: 200

playwright-cli -s=<session-name> eval "document.title"
```

For CDP mode:

```bash
curl -s http://127.0.0.1:<debug-port>/json/version
# Expected: JSON with "Browser", "Protocol-Version", "webSocketDebuggerUrl"

curl -s http://127.0.0.1:<debug-port>/json/list
# Expected: target list including pages

playwright-cli -s=<session-name> eval "document.title"
```

## Troubleshooting

- `Unexpected status 404` for `/json/version`: the tunneled port is not serving Chrome DevTools. Confirm Chrome was started with `--remote-debugging-port=<debug-port>` on the remote host, and that the tunnel maps the same port.
- `ECONNREFUSED`: the tunnel or browser host is down. Verify `ss -tlnp` on both sides and restart the tunnel or host.
- `browserType.connect()` fails with a version error: the remote Playwright engine does not match the CLI's embedded engine. Pin both to the same major/minor engine version.
- `Playwright Extension not found`: extension mode requires the Playwright Extension installed in a local Chrome/Edge profile; use `attach --endpoint` or `attach --cdp` instead.
- `No usable sandbox!` when starting headless Chrome: add `--no-sandbox` on systems with AppArmor/namespace restrictions.
- Page shows `about:blank` after attach: the remote browser has no active page or the context is empty; navigate with `playwright-cli -s=<session-name> goto <url>`.

## Common Mistakes

- Guessing remote host names, ports, or endpoint paths instead of asking for the printed endpoint.
- Exposing the browser endpoint or CDP port on `0.0.0.0` without an explicit request.
- Using `close` instead of `detach` when the remote browser host should remain running.
- Mixing the native `browser.bind()` endpoint with `connectOverCDP`, or vice versa.
- Starting Chrome without `--no-sandbox` on restricted systems and then assuming the CDP port is broken when it actually failed to start.
