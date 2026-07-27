---
name: imsight-dev-box-network
description: Use when explicitly invoking imsight-dev-box-network, routing from another Imsight skill, or using Imsight context to configure, audit, repair, or document dev-box networking, SSH tunnels, proxy access, relay access, exposed ports, remote Playwright browser control, headless NVIDIA VNC/RDP hybrid consoles, systemd user tunnel services, or host-to-host access. Do not use for generic networking tasks without Imsight context.
---

# Imsight Dev Box Network

## Overview

Use this skill as the entrypoint for development box networking tasks. Keep `SKILL.md` as a command router and load the specific networking reference needed for the task.

## When to Use

- Use for an explicit `imsight-dev-box-network` invocation or route from another Imsight skill.
- Use when `imsight` context requests supported proxy, tunnel, relay, port, systemd, or host-access work.
- Use when an Imsight dev box must host a visible Chrome instance for control by a remote Playwright client.
- Use when an NVIDIA-backed Ubuntu server needs a monitorless VNC bootstrap at the physical GDM login screen and explicitly switchable VNC or GNOME Desktop Sharing RDP access to the same local desktop after login.
- Do not use for generic networking, proxy, tunnel, or dev-box tasks without Imsight context.

## Workflow

1. If no subcommand or actionable task is present, handle `help`.
2. Load the named networking page, or select the applicable subcommand or sequence from a task-only request.
3. Select any second-level operation from that page.
4. For `proxy-scan`, obtain the port range, run the bundled scanner, and persist candidates only when requested.
5. For `chrome-start-for-remote-control`, gather the local runtime and port plus the remote transport inputs, then keep the Playwright endpoint private to loopback and print the exact remote handoff instructions.
6. For `setup-vnc-rdp-hybrid`, confirm the NVIDIA/GDM/Xorg scope, choose distinct bootstrap VNC, desktop VNC, and RDP ports plus an exposure policy, preserve current configuration, then require clean-boot and both-mode verification before completion.
7. For `via-ssh`, distinguish dynamic SOCKS5 from forwarding an existing proxy before choosing commands or units.
8. For vague tunnel requests, ask for the required details; inspect current services and ports before changes.
9. Prefer user systemd for persistent tunnels unless tmux or foreground operation is requested, and apply the non-blocking unit rules below.
10. For cleanup, remove only the requested stale service or process and verify the intended reverse SSH access tunnel remains healthy.

If the task does not map cleanly to these steps, use your native planning tool with the existing networking references, bundled scripts, output contract, and safety rules; ask for missing topology instead of guessing.

## Invocation Contract

- Preferred explicit form: `$imsight-dev-box-network use <subcommand> to do <task>`.
- Proxy setup second-level form: `$imsight-dev-box-network use proxy-setup <subcommand> to do <task>`.
- Task-only form: `$imsight-dev-box-network <task prompt>` means choose the applicable networking subcommand or sequence from the task.
- No subcommand and no task means `help`.
- `help` summarizes this skill and lists the subcommands below.

## Output Contract

When this skill writes networking notes, scan reports, manifests, or other skill-owned artifacts, choose the output directory in this order:

1. Use the output location explicitly provided by the user.
2. Otherwise, use `IMSIGHT_SKILL_OUTPUT_DIR` when set; relative values are resolved from the current project directory and absolute values are used as-is.
3. Otherwise, use `<project-dir>/.imsight-arts/dev-box-network/`.

This contract does not replace intentional operational destinations such as copied helper scripts, shell startup files, or user systemd service files required by a networking setup workflow.

## Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `help` | Explain this dev-box networking skill and list available subcommands | This entrypoint |
| `ssh-tunnels` | Set up, inspect, repair, or remove SSH reverse/forward tunnels | `references/ssh-tunnels.md` |
| `proxy-setup` | Set up proxy access, install proxy environment scripts, or scan proxy candidates | `references/proxy-setup.md` |
| `chrome-start-for-remote-control` | Launch visible local Chrome through a native Playwright endpoint and prepare secure remote client access | `commands/chrome-start-for-remote-control.md` |
| `chrome-attach-for-remote-control` | Attach a local Playwright client or CLI to a remotely run Chrome instance | `commands/chrome-attach-for-remote-control.md` |
| `setup-vnc-rdp-hybrid` | Configure GDM bootstrap VNC plus mutually exclusive desktop VNC/RDP access to the GPU-rendered physical console on a headless NVIDIA host | `commands/setup-vnc-rdp-hybrid.md` |

## Bundled Scripts

Use the bundled scripts instead of rewriting persistent transport loops or scanners:

- `scripts/setup-ssh-reverse-tunnel.sh`
- `scripts/setup-ssh-forward-tunnel.sh`
- `scripts/scan-proxy-candidates.py`
- `scripts/setup-proxy.sh`
- `scripts/unset-proxy.sh`
- `scripts/x11vnc-gdm-bootstrap-loop.sh`
- `scripts/x11vnc-hybrid-desktop-loop.sh`
- `scripts/remote-desktop-mode.sh`

The headless NVIDIA hybrid workflow also owns `assets/vnc-console-edid.bin.base64`,
the validated synthetic-monitor EDID that its command installs after decoding.

Copy them to the target dev box when missing or stale, make them executable, then create or update the matching user systemd service.

## Safety Rules

- Do not store real host inventory, private IPs, public IPs, live ports, usernames, relay aliases, or service names from the current machine in this skill.
- Do not expose SSH login tunnels on `0.0.0.0` unless the user explicitly asks.
- Do not remove working reverse SSH login tunnels while cleaning unrelated forward tunnels.
- Do not embed credentials or private keys in service files or docs.
- Do not expose an unencrypted VNC listener beyond a trusted network or authenticated tunnel.
- Do not replace a GPU-backed shared console with a TigerVNC, Xvnc, or other separate virtual desktop when the request requires the GDM login path, local-console mirroring, or hardware rendering.
- Do not use one x11vnc process or supervisor to migrate between GDM and the logged-in GNOME X11 server. Use separate bootstrap and desktop processes, separate ports, a stable-shell delay, and an explicit mutually exclusive desktop VNC/RDP mode switch.
- Use `BatchMode=yes` for non-interactive connectivity checks.
- For systemd tunnel services, use foreground `--block` under `Type=simple`; do not use `network-online.target`, `ExecStartPre` connectivity checks, readiness waits, `--background`, or `nohup`; keep shutdown fast with `TimeoutStopSec=1`, `KillMode=control-group`, `KillSignal=SIGKILL`, and `SendSIGKILL=yes`.
- Do not create tunnel units that can delay boot, shutdown, or reboot while waiting for SSH readiness or graceful disconnect.

## Guardrails

- DO NOT guess tunnel topology, aliases, ports, or exposure requirements.
- DO NOT rewrite bundled tunnel loops.
- DO NOT expose SSH login tunnels publicly without an explicit request.
- DO NOT create systemd units that block startup or shutdown.
- DO NOT remove a working reverse SSH access tunnel while cleaning unrelated forwarding.
- DO NOT claim a headless hybrid deployment is complete before verifying the actual GDM greeter, both mutually exclusive desktop modes, the NVIDIA OpenGL renderer, and no fresh NVIDIA Xid/GSP fault after a clean boot.
