#!/usr/bin/env bash
# Tier 2 — pgTAP RLS / trigger tests.
#
# Each test file is wrapped in BEGIN; ... ROLLBACK; so it is safe to run
# against the live remote project — nothing persists.
#
# Requirements:
#   • GATEFLOW_DB_URL exported  (Supabase dashboard → Project Settings →
#     Database → Connection string · psql)
#   • The 20240106_enable_pgtap migration has been applied.
#   • psql ≥ 14 installed locally.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -z "${GATEFLOW_DB_URL:-}" ]]; then
  echo "✗ Set GATEFLOW_DB_URL to the Supabase Postgres connection string." >&2
  exit 2
fi

tests=(
  supabase/tests/rls_profiles_test.sql
  supabase/tests/rls_pickup_requests_test.sql
  supabase/tests/rls_guardians_test.sql
  supabase/tests/rls_schedules_buses_students_test.sql
  supabase/tests/trigger_new_user_test.sql
)

fail=0
for f in "${tests[@]}"; do
  echo
  echo "── $f ──────────────────────────────"
  if ! psql "$GATEFLOW_DB_URL" \
        --no-psqlrc \
        --quiet \
        --variable ON_ERROR_STOP=1 \
        --file "$f"; then
    fail=1
  fi
done

exit "$fail"
