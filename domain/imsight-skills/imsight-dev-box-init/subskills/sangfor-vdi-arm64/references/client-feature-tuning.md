---
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

# Client Feature Tuning: Mapped Drive, Clipboard, Resolution

Use this reference after the client basically works (login + session up) to enable the RDP-style mapped drive, use clipboard file copy, or run the session windowed at a chosen resolution. All fixes are designed to be re-applied idempotently by the container launcher on every start.

## Workflow

1. For a missing mapped drive in the VM, follow **Mapped Drive (rvldisk)**.
2. For ad-hoc one-way file upload, follow **Clipboard File Copy**.
3. For windowed or non-native resolution sessions, follow **Resolution and Windowed Mode**.
4. Verify each change in a fresh session using the log lines named in each section.

If the client version differs from the verified one, re-derive any binary-patch offsets with the recipe in `imsight-dev-box-init->sangfor-vdi-arm64->session-crash-fix()` before applying them.

## Mapped Drive (rvldisk)

Symptom: the session works, but no shared/mapped drive appears in the VM, and `vdi_session.log` shows `DvcRvlDiskInstance::check_path` failing with `path  is invalid ,only abs path is accept` (empty path) right after `DvcRvlDisk peer version ...`, then `mount disk error !`.

Root cause: the client resolves the local folder to share by shelling out to `xdg-user-dir` (`xdg-user-dir DESKTOP`, plus a bare call for the home dir). Minimal container images do not ship `xdg-user-dirs`, so both paths come back empty and the mount never happens. The VDC side is usually fine (look for `Get LocalDiskRight 1` in `vdi_client.log`).

Fix, no binary patch needed:

1. Install a shim at `/usr/local/bin/xdg-user-dir` (and `/usr/bin/` for PATH variance) that prints `$HOME/Desktop` for `DESKTOP` and `$HOME` for other/bare invocations — or install the real `xdg-user-dirs` package when apt works.
2. Create the container user's `~/.config/user-dirs.dirs` with at least `XDG_DESKTOP_DIR="$HOME/Desktop"`, and create the `Desktop` directory.
3. To expose a host directory, bind-mount it into the container (for example `/home/<user>/vdi-share` → `/home/<vdiuser>/vdi-share`) and symlink `Desktop` → that dir; rvldisk follows the symlink.

Verify: after a new session starts, `vdi_session.log` shows `mount rvldisk /home/<vdiuser> success with access <n> and map name <hex>` and `recv add folder map reply`; the VM's file explorer shows a new mapped drive.

Direction and policy: upload (client → VM) works when the VDC grants LocalDiskRight; download (VM → client) may be policy-blocked by design — do not try to bypass VDC policy. The `mappath`/`homepath`/`desktoppath`/`pathaccess` session params come from VDC data with client-side defaults; an empty `mappath` in that JSON is normal on Linux and does not gate rvldisk.

## Clipboard File Copy

The RVLCLIP dynamic channel handles file copy through the clipboard: the client watches the host X clipboard with XFixes, and when a file copy lands (e.g. `x-special/gnome-copied-files` from the Files app), it claims ownership and streams the file to the VM on paste. No configuration is needed beyond a working session.

Usage: copy the file in the host file manager, then Ctrl+V inside the VM's Explorer. Check `vdi_session.log` for `XFixesSetSelectionOwnerNotify` and `new clipboard owner: client` if it misbehaves.

## Resolution and Windowed Mode

Mechanics found on the 5.9.1.3028 amd64 build:

- Per-VM display state lives in `/etc/sangfor/vdiclient/vdi_session_conf/vdi_session_display_status_<vmid>.conf` (`isfullscreen`, `displaymode`, `windowlen_w/h`, window position). The client reads it at session start and rewrites it when a session ends, so in-session display choices persist.
- At startup this build still force-enters fullscreen: the log shows `exit_full_screen` (honoring the conf) immediately followed by `enter_full_screen`, even with `isfullscreen=false` and with the session param `"fullscreen":"false"`. Treat startup fullscreen as the default; plan on toggling after connect.
- In-session control: the floating toolbar (adesk bar) has display toggles (`最大化` maximize/restore, `切换到单屏` single-screen on multi-monitor VMs). Toggling to windowed persists via the conf. Never drive the toolbar's power-off, restart, or restore-snapshot items during automation.
- `/etc/sangfor/vdiclient/display_resolution.conf` (absent by default) can pin the offered resolution list; `DisplayManager::check_resolution_enable` gates modes.
- Two version-specific `vdi_client` patches are relevant here (5.9.1.3028 amd64, `vdi_client` 1230456 bytes): the session-param default `fullscreen=true` → `"false"` at file offset `0x39e19` (`be 7e 3a 4b 00` → `be 8c 54 4b 00`), and the `mappath` default `""` → `"/home/"` at file offset `0x32d3e`. Both are optional tuning, verified to land in the session-params JSON; neither alone disables startup fullscreen.
- To target 1920×1080: set `isfullscreen=false`, `windowlen_w=1920`, `windowlen_h=1080` in the per-VM conf, start the session, then exit fullscreen from the toolbar; the guest follows the window through the agent's monitor-config messages.

## Guardrails

- DO NOT create share paths outside the container user's home or world-writable roots; rvldisk rejects non-absolute and root paths.
- DO NOT bypass VDC transfer policy (e.g. enabling download when the admin blocked it); limit fixes to client-side plumbing.
- DO NOT apply the listed patch offsets to any client build other than the verified one.
