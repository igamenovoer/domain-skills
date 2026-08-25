#!/usr/bin/env python3
"""Merge the maintained local-external Hindsight settings into Hermes config."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import tempfile
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Configure Hermes' Hindsight plugin without replacing unrelated keys."
    )
    parser.add_argument(
        "--hermes-home",
        type=Path,
        default=Path(os.environ.get("HERMES_HOME", Path.home() / ".hermes")),
        help="Hermes home (default: HERMES_HOME or ~/.hermes)",
    )
    parser.add_argument("--api-url", default="http://127.0.0.1:18888")
    parser.add_argument("--bank-id", default="hermes")
    parser.add_argument(
        "--bank-id-template",
        default="hermes-{profile}-{platform}-{user}",
    )
    parser.add_argument(
        "--no-backup",
        action="store_true",
        help="Do not refresh config.json.bak before writing.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    config_dir = args.hermes_home.expanduser().resolve() / "hindsight"
    config_path = config_dir / "config.json"
    config_dir.mkdir(mode=0o700, parents=True, exist_ok=True)

    if config_path.exists():
        try:
            config = json.loads(config_path.read_text())
        except json.JSONDecodeError as error:
            raise SystemExit(f"Refusing to replace invalid JSON in {config_path}: {error}")
        if not isinstance(config, dict):
            raise SystemExit(f"Refusing to replace non-object JSON in {config_path}.")
        if not args.no_backup:
            shutil.copy2(config_path, config_path.with_suffix(".json.bak"))
    else:
        config = {}

    config.update(
        {
            "mode": "local_external",
            "api_url": args.api_url,
            "bank_id": args.bank_id,
            "bank_id_template": args.bank_id_template,
            "memory_mode": "hybrid",
            "auto_retain": True,
            "auto_recall": True,
            "retain_async": True,
            "retain_every_n_turns": 1,
            "recall_budget": "mid",
            "recall_types": "observation",
        }
    )

    with tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        dir=config_dir,
        prefix=".config.",
        delete=False,
    ) as handle:
        json.dump(config, handle, indent=2, sort_keys=True)
        handle.write("\n")
        temporary = Path(handle.name)

    os.chmod(temporary, 0o600)
    os.replace(temporary, config_path)
    print(f"Updated {config_path}; unrelated keys were preserved.")
    if config_path.with_suffix(".json.bak").exists() and not args.no_backup:
        print(f"Previous configuration: {config_path.with_suffix('.json.bak')}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
