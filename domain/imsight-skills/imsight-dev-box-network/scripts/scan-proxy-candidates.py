#!/usr/bin/env python3
"""Scan loopback proxy candidates and emit grouped proxy env vars."""

from __future__ import annotations

import argparse
import ipaddress
import json
import os
import re
import socket
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


DEFAULT_HOST = "127.0.0.1"
DEFAULT_TEST_URL = "http://example.com"
ENV_NAMES = (
    "PROXY_MANUAL_CANDIDATE_LIST",
    "PROXY_LOCAL_CANDIDATE_LIST",
    "PROXY_REMOTE_CANDIDATE_LIST",
    "PROXY_TUNNEL_CANDIDATE_LIST",
)


@dataclass
class Candidate:
    url: str
    group: str
    port: int
    scheme: str
    listener: str


def parse_ports(spec: str) -> list[int]:
    ports: set[int] = set()
    for chunk in spec.split(","):
        chunk = chunk.strip()
        if not chunk:
            continue
        if "-" in chunk:
            start_s, end_s = chunk.split("-", 1)
            start = int(start_s)
            end = int(end_s)
            if start > end:
                raise ValueError(f"invalid descending port range: {chunk}")
            ports.update(range(start, end + 1))
        else:
            ports.add(int(chunk))
    for port in ports:
        if port < 1 or port > 65535:
            raise ValueError(f"invalid port: {port}")
    return sorted(ports)


def tcp_open(host: str, port: int, timeout: float) -> bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.settimeout(timeout)
        return sock.connect_ex((host, port)) == 0


def run_text(cmd: list[str]) -> str:
    try:
        return subprocess.run(
            cmd,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
        ).stdout
    except FileNotFoundError:
        return ""


def listener_map() -> dict[int, str]:
    listeners: dict[int, str] = {}
    text = run_text(["ss", "-H", "-ltnp"])
    if not text:
        text = run_text(["netstat", "-ltnp"])

    for line in text.splitlines():
        ports = re.findall(r"(?<![\d.])(?:\[?[0-9A-Fa-f:.%*]+\]?:|\*:)(\d+)\b", line)
        if not ports:
            continue
        # In LISTEN output, the first port is the local listening port.
        listeners.setdefault(int(ports[0]), line.strip())
    return listeners


def classify_listener(listener: str, unknown_group: str) -> str:
    lower = listener.lower()
    if re.search(r'(?:"ssh"|/ssh\b|\bssh\b|autossh|setup-ssh-forward-tunnel)', lower):
        return "tunnel"
    if not listener:
        return unknown_group
    return "local"


def is_loopback_host(host: str) -> bool:
    if host in {"localhost", "::1"}:
        return True
    try:
        return ipaddress.ip_address(host).is_loopback
    except ValueError:
        return False


def curl_works(proxy_url: str, test_url: str, timeout: float) -> bool:
    base = [
        "curl",
        "-fsSL",
        "--max-time",
        str(timeout),
        "-x",
        proxy_url,
        "-o",
        os.devnull,
        test_url,
    ]
    try:
        return subprocess.run(base, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
    except FileNotFoundError:
        return False


def shell_quote(value: str) -> str:
    return "'" + value.replace("'", "'\"'\"'") + "'"


def append_unique_csv(current: str, additions: str) -> str:
    values: list[str] = []
    seen: set[str] = set()
    for raw in (current, additions):
        for item in raw.split(","):
            item = item.strip()
            if item and item not in seen:
                seen.add(item)
                values.append(item)
    return ",".join(values)


def env_values(candidates: list[Candidate], manual: str = "", remote: str = "") -> dict[str, str]:
    local = ",".join(c.url for c in candidates if c.group == "local")
    scanned_remote = ",".join(c.url for c in candidates if c.group == "remote")
    tunnel = ",".join(c.url for c in candidates if c.group == "tunnel")
    remote = append_unique_csv(remote, scanned_remote)
    return {
        "PROXY_MANUAL_CANDIDATE_LIST": manual,
        "PROXY_LOCAL_CANDIDATE_LIST": local,
        "PROXY_REMOTE_CANDIDATE_LIST": remote,
        "PROXY_TUNNEL_CANDIDATE_LIST": tunnel,
    }


def emit_env(candidates: list[Candidate], manual: str = "", remote: str = "", shell_style: str = "posix") -> str:
    values = env_values(candidates, manual=manual, remote=remote)
    if shell_style == "fish":
        return "\n".join(f"set -gx {name} {shell_quote(values[name])}" for name in ENV_NAMES) + "\n"
    return "\n".join(f"export {name}={shell_quote(values[name])}" for name in ENV_NAMES) + "\n"


def shell_style_for_path(path: Path) -> str:
    if path.suffix == ".fish" or ".config/fish/" in str(path):
        return "fish"
    return "posix"


def startup_path_for_shell(shell_name: str, home: Path) -> Path:
    shell_name = Path(shell_name).name
    if shell_name == "zsh":
        return home / ".zshrc"
    if shell_name == "fish":
        return home / ".config/fish/conf.d/imsight-proxy.fish"
    if shell_name in {"bash", ""}:
        return home / ".bashrc"
    if shell_name in {"sh", "dash"}:
        return home / ".profile"
    return home / ".profile"


def resolve_startup_path(value: str | None, shell_name: str) -> Path | None:
    if value is None:
        return None
    home = Path.home()
    if value == "auto":
        return startup_path_for_shell(shell_name, home)
    return Path(value).expanduser()


def emit_startup_block(candidates: list[Candidate], manual: str, remote: str, shell_style: str) -> str:
    start = "# >>> imsight proxy candidates >>>"
    end = "# <<< imsight proxy candidates <<<"
    block = start + "\n" + emit_env(candidates, manual=manual, remote=remote, shell_style=shell_style)
    if shell_style == "fish":
        block += "# Run setup-proxy.sh from a bash-compatible shell when proxy variables are needed.\n"
    else:
        block += "# Source manually when proxy variables are needed:\n"
        block += '# source "$HOME/setup-proxy.sh"\n'
    block += end + "\n"
    return block


def env_value_from_startup(text: str, name: str) -> str:
    patterns = [
        rf"^\s*export\s+{re.escape(name)}=(['\"])(.*?)\1\s*$",
        rf"^\s*export\s+{re.escape(name)}=([^\s#]*)\s*$",
        rf"^\s*set\s+-gx\s+{re.escape(name)}\s+(['\"])(.*?)\1\s*$",
        rf"^\s*set\s+-gx\s+{re.escape(name)}\s+([^\s#]*)\s*$",
    ]
    for pattern in patterns:
        match = re.search(pattern, text, re.MULTILINE)
        if match:
            return match.group(2) if len(match.groups()) >= 2 else match.group(1)
    return os.environ.get(name, "")


def write_startup(path: Path, candidates: list[Candidate], manual: str | None = None, remote: str | None = None) -> None:
    start = "# >>> imsight proxy candidates >>>"
    end = "# <<< imsight proxy candidates <<<"
    text = path.read_text() if path.exists() else ""
    manual = manual if manual is not None else env_value_from_startup(text, "PROXY_MANUAL_CANDIDATE_LIST")
    remote = remote if remote is not None else env_value_from_startup(text, "PROXY_REMOTE_CANDIDATE_LIST")
    block = emit_startup_block(candidates, manual=manual, remote=remote, shell_style=shell_style_for_path(path))

    if start in text and end in text:
        before, rest = text.split(start, 1)
        _, after = rest.split(end, 1)
        text = before.rstrip() + "\n\n" + block + after.lstrip()
    elif text.strip():
        text = text.rstrip() + "\n\n" + block
    else:
        text = block
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Scan proxy ports, verify proxy protocol, and classify local, remote, or SSH-tunnel proxies."
    )
    parser.add_argument("--host", default=DEFAULT_HOST, help=f"loopback host to scan; default {DEFAULT_HOST}")
    parser.add_argument("--ports", required=True, help="ports or ranges to scan, comma-separated; ask the user for this value")
    parser.add_argument("--tcp-timeout", type=float, default=0.4, help="TCP connect timeout per port")
    parser.add_argument("--curl-timeout", type=float, default=6.0, help="curl verification timeout per candidate")
    parser.add_argument("--test-url", default=DEFAULT_TEST_URL, help=f"URL used to verify proxy behavior; default {DEFAULT_TEST_URL}")
    parser.add_argument("--unknown-as", choices=("local", "tunnel"), default="local", help="group for open ports whose listener process is hidden")
    parser.add_argument("--format", choices=("env", "json", "table"), default="env", help="output format")
    parser.add_argument("--manual-candidate-list", default=None, help="manual proxy candidates to put first in startup env vars")
    parser.add_argument("--remote-candidate-list", default=None, help="known remote proxy candidates to preserve or write")
    parser.add_argument("--shell", default=os.environ.get("SHELL", ""), help="shell name/path used by --write-startup auto")
    parser.add_argument("--write-startup", nargs="?", const="auto", help="write grouped env vars to a shell startup file; auto uses SHELL")
    parser.add_argument("--write-bashrc", nargs="?", const=str(Path.home() / ".bashrc"), help="write grouped env vars to .bashrc or the given file")
    args = parser.parse_args()

    try:
        ports = parse_ports(args.ports)
    except ValueError as exc:
        print(f"invalid --ports value: {exc}", file=sys.stderr)
        return 2
    listeners = listener_map()
    candidates: list[Candidate] = []
    scan_is_loopback = is_loopback_host(args.host)

    curl_available = subprocess.run(["sh", "-c", "command -v curl >/dev/null 2>&1"]).returncode == 0
    if not curl_available:
        print("curl is required to verify proxy protocols", file=sys.stderr)
        return 3

    for port in ports:
        if not tcp_open(args.host, port, args.tcp_timeout):
            continue
        listener = listeners.get(port, "")
        group = classify_listener(listener, args.unknown_as) if scan_is_loopback else "remote"
        for scheme in ("https", "http", "socks5"):
            url = f"{scheme}://{args.host}:{port}"
            if curl_works(url, args.test_url, args.curl_timeout):
                candidates.append(Candidate(url=url, group=group, port=port, scheme=scheme, listener=listener))

    if args.write_bashrc:
        write_startup(
            Path(args.write_bashrc).expanduser(),
            candidates,
            manual=args.manual_candidate_list,
            remote=args.remote_candidate_list,
        )
    startup_path = resolve_startup_path(args.write_startup, args.shell)
    if startup_path:
        write_startup(
            startup_path,
            candidates,
            manual=args.manual_candidate_list,
            remote=args.remote_candidate_list,
        )

    if args.format == "json":
        print(json.dumps([c.__dict__ for c in candidates], indent=2, sort_keys=True))
    elif args.format == "table":
        for c in candidates:
            listener = c.listener if c.listener else "<listener hidden>"
            print(f"{c.group}\t{c.scheme}\t{c.url}\t{listener}")
    else:
        manual = args.manual_candidate_list if args.manual_candidate_list is not None else os.environ.get("PROXY_MANUAL_CANDIDATE_LIST", "")
        remote = args.remote_candidate_list if args.remote_candidate_list is not None else os.environ.get("PROXY_REMOTE_CANDIDATE_LIST", "")
        print(emit_env(candidates, manual=manual, remote=remote), end="")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
