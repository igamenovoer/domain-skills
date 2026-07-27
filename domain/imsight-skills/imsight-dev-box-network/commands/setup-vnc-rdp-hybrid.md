# Set Up a Headless NVIDIA VNC/RDP Hybrid Console

Configure a new Ubuntu host with GDM and the proprietary NVIDIA driver so VNC reaches the physical GDM chooser before login, while the logged-in physical GNOME desktop can use either VNC or GNOME Desktop Sharing RDP. Keep the bootstrap VNC, desktop VNC, and RDP lifetimes separate.

## Workflow

1. **Confirm scope and inputs**. Require GDM, GNOME on Xorg, a working proprietary NVIDIA driver, one target connector, three non-conflicting ports, a desktop user, and an exposure policy. See **Scope and Inputs**.
2. **Audit and back up the host**. Inspect current display, GPU, remote-access, and Xorg state before writing files. See **Preflight and Rollback Material**.
3. **Prepare GDM and the NVIDIA console**. Force GDM to Xorg, expose the user chooser, install the synthetic EDID, and configure the chosen NVIDIA connector. See **GDM and NVIDIA Display**.
4. **Install bootstrap VNC**. Install the root-owned GDM supervisor, password, configuration, and system unit. See **Bootstrap VNC**.
5. **Install logged-in transport controls**. Install the user-owned desktop VNC supervisor, password, mode command, configuration, and user unit. See **Desktop VNC and Mode Switch**.
6. **Configure GNOME Desktop Sharing**. Configure user Desktop Sharing credentials when a graphical user session exists, or defer them until the first VNC login; keep system Remote Login disabled. See **GNOME Desktop Sharing RDP**.
7. **Select the default mode and reboot**. Use desktop VNC for the first boot unless RDP has already been configured and verified, reboot from an independent management path, and leave GDM untouched until bootstrap verification.
8. **Verify every transition**. Test GDM VNC, the selected desktop transport, SSH mode switching in both directions, the local monitor view, NVIDIA rendering, and GPU logs. See **Verification**.
9. **Report the deployment** using **Output Contract**.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this page's inputs, scripts, service boundaries, verification gates, and guardrails, then execute the plan.

## Scope and Inputs

Use this command only when all of the following are required:

- Ubuntu with GDM and an X11 GNOME session.
- A proprietary NVIDIA driver rendering the physical console.
- VNC access to the real GDM chooser before any user login.
- The same logged-in desktop on remote clients and a locally attached monitor.
- Explicit switching between desktop VNC and GNOME Desktop Sharing RDP.
- Operation without a monitor through a synthetic EDID.

Do not use this command for Wayland-only GDM, Intel or AMD graphics, a compute-only host without a graphical stack, or an independent virtual desktop.

Resolve these inputs before changing the host:

| Input | Requirement |
| --- | --- |
| Desktop user | Existing non-system user allowed to start a GNOME graphical session. |
| NVIDIA connector | Exact Xorg/NVIDIA connector mapped to the intended physical HDMI or DisplayPort socket. |
| GPU BusID | Required when multiple GPUs or ambiguous device selection exist. |
| Default mode | Prefer 2560x1440 at 60 Hz; use 1920x1080 for an unknown physical monitor. |
| Bootstrap VNC port | Free port for GDM, such as 5902. |
| Desktop VNC port | Different free port for the logged-in desktop, such as 5903. |
| Desktop RDP port | Free GNOME Desktop Sharing port, normally 3389. |
| Default desktop mode | `vnc` for broad client compatibility or `rdp` for better performance. |
| Exposure policy | Default to loopback plus SSH. Broader trusted-LAN access requires explicit approval and firewall restriction. |
| Backup location | Timestamped root-only directory, normally below `/var/backups/imsight-vnc/`. |

The bundled synthetic EDID advertises 1920x1080, 2560x1440, 3840x2160, 1440x1080, 1920x1440, 2880x2160, 1600x1200, 1280x960, and 1024x768 at approximately 60 Hz. Its preferred mode is 2560x1440.

## Architecture

Use these independent transports:

| Seat state | Transport | Ownership |
| --- | --- | --- |
| GDM owns `seat0` | Bootstrap x11vnc | Root system service; `Class=greeter` only |
| Desktop user owns `seat0`, VNC mode | Desktop x11vnc | User service; stable `Class=user`, `Type=x11` only |
| Desktop user owns `seat0`, RDP mode | GNOME Desktop Sharing | Stock user service |

The bootstrap and desktop x11vnc processes must use different ports, password files, logs, users, and target-class checks. A VNC client reconnects to the desktop port after GDM login; one RFB connection cannot migrate between the independent GDM and user X servers.

The desktop mode command must stop and disable the old user transport, wait for its listener to close, then enable the selected transport. Desktop VNC and RDP must never be active together.

## Preflight and Rollback Material

Inspect the host:

~~~bash
test -r /etc/os-release && . /etc/os-release && printf '%s %s\n' "$ID" "$VERSION_ID"
systemctl status display-manager.service --no-pager
nvidia-smi
lsmod | rg '^nvidia'
pgrep -a -x Xorg || true
pgrep -a -f 'x11vnc|Xvnc|Xtigervnc|gnome-remote-desktop' || true
ss -ltnp | rg ':<bootstrap-vnc-port>\b|:<desktop-vnc-port>\b|:<rdp-port>\b' || true
~~~

Confirm the proprietary driver, GDM, GNOME packages, Xorg session support, free ports, and an independent SSH path. Identify existing VNC or RDP services before stopping or replacing them.

Create a root-only backup and preserve every file that will change:

~~~bash
sudo install -d -o root -g root -m 0700 /var/backups/imsight-vnc/<timestamp>
sudo cp -a /etc/gdm3/custom.conf \
  /var/backups/imsight-vnc/<timestamp>/custom.conf.pre-hybrid
sudo test ! -e /etc/X11/xorg.conf || sudo cp -a /etc/X11/xorg.conf \
  /var/backups/imsight-vnc/<timestamp>/xorg.conf.pre-hybrid
sudo test ! -e /etc/systemd/system/x11vnc-gdm-bootstrap.service || sudo cp -a \
  /etc/systemd/system/x11vnc-gdm-bootstrap.service \
  /var/backups/imsight-vnc/<timestamp>/
~~~

Record the selected user's existing enablement for `gnome-remote-desktop.service` and any pre-existing desktop VNC unit.

## GDM and NVIDIA Display

Install prerequisites:

~~~bash
sudo apt update
sudo apt install --yes x11vnc x11-utils mesa-utils edid-decode ripgrep iproute2 util-linux
~~~

Ensure `/etc/gdm3/custom.conf` contains:

~~~ini
[daemon]
WaylandEnable=false
AutomaticLoginEnable=false
TimedLoginEnable=false
~~~

Ensure `/etc/gdm3/greeter.dconf-defaults` contains, then compile it:

~~~ini
[org/gnome/login-screen]
disable-user-list=false
~~~

~~~bash
sudo dconf update
~~~

Resolve `<skill-dir>` to this skill's directory, decode the bundled EDID, validate it, and install it:

~~~bash
vnc_edid_tmp=$(mktemp)
trap 'rm -f "$vnc_edid_tmp"' EXIT
base64 --decode <skill-dir>/assets/vnc-console-edid.bin.base64 >"$vnc_edid_tmp"
edid-decode --check "$vnc_edid_tmp"
sudo install -o root -g root -m 0644 "$vnc_edid_tmp" /etc/X11/vnc-console-edid.bin
~~~

Discover the connector from an existing Xorg log or a temporary approved monitor. Do not assume `DFP-0`. On multi-GPU systems, derive the NVIDIA BusID from `lspci -Dnn`.

Create `/etc/X11/xorg.conf`, replacing every placeholder deliberately:

~~~ini
Section "Device"
    Identifier "NvidiaHeadless"
    Driver "nvidia"
    BusID "PCI:<bus>:<device>:<function>"
    Option "AllowEmptyInitialConfiguration" "True"
    Option "ConnectedMonitor" "<DFP-N>"
    Option "CustomEDID" "<DFP-N>:/etc/X11/vnc-console-edid.bin"
EndSection

Section "Monitor"
    Identifier "HeadlessConsole"
    VendorName "VNC"
    ModelName "Synthetic NVIDIA Console"
EndSection

Section "Screen"
    Identifier "HeadlessScreen"
    Device "NvidiaHeadless"
    Monitor "HeadlessConsole"
    DefaultDepth 24
    Option "MetaModes" "<DFP-N>: <default-mode> +0+0"
    SubSection "Display"
        Depth 24
        Modes "2560x1440" "1920x1080" "3840x2160" "1440x1080" "1920x1440" "2880x2160" "1600x1200" "1280x960" "1024x768"
    EndSubSection
EndSection
~~~

A physical monitor later attached to that configured port shares the same logical console. Its EDID is overridden, so it must support the selected timing.

## Bootstrap VNC

Create a dedicated root-owned password:

~~~bash
sudo x11vnc -storepasswd /etc/x11vnc-gdm.pass
sudo chown root:root /etc/x11vnc-gdm.pass
sudo chmod 0600 /etc/x11vnc-gdm.pass
~~~

Create root-owned `/etc/default/x11vnc-gdm-bootstrap`:

~~~bash
GDM_VNC_PORT=<bootstrap-vnc-port>
GDM_VNC_PASSWORD_FILE=/etc/x11vnc-gdm.pass
GDM_VNC_LOG_FILE=/var/log/x11vnc-gdm.log
GDM_VNC_LOCALHOST=yes
~~~

Use `GDM_VNC_LOCALHOST=no` only for an explicitly approved trusted-LAN listener with a restrictive firewall.

Install the bundled supervisor and `/etc/systemd/system/x11vnc-gdm-bootstrap.service`:

~~~bash
sudo install -o root -g root -m 0755 \
  <skill-dir>/scripts/x11vnc-gdm-bootstrap-loop.sh \
  /usr/local/sbin/x11vnc-gdm-bootstrap-loop
~~~

~~~ini
[Unit]
Description=x11vnc bootstrap server for the active GDM greeter
After=display-manager.service
Wants=display-manager.service

[Service]
Type=simple
ExecStart=/usr/local/sbin/x11vnc-gdm-bootstrap-loop
Restart=always
RestartSec=2
TimeoutStopSec=4
KillMode=control-group

[Install]
WantedBy=graphical.target
~~~

~~~bash
sudo systemctl daemon-reload
sudo systemctl enable x11vnc-gdm-bootstrap.service
~~~

The supervisor derives the active GDM Xorg PID, virtual terminal, X socket, and Xauthority dynamically. It never attaches when `seat0` is owned by a user session.

## Desktop VNC and Mode Switch

Run this section as the selected desktop user. Install the parent-owned scripts:

~~~bash
install -d -m 0755 "$HOME/.local/bin" "$HOME/.config/systemd/user"
install -d -m 0700 "$HOME/.config/x11vnc" "$HOME/.local/state/x11vnc"
install -m 0755 <skill-dir>/scripts/x11vnc-hybrid-desktop-loop.sh \
  "$HOME/.local/bin/x11vnc-hybrid-desktop-loop"
install -m 0755 <skill-dir>/scripts/remote-desktop-mode.sh \
  "$HOME/.local/bin/remote-desktop-mode"
x11vnc -storepasswd "$HOME/.config/x11vnc/passwd"
chmod 0600 "$HOME/.config/x11vnc/passwd"
~~~

Create `~/.config/remote-desktop-mode.conf`:

~~~bash
GDM_VNC_PORT=<bootstrap-vnc-port>
X11VNC_DESKTOP_PORT=<desktop-vnc-port>
GNOME_RDP_PORT=<rdp-port>
X11VNC_DESKTOP_LOCALHOST=yes
~~~

Use `X11VNC_DESKTOP_LOCALHOST=no` only with the same explicit trusted-LAN and firewall approval as bootstrap VNC.

Create `~/.config/systemd/user/x11vnc-desktop.service`:

~~~ini
[Unit]
Description=x11vnc server for the active local GNOME desktop
After=gnome-session.target
PartOf=gnome-session.target
ConditionPathExists=%h/.config/x11vnc/passwd

[Service]
Type=simple
EnvironmentFile=-%h/.config/remote-desktop-mode.conf
ExecStart=%h/.local/bin/x11vnc-hybrid-desktop-loop
Restart=always
RestartSec=2
TimeoutStopSec=4
KillMode=control-group

[Install]
WantedBy=gnome-session.target
~~~

The desktop supervisor runs as the user, requires that user to own the active physical X11 seat, waits for X11 GNOME Shell and eight stable target polls, and stops after the target is absent for several polls. It uses conservative x11vnc capture options to reduce compositor interactions.

Reload the user manager:

~~~bash
systemctl --user daemon-reload
~~~

## GNOME Desktop Sharing RDP

Use GNOME **Desktop Sharing**, not system **Remote Login**. Configure Desktop Sharing credentials in GNOME Settings for the selected user, or use an approved secret-safe `grdctl rdp set-credentials` invocation that does not leak the password into shell history. Preserve the credentials in an approved store.

If no graphical user session exists yet, select VNC mode, complete the clean-boot GDM login, reconnect to desktop VNC, and configure Desktop Sharing from that physical GNOME session before testing RDP.

Enable remote control, set the confirmed port, prevent silent fallback to a different port, enable the RDP backend, and verify the user configuration:

~~~bash
grdctl rdp disable-view-only
grdctl rdp set-port <rdp-port>
grdctl rdp disable-port-negotiation
grdctl rdp enable
grdctl status
~~~

Disable system Remote Login:

~~~bash
sudo systemctl disable --now gnome-remote-desktop.service
sudo grdctl --system status
~~~

Select one persistent desktop mode over SSH:

~~~bash
remote-desktop-mode vnc
remote-desktop-mode rdp
remote-desktop-mode status
~~~

Run only one switch command. The selected unit's enablement persists across later graphical logins. If no graphical session exists, the selected mode is armed for the next login.

If `~/.local/bin` is absent from the SSH shell's `PATH`, invoke `$HOME/.local/bin/remote-desktop-mode` explicitly.

## Verification

Reboot through the independent SSH path. Do not log in locally before testing GDM.

### Fresh GDM

Require:

1. `seat0` has an active `Name=gdm`, `Class=greeter`, `Type=x11` session.
2. Only the bootstrap x11vnc process and configured bootstrap port exist.
3. A VNC client shows the real GDM chooser with expected normal users.
4. Keyboard and pointer input affect that chooser.
5. The configured modes appear in `xrandr`.
6. `glxinfo -B` reports direct rendering and an NVIDIA renderer.

Use the display and Xauthority arguments from the running bootstrap x11vnc process for `xrandr` and `glxinfo`; do not hard-code `:0` or a GDM UID.

### Desktop VNC mode

Log in through bootstrap VNC. The bootstrap connection must close when the user session takes `seat0`. After the stable-shell delay, reconnect to the distinct desktop VNC port and require:

1. Bootstrap VNC is absent.
2. Desktop x11vnc is user-owned and targets the active user's Xorg PID and Xauthority.
3. RDP is disabled and its port is closed.
4. VNC and the local monitor show the same windows, icons, pointer, and actions.
5. GNOME Shell remains active and `gnome-session-failed.service` is inactive.

### RDP mode and reverse switch

From SSH:

~~~bash
remote-desktop-mode rdp
remote-desktop-mode status
~~~

Require desktop VNC to close before RDP opens. Connect with a compatible RDP client and confirm it shares the local desktop. Then run:

~~~bash
remote-desktop-mode vnc
remote-desktop-mode status
~~~

Require RDP to close before desktop VNC returns. Recheck GNOME Shell health after both switches.

### GPU and transition checks

Confirm desktop OpenGL remains NVIDIA in both modes:

~~~bash
glxinfo -B
systemctl --user is-active org.gnome.Shell@x11.service
systemctl --user is-active gnome-session-failed.service
sudo journalctl -b -k --no-pager | rg 'NVRM|Xid|GspRmAlloc' || true
~~~

Treat fresh Xid or GSP allocation faults as failure. Restore the known-good Xorg configuration and reboot rather than repeatedly restarting GDM.

## Troubleshooting Guide

- Bootstrap VNC shows the wrong or a black display.
  - If the running x11vnc PID does not map to the active `Class=greeter` session's Xorg PID, then stop and correct the supervisor rather than hard-coding a display.
- Desktop VNC never opens after login.
  - If `org.gnome.Shell@x11.service` is not active or the seat is not the intended user's active X11 session, then repair the graphical session before restarting desktop VNC.
- Either desktop transport shows the same black framebuffer.
  - If `gnome-session-failed.service` is active, then treat the GNOME session as failed; save work when required and perform a clean logout/login or approved GDM restart.
- RDP works from one client but not another.
  - If server logs show successful graphics negotiation with another client, then treat the failing client as incompatible before changing Linux credentials or enabling system Remote Login.

## Output Contract

Report:

~~~text
Bootstrap VNC: active | inactive | blocked
Desktop mode: vnc | rdp | conflict | disabled
Desktop VNC: active | inactive | blocked
Desktop RDP: active | inactive | client-incompatible | blocked
Display path: GDM bootstrap -> selected transport on physical NVIDIA console
Connector and default mode: <connector>, <mode>
Listener policy: <loopback-tunnel-or-approved-LAN>
GDM chooser: verified | failed
Local-console identity: verified | failed
NVIDIA rendering: verified | failed
GPU fault check: clear | failed
Rollback backup: <path>
Next action: <handoff-or-remediation>
~~~

## Rollback

Disable the hybrid services, restore backed-up GDM and Xorg files, reload systemd, and reboot:

~~~bash
systemctl --user disable --now x11vnc-desktop.service
sudo systemctl disable --now x11vnc-gdm-bootstrap.service
sudo install -o root -g root -m 0644 \
  /var/backups/imsight-vnc/<timestamp>/custom.conf.pre-hybrid \
  /etc/gdm3/custom.conf
sudo test ! -e /var/backups/imsight-vnc/<timestamp>/xorg.conf.pre-hybrid || \
  sudo install -o root -g root -m 0644 \
    /var/backups/imsight-vnc/<timestamp>/xorg.conf.pre-hybrid \
    /etc/X11/xorg.conf
sudo systemctl daemon-reload
sudo reboot
~~~

Preserve credentials and backup files unless the user explicitly requests their removal.

## Guardrails

- DO NOT use one x11vnc process or supervisor to migrate between GDM and the user X server.
- DO NOT hard-code an X display number, GDM UID, Xauthority path, connector, BusID, account, address, or unconfirmed port.
- DO NOT reuse the bootstrap VNC port for desktop VNC.
- DO NOT run desktop VNC and GNOME Desktop Sharing simultaneously.
- DO NOT enable GDM automatic login when VNC must participate in authentication.
- DO NOT enable system GNOME Remote Login when the remote client must share the physical console.
- DO NOT expose unencrypted RFB beyond loopback without explicit trusted-network and firewall approval.
- DO NOT replace the physical NVIDIA console with an independent Xvnc or TigerVNC desktop.
- DO NOT claim completion without a clean-boot GDM test, shared local-console test, NVIDIA renderer check, both mode switches, and a clean GPU fault check.
