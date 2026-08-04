#!/usr/bin/env python3
"""Export FastAPI OpenAPI schema and diff against checked-in snapshot.

Usage (from repo root or backend/):
  python backend/scripts/check_openapi_snapshot.py
  python backend/scripts/check_openapi_snapshot.py --update
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

BACKEND_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = BACKEND_ROOT.parent
SNAPSHOT = REPO_ROOT / "openapi" / "lexivo.openapi.json"

# Ensure `app` is importable when run from repo root.
if str(BACKEND_ROOT) not in sys.path:
    sys.path.insert(0, str(BACKEND_ROOT))


def _normalize(schema: object) -> str:
    return json.dumps(schema, indent=2, sort_keys=True, ensure_ascii=False) + "\n"


def export_schema() -> dict:
    from app.main import create_app

    return create_app().openapi()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--update",
        action="store_true",
        help="Rewrite openapi/lexivo.openapi.json from create_app().openapi()",
    )
    args = parser.parse_args()

    current = export_schema()
    normalized = _normalize(current)

    if args.update:
        SNAPSHOT.parent.mkdir(parents=True, exist_ok=True)
        SNAPSHOT.write_text(normalized, encoding="utf-8")
        print(f"Updated {SNAPSHOT}")
        return 0

    if not SNAPSHOT.is_file():
        print(f"MISSING snapshot: {SNAPSHOT}", file=sys.stderr)
        return 1

    expected = SNAPSHOT.read_text(encoding="utf-8")
    # Re-normalize file contents so whitespace-only drift is caught consistently.
    try:
        expected_norm = _normalize(json.loads(expected))
    except json.JSONDecodeError as exc:
        print(f"Invalid snapshot JSON: {exc}", file=sys.stderr)
        return 1

    if expected_norm != normalized:
        print(
            "OpenAPI snapshot drift detected.\n"
            f"  Snapshot: {SNAPSHOT}\n"
            "  Fix: python backend/scripts/check_openapi_snapshot.py --update\n"
            "  Or regenerate via running backend + ./tool/generate_api_client.sh",
            file=sys.stderr,
        )
        return 1

    print(f"OpenAPI snapshot OK: {SNAPSHOT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
