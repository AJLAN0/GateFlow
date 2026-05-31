#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -z "${GATEFLOW_DB_URL:-}" ]]; then
  echo "ERROR: Set GATEFLOW_DB_URL to your Supabase Postgres connection string."
  echo "  Dashboard → Project Settings → Database → Connection string (URI)"
  exit 1
fi

echo "==> Seeding integration demo accounts + fixtures"
psql "$GATEFLOW_DB_URL" -v ON_ERROR_STOP=1 -f supabase/seed_demo_integration.sql
chmod +x tool/verify_demo_auth.sh
./tool/verify_demo_auth.sh parent@demo.gateflow.app
echo "==> Done. Demo password: GateFlow@2024"
