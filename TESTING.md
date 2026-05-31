# GateFlow Testing Guide

Three-tier hybrid test suite covering RBAC, guardians, schedules, gate verification, student status, notifications, realtime bus tracking, and pickup requests.

## Quick start

```bash
# Tier 1 only (fast, no secrets) — run anywhere
chmod +x tool/*.sh
./tool/run_tests.sh

# Tier 2 (RLS/RBAC in Postgres) — needs DB URL
export GATEFLOW_DB_URL='postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres'
./tool/run_pgtap.sh

# Tier 3 (integration against remote Supabase) — needs .env.json + demo accounts
./tool/run_integration.sh

# All tiers (skips 2/3 if env missing)
./tool/test_all.sh
```

## Prerequisites

| Tier | Requires | Safe for remote? |
|------|----------|------------------|
| 1 – Unit | `flutter test` only | Yes (no network) |
| 2 – pgTAP | `GATEFLOW_DB_URL`, `psql`, pgTAP extension | Yes (BEGIN/ROLLBACK) |
| 3 – Integration | `.env.json`, seeded demo accounts | Yes (creates + cleans up test rows) |

### Enable pgTAP (one-time)

```bash
supabase db push   # applies migrations including pgTAP + notifications RLS + realtime
```

### Seed demo accounts (Tier 3)

Integration tests sign in with the anon key. Demo users must exist in **Auth** with matching **`auth.identities`** rows (required for email/password login).

**One-time setup (recommended):**

```bash
export GATEFLOW_DB_URL='postgresql://postgres.[ref]:[password]@…pooler.supabase.com:6543/postgres'
./tool/seed_demo.sh
```

Or let the integration runner seed automatically when `GATEFLOW_DB_URL` is set:

```bash
export GATEFLOW_DB_URL='…'
./tool/run_integration.sh
```

Demo accounts (password **`GateFlow@2024`**):

- `staff@demo.gateflow.app` — school_staff
- `parent@demo.gateflow.app` — parent (linked to demo student)
- `driver@demo.gateflow.app` — bus_driver
- `guardian@demo.gateflow.app` — guardian

The in-app seed button uses sign-up API (also works if email confirmation is disabled). Prefer **`./tool/seed_demo_admin.sh`** when you have the service role key; otherwise use SQL seed.

If integration tests fail with **auth HTTP 400**, re-run seed then verify:

```bash
./tool/seed_demo.sh
./tool/verify_demo_auth.sh parent@demo.gateflow.app
```

Admin API (most reliable):

```bash
export SUPABASE_SERVICE_ROLE_KEY='…'
./tool/seed_demo_admin.sh
```

## Tier 1 – Dart unit tests (`test/unit/`)

Uses offline `MockState` (Supabase not configured during `flutter test`). Tests business logic:

- Student status transitions
- Gate verification + release
- Pickup request lifecycle
- Driver triple-scan outcome
- Role inference from email

```bash
flutter test test/unit/
```

## Tier 2 – pgTAP SQL tests (`supabase/tests/`)

Tests Row-Level Security policies and triggers. Each file wraps tests in `BEGIN … ROLLBACK` so nothing persists on the remote DB.

```bash
export GATEFLOW_DB_URL='…'
./tool/run_pgtap.sh
```

Files:

- `rls_profiles_test.sql` — staff update same-school profiles
- `rls_pickup_requests_test.sql` — parent/staff request access + delete
- `rls_guardians_test.sql` — guardian authorization policies
- `rls_schedules_buses_students_test.sql` — schedules, buses, student status
- `trigger_new_user_test.sql` — profile auto-creation from auth metadata

## Tier 3 – Integration tests (`test/integration/`)

Gated by `--dart-define=GATEFLOW_IT=true`. Skipped automatically when the flag is absent.

```bash
flutter test test/integration \
  --dart-define=GATEFLOW_IT=true \
  --dart-define-from-file=.env.json
```

Coverage:

| Area | Test file |
|------|-----------|
| RBAC smoke | `rbac_smoke_test.dart` |
| Guardian authorization | `guardian_authorization_test.dart` |
| Schedule setup | `schedule_setup_test.dart` |
| Pickup request lifecycle | `pickup_request_lifecycle_test.dart` |
| Student status update | `student_status_update_test.dart` |
| In-app notifications | `notification_test.dart` |
| Realtime bus tracking | `realtime_bus_tracking_test.dart` |

**Note:** “Push notifications” in the app are in-app `notifications` rows + `broadcast_school_notification` RPC — not FCM device push.

**Note:** Gate “QR” is simulated; tests cover national-ID/phone lookup + release logic.

## CI recommendations

- **Every PR:** `./tool/run_tests.sh` (Tier 1)
- **Nightly / pre-release:** Tier 2 + Tier 3 with secrets in CI env
