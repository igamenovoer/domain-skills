#!/bin/bash
# Unset common proxy environment variables.
# Usage: source ~/unset-proxy.sh

unset http_proxy
unset https_proxy
unset ftp_proxy
unset no_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
unset FTP_PROXY
unset NO_PROXY
unset ALL_PROXY
unset all_proxy

echo "Proxy environment variables have been unset."
