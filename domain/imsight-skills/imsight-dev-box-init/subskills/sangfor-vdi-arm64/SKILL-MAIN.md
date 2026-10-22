---
name: sangfor-vdi-arm64
description: Use when setting up the Sangfor VDI (aDesk / 深信服桌面云) Linux client on an arm64/aarch64 Ubuntu host, when the x86_64-only client must run under qemu-user or box64 instruction translation inside Docker, when the VDI gateway is reachable only through an intermediate SSH host or HTTP proxy, or when vdi_session dies a few seconds after login (libusb hotplug NULL-context SIGSEGV).
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

# Sangfor VDI Client on arm64 Ubuntu

## Overview

Run the Sangfor VDI Linux client on an arm64 Ubuntu box by executing the official x86_64 Ubuntu package inside a qemu-user amd64 Docker container, displaying its windows on the host's X desktop, optionally bridging all client TCP traffic through an intermediate SSH-reachable host. A known post-login `vdi_session` crash (NULL libusb context in the hotplug listener) is repaired with a small, version-checked binary patch.

## When to Use

Use this subskill when an arm64 Ubuntu host (Jetson, RK, DGX-class, or similar) must run the Sangfor VDI client; when the client GUI must appear on the host's existing X or RDP desktop; when the VDI gateway sits behind a network only reachable via an intermediate SSH host; or when an existing setup loses its session a few seconds after the desktop windows appear. Do not use it on x86_64 hosts (install the native package directly), for other VDI vendors, or when the host has no Docker and cannot get qemu-user binfmt.

## Workflow

1. Confirm the target environment: arm64 Ubuntu host with Docker, a running X server (local or RDP), and network reachability to the VDI gateway either directly or through an intermediate host.
2. If the gateway is not directly reachable, set up bridging first with `network-bridge()`; otherwise skip it.
3. Build and launch the client with `qemu-container-setup()`; verify the login window appears on the desktop.
4. Have the user log in and open their desktop resource; the user types credentials, never the agent.
5. If the session window appears and then dies within a few seconds, apply `session-crash-fix()` and retry.
6. Report the container name, start/stop runbook, and any remaining limitations (USB redirection, UDP media).

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this subskill's commands, resources, constraints, and user request, then execute the plan. For assessment of the native arm64 or box64 routes before committing to qemu, consult `native-routes()`.

## Invocation Contract

- Invoke `imsight-dev-box-init->sangfor-vdi-arm64` to summarize this subskill.
- Invoke a command as `imsight-dev-box-init->sangfor-vdi-arm64-><subcommand>()`.
- Invoke `imsight-dev-box-init->sangfor-vdi-arm64->help()` to list the commands below.

## Subcommands

### Procedural Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `qemu-container-setup` | Build and run the amd64 Ubuntu client container under qemu-user binfmt and show its GUI on the host X desktop. | `references/qemu-container-setup.md` |
| `network-bridge` | Reach an isolated VDI gateway through an intermediate SSH host or HTTP proxy when the arm64 host has no direct route. | `references/network-bridge.md` |
| `session-crash-fix` | Diagnose and binary-patch the post-login `vdi_session` SIGSEGV caused by a NULL libusb context in the hotplug listener. | `references/session-crash-fix.md` |
| `client-feature-tuning` | Enable the rvldisk mapped drive, use clipboard file copy, or run the session windowed at a chosen resolution after basic setup works. | `references/client-feature-tuning.md` |
| `native-routes` | Assess the native arm64 deb and box64 routes, their packaging prerequisites, and their known failure modes. | `references/native-routes.md` |

### Helper Subcommands

No helper subcommands are currently exposed.

### Misc Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `help` | Explain this subskill and list its commands. | This entrypoint |

## Resource Ownership

This subskill owns the four setup and forensics references plus the helper scripts `parse-qemu-core.py` (qemu guest-core register parser), `disasm-window.py` (capstone disassembly helper), and `start-vdi-container.sh` (generic container launcher template).

## Guardrails

- DO NOT modify, SSH-configure, or install anything on the intermediate proxy host or the VDI gateway; use only endpoints that already exist there.
- DO NOT wrap `vdi_session` or the client agents in shell-script wrappers; the client's securestart check rejects a mismatched `/proc/self/exe`.
- DO NOT inject symbol-interposition libraries (wrappers for `kill`, `sigaction`, `waitpid`, and similar) into client processes under qemu-user; they segfault the client at startup.
- DO NOT hardcode hotplug patch offsets for any client build other than the one they were derived from; re-derive offsets per package version with the forensics recipe.
- DO NOT record gateway addresses, credentials, VDI resource names, or session screen contents in the skill sources, committed notes, or reports.
- DO NOT let loopback traffic enter the proxy path; the client talks to its own local agent on `127.0.0.1`.
- DO NOT drive the in-session toolbar's power-off, restart, or restore-snapshot buttons during automated checks; they act on the user's VM immediately.
- DO NOT rely on iptables or nftables inside containers when the host kernel lacks container netfilter support; proxy at the `LD_PRELOAD` layer instead.

## Troubleshooting Guide

- Login window quits with a client-update or version-check message
  - If the launcher leaves the package's install/update flag files behind, then remove `/etc/sangfor/vdiclient/is_installing_depend` and `/run/sangfor/vdiclient/is_updating` at every container start.
- Captcha image is blank or unreadable
  - If the bundled Qt4 cannot decode GIF, then install the package's `imageformats` plugins (notably `libqgif.so`) into the client's Qt plugin path.
- Session window appears then vanishes after two to three seconds with no error in client logs
  - If the session dies silently, then follow `session-crash-fix()`: obtain a qemu guest core from a writable guest cwd and identify the faulting call.
- After login the UI reports a resource or network failure even though the proxy is fine
  - If this message appears after the session process died, then treat it as the session crash, not a network problem; inspect `vdi_session.log` first.
- No qemu guest core is produced after a crash
  - If the guest cwd is not writable by the container user, then launch the agents from the container user's home directory so qemu can write `qemu_<comm>_<ts>_<pid>.core` there.
- Trace or stderr from spawned client processes is missing
  - If `vdi_session` or `vdi_client` output is absent, then export the diagnostics environment (`QEMU_STRACE`, preload libraries) to the agent process that spawns them, because children inherit it from there.
- Xcursor warnings or cursor-theme lookups for an all-zero hash appear right before a crash
  - If the container image ships a stripped icon theme without a `cursors/` directory, then install a full cursor theme set; note this fixes cursor rendering noise only, not the hotplug session crash.
- Session works but the VM shows no mapped drive
  - If `vdi_session.log` shows `check_path` failing with an empty path, then install the `xdg-user-dir` shim and Desktop directory from `client-feature-tuning()`; the client resolves the share folder through that tool.
- Session always opens fullscreen despite a windowed display config
  - If the log shows `exit_full_screen` immediately followed by `enter_full_screen` at connect, then treat startup fullscreen as build behavior and switch to windowed from the in-session toolbar; the choice persists per VM.
