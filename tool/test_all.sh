#!/usr/bin/env bash
# Run all three test tiers in sequence. Each tier is independent;
# a failure in one does not stop the others — final exit code is the
# logical OR of all tier exit codes.
set -uo pipefail
cd "$(dirname "$0")/.."

rc=0

echo "▶ Tier 1: flutter test (unit)"
tool/run_tests.sh || rc=$?

if [[ -n "${GATEFLOW_DB_URL:-}" ]]; then
  echo
  echo "▶ Tier 2: pgTAP"
  tool/run_pgtap.sh || rc=$?
else
  echo
  echo "↷ Tier 2 skipped (GATEFLOW_DB_URL not set)"
fi

if [[ -f .env.json ]]; then
  echo
  echo "▶ Tier 3: integration"
  tool/run_integration.sh || rc=$?
else
  echo
  echo "↷ Tier 3 skipped (.env.json missing)"
fi

exit "$rc"
