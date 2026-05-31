#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f .env.json ]]; then
  echo "ERROR: .env.json not found. Copy .env.json.example and fill in credentials."
  exit 1
fi

if [[ -n "${GATEFLOW_DB_URL:-}" ]]; then
  echo "==> Seeding demo accounts (GATEFLOW_DB_URL)"
  psql "$GATEFLOW_DB_URL" -v ON_ERROR_STOP=1 -f supabase/seed_demo_integration.sql
  chmod +x tool/verify_demo_auth.sh
  ./tool/verify_demo_auth.sh parent@demo.gateflow.app
else
  echo "WARN: GATEFLOW_DB_URL not set — skipping demo seed."
  echo "      Export GATEFLOW_DB_URL or run ./tool/seed_demo.sh first."
fi

echo "==> Tier 3: Integration tests (remote Supabase, opt-in)"
flutter test test/integration \
  --concurrency=1 \
  --dart-define=GATEFLOW_IT=true \
  --dart-define-from-file=.env.json
