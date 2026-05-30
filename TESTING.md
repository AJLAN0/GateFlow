# GateFlow Test Suite

Three complementary tiers, each optimised for a different layer of the stack.

| Tier | What it covers | Where it runs | When to run |
|------|----------------|---------------|-------------|
| **1 · Dart unit** | `MockState` business logic — request lifecycle, gate verification, driver scan FSM, role inference, status round-trips | `flutter test` (offline, no infra) | Every push / pre-commit |
| **2 · pgTAP** | RBAC, RLS policies, `fn_handle_new_user` trigger | `psql` against the live DB inside `BEGIN; … ROLLBACK;` | Before merging changes that touch SQL / policies |
| **3 · Dart integration** | End-to-end service flows over Supabase: guardian approval, schedule CRUD, request lifecycle, driver scope, notifications, realtime bus | `flutter test integration_test` against remote Supabase, gated by `GATEFLOW_IT=true` | Before releases; locally when wiring a new service |

The split mirrors enforcement layers. RBAC is enforced **only by Postgres RLS**,
so the truth-table for it lives in Tier 2; Tier 3 is a smoke-level sanity check
on top.

---

## Tier 1 — Dart unit tests

```bash
flutter pub get
tool/run_tests.sh           # → flutter test test/unit
```

No secrets, no network. `MockState`'s offline seed makes every mutation
deterministic; tests assert against the same in-memory lists the UI reads from.

Files: `test/unit/*.dart`, helpers in `test/support/`.

---

## Tier 2 — pgTAP RLS & trigger tests

Apply the new `20240106_enable_pgtap` migration to your project once, then:

```bash
export GATEFLOW_DB_URL='postgresql://postgres:[PWD]@db.[PROJECT].supabase.co:5432/postgres'
tool/run_pgtap.sh
```

What you'll get: `ok 1 … ok N` lines per file. The whole run is wrapped in a
transaction that rolls back, so the database is left in exactly the state it
was before — safe to point at production.

Files: `supabase/tests/*.sql`, helpers in `supabase/tests/_helpers.sql`.

---

## Tier 3 — Dart integration tests (opt-in)

Tier 3 mutates real data — it lives behind an env flag so it can never
fire by accident.

Prerequisites:

1. `.env.json` at repo root (copy `.env.json.example` and fill in).
2. Demo accounts seeded — sign in once and hit the "Seed demo accounts"
   action, or call `SeedService.instance.seedDemoAccounts()` from a tool.

Run:

```bash
tool/run_integration.sh                 # default device: chrome
GATEFLOW_DEVICE=macos tool/run_integration.sh
```

Each test tracks the IDs it creates and removes them in `tearDownAll`. The
demo staff/parent/driver/guardian credentials are never modified.

Files: `integration_test/*_test.dart`, harness in `integration_test/support/`.

---

## Run everything

```bash
tool/test_all.sh
```

Tier 2 and Tier 3 are skipped automatically when their prerequisites are
missing, so this works in CI without any branching.

---

## Area coverage map

| Requested area | Tier 1 | Tier 2 | Tier 3 |
|----------------|--------|--------|--------|
| RBAC | — | `rls_profiles_test.sql` + all `rls_*` | `rbac_smoke_test.dart` |
| Guardian Authorization | `pickup_request_test.dart` (linked-child path) | `rls_guardians_test.sql` | `guardian_authorization_test.dart` |
| Schedule Setup | — | `rls_schedules_buses_students_test.sql` | `schedule_setup_test.dart` |
| Parent Verification (QR) | `gate_verification_test.dart` | — | covered inside guardian + request flows |
| Student Status Update | `student_status_test.dart`, `driver_scan_test.dart` | `rls_schedules_buses_students_test.sql` | `student_status_update_test.dart` |
| Push Notification | — | — | `notification_test.dart` (rows + RPC) — real FCM is manual |
| Real-Time Bus Tracking | — | — | `realtime_bus_tracking_test.dart` |
| Early Pickup / Late Drop-off | `pickup_request_test.dart` | `rls_pickup_requests_test.sql` | `pickup_request_lifecycle_test.dart` |

## Naming notes

* **"Push Notification"** in this app means `notifications` rows + the
  `broadcast_school_notification` RPC. There is no FCM client wired into
  the codebase, so Tier 3 verifies the in-app-notification surface only.
  Device-side push delivery remains a manual check.
* **"QR at the gate"** is currently simulated via `_simulateQr`; verification
  is by national ID / phone lookup. Tier 1 tests the lookup + release
  logic and the simulated-QR passthrough.
