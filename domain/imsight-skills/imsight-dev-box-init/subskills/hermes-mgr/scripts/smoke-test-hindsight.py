#!/usr/bin/env python3
"""Run a temporary retain/recall test and delete its Hindsight bank."""

from __future__ import annotations

import argparse
import json
import time
import urllib.error
import urllib.request
import uuid


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Exercise Hindsight retain/recall in a disposable bank."
    )
    parser.add_argument(
        "--api-url",
        default="http://127.0.0.1:18888",
        help="Hindsight API URL (default: http://127.0.0.1:18888)",
    )
    return parser.parse_args()


def request_json(
    url: str,
    method: str,
    payload: dict | None = None,
    timeout: int = 180,
) -> object:
    body = None if payload is None else json.dumps(payload).encode()
    request = urllib.request.Request(
        url,
        data=body,
        method=method,
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(request, timeout=timeout) as response:
        content = response.read()
    return json.loads(content) if content else {}


def main() -> int:
    args = parse_args()
    base_url = args.api_url.rstrip("/")
    bank_id = f"hermes-sanity-{uuid.uuid4().hex[:12]}"
    marker = f"paper-kite-{uuid.uuid4().hex[:10]}"
    bank_url = f"{base_url}/v1/default/banks/{bank_id}"

    try:
        request_json(
            f"{bank_url}/memories",
            "POST",
            {
                "async": False,
                "items": [
                    {
                        "content": f"The temporary Hindsight sanity codename is {marker}.",
                        "context": "temporary integration test",
                    }
                ],
            },
        )

        recalled = None
        for attempt in range(3):
            recalled = request_json(
                f"{bank_url}/memories/recall",
                "POST",
                {
                    "query": "What is the temporary Hindsight sanity codename?",
                    "types": ["world", "experience", "observation"],
                    "budget": "mid",
                },
            )
            if marker.lower() in json.dumps(recalled).lower():
                break
            if attempt < 2:
                time.sleep(2)

        if marker.lower() not in json.dumps(recalled).lower():
            raise RuntimeError("Recall succeeded but did not return the retained marker.")

        print("Hindsight retain/recall smoke test passed.")
        return 0
    except (urllib.error.URLError, RuntimeError, ValueError) as error:
        print(f"Hindsight smoke test failed: {error}")
        return 1
    finally:
        try:
            request_json(bank_url, "DELETE", timeout=30)
            print(f"Deleted disposable bank {bank_id}.")
        except Exception as error:
            print(f"WARNING: could not delete disposable bank {bank_id}: {error}")


if __name__ == "__main__":
    raise SystemExit(main())
