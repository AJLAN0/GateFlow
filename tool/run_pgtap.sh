#!/usr/bin/env bash
# Tier 2 — pgTAP RBAC / RLS / trigger tests against the remote Supabase.
# -----------------------------------------------------------------------------
# Every test file wraps its body in BEGIN; ... ROLLBACK; — nothing persists.
#
# Required env:
#   GATEFLOW_DB_URL   postgres://...   (use the *direct* connection string from
#                                       the Supabase dashboard; pgTAP runs as a
#                                       superuser-equivalent role).
#
# Usage:
#   GATEFLOW_DB_URL='postgresql://...' tool/run_pgtap.sh
set -euo pipefail
cd "$(dirname "$0")/.."

: "${GATEFLOW_DB_URL:?GATEFLOW_DB_URL must be set to your Supabase DB connection string}"

FILES=(
  supabase/tests/rls_profiles_test.sql
  supabase/tests/rls_pickup_requests_test.sql
  supabase/tests/rls_guardians_test.sql
  supabase/tests/rls_schedules_buses_students_test.sql
  supabase/tests/trigger_new_user_test.sql
)

fail=0
for f in "${FILES[@]}"; do
  echo "▶ pgTAP — $f"
  if ! psql "$GATEFLOW_DB_URL" -v ON_ERROR_STOP=1 -X -q -f "$f"; then
    echo "  ✗ $f failed"
    fail=1
  fi
done

if [[ $fail -ne 0 ]]; then
  echo "✗ Some pgTAP files failed"
  exit 1
fi
echo "✓ All pgTAP files passed"
