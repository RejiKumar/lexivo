#!/usr/bin/env bash
# CI-enforced OpenAPI snapshot check (ci-cd §5).
# Full dart-dio codegen remains optional (TODO(openapi-codegen)).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export PYTHONPATH="${ROOT}/backend${PYTHONPATH:+:$PYTHONPATH}"
exec python backend/scripts/check_openapi_snapshot.py "$@"
