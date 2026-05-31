#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

./tool/run_tests.sh

if [[ -n "${GATEFLOW_DB_URL:-}" ]]; then
  ./tool/run_pgtap.sh
else
  echo "SKIP: Tier 2 pgTAP (GATEFLOW_DB_URL not set)"
fi

if [[ -f .env.json ]]; then
  ./tool/run_integration.sh
else
  echo "SKIP: Tier 3 integration (.env.json not found)"
fi
