#!/bin/sh
# kimi-project.sh — launcher for kimi-project.py, the Kimi Code auth-session
# manager. All logic lives in the sibling Python script; this entrypoint only
# keeps the familiar .sh invocation working. Install both files side by side.
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
exec python3 "$here/kimi-project.py" "$@"
