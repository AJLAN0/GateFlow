#!/usr/bin/env bash
# Seed demo users via Supabase Auth Admin API (creates working auth.identities).
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f .env.json ]]; then
  echo "ERROR: .env.json not found."
  exit 1
fi

if [[ -z "${SUPABASE_SERVICE_ROLE_KEY:-}" ]]; then
  echo "ERROR: Set SUPABASE_SERVICE_ROLE_KEY (Dashboard → Settings → API → service_role)."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq required."
  exit 1
fi

URL="$(jq -r .SUPABASE_URL .env.json | sed 's|/$||')"
SRK="$SUPABASE_SERVICE_ROLE_KEY"
SCHOOL_ID="00000000-0000-0000-0000-000000000001"
PW="GateFlow@2024"

upsert_user() {
  local email="$1" role="$2" name="$3"
  local extra="${4:-{}}"

  local existing
  existing="$(curl -sS -G "$URL/auth/v1/admin/users" \
    -H "apikey: $SRK" -H "Authorization: Bearer $SRK" \
    --data-urlencode "email=$email" | jq -r '.users[0].id // empty')"

  if [[ -n "$existing" ]]; then
    curl -sS -X PUT "$URL/auth/v1/admin/users/$existing" \
      -H "apikey: $SRK" -H "Authorization: Bearer $SRK" \
      -H "Content-Type: application/json" \
      -d "{\"password\":\"$PW\",\"email_confirm\":true,\"user_metadata\":$(jq -nc \
        --arg n "$name" --arg r "$role" --arg s "$SCHOOL_ID" \
        --argjson x "$extra" \
        '{full_name:$n,role:$r,school_id:$s} + $x')}" >/dev/null
    echo "– Updated $email ($existing)" >&2
    echo "$existing"
    return
  fi

  local created
  created="$(curl -sS -X POST "$URL/auth/v1/admin/users" \
    -H "apikey: $SRK" -H "Authorization: Bearer $SRK" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$email\",\"password\":\"$PW\",\"email_confirm\":true,\"user_metadata\":$(jq -nc \
      --arg n "$name" --arg r "$role" --arg s "$SCHOOL_ID" \
      --argjson x "$extra" \
      '{full_name:$n,role:$r,school_id:$s} + $x')}" | jq -r '.id')"

  if [[ -z "$created" || "$created" == "null" ]]; then
    echo "ERROR: Failed to create $email" >&2
    exit 1
  fi
  echo "✓ Created $email ($created)" >&2
  echo "$created"
}

echo "==> Admin API demo seed"
if [[ -n "${GATEFLOW_DB_URL:-}" ]]; then
  psql "$GATEFLOW_DB_URL" -v ON_ERROR_STOP=1 -c \
    "INSERT INTO public.schools (id,name,address,phone,email) VALUES ('$SCHOOL_ID','GateFlow Demo School','Riyadh','+966110000000','admin@gateflow.demo') ON CONFLICT (id) DO NOTHING;"
fi

STAFF="$(upsert_user staff@demo.gateflow.app school_staff 'Noura Al-Zahrani')"
PARENT="$(upsert_user parent@demo.gateflow.app parent 'Khaled Al-Otaibi' '{"national_id":"1234567890","phone":"+966501112233"}')"
DRIVER="$(upsert_user driver@demo.gateflow.app bus_driver 'Omar Bin Saleh')"
GUARDIAN="$(upsert_user guardian@demo.gateflow.app guardian 'Mohammed Ali' '{"national_id":"9876543210","phone":"+96650004411"}')"

if [[ -n "${GATEFLOW_DB_URL:-}" ]]; then
  psql "$GATEFLOW_DB_URL" -v ON_ERROR_STOP=1 <<SQL
UPDATE profiles SET school_id='$SCHOOL_ID', role='school_staff', is_active=true WHERE id='$STAFF';
UPDATE profiles SET school_id='$SCHOOL_ID', role='parent', national_id='1234567890', phone='+966501112233', is_active=true WHERE id='$PARENT';
UPDATE profiles SET school_id='$SCHOOL_ID', role='bus_driver', is_active=true WHERE id='$DRIVER';
UPDATE profiles SET school_id='$SCHOOL_ID', role='guardian', national_id='9876543210', phone='+96650004411', is_active=true WHERE id='$GUARDIAN';

INSERT INTO buses (id,name,route_label,plate_number,school_id,driver_id,status)
VALUES ('00000000-0000-0000-0000-000000000010','Bus 12A','North Route · Zones A–D','ABC-1234','$SCHOOL_ID','$DRIVER','stationary')
ON CONFLICT (id) DO UPDATE SET driver_id=EXCLUDED.driver_id;

INSERT INTO students (id,name,grade,school_id,status,transport_type,bus_id)
VALUES ('00000000-0000-0000-0000-000000000021','Noah Khaled','Grade 1','$SCHOOL_ID','at_school','bus','00000000-0000-0000-0000-000000000010')
ON CONFLICT (id) DO UPDATE SET bus_id=EXCLUDED.bus_id;

INSERT INTO parent_students (parent_id,student_id)
VALUES ('$PARENT','00000000-0000-0000-0000-000000000021')
ON CONFLICT (parent_id,student_id) DO NOTHING;
SQL
fi

chmod +x tool/verify_demo_auth.sh
./tool/verify_demo_auth.sh parent@demo.gateflow.app
echo "==> Admin seed complete"
