# Set Up a Headless NVIDIA Console VNC Server

Use this command to configure an Ubuntu server with the proprietary NVIDIA driver so a password-protected VNC connection reaches the real GDM greeter before any desktop user logs in. After login, the same GPU-rendered GNOME console remains visible and controllable both remotely and on a monitor attached to the configured port.

## Workflow

1. **Confirm the architecture and collect inputs**. Require Ubuntu, GDM, GNOME on Xorg, a proprietary NVIDIA driver, one intended NVIDIA display connector, a VNC port, and an exposure policy. See **Scope and Inputs**.
2. **Audit the current console and preserve rollback material**. Inspect the display manager, GPU, current VNC listeners, and existing Xorg configuration before changing anything. See **Preflight and Backup**.
3. **Prepare GDM and prerequisites**. Install the Xorg/VNC verification tools, force GDM to use Xorg, and make the normal GDM user chooser available without automatic login. See **GDM Preparation**.
4. **Install the synthetic display**. Decode the bundled EDID and configure the selected NVIDIA connector and default mode in Xorg. See **Synthetic NVIDIA Display**.
5. **Install the VNC console-following service**. Create the RFB password file, dynamic Xorg-auth wrapper, and root system service. See **x11vnc Service**.
6. **Reboot with user approval and verify the greeter**. Confirm the actual GDM chooser is visible before any desktop login, then check the headless console's modes and renderer. See **Clean-Boot Verification**.
7. **Verify the logged-in shared console and report the result**. Reconnect after GDM replaces Xorg and report the shared-console, GPU, security, and rollback state. See **Logged-In Verification and Output Contract**.

If the task does not map cleanly to these steps, use the native planning tool to derive a safe plan from this command's scope, inputs, templates, verification contract, and guardrails. Ask for missing connector or exposure information rather than guessing.

## Scope and Inputs

This command supports only:

- Ubuntu with gdm3, GNOME, and an Xorg greeter/session path.
- The proprietary NVIDIA driver rendering the physical console.
- x11vnc capturing that console; it does not create an independent desktop.
- A synthetic EDID retaining one chosen NVIDIA digital connector while no monitor is attached.

Do not use this command for Wayland-only GDM, Intel or AMD GPUs, compute-only NVIDIA hosts without a graphical stack, or a separate virtual desktop request.

Collect and confirm these values:

| Input | Requirement |
| --- | --- |
| NVIDIA connector | Exact NVIDIA Xorg connector name such as DFP-0, mapped to the physical HDMI/DP socket intended for a future monitor. Never assume DFP-0. |
| Default mode | 2560x1440 at 60 Hz by default. Use 1920x1080 when an unknown physical monitor may not support QHD. |
| VNC port | A confirmed-free TCP port, normally 5900 or a user-selected alternate. |
| Listener policy | Default to loopback plus an authenticated tunnel. A trusted-LAN listener requires explicit firewall and exposure approval. |
| GPU selection | The single NVIDIA GPU, or an Xorg BusID when the host has multiple GPUs. |
| Backup directory | A timestamped path under /var/backups/imsight-vnc/ unless the user selects another safe location. |

The bundled EDID advertises these 60 Hz modes: 1920x1080, 2560x1440, 3840x2160, 1440x1080, 1920x1440, 2880x2160, 1600x1200, 1280x960, and 1024x768. Its preferred mode is 2560x1440. A monitor later attached to the configured physical port sees the same logical console and remote actions; its own EDID is overridden, so it must support the selected timing.

## Preflight and Backup

Inspect the host before writing files:

~~~bash
test -r /etc/os-release && . /etc/os-release && printf '%s %s\n' "$ID" "$VERSION_ID"
systemctl status display-manager.service --no-pager
nvidia-smi
lsmod | rg '^nvidia'
pgrep -a -x Xorg || true
pgrep -a -f 'x11vnc|Xvnc|Xtigervnc|gnome-remote-desktop' || true
ss -tlnp | rg ':<vnc-port>\b' || true
~~~

Confirm the proprietary driver, GDM, and an Xorg path. If another VNC server or GNOME Remote Desktop owns the requested port, inspect it and obtain approval before stopping or replacing it.

Create a timestamped rollback directory and save only files that will change:

~~~bash
sudo install -d -o root -g root -m 0700 /var/backups/imsight-vnc/<timestamp>
sudo cp -a /etc/gdm3/custom.conf \
  /var/backups/imsight-vnc/<timestamp>/custom.conf.pre-vnc
sudo test ! -e /etc/X11/xorg.conf || sudo cp -a /etc/X11/xorg.conf \
  /var/backups/imsight-vnc/<timestamp>/xorg.conf.pre-vnc
sudo test ! -e /etc/systemd/system/x11vnc-console.service || sudo cp -a \
  /etc/systemd/system/x11vnc-console.service /var/backups/imsight-vnc/<timestamp>/
~~~

Discover the connector before creating Xorg configuration. Prefer a prior Xorg log or an approved temporary monitor. NVIDIA names are driver-specific; correlate the intended HDMI/DP socket with its Xorg name such as DFP-0. On a multi-GPU host, derive the target GPU with:

~~~bash
lspci -Dnn | rg -i 'vga|3d|nvidia'
~~~

Use the GPU's decimal PCI address in BusID "PCI:<bus>:<device>:<function>".

## GDM Preparation

Install the required packages:

~~~bash
sudo apt update
sudo apt install --yes x11vnc x11-utils mesa-utils edid-decode
~~~

Edit /etc/gdm3/custom.conf so the [daemon] section contains:

~~~ini
[daemon]
WaylandEnable=false
AutomaticLoginEnable=false
TimedLoginEnable=false
~~~

Make the normal GDM account chooser visible. In /etc/gdm3/greeter.dconf-defaults, ensure this setting exists, then compile it:

~~~ini
[org/gnome/login-screen]
disable-user-list=false
~~~

~~~bash
sudo dconf update
~~~

If an expected user is still absent, inspect its shell and AccountsService record. Do not turn a system account into a visible desktop account simply to satisfy this workflow.

~~~bash
getent passwd <desktop-user>
sudo test ! -f /var/lib/AccountsService/users/<desktop-user> || \
  sudo sed -n '1,120p' /var/lib/AccountsService/users/<desktop-user>
~~~

## Synthetic NVIDIA Display

Resolve <skill-dir> to this skill's directory, decode the bundled EDID, validate it, and install it:

~~~bash
vnc_edid_tmp=$(mktemp)
trap 'rm -f "$vnc_edid_tmp"' EXIT
base64 --decode <skill-dir>/assets/vnc-console-edid.bin.base64 >"$vnc_edid_tmp"
edid-decode --check "$vnc_edid_tmp"
sudo install -o root -g root -m 0644 "$vnc_edid_tmp" /etc/X11/vnc-console-edid.bin
~~~

Write /etc/X11/xorg.conf, replacing every placeholder deliberately. Omit BusID only after confirming that no competing GPU selection is possible.

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

Do not introduce an EDID-less AllowNonEdidModes workaround. If NVIDIA rejects the mode, restore the backup, correct the connector or EDID configuration, and reboot for a clean retry. Repeated GDM restarts do not reliably recover a GPU after an Xid/GSP error.

## x11vnc Service

Create the VNC password file interactively, then secure it. Legacy VNC authentication has only eight effective password characters and does not encrypt the stream:

~~~bash
sudo x11vnc -storepasswd /etc/x11vnc-console.pass
sudo chown root:root /etc/x11vnc-console.pass
sudo chmod 0600 /etc/x11vnc-console.pass
~~~

Install this root-owned, executable /usr/local/sbin/x11vnc-console-loop. It discovers the current Xorg -auth argument and tests live X sockets rather than assuming :0, a fixed GDM UID, or a fixed Xauthority path. When GDM replaces Xorg at login or logout, x11vnc exits and the loop reattaches.

~~~bash
#!/bin/bash
set -u

while true; do
  attached=0
  while IFS= read -r xorg_pid; do
    auth=$(tr '\0' '\n' <"/proc/$xorg_pid/cmdline" |
      awk 'previous == "-auth" { print; exit } { previous = $0 }')
    [ -n "$auth" ] && [ -r "$auth" ] || continue

    for socket in /tmp/.X11-unix/X*; do
      [ -S "$socket" ] || continue
      display=":\${socket##*/X}"
      env DISPLAY="$display" XAUTHORITY="$auth" xdpyinfo >/dev/null 2>&1 || continue

      attached=1
      /usr/bin/x11vnc -display "$display" -auth "$auth" \
        -rfbauth /etc/x11vnc-console.pass -rfbport <vnc-port> \
        -noshm -forever -shared -repeat <listener-option> \
        -o /var/log/x11vnc-console.log
      break
    done
    [ "$attached" -eq 1 ] && break
  done < <(pgrep -x Xorg || true)
  sleep 2
done
~~~

Use -localhost for <listener-option> by default and carry VNC over an authenticated SSH tunnel. For an explicitly approved trusted LAN, omit that option or bind to the approved LAN address, then apply an equally restrictive firewall policy.

Install this unit as /etc/systemd/system/x11vnc-console.service:

~~~ini
[Unit]
Description=Shared VNC service for the GDM/NVIDIA console
After=display-manager.service
Wants=display-manager.service

[Service]
Type=simple
ExecStart=/usr/local/sbin/x11vnc-console-loop
Restart=always
RestartSec=2
TimeoutStopSec=3
KillMode=control-group

[Install]
WantedBy=graphical.target
~~~

~~~bash
sudo install -o root -g root -m 0755 <local-wrapper-path> /usr/local/sbin/x11vnc-console-loop
sudo install -o root -g root -m 0644 <local-unit-path> /etc/systemd/system/x11vnc-console.service
sudo systemctl daemon-reload
sudo systemctl enable x11vnc-console.service
~~~

## Clean-Boot Verification

Ask before rebooting. A clean GPU initialization is required. After reboot, do not log in locally before the greeter test.

From an independent management path, verify that the services and listener exist:

~~~bash
systemctl is-active gdm3.service x11vnc-console.service
pgrep -a -x Xorg
pgrep -a -x x11vnc
ss -tlnp | rg ':<vnc-port>\b'
~~~

Connect the VNC client through the selected listener or tunnel. Before desktop login, require:

- The actual GDM user chooser and expected normal accounts are visible.
- The framebuffer is rendered, not black, frozen, or a virtual desktop.
- A monitor attached to the configured physical port, when available, shows the same greeter and pointer actions.
- The listener follows the selected loopback or trusted-LAN policy.

Use the display and Xauthority arguments from the running x11vnc command to run xrandr --query, xrandr --listmonitors, and glxinfo -B. Require one active synthetic console monitor, the advertised modes, direct rendering, and an NVIDIA OpenGL renderer—not llvmpipe.

Inspect the clean boot for GPU faults:

~~~bash
sudo journalctl -b -k --no-pager | rg 'NVRM|Xid|GspRmAlloc' || true
~~~

Do not accept fresh Xid or GSP allocation errors as success. Restore the saved configuration and reboot before another test.

## Logged-In Verification and Output Contract

Log in through the VNC greeter. The VNC client may disconnect once while GDM replaces Xorg; reconnect after the loop attaches to the user console. Confirm remote actions appear locally and local keyboard/mouse actions appear remotely.

Require the logged-in session to retain the expected monitor count and modes, direct NVIDIA OpenGL rendering, and no new GPU faults. Report:

~~~text
Console VNC: active | inactive | blocked
Display path: GDM greeter -> logged-in shared NVIDIA Xorg console
Connector: <DFP-N> mapped to <physical-port>
Default mode: <mode>
VNC listener: <loopback-or-approved-network-policy>:<port>
GDM user chooser: verified | failed
NVIDIA rendering: verified | failed
Clean-boot GPU fault check: clear | failed
Rollback backup: <backup-directory>
Next: <reconnect, firewall, or rollback action>
~~~

## Rollback

Disable the VNC service, restore the saved GDM and Xorg files, reload configuration, then reboot. Preserve the backup and unrelated remote-access services. If the GPU is in an Xid/GSP error state, a GDM restart is insufficient; restore the configuration and reboot.

## Guardrails

- DO NOT use this command for a separate virtual desktop, a Wayland-only GDM path, or a non-NVIDIA GPU.
- DO NOT hard-code a display number, GDM UID, Xauthority path, NVIDIA connector, port, account name, or network address.
- DO NOT omit the synthetic EDID or use an EDID-less AllowNonEdidModes workaround for a headless NVIDIA connector.
- DO NOT enable automatic desktop login when the VNC connection must participate in the GDM login process.
- DO NOT expose unencrypted RFB beyond a user-approved trusted LAN or authenticated tunnel.
- DO NOT claim hardware acceleration from nvidia-smi alone; require the Xorg glxinfo -B renderer check.
- DO NOT keep restarting GDM after an NVIDIA Xid or GSP fault; restore the known-good configuration and reboot.
