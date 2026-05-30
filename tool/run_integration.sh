#!/usr/bin/env bash
# Tier 3 — Dart integration tests against the remote Supabase project.
#
# Requirements:
#   • .env.json present at repo root with SUPABASE_URL + SUPABASE_ANON_KEY.
#   • Demo accounts have been seeded (App → Settings → "Seed demo accounts"
#     or run SeedService.instance.seedDemoAccounts() once).
#   • A connected device or browser (chrome / desktop) for `flutter test
#     integration_test`.
#
# The test files no-op unless GATEFLOW_IT is true, so this script enforces it.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f .env.json ]]; then
  echo "✗ .env.json missing. Copy .env.json.example and fill it in." >&2
  exit 2
fi

DEVICE="${GATEFLOW_DEVICE:-chrome}"

exec flutter test integration_test \
  --device-id "$DEVICE" \
  --dart-define=GATEFLOW_IT=true \
  --dart-define-from-file=.env.json \
  "$@"
