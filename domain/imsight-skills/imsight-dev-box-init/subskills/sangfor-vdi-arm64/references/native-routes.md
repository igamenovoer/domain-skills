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

# Native arm64 and box64 Routes: Assessment Notes

Use this reference to judge whether the native arm64 client package or box64 can replace the qemu-user amd64 container on a given host, and to avoid re-investing in their known dead ends.

## Workflow

1. Read **Native arm64 Package** and decide whether the packaging prerequisites are acceptable.
2. Read **box64 Route** and decide whether the available box64 version escapes its known GUI crash.
3. If either route is attempted, reuse the packaging notes here; otherwise proceed directly to `imsight-dev-box-init->sangfor-vdi-arm64->qemu-container-setup()`.

## Native arm64 Package

The gateway's Linux install page offers arm64 debs for UOS and Kylin only — no Ubuntu arm64 build. The binaries require `GLIBC_2.29+` (check with `readelf --version-info`).

Packaging prerequisites observed:

- Base image: a Debian-family arm64 rootfs with glibc ≥ 2.29. Deepin arm64 (glibc 2.38) works and is the upstream of UOS, which the UOS client build expects. Kylin/UOS public container images are RPM-based servers (glibc 2.28) or too old — unsuitable.
- `/etc/os-release` must report UOS 20 (`ID=uos`, `VERSION_ID=20`); the bundled `vdi_super_agent` rejects other IDs and exits.
- Copy the deb's bundled Qt 4.8.7 into the client lib dir with `libQt*.so.4` symlinks; add `libidn.so.11` and OpenLDAP 2.4 from Debian bullseye arm64; add `libasound2`; add Qt4 `imageformats` (GIF needed for the captcha).
- The self-update and service-wait gates may need the same treatment as the version flags in the qemu route (client quits on update checks).

Known blocker (unresolved when abandoned): the session broker `vdi_client` dies about a second after start with `*** stack smashing detected ***`, so the resource page never reaches a real session. Later stages were never exercised; the libusb hotplug crash family from `session-crash-fix()` would likely also apply. No core/gdb analysis was completed on this crash.

## box64 Route

Observed with box64 0.2.6 on the arm64 host, x86_64 client payload on an arm64 rootfs:

- `vdi_super_agent` and `vdi_webui_agent` start and the webui agent listens on `127.0.0.1:31113`.
- The Qt4 GUI (`vdi_local_client`) shows the login window, then segfaults: `libpng warning: Application jmp_buf size changed` followed by a core dump. Cause: box64 substitutes native arm64 builds of `libpng`/`libfreetype`/`libfontconfig` into the x86 process and the struct/ABI layouts differ. Forcing the bundled x86 libraries via `BOX64_EMULATED_LIBS` fixes symbol errors but not the segfault.
- Docker `--platform linux/amd64` does not work through box64 for full amd64 images (missing x86 loader/libs inside the image); the route requires a hand-assembled hybrid rootfs.

Conclusion: box64 is viable for the headless agents but not for the Qt4 GUI at the tested version. Reassess only with a substantially newer box64.

## Guardrails

- DO NOT present the native or box64 route as working to the user; both are documented here as assessed-but-blocked alternatives.
- DO NOT keep the UOS `os-release` disguise on a host where other tooling depends on the real OS identity; apply it inside a container only.
