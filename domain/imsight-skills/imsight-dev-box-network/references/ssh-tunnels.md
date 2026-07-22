# SSH Tunnels

Use this reference to set up, inspect, repair, or remove SSH reverse and forward tunnels on Imsight development boxes.

## Workflow

1. Apply **Common Policy** and install or refresh the bundled scripts.
2. Create and verify the relay SSH alias.
3. Gather missing inputs using **Interactive Intake For Vague Requests**.
4. Select tmux or user systemd, then execute the matching reverse, forward, inspection, or cleanup procedure.
5. Verify the requested tunnel and preserve unrelated working tunnels.
6. Use **Troubleshooting** when validation fails.

If the task does not map cleanly to these steps, plan only from the documented tunnel directions, runtime modes, scripts, and safety rules; ask for missing endpoints, ports, or exposure intent.

## Common Policy

- First create an SSH config `Host` entry for the tunnel server/relay and make it work with public-key authentication. Do not build persistent tunnel services around raw IPs until the alias is stable and `ssh -o BatchMode=yes <alias> true` succeeds.
- For reverse tunnels whose main purpose is exposing SSH login to a relay, bind the remote listener to the relay's localhost: pass `--remote-bind-addr 127.0.0.1`. Access the tunnel through `ProxyJump` unless the user explicitly asks for direct exposure.
- For other reverse tunnels, default to `--remote-bind-addr 0.0.0.0` so the relay exposes the service externally. Use localhost only when the user states it should be private to the relay.
- For forward tunnels, bind the local listener to localhost through `scripts/setup-ssh-forward-tunnel.sh`; the script maps `127.0.0.1:<local-port>` to the remote host's `127.0.0.1:<remote-port>`.
- There are two supported runtime modes:
  - Tmux mode: run tunnels as foreground processes in a persistent tmux session.
  - Systemd mode: run each tunnel as a user systemd service.
- When multiple tunnels are opened in tmux mode, put them in different windows of the same tmux session.
- User systemd tunnel services must not delay boot, shutdown, or reboot. For every systemd tunnel unit this skill creates, run the tunnel script in foreground `--block` mode under `Type=simple`, do not use `--background`/`nohup`, do not wait for network readiness or tunnel readiness, and allow systemd to kill the whole service control group quickly on stop.

## Bundled Scripts

Use the scripts from this skill:

```text
scripts/setup-ssh-reverse-tunnel.sh
scripts/setup-ssh-forward-tunnel.sh
```

Install or refresh them on a target host:

```bash
mkdir -p "$HOME/bin"
cp /path/to/skill/scripts/setup-ssh-reverse-tunnel.sh "$HOME/bin/setup-ssh-reverse-tunnel.sh"
cp /path/to/skill/scripts/setup-ssh-forward-tunnel.sh "$HOME/bin/setup-ssh-forward-tunnel.sh"
chmod +x "$HOME/bin/setup-ssh-reverse-tunnel.sh" "$HOME/bin/setup-ssh-forward-tunnel.sh"
```

If the host already uses `~/setup-ssh-reverse-tunnel.sh` and `~/setup-ssh-forward-tunnel.sh`, either replace those paths intentionally or write the systemd unit to the copied `~/bin/...` paths.

## Step 1: Create Relay SSH Config

Create or update a `Host` entry for the tunnel server before creating any tunnel. Use public-key authentication through `IdentityFile`; do not rely on password prompts for persistent tunnels.

Example:

```sshconfig
Host <relay-alias>
  HostName <relay-host-or-ip>
  Port <ssh-port>
  User <relay-user>
  IdentityFile ~/.ssh/<private-key-file>
  IdentitiesOnly yes
  ServerAliveInterval 20
  ServerAliveCountMax 60
```

Validate the alias:

```bash
ssh -G <relay-alias> | sed -n '1,80p'
ssh -o BatchMode=yes -o ConnectTimeout=8 <relay-alias> 'echo ok'
```

If `BatchMode=yes` fails, fix keys, `IdentityFile`, username, port, or host key prompts before configuring tmux or systemd tunnel runtime.

## Interactive Intake For Vague Requests

If the user only says something like "setup ssh tunnel", "create tunnel", or "make a relay tunnel", do not guess. Ask for the missing required information before creating scripts, tmux windows, services, or SSH config.

Ask concise questions in this order:

1. Tunnel direction: reverse tunnel from this dev box to a relay, or forward tunnel from this dev box to a remote service?
2. Purpose: SSH login exposure, or another service?
3. Tunnel server/relay SSH alias: existing `Host` alias or host/user/port/key needed to create one?
4. Ports: local target port and remote exposed port for reverse tunnels; local listen port and remote service port for forward tunnels. For SSH-login reverse tunnels, always ask for both the local SSH port and the remote exposed port; do not assume either one.
5. Runtime mode: tmux foreground session or user systemd service?
6. Bind policy: for SSH-login reverse tunnels default to relay `127.0.0.1`; for other reverse tunnels default to `0.0.0.0`; ask only if the user may want the opposite.
7. Persistence: if systemd mode, should lingering be enabled when permission is available?

Minimal prompt:

```text
To set up the SSH tunnel, I need:
1. reverse or forward?
2. SSH-login tunnel or service tunnel?
3. relay/remote SSH alias, or host/user/port/key to create one?
4. ports? For SSH-login reverse tunnels, provide both local SSH port and remote exposed port.
5. tmux foreground or systemd service?
```

Once the user answers, normalize the result into a concrete plan:

```text
Direction:
Relay/remote alias:
Local target/listen port:
Remote exposed/service port:
Remote bind address:
Runtime mode:
Service or tmux session/window name:
```

## Runtime Mode A: Tmux Foreground Session

Use tmux mode when iterating, testing, or when the user wants foreground visibility without systemd installation.

Create one shared session for networking tunnels:

```bash
SESSION="devbox-tunnels"
tmux new-session -d -s "$SESSION" -n "rev-<remote-port>"
tmux send-keys -t "$SESSION:rev-<remote-port>" \
  '~/setup-ssh-reverse-tunnel.sh --remote-addr <relay-alias> --remote-port <remote-port> --local-port <local-port> --remote-bind-addr <bind-addr> --block' C-m
```

Add another tunnel as a new window in the same session:

```bash
tmux new-window -t "$SESSION" -n "fwd-<local-port>"
tmux send-keys -t "$SESSION:fwd-<local-port>" \
  '~/setup-ssh-forward-tunnel.sh --remote-addr <remote-alias> --remote-port <remote-port> --local-port <local-port> --block' C-m
```

Inspect:

```bash
tmux list-windows -t "$SESSION"
tmux attach -t "$SESSION"
```

Stop one tunnel by killing its window:

```bash
tmux kill-window -t "$SESSION:rev-<remote-port>"
```

Stop all tunnels in the session:

```bash
tmux kill-session -t "$SESSION"
```

The bundled scripts also support their own `--tmux` mode, but that creates per-tunnel sessions such as `ssh-tunnel-<remote-port>` or `ssh-fwd-<local-port>`. For multi-tunnel setups, prefer the shared-session/multiple-window pattern above.

## Runtime Mode B: User Systemd Service

Use systemd mode when the tunnel should survive logout and restart automatically.

Keep tunnel units reboot-friendly. For systemd, do not start the tunnel script with `--background`: systemd would track the short-lived wrapper instead of the real tunnel process, which weakens restart, logging, and cleanup. Use `Type=simple` with foreground `--block`; systemd treats the service as started when the script process is launched, not when the SSH tunnel becomes reachable. That immediate "started" state is intentional because the tunnel can recover in its own reconnect loop after the relay or network appears.

Do not make units wait on `network-online.target`, `ExecStartPre` SSH checks, remote listener probes, or custom readiness loops. A missing or slow relay should not slow login, shutdown, or reboot. Use `After=network.target`, foreground `ExecStart`, and immediate stop behavior:

```ini
After=network.target
TimeoutStopSec=1
KillMode=control-group
KillSignal=SIGKILL
SendSIGKILL=yes
```

For bundled tunnel scripts in systemd units, omit readiness/status checks. The reconnect loop should handle slow or unreachable remotes without making systemd wait. If the user explicitly asks for health reporting, put it in inspection commands, logs, or a separate monitor rather than in service startup or shutdown.

Create the unit under:

```text
~/.config/systemd/user/<service-name>.service
```

Enable and start:

```bash
systemctl --user daemon-reload
systemctl --user enable --now <service-name>.service
```

If the tunnel must keep running when the user is logged out and the user has sudo permission, enable lingering:

```bash
loginctl enable-linger "$USER"
```

If `loginctl enable-linger "$USER"` fails due to permission, leave the service enabled and tell the user that lingering still needs an admin.

## Inspect Existing Tunnels

Local process and unit scan:

```bash
ps -eo pid,ppid,stat,lstart,command | rg -i 'ssh -[NfMTLDR]|autossh|setup-ssh-(reverse|forward)-tunnel'
systemctl --user list-units --type=service --all | rg -i 'ssh-(rev|fwd)|tunnel'
systemctl --user list-unit-files | rg -i 'ssh-(rev|fwd)|tunnel'
```

Port scan:

```bash
ss -ltnp | rg ':<port>|ssh|LISTEN'
```

Service detail:

```bash
systemctl --user status ssh-rev-<remote-port>.service --no-pager
journalctl --user -u ssh-rev-<remote-port>.service -n 80 --no-pager
```

SSH config resolution:

```bash
ssh -G <relay-alias> | sed -n '1,80p'
```

Remote relay probe:

```bash
ssh -o BatchMode=yes -o ConnectTimeout=8 <relay-alias> 'hostname; command -v ss >/dev/null && ss -ltn || netstat -ltn 2>/dev/null || true'
```

## Reverse Tunnel For SSH Login

Use this pattern when the tunnel exposes a dev box SSH daemon through a relay.

Always ask the user for both:

- `local-ssh-port`: the SSH daemon port on the dev box.
- `relay-local-port`: the port opened on the relay.

Do not assume the local SSH port is `22`, and do not invent a remote relay port.

Command:

```bash
~/setup-ssh-reverse-tunnel.sh \
  --remote-addr <relay-alias> \
  --remote-port <relay-local-port> \
  --local-port <local-ssh-port> \
  --remote-bind-addr 127.0.0.1 \
  --block
```

Example user systemd service:

```ini
[Unit]
Description=SSH reverse tunnel <host>:ssh -> <relay>:<remote-port> (localhost only)
After=network.target

[Service]
Type=simple
ExecStart=%h/setup-ssh-reverse-tunnel.sh --remote-addr <relay-alias> --remote-port <remote-port> --local-port <local-ssh-port> --remote-bind-addr 127.0.0.1 --block
Restart=always
RestartSec=10
TimeoutStopSec=1
KillMode=control-group
KillSignal=SIGKILL
SendSIGKILL=yes

[Install]
WantedBy=default.target
```

Enable:

```bash
systemctl --user daemon-reload
systemctl --user enable --now ssh-rev-<remote-port>.service
loginctl enable-linger "$USER"
```

Client SSH config should use `ProxyJump` through the relay:

```sshconfig
Host <devbox>-proxy
  HostName 127.0.0.1
  Port <remote-port>
  User <user>
  IdentityFile ~/.ssh/<private-key-file>
  ForwardX11 yes
  ProxyJump <relay-alias>
```

## Reverse Tunnel For Non-SSH Services

Use this when the user wants a dev-box service exposed from the relay.

Default public relay bind:

```bash
~/setup-ssh-reverse-tunnel.sh \
  --remote-addr <relay-alias> \
  --remote-port <relay-public-port> \
  --local-port <local-service-port> \
  --remote-bind-addr 0.0.0.0 \
  --block
```

Private relay-only bind:

```bash
~/setup-ssh-reverse-tunnel.sh \
  --remote-addr <relay-alias> \
  --remote-port <relay-local-port> \
  --local-port <local-service-port> \
  --remote-bind-addr 127.0.0.1 \
  --block
```

Name the systemd unit `ssh-rev-<remote-port>.service` unless a more specific service name is clearer.

## Forward Tunnel

Use this when the dev box needs local access to a service reachable only from a remote host.

Command:

```bash
~/setup-ssh-forward-tunnel.sh \
  --remote-addr <remote-alias> \
  --remote-port <remote-service-port> \
  --local-port <local-port> \
  --block
```

Example user systemd service:

```ini
[Unit]
Description=SSH forward tunnel localhost:<local-port> -> <remote-alias>:<remote-port>
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
ExecStart=%h/setup-ssh-forward-tunnel.sh --remote-addr <remote-alias> --remote-port <remote-port> --local-port <local-port> --block
Restart=always
RestartSec=10
TimeoutStopSec=1
KillMode=control-group
KillSignal=SIGKILL
SendSIGKILL=yes

[Install]
WantedBy=default.target
```

## Remove Dead Tunnel Service

Use this when a remote alias no longer resolves or the remote service is permanently gone.

```bash
systemctl --user stop ssh-fwd-<local-port>.service || true
systemctl --user disable ssh-fwd-<local-port>.service || true
rm -f "$HOME/.config/systemd/user/ssh-fwd-<local-port>.service"
systemctl --user daemon-reload
systemctl --user reset-failed ssh-fwd-<local-port>.service || true
```

Verify cleanup:

```bash
ps -ef | rg 'setup-ssh-forward-tunnel|ssh-fwd-<local-port>|:<local-port>|<remote-alias>' || true
ss -ltn | awk '$4 ~ /:<local-port>$/ {print}'
systemctl --user list-units --type=service --all | rg -i 'ssh-fwd|<local-port>|ssh-rev|tunnel' || true
```

## Troubleshooting

- `Could not resolve hostname <alias>`: the SSH config alias is missing or stale. Remove the dead service if the remote is gone; otherwise add/fix the alias in `~/.ssh/config`.
- Exit code `255`: generic SSH failure. Check DNS/alias, key auth, host key prompt, remote reachability, and remote `AllowTcpForwarding`.
- No listener after service start: check `journalctl --user -u <service> -n 80 --no-pager` and confirm the script has `ExitOnForwardFailure=yes`.
- Remote `ss` missing: try `netstat -ltn`, `lsof -i`, or `nc -z`.
