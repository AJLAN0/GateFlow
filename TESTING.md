# Testing GateFlow

GateFlow ships with a **3-tier hybrid test suite**. Each tier has a different
cost / coverage trade-off, so you can pick what to run depending on what you
have on hand (laptop only, DB credentials, demo accounts).

| Tier | What it covers                                  | Where it runs                                | Speed  | Prereqs                          |
|------|--------------------------------------------------|-----------------------------------------------|--------|----------------------------------|
| 1    | MockState business logic (no infra)              | `flutter test` locally                        | <2s    | Flutter SDK                      |
| 2    | RBAC / RLS / triggers in Postgres (pgTAP)        | `psql` against remote Supabase (rolled back)  | ~5s    | `GATEFLOW_DB_URL`, `psql`        |
| 3    | End-to-end service / realtime / notification     | `flutter test integration_test` against remote | ~30s+ | `.env.json` + seeded demo users   |

The 8 requested coverage areas split across these tiers — see the
*Area-by-area* table at the bottom.

## Tier 1 — Dart unit tests

```bash
tool/run_tests.sh
# or: flutter test test/unit
```

These tests never touch Supabase. They drive the offline `MockState` seam:

- `student_status_test.dart` – `updateStudentStatus`, enum round-trip, listener count
- `gate_verification_test.dart` – `releaseStudentAfterVerification`, `approvedParentRequestsAwaitingPickup`, gate-directory lookup
- `pickup_request_test.dart` – `submitNewParentRequest`, `updateRequestStatus`, `updateSchoolTimeRequest`
- `driver_scan_test.dart` – triple-scan phase machine + alert emission
- `role_mapping_test.dart` – `roleFromString`, `inferRoleFromEmail`, offline `signInWithEmailPassword`

Helpers live in `test/support/state_factory.dart`.

## Tier 2 — pgTAP RBAC / RLS / triggers

Each `*.sql` file under `supabase/tests/` is structured as:

```sql
BEGIN;
\i supabase/tests/_helpers.sql
SELECT plan(N);
-- ...assertions...
SELECT * FROM finish();
ROLLBACK;
```

Because every test rolls back, **nothing persists** in your remote DB —
safe to run against the live Supabase project you already have.

### One-time setup

The new migration `supabase/migrations/20240106000000_enable_pgtap.sql`
installs the `pgtap` extension into the `extensions` schema. Apply it once
(via `supabase db push` from a workstation, or by pasting the SQL into the
Supabase SQL editor).

### Running

```bash
export GATEFLOW_DB_URL='postgresql://postgres:<password>@<project>.supabase.co:5432/postgres'
tool/run_pgtap.sh
```

Use the **direct** connection string (port 5432) from
*Project Settings → Database → Connection string* so the
`request.jwt.claims` `SET LOCAL` calls work.

### Files

| File                                       | Covers |
|--------------------------------------------|--------|
| `rls_profiles_test.sql`                    | Staff cross-school isolation; staff UPDATE own school; `my_role()` / `my_school_id()` resolution |
| `rls_pickup_requests_test.sql`             | Parent own-only, parent delete-own-pending, staff school-wide UPDATE/DELETE |
| `rls_guardians_test.sql`                   | Parent manages own; staff manages in-school; cross-school blocked |
| `rls_schedules_buses_students_test.sql`    | Staff CRUD; driver UPDATE own-bus only; driver cannot delete schedules |
| `trigger_new_user_test.sql`                | `fn_handle_new_user` reads metadata correctly |

## Tier 3 — Dart integration

Opt-in. The suite is gated by `bool.fromEnvironment('GATEFLOW_IT')` so it
never accidentally runs in `flutter test`.

### Prereqs

1. `.env.json` (copy `.env.json.example`) populated with `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
2. Demo accounts seeded (use the in-app *Seed demo accounts* button, or run `dart run tool/seed_accounts.dart`). All four roles use password `GateFlow@2024`.

### Running

```bash
tool/run_integration.sh
```

Expands to:

```bash
flutter test integration_test \
  --dart-define=GATEFLOW_IT=true \
  --dart-define-from-file=.env.json
```

### Files & flows

| File                                   | Flow |
|----------------------------------------|------|
| `rbac_smoke_test.dart`                 | Parent vs. staff visibility on `pickup_requests`; parent insert into `daily_schedules` is denied |
| `guardian_authorization_test.dart`     | Parent submit → staff approve → gate-lookup |
| `schedule_setup_test.dart`             | Staff `ScheduleService` CRUD; non-staff insert denied |
| `pickup_request_lifecycle_test.dart`   | Parent submit → staff approve → `releaseAtGate`; parent delete-own-pending |
| `student_status_update_test.dart`      | Staff status update persists; driver own-bus only |
| `notification_test.dart`               | `NotificationService.send` + `unreadCount` + `markAllRead`; `broadcast_school_notification` RPC fans out |
| `realtime_bus_tracking_test.dart`      | One client updates `buses.status`, a subscriber receives the new value within 15s |

Created rows are tracked per-test and deleted in `tearDownAll`.
Broadcast notification rows that land in other users' mailboxes are not
deletable from the test client (RLS keeps them owner-only), so they accumulate
slowly — acceptable for a smoke flow.

## Run everything

```bash
# fastest path
tool/run_tests.sh                                  # Tier 1

# DB-backed
GATEFLOW_DB_URL='...' tool/run_pgtap.sh            # Tier 2

# end-to-end
tool/run_integration.sh                            # Tier 3

# all three
GATEFLOW_DB_URL='...' tool/test_all.sh
```

## Area-by-area coverage

| Area                              | Tier 1 (unit)                       | Tier 2 (pgTAP)                                | Tier 3 (integration)                   |
|-----------------------------------|--------------------------------------|------------------------------------------------|----------------------------------------|
| RBAC                              | role_mapping                         | rls_profiles + every other rls_* file          | rbac_smoke                             |
| Guardian Authorization            | gate_verification (directory)        | rls_guardians                                  | guardian_authorization                 |
| Schedule Setup                    | —                                    | rls_schedules_buses_students                   | schedule_setup                         |
| Parent Verification ("QR" lookup) | gate_verification                    | —                                              | guardian_authorization (gate lookup)   |
| Student Status Update             | student_status                       | rls_schedules_buses_students (driver policy)   | student_status_update                  |
| Push Notification (rows + RPC)    | —                                    | —                                              | notification                           |
| Real-Time Tracking (Bus)          | —                                    | —                                              | realtime_bus_tracking                  |
| Early Pickup / Late Drop-off      | pickup_request                       | rls_pickup_requests                            | pickup_request_lifecycle               |

## Notes and caveats

- **"Push Notification"** in this app means the `notifications` table + the
  `broadcast_school_notification` RPC. There is no Firebase Cloud Messaging
  wiring yet (the `firebase_messaging` plugin is **not** a dependency). FCM
  device delivery is a manual check until that wiring lands.
- **"QR at the gate"** is currently a simulated payload (`_simulateQr`);
  the real gate flow is national-ID / phone lookup. The tests assert that
  lookup logic and the simulated payload toggle.
- **Tier 2 safety**: every test BEGINs and ROLLBACKs, so the remote DB is
  byte-for-byte identical before and after.
- **Tier 3 safety**: rows created during a run are tracked and deleted in
  `tearDownAll`. Real demo account credentials are never modified.
- **Realtime test** uses a generous 15s timeout. Bump it if your network is
  slow; consider running just `realtime_bus_tracking_test.dart` to debug.
