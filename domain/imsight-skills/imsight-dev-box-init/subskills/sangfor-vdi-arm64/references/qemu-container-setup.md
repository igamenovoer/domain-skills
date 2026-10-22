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

# QEMU amd64 Container Setup

Use this reference to build and run the Sangfor VDI x86_64 Ubuntu client inside a Docker container on an arm64 Ubuntu host, translated by qemu-user binfmt, with its GUI on the host's X desktop.

## Workflow

1. Verify **Prerequisites**: qemu binfmt beats any box64 registration, Docker works, and the host X desktop is identified.
2. Build the image per **Image Build**.
3. Write the launcher per **Launcher Script** (flag cleanup, non-root user, agent startup order, self-heal patch hook).
4. Start the container per **Run** and verify per **Verify**.
5. If the session dies after login, continue to `imsight-dev-box-init->sangfor-vdi-arm64->session-crash-fix()`.

If the environment differs (no X authority file, Wayland-only, missing binfmt), use the native planning tool to adapt the steps; keep the invariants in **Guardrails**.

## Prerequisites

- Host: arm64 Ubuntu with Docker; user in the `docker` group.
- qemu-user binfmt registered for x86_64:
  ```bash
  sudo apt-get install -y qemu-user-static binfmt-support
  sudo update-binfmts --enable qemu-x86_64
  cat /proc/sys/fs/binfmt_misc/qemu-x86_64   # expect interpreter ...-binfmt-P, flags: POF
  docker run --rm --platform linux/amd64 ubuntu:20.04 uname -m   # expect x86_64
  ```
  A legacy box64 binfmt registration for `x86_64` may coexist; Docker picks the qemu `qemu-x86_64` entry for `--platform linux/amd64` containers. If `uname -m` prints aarch64, the box64 entry is winning: fix binfmt before continuing.
- A running X server on the host (local Xorg or an RDP-served desktop). Note its `DISPLAY` (for example `:1`) and a readable Xauthority for the user that owns the session (for example the GDM cookie at `/run/user/<uid>/gdm/Xauthority`).
- The VDI gateway address (host/IP and port, usually 443) and, if needed, a working network bridge from `network-bridge()`.

## Image Build

Base: `ubuntu:20.04` amd64. The official client deb (`com.sangfor.vdi`, Ubuntu x86_64 build) is downloaded from the gateway's Linux install page (`/com/installLINUX.html`); its `postinst` detects Ubuntu 20.04 and installs the bundled Qt 4.8.7 plus `imageformats`.

Dockerfile sketch:

```dockerfile
FROM --platform=linux/amd64 ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl proxychains4 libasound2 libxcursor1 adwaita-icon-theme-full \
    && rm -rf /var/lib/apt/lists/*
COPY com.sangfor.vdi.deb /tmp/
RUN dpkg -i /tmp/com.sangfor.vdi.deb || apt-get -f install -y
# non-root runtime user; uid/name are free, keep them consistent everywhere
ARG VDI_USER=vdiuser
RUN useradd -m -s /bin/bash -G sudo ${VDI_USER} && echo "${VDI_USER}:changeme" | chpasswd \
    && mkdir -p /run/sangfor/vdiclient \
    && chown -R ${VDI_USER}:${VDI_USER} /usr/local/sangfor /var/log/sangfor /etc/sangfor
COPY start-vdi-container.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/start-vdi-container.sh"]
```

Notes:

- `adwaita-icon-theme-full` (or a copied full cursor set) prevents noisy Xcursor misses; the Ubuntu minimal theme subset ships no `cursors/` directory.
- Check `ldd` on every binary in `/usr/local/sangfor/vdiclient/bin/` inside the built image; missing sonames must be resolved from the deb's bundled `thirdpart/` payloads or Ubuntu packages.
- Build times are slow under qemu; that is expected.

## Launcher Script

Use `scripts/start-vdi-container.sh` from this subskill as the template. Its required responsibilities:

1. Export `DISPLAY`, `XAUTHORITY=/tmp/xauth`, the client's `QT_PLUGIN_PATH` and `LD_LIBRARY_PATH`, and the proxy environment from `network-bridge()`.
2. Remove stale state at every start: `/etc/sangfor/vdiclient/is_installing_depend`, `/run/sangfor/vdiclient/is_updating`, old `*.sock`/`*.lock` under `/run/sangfor/vdiclient/`.
3. Synthesize a logind-style user record at `/run/systemd/users/<uid>` (the client refuses to run its GUI for a user without an "active" record) and a writable `XDG_RUNTIME_DIR`.
4. Clear setuid bits on `vdi_session`/`rapp_session` so `LD_PRELOAD` survives exec.
5. Apply the crash-fix binary patch idempotently (see `session-crash-fix()`); the template carries a byte-checked `dd` block keyed on `PATCH_FILE_OFFSET`.
6. Start `vdi_super_agent`, wait for its socket; start `vdi_webui_agent`, wait for its TCP listener; then run `vdi_local_client` in the foreground and keep the container alive (`sleep infinity`) when it exits, so the agents stay up for reconnects.
7. Run all client processes as the non-root user via `runuser -u <user> -- env ...`, from a cwd that user can write (its home), so qemu guest cores land somewhere writable.

## Run

```bash
docker run -d --name sangfor-vdi --platform linux/amd64 \
  --ipc=host \
  -e DISPLAY=:1 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /run/user/<host-uid>/gdm/Xauthority:/tmp/xauth:ro \
  sangfor-vdi:x86
```

- `--ipc=host` lets the guest use X MIT-SHM shared memory with the host X server; without it rendering falls back or fails.
- Mount the Xauthority that matches the X server's owning user; a root-only cookie cannot be read by the container user.
- No special network flags are needed when using proxychains; the container only needs to reach the proxy host (default bridge is fine).

## Verify

1. `docker logs` shows the three agents started; the webui agent listens on `127.0.0.1:31113` inside the container.
2. On the host: `DISPLAY=:1 xdotool search --name ".*" getwindowname %@ | grep -i sangfor` (or the localized client title) finds the login window; a root-window screenshot shows the gateway login page.
3. If a bridge is in use: `docker exec sangfor-vdi proxychains4 curl -k https://<gateway>/` returns HTTP 200.
4. The user logs in and opens a resource; the desktop window must stay up. If it dies, continue to `session-crash-fix()`.

## Guardrails

- DO NOT run the client as root inside the container; several client components misbehave and the user's desktop cookie model assumes a regular uid.
- DO NOT publish container ports to the host; all client traffic is outbound through the proxy path.
