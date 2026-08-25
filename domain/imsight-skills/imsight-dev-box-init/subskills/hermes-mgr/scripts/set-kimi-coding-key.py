#!/usr/bin/env python3
"""Safely upsert KIMI_CODING_API_KEY in a Hermes dotenv file."""

from __future__ import annotations

import argparse
import getpass
import os
import re
import tempfile
from pathlib import Path


VARIABLE = "KIMI_CODING_API_KEY"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=f"Prompt for and securely store {VARIABLE} without printing it."
    )
    parser.add_argument(
        "--env-file",
        type=Path,
        default=Path.home() / ".hermes" / ".env",
        help="Hermes dotenv file (default: ~/.hermes/.env)",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    env_file = args.env_file.expanduser().resolve()
    secret = getpass.getpass("Kimi Coding API key: ")
    if not secret:
        raise SystemExit("Refusing to store an empty key.")
    if any(character.isspace() for character in secret):
        raise SystemExit("Refusing a key containing whitespace.")

    env_file.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    original = env_file.read_text() if env_file.exists() else ""
    matcher = re.compile(rf"^\s*{re.escape(VARIABLE)}=")
    output: list[str] = []
    replaced = False

    for line in original.splitlines():
        if matcher.match(line):
            if not replaced:
                output.append(f"{VARIABLE}={secret}")
                replaced = True
            continue
        output.append(line)

    if not replaced:
        if output and output[-1]:
            output.append("")
        output.append(f"{VARIABLE}={secret}")

    payload = "\n".join(output) + "\n"
    with tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        dir=env_file.parent,
        prefix=f".{env_file.name}.",
        delete=False,
    ) as handle:
        handle.write(payload)
        temporary = Path(handle.name)

    os.chmod(temporary, 0o600)
    os.replace(temporary, env_file)
    print(f"Stored {VARIABLE} in {env_file} with mode 0600.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
