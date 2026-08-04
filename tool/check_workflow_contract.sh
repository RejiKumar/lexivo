#!/usr/bin/env bash
# Workflow contract: required composite actions must exist (ci-cd §0.5 / §11).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
missing=0
for path in \
  ".github/actions/lint/action.yml" \
  ".github/actions/test/action.yml" \
  ".github/actions/build/action.yml" \
  ".github/actions/deploy-cloud-run/action.yml" \
  ".github/actions/deploy-cloudflare-pages/action.yml" \
  ".github/workflows/pr.yml" \
  ".github/workflows/main.yml" \
  ".github/workflows/deploy-production.yml"
do
  if [[ ! -f "$ROOT/$path" ]]; then
    echo "MISSING: $path"
    missing=1
  else
    echo "OK: $path"
  fi
done
# Deploy composites must require environment input (no hardcoded project in YAML body).
for deploy in deploy-cloud-run deploy-cloudflare-pages; do
  file="$ROOT/.github/actions/$deploy/action.yml"
  if [[ -f "$file" ]]; then
    if ! grep -q "environment:" "$file"; then
      echo "FAIL: $deploy missing environment input"
      missing=1
    fi
    if grep -EIq 'projects/[a-z0-9-]+|project_id:\s*["'\'']?[a-z][a-z0-9-]+' "$file"; then
      echo "FAIL: $deploy appears to hardcode a GCP project id"
      missing=1
    fi
  fi
done
exit "$missing"
