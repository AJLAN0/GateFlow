#!/usr/bin/env bash
# Chain the three tiers in order: unit → pgTAP (if DB URL set) → integration.
set -euo pipefail
cd "$(dirname "$0")/.."

bash tool/run_tests.sh

if [[ -n "${GATEFLOW_DB_URL:-}" ]]; then
  bash tool/run_pgtap.sh
else
  echo "↷ Skipping Tier 2 (pgTAP) — set GATEFLOW_DB_URL to enable."
fi

if [[ -f .env.json ]]; then
  bash tool/run_integration.sh
else
  echo "↷ Skipping Tier 3 (integration) — .env.json not found."
fi
