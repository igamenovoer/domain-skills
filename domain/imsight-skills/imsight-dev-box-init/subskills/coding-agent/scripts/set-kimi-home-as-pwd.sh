#!/bin/sh
# Source this file to make Kimi Code CLI use the current directory's
# .kimi-code/ as its data root (config, sessions, logs, credentials)
# instead of ~/.kimi-code.
#
# Usage:
#   source ~/set-kimi-home-as-pwd.sh

# Exporting only has an effect when the file is sourced.
if ! (return 0 2>/dev/null); then
    echo "This script must be sourced: source ~/set-kimi-home-as-pwd.sh" >&2
    exit 1
fi

KIMI_CODE_HOME="$(pwd -P)/.kimi-code"
export KIMI_CODE_HOME
mkdir -p "$KIMI_CODE_HOME"

echo "KIMI_CODE_HOME=$KIMI_CODE_HOME"
echo "kimi will now use project-scope data in this shell. Run 'unset KIMI_CODE_HOME' to revert."
