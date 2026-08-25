#!/usr/bin/env python3
"""Merge approved Feishu pairing IDs into Hermes' static Feishu allowlist."""

from __future__ import annotations

import argparse
import json
import os
import stat
import tempfile
from pathlib import Path


ENV_KEY = "FEISHU_ALLOWED_USERS"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Check or merge approved Feishu pairing IDs into "
            "FEISHU_ALLOWED_USERS without printing the IDs."
        )
    )
    parser.add_argument(
        "--hermes-home",
        type=Path,
        default=Path(os.environ.get("HERMES_HOME", Path.home() / ".hermes")),
        help="Hermes home to inspect (default: HERMES_HOME or ~/.hermes)",
    )
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="Check coverage without writing (default)")
    mode.add_argument("--apply", action="store_true", help="Merge approved pairing IDs into .env")
    return parser.parse_args()


def approved_pairing_ids(hermes_home: Path) -> list[str]:
    candidates = (
        hermes_home / "platforms" / "pairing" / "feishu-approved.json",
        hermes_home / "pairing" / "feishu-approved.json",
    )
    approved: list[str] = []
    seen: set[str] = set()
    for path in candidates:
        if not path.is_file():
            continue
        try:
            payload = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            raise RuntimeError(f"could not read pairing store {path}: {exc}") from exc
        if not isinstance(payload, dict):
            raise RuntimeError(f"unexpected pairing store shape in {path}")
        for raw_user_id in payload:
            user_id = str(raw_user_id).strip()
            if user_id and user_id not in seen:
                approved.append(user_id)
                seen.add(user_id)
    return approved


def unquote_dotenv_value(raw: str) -> str:
    value = raw.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        value = value[1:-1]
    return value


def active_env_assignment(line: str) -> tuple[str, str] | None:
    stripped = line.strip()
    if not stripped or stripped.startswith("#"):
        return None
    if stripped.startswith("export "):
        stripped = stripped[7:].lstrip()
    key, separator, raw_value = stripped.partition("=")
    if not separator:
        return None
    return key.strip(), unquote_dotenv_value(raw_value)


def read_env_file(env_path: Path) -> tuple[list[str], list[str]]:
    if not env_path.exists():
        return [], []
    try:
        lines = env_path.read_text(encoding="utf-8").splitlines(keepends=True)
    except OSError as exc:
        raise RuntimeError(f"could not read {env_path}: {exc}") from exc
    values: list[str] = []
    for line in lines:
        assignment = active_env_assignment(line)
        if assignment and assignment[0] == ENV_KEY:
            values = [part.strip() for part in assignment[1].split(",") if part.strip()]
    return lines, values


def merged_allowlist(existing: list[str], approved: list[str]) -> list[str]:
    merged: list[str] = []
    seen: set[str] = set()
    for user_id in [*existing, *approved]:
        if user_id and user_id not in seen:
            merged.append(user_id)
            seen.add(user_id)
    return merged


def render_env(lines: list[str], merged: list[str]) -> str:
    replacement = f"{ENV_KEY}={','.join(merged)}\n"
    rendered: list[str] = []
    inserted = False
    for line in lines:
        assignment = active_env_assignment(line)
        if assignment and assignment[0] == ENV_KEY:
            if not inserted:
                rendered.append(replacement)
                inserted = True
            continue
        rendered.append(line)
    if not inserted:
        if rendered and not rendered[-1].endswith("\n"):
            rendered[-1] += "\n"
        rendered.append(replacement)
    return "".join(rendered)


def atomic_write_private(env_path: Path, content: str) -> None:
    env_path.parent.mkdir(parents=True, exist_ok=True)
    mode = stat.S_IMODE(env_path.stat().st_mode) if env_path.exists() else 0o600
    if mode & 0o077:
        mode = 0o600
    temp_name = ""
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            dir=env_path.parent,
            prefix=f".{env_path.name}.",
            delete=False,
        ) as handle:
            temp_name = handle.name
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        os.chmod(temp_name, mode)
        os.replace(temp_name, env_path)
    finally:
        if temp_name:
            try:
                Path(temp_name).unlink()
            except FileNotFoundError:
                pass


def main() -> int:
    args = parse_args()
    hermes_home = args.hermes_home.expanduser().resolve()
    env_path = hermes_home / ".env"

    try:
        approved = approved_pairing_ids(hermes_home)
        lines, existing = read_env_file(env_path)
    except RuntimeError as exc:
        print(f"error={exc}")
        return 2

    wildcard = "*" in existing
    covered = wildcard or set(approved).issubset(existing)
    merged = existing if wildcard else merged_allowlist(existing, approved)
    change_needed = merged != existing

    print(f"approved_feishu_users={len(approved)}")
    print(f"static_allowlist_entries={len(existing)}")
    print(f"paired_users_covered={'yes' if covered else 'no'}")
    print(f"change_needed={'yes' if change_needed else 'no'}")

    if not args.apply:
        return 0
    if not approved:
        print("error=no approved Feishu pairing users found; refusing to write")
        return 2
    if wildcard:
        print("applied=no (static allowlist already contains wildcard)")
        return 0
    if not change_needed:
        print("applied=no (already covered)")
        return 0

    try:
        atomic_write_private(env_path, render_env(lines, merged))
    except OSError as exc:
        print(f"error=could not update {env_path}: {exc}")
        return 2

    print(f"applied=yes added_entries={len(merged) - len(existing)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
