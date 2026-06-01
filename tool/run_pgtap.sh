#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -z "${GATEFLOW_DB_URL:-}" ]]; then
  echo "ERROR: Set GATEFLOW_DB_URL to your Supabase Postgres connection string."
  echo "  Dashboard → Project Settings → Database → Connection string (URI)"
  exit 1
fi

echo "==> Tier 2: pgTAP RLS tests (each file runs in BEGIN/ROLLBACK)"
for f in supabase/tests/*_test.sql; do
  echo "--- $f"
  psql "$GATEFLOW_DB_URL" -v ON_ERROR_STOP=1 -f "$f"
done
echo "==> All pgTAP tests passed."
