# GateFlow · Database Entity Relationship Diagram

## ERD (Mermaid)

```mermaid
erDiagram

  %% ─────────────────────────────────────────────
  %% CORE ENTITIES
  %% ─────────────────────────────────────────────

  schools {
    uuid   id          PK
    text   name
    text   address
    text   phone
    text   email
    text   logo_url
    tstz   created_at
    tstz   updated_at
  }

  profiles {
    uuid        id          PK  "FK → auth.users"
    text        full_name
    text        phone
    user_role   role            "parent | guardian | bus_driver | school_staff"
    uuid        school_id   FK
    text        national_id
    text        avatar_url
    bool        is_active
    tstz        created_at
    tstz        updated_at
  }

  buses {
    uuid             id           PK
    text             name
    text             route_label
    text             plate_number
    uuid             driver_id    FK
    bus_status_enum  status           "stationary | on_route_to_school | on_route_to_home"
    uuid             school_id    FK
    text             last_update_label
    tstz             created_at
    tstz             updated_at
  }

  students {
    uuid                 id          PK
    text                 name
    text                 grade
    uuid                 school_id   FK
    student_status_enum  status          "at_home | on_bus_to_school | at_school | on_bus_to_home | picked_up_by_car"
    transport_type_enum  transport_type  "bus | car"
    uuid                 bus_id      FK  "nullable"
    text                 last_update_label
    text                 profile_photo_url
    tstz                 created_at
    tstz                 updated_at
  }

  %% ─────────────────────────────────────────────
  %% LINK TABLES
  %% ─────────────────────────────────────────────

  parent_students {
    uuid  id          PK
    uuid  parent_id   FK
    uuid  student_id  FK
    tstz  created_at
  }

  guardians {
    uuid                  id                PK
    uuid                  guardian_user_id  FK  "nullable – if guardian has an account"
    uuid                  parent_id         FK
    text                  full_name
    text                  phone
    text                  email
    text                  relationship
    text                  national_id
    guardian_status_enum  status                "pending | approved | rejected"
    uuid                  authorized_by     FK  "nullable – admin who approved"
    tstz                  authorized_at
    text                  notes
    tstz                  created_at
    tstz                  updated_at
  }

  guardian_students {
    uuid  id          PK
    uuid  guardian_id FK
    uuid  student_id  FK
    tstz  created_at
  }

  %% ─────────────────────────────────────────────
  %% OPERATIONAL ENTITIES
  %% ─────────────────────────────────────────────

  pickup_requests {
    uuid                  id                    PK
    uuid                  student_id            FK
    uuid                  requested_by          FK
    text                  type                      "Early Pickup | Late Drop-off | Car Pickup"
    request_status_enum   status                    "pending | approved | rejected"
    text                  time_label
    text                  pickup_person_summary
    date                  date
    text                  notes
    uuid                  reviewed_by           FK  "nullable"
    tstz                  reviewed_at
    bool                  released_at_gate
    tstz                  released_at
    tstz                  created_at
    tstz                  updated_at
  }

  daily_schedules {
    uuid  id              PK
    uuid  school_id       FK
    text  class_name
    text  grade
    date  date
    time  arrival_time
    time  departure_time
    text  notes
    uuid  created_by      FK
    tstz  created_at
    tstz  updated_at
  }

  notifications {
    uuid  id              PK
    uuid  user_id         FK
    text  title
    text  body
    text  type                "info | success | warning | alert"
    bool  is_read
    uuid  reference_id        "nullable – linked object (request, student…)"
    text  reference_type
    tstz  created_at
  }

  operational_alerts {
    uuid  id          PK
    uuid  school_id   FK
    text  title
    text  body
    text  severity        "info | warning | critical"
    bool  is_resolved
    uuid  created_by  FK  "nullable"
    tstz  created_at
  }

  driver_scan_logs {
    uuid             id          PK
    uuid             driver_id   FK
    uuid             student_id  FK
    uuid             bus_id      FK  "nullable"
    scan_action_enum action          "boarded | dropped_off"
    text             notes
    tstz             scanned_at
  }

  gate_verification_logs {
    uuid  id                   PK
    uuid  verified_by          FK
    text  person_national_id
    text  person_phone
    text  person_name
    text  student_names[]
    text  verification_result      "approved | rejected"
    uuid  pickup_request_id   FK  "nullable"
    text  notes
    tstz  verified_at
  }

  %% ─────────────────────────────────────────────
  %% RELATIONSHIPS
  %% ─────────────────────────────────────────────

  schools            ||--o{ profiles             : "hosts"
  schools            ||--o{ buses                : "owns"
  schools            ||--o{ students             : "enrolls"
  schools            ||--o{ daily_schedules      : "schedules"
  schools            ||--o{ operational_alerts   : "broadcasts"

  profiles           ||--o{ parent_students      : "parent links"
  profiles           ||--o{ guardians            : "submits (parent)"
  profiles           ||--o{ guardians            : "authorized_by (admin)"
  profiles           ||--o{ pickup_requests      : "requests (parent)"
  profiles           ||--o{ pickup_requests      : "reviews (admin)"
  profiles           ||--o{ notifications        : "receives"
  profiles           ||--o{ driver_scan_logs     : "scans (driver)"
  profiles           ||--o{ gate_verification_logs : "verifies (staff)"
  profiles           ||--o| buses                : "drives"

  students           ||--o{ parent_students      : "linked to"
  students           ||--o{ guardian_students    : "authorized for"
  students           ||--o{ pickup_requests      : "subject of"
  students           ||--o{ driver_scan_logs     : "scanned"
  buses              ||--o{ students             : "carries"
  buses              ||--o{ driver_scan_logs     : "scan on"

  guardians          ||--o{ guardian_students    : "authorized for"
  pickup_requests    ||--o| gate_verification_logs : "released via"
```

---

## Table Descriptions

| Table | Role | Key Relationships |
|---|---|---|
| `schools` | Root tenant — every other record belongs to a school | All entities FK here |
| `profiles` | All users (parent / guardian / driver / staff). Auto-created by DB trigger on auth signup | FK to `schools`, drives `parent_students`, `guardians`, `buses` |
| `buses` | Fleet record with live status | FK to `profiles` (driver), `schools` |
| `students` | Student roster with real-time transport status | FK to `schools`, `buses` |
| `parent_students` | Many-to-many: a parent can have multiple children; a child can have multiple parents | Links `profiles` ↔ `students` |
| `guardians` | Guardian invite submitted by parent, approved by school admin | FK to `profiles` (parent, guardian_user, authorized_by) |
| `guardian_students` | Which students each approved guardian may pick up | Links `guardians` ↔ `students` |
| `pickup_requests` | Early-pickup / late-dropoff / car-pickup requests | FK to `students`, `profiles` (requester, reviewer) |
| `daily_schedules` | Per-class daily schedule entries created by admin | FK to `schools`, `profiles` (creator) |
| `notifications` | Per-user notification inbox; broadcast via `broadcast_school_notification()` | FK to `profiles` |
| `operational_alerts` | Staff bulletins visible to all school staff / drivers | FK to `schools`, `profiles` (creator) |
| `driver_scan_logs` | Immutable audit trail — every QR/manual scan recorded | FK to `profiles`, `students`, `buses` |
| `gate_verification_logs` | Every gate check (national ID or phone lookup) recorded | FK to `profiles`, `pickup_requests` |

---

## Enum Types

| Enum | Values |
|---|---|
| `user_role` | `parent` · `guardian` · `bus_driver` · `school_staff` |
| `student_status_enum` | `at_home` · `on_bus_to_school` · `at_school` · `on_bus_to_home` · `picked_up_by_car` |
| `bus_status_enum` | `stationary` · `on_route_to_school` · `on_route_to_home` |
| `request_status_enum` | `pending` · `approved` · `rejected` |
| `transport_type_enum` | `bus` · `car` |
| `guardian_status_enum` | `pending` · `approved` · `rejected` |
| `scan_action_enum` | `boarded` · `dropped_off` |

---

## Key DB Functions

| Function | Purpose |
|---|---|
| `fn_handle_new_user()` | Trigger on `auth.users` INSERT — auto-creates the `profiles` row from user metadata |
| `fn_updated_at()` | Trigger on every mutable table — keeps `updated_at` current |
| `broadcast_school_notification(school_id, title, body, type, roles[])` | Inserts a notification row for every active profile in the school matching the given roles |
| `my_school_id()` | Stable helper used by RLS policies — returns the calling user's `school_id` |
| `my_role()` | Stable helper used by RLS policies — returns the calling user's role enum |

---

## Row-Level Security Summary

| Table | Who can SELECT | Who can INSERT/UPDATE/DELETE |
|---|---|---|
| `profiles` | Own row + same school | Own row (update); staff (insert) |
| `students` | Own children (parent) + same school (staff/driver) | School staff (all); driver (status update only) |
| `buses` | Same school | School staff |
| `parent_students` | Own links | School staff |
| `guardians` | Own (parent) + school (staff) | Parent (own); school staff (approve/reject) |
| `guardian_students` | Guardian (own) / staff / parent | Staff + parent |
| `pickup_requests` | Own (parent) + school students (staff) | Parent (insert own); staff (update status) |
| `daily_schedules` | Same school | School staff |
| `notifications` | Own | Own |
| `operational_alerts` | Same school | School staff |
| `driver_scan_logs` | Own driver / same school buses | Driver (insert own) |
| `gate_verification_logs` | Own (verified_by) | Staff |
