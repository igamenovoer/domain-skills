# Install Proxy Scripts

Use this reference to install the bundled proxy environment scripts onto a new host and configure proxy candidate groups in the user's shell startup file.

Do not record real proxy inventory from the current host in this skill. Discover candidates on the target host at setup time.

## Workflow

1. Follow **Install Workflow** and use the bundled scripts.
2. Select or discover candidate groups, using `proxy-scan` when requested.
3. Validate candidate protocols before persisting them.
4. Update only the managed shell-startup block.
5. Run the end-to-end checks and use **Troubleshooting** for failures.

If the task does not map cleanly to these steps, plan only from the bundled scripts, candidate groups, validation, and managed-block rules; ask for the scan range or shell file when missing.

## Install Workflow

1. Copy `scan-proxy-candidates.py`, `setup-proxy.sh`, and `unset-proxy.sh` into the target user's home directory unless the user specifies another install location.
2. Ask the user for the proxy port or port range to scan. Do not assume a range. Run `proxy-scan` over the user-provided range, classify verified proxies into `local`, `remote`, or `tunnel`, and write the grouped env vars to the shell startup file selected from the user's shell type.
3. If the user gives manual proxy addresses, write them to `PROXY_MANUAL_CANDIDATE_LIST` in the same managed startup block so they are tried before scanned groups.

## Bundled Scripts

Copy these scripts from the skill:

```text
scripts/scan-proxy-candidates.py
scripts/setup-proxy.sh
scripts/unset-proxy.sh
```

Install to the target user's home directory by default:

```bash
cp /path/to/skill/scripts/scan-proxy-candidates.py "$HOME/scan-proxy-candidates.py"
cp /path/to/skill/scripts/setup-proxy.sh "$HOME/setup-proxy.sh"
cp /path/to/skill/scripts/unset-proxy.sh "$HOME/unset-proxy.sh"
chmod +x "$HOME/scan-proxy-candidates.py" "$HOME/setup-proxy.sh" "$HOME/unset-proxy.sh"
```

If the user specifies another location, copy the scripts there and use that location consistently in examples and startup-file comments.

The setup script must be sourced:

```bash
source "$HOME/setup-proxy.sh"
```

The unset script should also be sourced:

```bash
source "$HOME/unset-proxy.sh"
```

## Proxy Candidate Groups

Proxy candidates can include a manual list plus three ordered groups:

- `manual`: `PROXY_MANUAL_CANDIDATE_LIST`; tried first regardless of whether the entries are local, remote, or tunneled proxies. It can be empty or omitted.

- `local`: proxies running on this host, including host-side proxies reachable from Docker containers.
- `remote`: proxies running on remote or LAN servers, reached directly over HTTP, HTTPS, or SOCKS5 transport.
- `tunnel`: remote proxies mapped onto this host through SSH tunnels.

By default, `setup-proxy.sh` scans `manual,local,remote,tunnel`. Override the group order after the manual list with:

```bash
source "$HOME/setup-proxy.sh" --proxy-types local,tunnel,remote
```

Use a one-off explicit list when the user wants to bypass grouped scanning:

```bash
source "$HOME/setup-proxy.sh" --proxy-candidate-list "http://127.0.0.1:<port>,socks5://127.0.0.1:<port>"
```

HTTPS behavior:

- `setup-proxy.sh` prefers a reachable `https://` proxy candidate for `HTTPS_PROXY`/`https_proxy`.
- If no `https://` proxy is found, the selected HTTP/SOCKS proxy is also used for HTTPS by default.
- If the user forbids HTTP/SOCKS fallback for HTTPS, set `SETUP_PROXY_FORBID_HTTP_FOR_HTTPS=1` before sourcing `setup-proxy.sh` or add it to the managed startup block.

## Subcommand: proxy-scan

Use this subcommand when the user asks to scan proxy ports, discover local proxies, classify SSH-tunnel proxies, find normal remote proxies, add manual proxy addresses, or update shell startup proxy candidate variables.

Run the bundled scanner:

```bash
"$HOME/scan-proxy-candidates.py" --ports <port-or-port-range> --format table
```

The scanner:

- checks loopback TCP ports,
- verifies whether `https://`, `http://`, or `socks5://` proxy candidates work using `curl`,
- classifies listeners owned by `ssh`, `autossh`, or `setup-ssh-forward-tunnel` as tunnel proxies,
- classifies other visible listeners as local proxies,
- classifies verified proxies scanned on a non-loopback `--host` as remote proxies,
- treats hidden listener owners as local by default unless `--unknown-as tunnel` is supplied.

It requires `curl` for protocol verification. It uses `ss` when available, with `netstat` as a fallback, to classify listener ownership.

The scan range is required. If the user does not provide one, ask before scanning:

```bash
"$HOME/scan-proxy-candidates.py" --ports <port-or-port-range> --format env
```

To update the managed shell startup block directly, choose the startup file from `SHELL`:

```bash
"$HOME/scan-proxy-candidates.py" --ports <port-or-port-range> --write-startup auto
```

Shell startup selection:

```text
bash -> ~/.bashrc
zsh  -> ~/.zshrc
fish -> ~/.config/fish/conf.d/imsight-proxy.fish
sh   -> ~/.profile
other/unknown -> ~/.profile
```

The direct update preserves existing `PROXY_MANUAL_CANDIDATE_LIST` and `PROXY_REMOTE_CANDIDATE_LIST` values unless explicit values are supplied. It replaces discovered local/tunnel candidates for loopback scans and discovered remote candidates for non-loopback scans.

If the user gives manual proxy addresses, pass them explicitly:

```bash
"$HOME/scan-proxy-candidates.py" \
  --ports <port-or-port-range> \
  --manual-candidate-list "http://127.0.0.1:<port>,socks5://127.0.0.1:<port>" \
  --write-startup auto
```

To scan a normal remote proxy host, use `--host`:

```bash
"$HOME/scan-proxy-candidates.py" --host <remote-host-or-ip> --ports <port-or-port-range> --write-startup auto
```

If reviewing before writing, capture env output first:

```bash
"$HOME/scan-proxy-candidates.py" --ports <port-or-port-range> --format env
```

## Validate Candidate Protocols

HTTP proxy test:

```bash
curl -x "http://127.0.0.1:<port>" -I --max-time 8 http://example.com
```

HTTPS over HTTP proxy:

```bash
curl -x "http://127.0.0.1:<port>" -I --max-time 10 https://www.google.com
```

SOCKS5 proxy test:

```bash
curl -x "socks5://127.0.0.1:<port>" -I --max-time 10 https://www.google.com
```

Keep candidates that return a successful HTTP status or establish CONNECT for HTTPS.

## Add Candidate Groups To A Shell Startup File

Prefer `scan-proxy-candidates.py --write-startup auto` for normal installation. If a manual edit is needed for a POSIX-style shell, write or replace a managed block in the shell startup file chosen from the user's shell type. For fish, prefer the scanner's `--write-startup auto` so it writes `set -gx` syntax.

```bash
STARTUP_FILE="$HOME/.bashrc"  # Use ~/.zshrc for zsh or ~/.profile for sh.
PROXY_MANUAL_CANDIDATES="<comma-separated-manual-candidates>"
PROXY_LOCAL_CANDIDATES="<comma-separated-local-candidates>"
PROXY_REMOTE_CANDIDATES="<comma-separated-remote-candidates>"
PROXY_TUNNEL_CANDIDATES="<comma-separated-tunnel-candidates>"

python3 - "$STARTUP_FILE" "$PROXY_MANUAL_CANDIDATES" "$PROXY_LOCAL_CANDIDATES" "$PROXY_REMOTE_CANDIDATES" "$PROXY_TUNNEL_CANDIDATES" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
manual_candidates = sys.argv[2]
local_candidates = sys.argv[3]
remote_candidates = sys.argv[4]
tunnel_candidates = sys.argv[5]
start = "# >>> imsight proxy candidates >>>"
end = "# <<< imsight proxy candidates <<<"
block = f"""{start}
export PROXY_MANUAL_CANDIDATE_LIST="{manual_candidates}"
export PROXY_LOCAL_CANDIDATE_LIST="{local_candidates}"
export PROXY_REMOTE_CANDIDATE_LIST="{remote_candidates}"
export PROXY_TUNNEL_CANDIDATE_LIST="{tunnel_candidates}"
# Source manually when proxy variables are needed:
# source "$HOME/setup-proxy.sh"
{end}
"""

text = path.read_text() if path.exists() else ""
if start in text and end in text:
    before, rest = text.split(start, 1)
    _, after = rest.split(end, 1)
    text = before.rstrip() + "\n\n" + block + after.lstrip()
else:
    text = text.rstrip() + "\n\n" + block
path.write_text(text)
PY
```

Do not automatically source `setup-proxy.sh` from the startup file unless the user explicitly wants every new shell to enable proxy variables. By default, only persist candidate lists and let the user run:

```bash
source ~/setup-proxy.sh
```

Use `PROXY_MANUAL_CANDIDATE_LIST` for known-good candidates that should win over the grouped scan order.

## End-To-End Install Pattern

```bash
cp /path/to/skill/scripts/setup-proxy.sh "$HOME/setup-proxy.sh"
cp /path/to/skill/scripts/unset-proxy.sh "$HOME/unset-proxy.sh"
cp /path/to/skill/scripts/scan-proxy-candidates.py "$HOME/scan-proxy-candidates.py"
chmod +x "$HOME/setup-proxy.sh" "$HOME/unset-proxy.sh" "$HOME/scan-proxy-candidates.py"

"$HOME/scan-proxy-candidates.py" --ports <port-or-port-range> --write-startup auto --format table
```

Replace `<port-or-port-range>` with the user-provided scan range. Then inspect the table output. If the user provided manual proxies, add `--manual-candidate-list "<comma-separated-proxies>"`. Leave remote candidate lists empty unless remote proxy addresses are validated or scanned with `--host`.

## Troubleshooting

- `source ~/setup-proxy.sh` prints "No reachable proxy found": candidate lists are empty, stale, or ports are not reachable from this host.
- `--proxy-types remote,tunnel` finds nothing: populate `PROXY_REMOTE_CANDIDATE_LIST` or `PROXY_TUNNEL_CANDIDATE_LIST`, or include `local` in the scan order.
- HTTP test succeeds but SOCKS5 fails: keep only the `http://` candidate for that port.
- SOCKS5 test succeeds but HTTP fails: keep only the `socks5://` candidate for that port.
- HTTPS should not use HTTP/SOCKS fallback: set `SETUP_PROXY_FORBID_HTTP_FOR_HTTPS=1`.
- Corporate or private networks: extend `SETUP_PROXY_NO_PROXY` before sourcing `setup-proxy.sh`.
