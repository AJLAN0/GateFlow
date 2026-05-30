#!/usr/bin/env bash
# Tier 3 — opt-in Dart integration tests against the remote Supabase.
# Uses real demo accounts; rows created during the run are cleaned up.
#
# Prerequisites:
#   * .env.json with SUPABASE_URL + SUPABASE_ANON_KEY at the repo root.
#   * Demo accounts seeded (the in-app "Seed demo accounts" button, or
#     `dart run tool/seed_accounts.dart`).
#
# Usage:
#   tool/run_integration.sh                  # all integration tests
#   tool/run_integration.sh -d <device-id>   # pass extra flutter args
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f .env.json ]]; then
  echo "✗ .env.json is missing. Copy .env.json.example and fill in your project keys."
  exit 1
fi

echo "▶ Tier 3 — flutter test integration_test (GATEFLOW_IT=true)"
flutter test integration_test \
  --dart-define=GATEFLOW_IT=true \
  --dart-define-from-file=.env.json \
  "$@"
