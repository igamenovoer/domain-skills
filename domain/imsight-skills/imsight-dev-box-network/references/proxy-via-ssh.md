# Proxy Via SSH

Use this reference when an Imsight dev box or workstation needs to reach a target address through an SSH-accessible middle host.

## Workflow

1. Select the existing pattern under **Choose The Pattern**.
2. Apply the matching dynamic SOCKS5, existing-proxy forwarding, or single-service procedure.
3. Select systemd or tmux only as provided by the chosen case and user request.
4. Run **Validation** and enforce **Safety Rules**.

If the task does not map cleanly to these steps, plan only from the documented SSH proxy patterns and safety rules; ask which proxy service and runtime mode are intended.

## Choose The Pattern

Ask for these details when the request is underspecified:

1. SSH middle host alias or `<ssh-user>@<ssh-host>`.
2. Local listen port for the proxy.
3. Local bind address; use a loopback-only address by default.
4. Target address or service that should be reachable through the middle host.
5. Runtime mode: foreground, tmux, or user systemd service.
6. Whether the middle host should resolve DNS names for the client.

Choose one of these cases:

| Case | Use When | SSH Mechanism |
| --- | --- | --- |
| Dynamic SOCKS5 proxy | The client must access many hosts/ports reachable from the SSH middle host, or the target emits absolute URLs/IPs that should stay unchanged | `ssh -D` |
| Forward an existing proxy | A proxy service already runs on the SSH host or a host reachable from it, and the client only needs that one proxy endpoint locally | `ssh -L` |
| Direct single-service forward | The client only needs one target host/port and the tool cannot use SOCKS/HTTP proxy settings | `ssh -L` |

Prefer dynamic SOCKS5 for browser access, Git HTTP access to internal hosts, and other workflows where the destination may change during use. Prefer a direct local forward only for single fixed services.

## Case: Dynamic SOCKS5 Proxy

This creates a local SOCKS5 proxy. Traffic exits from the SSH middle host.

Foreground command:

```bash
ssh -N \
  -D <local-bind-address>:<local-socks-port> \
  -o ExitOnForwardFailure=yes \
  -o ServerAliveInterval=60 \
  -o ServerAliveCountMax=3 \
  <ssh-middle-alias>
```

Use `socks5h://` when the client should send hostname resolution through the proxy:

```bash
curl --socks5-hostname <local-proxy-host>:<local-socks-port> -I --max-time 10 <target-url>
git -c http.proxy=socks5h://<local-proxy-host>:<local-socks-port> clone <target-git-http-url>
```

For browsers, configure:

```text
SOCKS5 host: <local-proxy-host>
Port: <local-socks-port>
```

Use `socks5h://<local-proxy-host>:<local-socks-port>` in tools that accept proxy URLs and should resolve DNS on the SSH middle host. Use `socks5://` only when local DNS resolution is acceptable.

## Dynamic SOCKS5 Systemd User Service

Use this when the SOCKS proxy should survive logout and restart automatically. Keep the unit non-blocking and let SSH reconnect through systemd restart.

```ini
[Unit]
Description=SSH SOCKS5 proxy via <ssh-middle-alias> on <local-bind-address>:<local-socks-port>
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
ExecStart=/usr/bin/ssh -N -D <local-bind-address>:<local-socks-port> -o ExitOnForwardFailure=yes -o ServerAliveInterval=60 -o ServerAliveCountMax=3 <ssh-middle-alias>
Restart=always
RestartSec=10
TimeoutStopSec=1
KillMode=control-group
KillSignal=SIGKILL
SendSIGKILL=yes

[Install]
WantedBy=default.target
```

Install under:

```text
~/.config/systemd/user/ssh-socks-<local-socks-port>.service
```

Enable:

```bash
systemctl --user daemon-reload
systemctl --user enable --now ssh-socks-<local-socks-port>.service
```

If the service must run while the user is logged out and the user has permission:

```bash
loginctl enable-linger "$USER"
```

## Dynamic SOCKS5 Tmux Mode

Use tmux for manual operation or testing:

```bash
SESSION="devbox-tunnels"
tmux new-session -d -s "$SESSION" -n "socks-<local-socks-port>" 2>/dev/null || true
tmux new-window -t "$SESSION" -n "socks-<local-socks-port>" 2>/dev/null || true
tmux send-keys -t "$SESSION:socks-<local-socks-port>" \
  'ssh -N -D <local-bind-address>:<local-socks-port> -o ExitOnForwardFailure=yes -o ServerAliveInterval=60 -o ServerAliveCountMax=3 <ssh-middle-alias>' C-m
```

Inspect:

```bash
tmux attach -t "$SESSION"
ss -ltnp | rg ':<local-socks-port>|ssh|LISTEN'
```

## Case: Forward An Existing Proxy

Use this when a proxy service already exists on or behind the SSH middle host. This does not create a SOCKS proxy from SSH itself; it maps an existing proxy endpoint onto the chosen local bind address.

Proxy on the SSH host:

```bash
ssh -N \
  -L <local-bind-address>:<local-port>:<remote-proxy-bind-address>:<remote-proxy-port> \
  -o ExitOnForwardFailure=yes \
  <ssh-middle-alias>
```

Proxy on another host reachable from the SSH host:

```bash
ssh -N \
  -L <local-bind-address>:<local-port>:<proxy-host-reachable-from-middle>:<remote-proxy-port> \
  -o ExitOnForwardFailure=yes \
  <ssh-middle-alias>
```

Then use the local proxy according to its protocol:

```bash
curl -x http://<local-proxy-host>:<local-port> -I --max-time 10 <test-url>
curl --socks5-hostname <local-proxy-host>:<local-port> -I --max-time 10 <test-url>
```

If this tunnel should be persistent and it forwards `<local-bind-address>:<local-port>` to the SSH host's own proxy bind address and port, use the bundled `setup-ssh-forward-tunnel.sh` pattern from `references/ssh-tunnels.md`. If the destination is a third host behind the middle host, write a direct `ssh -L` systemd unit because the bundled script only forwards to the remote host's loopback.

## Case: Direct Single-Service Forward

Use this when the tool cannot use a proxy and only one target host/port is needed:

```bash
ssh -N \
  -L <local-bind-address>:<local-port>:<target-host-reachable-from-middle>:<target-port> \
  -o ExitOnForwardFailure=yes \
  <ssh-middle-alias>
```

Then access:

```text
<local-service-url>
```

Do not use this for web apps that emit absolute URLs pointing back to the original internal host unless the client can resolve and reach those URLs through another proxy path.

## Validation

Check the local listener:

```bash
ss -ltnp | rg ':<local-port-or-socks-port>|ssh|LISTEN'
```

Test through SOCKS5:

```bash
curl --socks5-hostname <local-proxy-host>:<local-socks-port> -I --max-time 10 <target-url>
```

Test through HTTP proxy:

```bash
curl -x http://<local-proxy-host>:<local-port> -I --max-time 10 <test-url>
```

Inspect SSH config before making persistent units:

```bash
ssh -G <ssh-middle-alias> | sed -n '1,80p'
ssh -o BatchMode=yes -o ConnectTimeout=8 <ssh-middle-alias> 'echo ok'
```

## Safety Rules

- Bind local proxy listeners to a loopback-only address by default.
- Do not bind proxy listeners to a wildcard or externally reachable address unless the user explicitly asks for LAN exposure and accepts the risk.
- Do not store concrete private hostnames, private IPs, usernames, or live proxy inventory in this reference.
- For persistent services, require public-key SSH auth and a stable SSH config alias before creating the unit.
- Prefer `socks5h://` for Git and HTTP clients when the destination hostname is only resolvable from the SSH middle host.
