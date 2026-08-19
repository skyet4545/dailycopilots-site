#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import UTC, datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def now_iso() -> str:
    return datetime.now(UTC).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def ensure(path: Path, kind: str) -> dict[str, object]:
    ok = path.is_dir() if kind == "dir" else path.is_file()
    return {"kind": "path", "path": str(path), "expect": kind, "ok": ok}


def command(cmd: list[str]) -> dict[str, object]:
    proc = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
    return {
        "kind": "command",
        "command": cmd,
        "ok": proc.returncode == 0,
        "returncode": proc.returncode,
        "stdout": proc.stdout.strip(),
        "stderr": proc.stderr.strip(),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--stage", default="preflight")
    args = parser.parse_args()

    results = [
        ensure(ROOT / "product-truth.json", "file"),
        ensure(ROOT / "ci" / "validate-product-contract.mjs", "file"),
        ensure(ROOT / "site-deploy", "dir"),
        ensure(ROOT / "site-deploy" / "_redirects", "file"),
        ensure(ROOT / "site-deploy" / "netlify.toml", "file"),
    ]

    if args.stage == "preflight":
        results.append(command(["node", "ci/validate-product-contract.mjs"]))

    ok = all(item["ok"] for item in results)
    print(
        json.dumps(
            {
                "repo": str(ROOT),
                "stage": args.stage,
                "status": "ok" if ok else "failed",
                "checked_at": now_iso(),
                "results": results,
            },
            indent=2,
        )
    )
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
