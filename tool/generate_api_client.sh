#!/usr/bin/env bash
# Regenerate OpenAPI snapshot and (eventually) the Dart Dio client.
#
# TODO(openapi-codegen): wire openapi-generator-cli (dart-dio) or
# swagger_dart_code_generator once dependency/SDK pins allow a stable
# generated package. Until then, `lib/core/network/api_client.dart` is an
# interim typed Dio façade matching paths in openapi/lexivo.openapi.json.
#
# CI enforces snapshot drift via ./tool/check_openapi_snapshot.sh
# (in-process create_app().openapi()). Full codegen remains optional.
#
# Usage:
#   ./tool/generate_api_client.sh [BASE_URL]
#   # Prefer offline update when backend deps are installed:
#   python backend/scripts/check_openapi_snapshot.py --update
#
# Prerequisites: curl, python3 (optional pretty-print), backend running
# (for curl path only).

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE_URL="${1:-http://localhost:8000}"
OUT="$ROOT/openapi/lexivo.openapi.json"

echo "Fetching OpenAPI from ${BASE_URL}/openapi.json ..."
curl -fsS "${BASE_URL}/openapi.json" -o "$OUT"
echo "Wrote $OUT"
echo "Next: regenerate Dart client into lib/core/network/generated/ (not yet automated)."
