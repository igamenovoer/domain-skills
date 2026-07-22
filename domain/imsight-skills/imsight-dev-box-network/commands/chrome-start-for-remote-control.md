# Start Chrome For Remote Playwright Control

Use this command to launch a visible Google Chrome instance on the local host, publish it through Playwright's native browser endpoint, and prepare a secure connection handoff for a remote Playwright client.

## Workflow

1. **Gather the required inputs**. Obtain the local runtime, local bind port, session name, remote transport, and remote listen port. See **Input Contract**.
2. **Verify prerequisites**. Confirm Chrome, Playwright 1.59 or later, a free local port, and compatible client/server versions. See **Prerequisite Checks**.
3. **Launch the browser host**. Select the Node.js or Python pattern under **Browser Host Patterns**, create an initial page so Chrome is visible, bind only to loopback, and keep the host process alive.
4. **Capture the endpoint**. Preserve the complete `ws://` endpoint, including its unguessable path, and record the host process and Playwright version.
5. **Create the secure transport** when the controller is on another machine. Prefer the loopback-only SSH reverse tunnel under **Remote Transport** unless the user supplies another authenticated private transport.
6. **Verify local and remote access**. Confirm the browser window, local listener, transport listener, and a real Playwright `connect()` operation. See **Verification**.
7. **Report the handoff** using **Output Contract**, including the exact remote endpoint and the next command the remote operator should run.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's inputs, host patterns, transport rules, verification checks, and guardrails, then execute the plan.

## Input Contract

Resolve these values before launching anything:

| Input | Requirement |
| --- | --- |
| Local runtime | Choose an installed supported Playwright runtime, normally Node.js or Python. |
| Local bind port | Use a user-provided or confirmed available TCP port. Do not assume a default. |
| Session name | Use a descriptive non-secret label; do not derive it from private inventory unless requested. |
| Browser channel | Use Google Chrome through Playwright's `chrome` channel unless the user requests another Chromium channel. |
| Remote transport | Use an authenticated private transport. For SSH, obtain a working SSH host or alias. |
| Remote listen port | Obtain a free port on the controller side of the transport. It may differ from the local port. |
| Lifetime | Determine whether the host should run in the foreground, a detached process, tmux, or a service. |

If the request omits a port, SSH destination, or lifetime policy needed for the requested operation, ask for that value instead of inventing it. A local port of `0` may be used only when the operating system should select an ephemeral port and the resulting endpoint will be captured before transport setup.

## Prerequisite Checks

1. Confirm the selected Playwright runtime is version 1.59 or later because `Browser.bind()` was introduced in 1.59.
2. Confirm Google Chrome is installed and Playwright can launch `channel="chrome"` with `headless=false`.
3. Confirm the local bind port is free on `127.0.0.1`.
4. Record the exact Playwright host version. The remote client's major and minor version must match the host; patch versions within that line are compatible.
5. If SSH will carry the endpoint, confirm non-interactive authentication and remote forwarding support before launching a persistent tunnel.

Use platform-appropriate inspection commands rather than assuming an operating system. Examples include `Get-NetTCPConnection` on Windows and `ss -ltn` on Linux.

## Browser Host Patterns

Choose one pattern that matches the installed local runtime. Parameterize the bind port and session name through arguments, configuration, or environment variables; do not replace the placeholders with values from this skill.

### Node.js

```js
const { chromium } = require('playwright');

const bindPort = Number(process.env.PLAYWRIGHT_BIND_PORT);
const sessionName = process.env.PLAYWRIGHT_SESSION_NAME || 'remote-chrome';

if (!Number.isInteger(bindPort) || bindPort < 0 || bindPort > 65535) {
  throw new Error('Set PLAYWRIGHT_BIND_PORT to an available TCP port.');
}

(async () => {
  const browser = await chromium.launch({
    channel: 'chrome',
    headless: false,
  });

  const initialContext = await browser.newContext();
  await initialContext.newPage();

  const { endpoint } = await browser.bind(sessionName, {
    host: '127.0.0.1',
    port: bindPort,
  });

  console.log(`Playwright version: ${require('playwright/package.json').version}`);
  console.log(`Endpoint: ${endpoint}`);
  console.log('Keep this process running while remote clients are connected.');

  const shutdown = async () => {
    await browser.close();
    process.exit(0);
  };
  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);

  await new Promise(() => {});
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
```

### Python

```python
import importlib.metadata
import os
import signal
import threading

from playwright.sync_api import sync_playwright


bind_port = int(os.environ["PLAYWRIGHT_BIND_PORT"])
session_name = os.environ.get("PLAYWRIGHT_SESSION_NAME", "remote-chrome")

if not 0 <= bind_port <= 65535:
    raise ValueError("PLAYWRIGHT_BIND_PORT must be an available TCP port")

stop_event = threading.Event()
signal.signal(signal.SIGINT, lambda *_: stop_event.set())
signal.signal(signal.SIGTERM, lambda *_: stop_event.set())

with sync_playwright() as playwright:
    browser = playwright.chromium.launch(channel="chrome", headless=False)
    initial_context = browser.new_context()
    initial_context.new_page()
    binding = browser.bind(
        session_name,
        host="127.0.0.1",
        port=bind_port,
    )

    print(f"Playwright version: {importlib.metadata.version('playwright')}")
    print(f"Endpoint: {binding['endpoint']}")
    print("Keep this process running while remote clients are connected.")
    stop_event.wait()
    browser.close()
```

The initial page is intentional: a headful browser process may not show a window until a context owns a page. Keep the browser-host process alive for the entire remote-control session.

## Remote Transport

Keep the Playwright listener on local loopback and transport it through an authenticated channel. For an SSH reverse tunnel from the browser host to the controller-side SSH machine, use:

```bash
ssh -NT \
  -o BatchMode=yes \
  -o ExitOnForwardFailure=yes \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=3 \
  -R 127.0.0.1:<remote-port>:127.0.0.1:<local-port> \
  <ssh-host>
```

The endpoint printed by the browser host has this shape:

```text
ws://127.0.0.1:<local-port>/<endpoint-path>
```

The remote client must replace only the authority's port while preserving the complete path:

```text
ws://127.0.0.1:<remote-port>/<endpoint-path>
```

Treat the full endpoint as a credential. Anyone who can reach it may control the browser. Keep both the Playwright listener and the remote SSH listener bound to `127.0.0.1` unless the user explicitly approves a broader, secured exposure design.

## Remote Client Patterns

Use Playwright's native `connect()` method, not `connect_over_cdp()` or `connectOverCDP()`, for an endpoint created by `Browser.bind()`.

### Node.js

```js
const { chromium } = require('playwright');

(async () => {
  const endpoint = process.env.PLAYWRIGHT_REMOTE_ENDPOINT;
  const browser = await chromium.connect(endpoint);
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://example.com');
  console.log(await page.title());
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
```

### Python

```python
import os

from playwright.sync_api import sync_playwright


endpoint = os.environ["PLAYWRIGHT_REMOTE_ENDPOINT"]

with sync_playwright() as playwright:
    browser = playwright.chromium.connect(endpoint)
    context = browser.new_context()
    page = context.new_page()
    page.goto("https://example.com")
    print(page.title())
```

Use a user-selected validation URL when network access or site policy makes the placeholder unsuitable. Multiple compatible Playwright clients may connect to the same bound browser.

## Verification

Verify each layer once, in order:

1. The local Chrome window exists and responds.
2. The browser-host process remains alive and the chosen local loopback port is listening.
3. The host log contains the complete endpoint and the recorded Playwright version.
4. When a transport is requested, the remote loopback port is listening and can reach the local Playwright port.
5. A remote client with a matching Playwright major/minor version can call `connect()`, create or select a context and page, navigate to a user-approved URL, and observe the visible Chrome window.

Do not repeatedly probe once a real remote `connect()` and page operation succeeds. Preserve the running host and tunnel for handoff.

## Output Contract

After launching the browser host, print:

```text
Browser host: started or already running
Local listener: 127.0.0.1:<local-port>
Host process: <process-id-or-runtime-owner>
Playwright version: <version>
Local endpoint: ws://127.0.0.1:<local-port>/<endpoint-path>
Next: establish the selected private transport to the remote controller
```

After establishing transport, print:

```text
Transport: active
Mapping: remote 127.0.0.1:<remote-port> -> local 127.0.0.1:<local-port>
Transport process or service: <identifier>
Remote endpoint: ws://127.0.0.1:<remote-port>/<endpoint-path>
Remote requirement: use matching Playwright major/minor and native connect()
Next: export PLAYWRIGHT_REMOTE_ENDPOINT and run the selected remote client pattern
```

Include log or state-file locations when the chosen lifetime mode creates them. State clearly that the host process and transport must remain running.

## Troubleshooting Guide

- `browser.bind` or `Browser.bind` is missing.
  - If Playwright is older than 1.59, then upgrade both host and client to the same supported major/minor line before retrying.
- Chrome starts but no window appears.
  - If the host has no context or page, then create an initial context and page after launch.
- The local bind fails.
  - If the port is occupied, then choose another confirmed-free port and regenerate the endpoint.
- The tunnel process exits immediately.
  - If SSH reports remote-forward failure, then check authentication, `AllowTcpForwarding`, the remote port, and listener conflicts before retrying.
- The remote client cannot connect.
  - If TCP forwarding works, then confirm the endpoint path was preserved exactly and the client major/minor version matches the host.
- The remote connection has reduced or unexpected Playwright behavior.
  - If the client used CDP attachment, then switch to native `chromium.connect()` with the bound Playwright endpoint.

## Guardrails

- DO NOT guess hostnames, aliases, usernames, ports, process names, project paths, or service names.
- DO NOT bind the Playwright endpoint or SSH remote listener to a non-loopback address without explicit approval and a reviewed access-control design.
- DO NOT omit, truncate, rewrite, or publicly disclose the endpoint path.
- DO NOT use CDP attachment for a native Playwright bound-browser endpoint.
- DO NOT launch host and client with incompatible Playwright major/minor versions.
- DO NOT stop an existing browser host, tunnel, or unrelated listener merely because the requested port is occupied.
- DO NOT terminate the browser-host process or requested transport before the user completes the remote-control session.
