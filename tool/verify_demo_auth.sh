#!/usr/bin/env bash
# Verify demo parent can sign in via Supabase Auth API (anon key).
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f .env.json ]]; then
  echo "ERROR: .env.json not found."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "WARN: jq not installed — skipping auth verify."
  exit 0
fi

URL="$(jq -r .SUPABASE_URL .env.json | sed 's|/$||')"
KEY="$(jq -r .SUPABASE_ANON_KEY .env.json)"
EMAIL="${1:-parent@demo.gateflow.app}"
PASSWORD="${2:-GateFlow@2024}"

RESP="$(curl -sS -w "\n%{http_code}" -X POST \
  "$URL/auth/v1/token?grant_type=password" \
  -H "apikey: $KEY" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")"

HTTP="$(echo "$RESP" | tail -n1)"
BODY="$(echo "$RESP" | sed '$d')"

if [[ "$HTTP" != "200" ]]; then
  echo "ERROR: Demo sign-in failed for $EMAIL (HTTP $HTTP)"
  echo "$BODY" | head -c 500
  echo ""
  echo "Re-run: export GATEFLOW_DB_URL=... && ./tool/seed_demo.sh"
  exit 1
fi

echo "OK: $EMAIL can sign in (HTTP 200)"
