#!/bin/bash
# Generic launcher template for the Sangfor VDI amd64 client container.
# Copy into the image as /usr/local/bin/start-vdi-container.sh and use as ENTRYPOINT.
# Placeholders: VDI_USER (non-root runtime user), PATCH_FILE_OFFSET (from
# session-crash-fix derivation; leave empty to skip), proxy env (see network-bridge).
set -u

VDI_USER=${VDI_USER:-vdiuser}
VDI_UID=$(id -u "$VDI_USER")
BIN=/usr/local/sangfor/vdiclient/bin
PATCH_FILE_OFFSET=${PATCH_FILE_OFFSET:-}   # decimal or 0x... file offset in vdi_session

export DISPLAY=${DISPLAY:-:1}
export XAUTHORITY=${XAUTHORITY:-/tmp/xauth}
export QT_PLUGIN_PATH=$BIN
export LD_LIBRARY_PATH=/usr/local/sangfor/vdiclient/lib:${LD_LIBRARY_PATH:-}
export PROXYCHAINS_CONF_FILE=${PROXYCHAINS_CONF_FILE:-/etc/proxychains4.conf}
export PROXYCHAINS_QUIET_MODE=1
# Diagnostics: inherited by spawned children (vdi_client/vdi_session).
# QEMU_STRACE floods logs; enable only while diagnosing.
# export QEMU_STRACE=1

mkdir -p /run/sangfor/vdiclient /run/systemd/users "/run/user/$VDI_UID"
chown "$VDI_USER":"$VDI_USER" /run/sangfor/vdiclient "/run/user/$VDI_UID"
chmod 700 "/run/user/$VDI_UID"

# 1. clear stale installer/updater flags (client refuses to start otherwise)
rm -f /etc/sangfor/vdiclient/is_installing_depend /run/sangfor/vdiclient/is_updating
rm -f /run/sangfor/vdiclient/vdi_super_agent.sock \
      /run/sangfor/vdiclient/vdi_webui_agent.sock \
      /run/sangfor/vdiclient/vdi_client.sock \
      /run/sangfor/vdiclient/*.lock

# 2. synthetic logind-style active-user record (GUI refuses without it)
printf 'NAME=%s\nUID=%s\nSTATE=active\nSTOPPING=no\nRUNTIME=/run/user/%s\nSESSIONS=1\nSEATS=seat0\nACTIVE_SESSIONS=1\n' \
    "$VDI_USER" "$VDI_UID" "$VDI_UID" > "/run/systemd/users/$VDI_UID"
chown "$VDI_USER":"$VDI_USER" "/run/systemd/users/$VDI_UID"

# 3. clear setuid bits so LD_PRELOAD (proxychains) survives exec
chmod -s "$BIN/vdi_session" "$BIN/rapp_session" 2>/dev/null || true

# 4. idempotent crash-fix patch; see session-crash-fix reference
_vs="$BIN/vdi_session"
if [ -n "$PATCH_FILE_OFFSET" ] && \
   [ "$(od -An -tx1 -j $((PATCH_FILE_OFFSET)) -N1 "$_vs" | tr -d ' \n')" = "e8" ]; then
    printf '\xb8\xff\xff\xff\xff' | dd of="$_vs" bs=1 seek=$((PATCH_FILE_OFFSET)) conv=notrunc 2>/dev/null
    echo "patched vdi_session at file offset $PATCH_FILE_OFFSET"
fi

# 5. agents from a writable cwd so qemu guest cores can land there
cd "/home/$VDI_USER"

as_user() {
    runuser -u "$VDI_USER" -- env \
        HOME="/home/$VDI_USER" USER="$VDI_USER" LOGNAME="$VDI_USER" \
        DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" \
        XDG_RUNTIME_DIR="/run/user/$VDI_UID" \
        QT_PLUGIN_PATH="$QT_PLUGIN_PATH" \
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
        PROXYCHAINS_CONF_FILE="$PROXYCHAINS_CONF_FILE" \
        PROXYCHAINS_QUIET_MODE=1 \
        proxychains4 -f "$PROXYCHAINS_CONF_FILE" "$@"
}

as_user "$BIN/vdi_super_agent" >/tmp/vdi_super_agent.out 2>&1 &
for _ in $(seq 1 30); do
    [ -S /run/sangfor/vdiclient/vdi_super_agent.sock ] && break
    sleep 1
done

as_user "$BIN/vdi_webui_agent" >/tmp/vdi_webui_agent.out 2>&1 &
for _ in $(seq 1 30); do
    (exec 3<>/dev/tcp/127.0.0.1/31113) 2>/dev/null && break
    sleep 1
done
sleep 1

as_user "$BIN/vdi_local_client"
echo "vdi_local_client exited rc=$?; keeping container alive for the agents"
sleep infinity
