-- =============================================================================
-- GateFlow · Supabase Initial Schema
-- Covers: schools, profiles, students, buses, guardians, pickup_requests,
--         daily_schedules, notifications, operational_alerts,
--         driver_scan_logs, gate_verification_logs
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Extensions
-- ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
CREATE TYPE user_role            AS ENUM ('parent','guardian','bus_driver','school_staff');
CREATE TYPE student_status_enum  AS ENUM ('at_home','on_bus_to_school','at_school','on_bus_to_home','picked_up_by_car');
CREATE TYPE bus_status_enum      AS ENUM ('stationary','on_route_to_school','on_route_to_home');
CREATE TYPE request_status_enum  AS ENUM ('pending','approved','rejected');
CREATE TYPE transport_type_enum  AS ENUM ('bus','car');
CREATE TYPE guardian_status_enum AS ENUM ('pending','approved','rejected');
CREATE TYPE scan_action_enum     AS ENUM ('boarded','dropped_off');

-- ---------------------------------------------------------------------------
-- SCHOOLS
-- ---------------------------------------------------------------------------
CREATE TABLE schools (
  id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        TEXT        NOT NULL,
  address     TEXT,
  phone       TEXT,
  email       TEXT,
  logo_url    TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- PROFILES  (linked 1-to-1 with auth.users)
-- ---------------------------------------------------------------------------
CREATE TABLE profiles (
  id           UUID         PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name    TEXT         NOT NULL,
  phone        TEXT,
  role         user_role    NOT NULL DEFAULT 'parent',
  school_id    UUID         REFERENCES schools(id) ON DELETE SET NULL,
  national_id  TEXT,
  avatar_url   TEXT,
  is_active    BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- BUSES
-- ---------------------------------------------------------------------------
CREATE TABLE buses (
  id                 UUID              PRIMARY KEY DEFAULT uuid_generate_v4(),
  name               TEXT              NOT NULL,
  route_label        TEXT,
  plate_number       TEXT,
  driver_id          UUID              REFERENCES profiles(id) ON DELETE SET NULL,
  status             bus_status_enum   NOT NULL DEFAULT 'stationary',
  school_id          UUID              NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  last_update_label  TEXT,
  created_at         TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ       NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- STUDENTS
-- ---------------------------------------------------------------------------
CREATE TABLE students (
  id                 UUID                 PRIMARY KEY DEFAULT uuid_generate_v4(),
  name               TEXT                 NOT NULL,
  grade              TEXT                 NOT NULL,
  school_id          UUID                 NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  status             student_status_enum  NOT NULL DEFAULT 'at_home',
  transport_type     transport_type_enum  NOT NULL DEFAULT 'car',
  bus_id             UUID                 REFERENCES buses(id) ON DELETE SET NULL,
  last_update_label  TEXT,
  profile_photo_url  TEXT,
  created_at         TIMESTAMPTZ          NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ          NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- PARENT ↔ STUDENT  (many-to-many)
-- ---------------------------------------------------------------------------
CREATE TABLE parent_students (
  id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  parent_id   UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  student_id  UUID        NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (parent_id, student_id)
);

-- ---------------------------------------------------------------------------
-- GUARDIANS  (submitted by parent, approved by school)
-- ---------------------------------------------------------------------------
CREATE TABLE guardians (
  id                  UUID                 PRIMARY KEY DEFAULT uuid_generate_v4(),
  guardian_user_id    UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  parent_id           UUID                 NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  full_name           TEXT                 NOT NULL,
  phone               TEXT,
  email               TEXT,
  relationship        TEXT,
  national_id         TEXT,
  status              guardian_status_enum NOT NULL DEFAULT 'pending',
  authorized_by       UUID                 REFERENCES profiles(id),
  authorized_at       TIMESTAMPTZ,
  notes               TEXT,
  created_at          TIMESTAMPTZ          NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ          NOT NULL DEFAULT NOW()
);

-- Guardian ↔ Student authorization (many-to-many)
CREATE TABLE guardian_students (
  id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  guardian_id UUID        NOT NULL REFERENCES guardians(id) ON DELETE CASCADE,
  student_id  UUID        NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (guardian_id, student_id)
);

-- ---------------------------------------------------------------------------
-- PICKUP REQUESTS
-- ---------------------------------------------------------------------------
CREATE TABLE pickup_requests (
  id                     UUID                  PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id             UUID                  NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  requested_by           UUID                  NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type                   TEXT                  NOT NULL,
  status                 request_status_enum   NOT NULL DEFAULT 'pending',
  time_label             TEXT,
  pickup_person_summary  TEXT,
  date                   DATE                  NOT NULL DEFAULT CURRENT_DATE,
  notes                  TEXT,
  reviewed_by            UUID                  REFERENCES profiles(id),
  reviewed_at            TIMESTAMPTZ,
  released_at_gate       BOOLEAN               NOT NULL DEFAULT FALSE,
  released_at            TIMESTAMPTZ,
  created_at             TIMESTAMPTZ           NOT NULL DEFAULT NOW(),
  updated_at             TIMESTAMPTZ           NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- DAILY SCHEDULES
-- ---------------------------------------------------------------------------
CREATE TABLE daily_schedules (
  id               UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  school_id        UUID        NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  class_name       TEXT        NOT NULL,
  grade            TEXT,
  date             DATE        NOT NULL DEFAULT CURRENT_DATE,
  arrival_time     TIME,
  departure_time   TIME,
  notes            TEXT,
  created_by       UUID        REFERENCES profiles(id),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- NOTIFICATIONS
-- ---------------------------------------------------------------------------
CREATE TABLE notifications (
  id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title           TEXT        NOT NULL,
  body            TEXT        NOT NULL,
  type            TEXT        NOT NULL DEFAULT 'info',
  is_read         BOOLEAN     NOT NULL DEFAULT FALSE,
  reference_id    UUID,
  reference_type  TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- OPERATIONAL ALERTS  (staff bulletins)
-- ---------------------------------------------------------------------------
CREATE TABLE operational_alerts (
  id           UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  school_id    UUID        NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  title        TEXT        NOT NULL,
  body         TEXT        NOT NULL,
  severity     TEXT        NOT NULL DEFAULT 'info',
  is_resolved  BOOLEAN     NOT NULL DEFAULT FALSE,
  created_by   UUID        REFERENCES profiles(id),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- DRIVER SCAN LOGS
-- ---------------------------------------------------------------------------
CREATE TABLE driver_scan_logs (
  id          UUID              PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id   UUID              NOT NULL REFERENCES profiles(id),
  student_id  UUID              NOT NULL REFERENCES students(id),
  bus_id      UUID              REFERENCES buses(id),
  action      scan_action_enum  NOT NULL,
  notes       TEXT,
  scanned_at  TIMESTAMPTZ       NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- GATE VERIFICATION LOGS
-- ---------------------------------------------------------------------------
CREATE TABLE gate_verification_logs (
  id                   UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  verified_by          UUID        NOT NULL REFERENCES profiles(id),
  person_national_id   TEXT,
  person_phone         TEXT,
  person_name          TEXT,
  student_names        TEXT[]      DEFAULT '{}',
  verification_result  TEXT        NOT NULL DEFAULT 'approved',
  pickup_request_id    UUID        REFERENCES pickup_requests(id),
  notes                TEXT,
  verified_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- INDEXES
-- =============================================================================
CREATE INDEX idx_profiles_school          ON profiles(school_id);
CREATE INDEX idx_profiles_role            ON profiles(role);
CREATE INDEX idx_students_school          ON students(school_id);
CREATE INDEX idx_students_status          ON students(status);
CREATE INDEX idx_students_bus             ON students(bus_id);
CREATE INDEX idx_buses_school             ON buses(school_id);
CREATE INDEX idx_buses_driver             ON buses(driver_id);
CREATE INDEX idx_parent_students_parent   ON parent_students(parent_id);
CREATE INDEX idx_parent_students_student  ON parent_students(student_id);
CREATE INDEX idx_guardians_parent         ON guardians(parent_id);
CREATE INDEX idx_guardians_status         ON guardians(status);
CREATE INDEX idx_guardian_students_g      ON guardian_students(guardian_id);
CREATE INDEX idx_guardian_students_s      ON guardian_students(student_id);
CREATE INDEX idx_requests_student         ON pickup_requests(student_id);
CREATE INDEX idx_requests_by              ON pickup_requests(requested_by);
CREATE INDEX idx_requests_status          ON pickup_requests(status);
CREATE INDEX idx_requests_date            ON pickup_requests(date);
CREATE INDEX idx_notifications_user       ON notifications(user_id);
CREATE INDEX idx_notifications_read       ON notifications(is_read);
CREATE INDEX idx_schedules_school         ON daily_schedules(school_id);
CREATE INDEX idx_schedules_date           ON daily_schedules(date);
CREATE INDEX idx_scan_logs_driver         ON driver_scan_logs(driver_id);
CREATE INDEX idx_scan_logs_student        ON driver_scan_logs(student_id);
CREATE INDEX idx_alerts_school            ON operational_alerts(school_id);
CREATE INDEX idx_gate_logs_by             ON gate_verification_logs(verified_by);

-- =============================================================================
-- TRIGGERS: auto-update updated_at
-- =============================================================================
CREATE OR REPLACE FUNCTION fn_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER tg_profiles_upd         BEFORE UPDATE ON profiles         FOR EACH ROW EXECUTE FUNCTION fn_updated_at();
CREATE TRIGGER tg_buses_upd            BEFORE UPDATE ON buses             FOR EACH ROW EXECUTE FUNCTION fn_updated_at();
CREATE TRIGGER tg_students_upd         BEFORE UPDATE ON students          FOR EACH ROW EXECUTE FUNCTION fn_updated_at();
CREATE TRIGGER tg_guardians_upd        BEFORE UPDATE ON guardians         FOR EACH ROW EXECUTE FUNCTION fn_updated_at();
CREATE TRIGGER tg_requests_upd         BEFORE UPDATE ON pickup_requests   FOR EACH ROW EXECUTE FUNCTION fn_updated_at();
CREATE TRIGGER tg_schedules_upd        BEFORE UPDATE ON daily_schedules   FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

-- =============================================================================
-- AUTO-CREATE PROFILE ON SIGNUP.
-- =============================================================================
CREATE OR REPLACE FUNCTION fn_handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'parent')
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION fn_handle_new_user();

-- =============================================================================
-- HELPER: broadcast notification to all school users of given roles
-- =============================================================================
CREATE OR REPLACE FUNCTION broadcast_school_notification(
  p_school_id  UUID,
  p_title      TEXT,
  p_body       TEXT,
  p_type       TEXT    DEFAULT 'info',
  p_roles      TEXT[]  DEFAULT ARRAY['parent','guardian','bus_driver','school_staff']
)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO notifications (user_id, title, body, type)
  SELECT id, p_title, p_body, p_type
  FROM   profiles
  WHERE  school_id = p_school_id
    AND  role::TEXT = ANY(p_roles)
    AND  is_active  = TRUE;
END;
$$;

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================
ALTER TABLE schools                ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles               ENABLE ROW LEVEL SECURITY;
ALTER TABLE buses                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE students               ENABLE ROW LEVEL SECURITY;
ALTER TABLE parent_students        ENABLE ROW LEVEL SECURITY;
ALTER TABLE guardians              ENABLE ROW LEVEL SECURITY;
ALTER TABLE guardian_students      ENABLE ROW LEVEL SECURITY;
ALTER TABLE pickup_requests        ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_schedules        ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications          ENABLE ROW LEVEL SECURITY;
ALTER TABLE operational_alerts     ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_scan_logs       ENABLE ROW LEVEL SECURITY;
ALTER TABLE gate_verification_logs ENABLE ROW LEVEL SECURITY;

-- Helper: authenticated user's school_id
-- SECURITY DEFINER prevents infinite RLS recursion (this fn queries profiles,
-- which has policies that call this fn).
CREATE OR REPLACE FUNCTION my_school_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT school_id FROM profiles WHERE id = auth.uid();
$$;

-- Helper: authenticated user's role
CREATE OR REPLACE FUNCTION my_role()
RETURNS user_role
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$;

-- --- schools ---
CREATE POLICY "school members can view own school" ON schools
  FOR SELECT USING (id = my_school_id());

-- --- profiles ---
CREATE POLICY "own profile: select" ON profiles
  FOR SELECT USING (id = auth.uid() OR school_id = my_school_id());

CREATE POLICY "own profile: update" ON profiles
  FOR UPDATE USING (id = auth.uid());

CREATE POLICY "staff: insert profiles" ON profiles
  FOR INSERT WITH CHECK (my_role() = 'school_staff');

-- --- buses ---
CREATE POLICY "school members: view buses" ON buses
  FOR SELECT USING (school_id = my_school_id());

CREATE POLICY "staff: manage buses" ON buses
  FOR ALL USING (school_id = my_school_id() AND my_role() = 'school_staff');

-- --- students ---
CREATE POLICY "parent: view own children" ON students
  FOR SELECT USING (
    id IN (SELECT student_id FROM parent_students WHERE parent_id = auth.uid())
    OR school_id = my_school_id()
  );

CREATE POLICY "staff: manage students" ON students
  FOR ALL USING (school_id = my_school_id() AND my_role() = 'school_staff');

CREATE POLICY "driver: update student status" ON students
  FOR UPDATE USING (
    bus_id IN (SELECT id FROM buses WHERE driver_id = auth.uid())
  );

-- --- parent_students ---
CREATE POLICY "parent: view own links" ON parent_students
  FOR SELECT USING (parent_id = auth.uid());

CREATE POLICY "staff: manage parent-student links" ON parent_students
  FOR ALL USING (my_role() = 'school_staff');

-- --- guardians ---
CREATE POLICY "parent: manage own guardians" ON guardians
  FOR ALL USING (parent_id = auth.uid());

CREATE POLICY "staff: manage all guardians in school" ON guardians
  FOR ALL USING (
    parent_id IN (
      SELECT id FROM profiles WHERE school_id = my_school_id()
    )
    AND my_role() = 'school_staff'
  );

-- --- guardian_students ---
CREATE POLICY "guardian: view own assignments" ON guardian_students
  FOR SELECT USING (
    guardian_id IN (
      SELECT id FROM guardians WHERE guardian_user_id = auth.uid()
    )
    OR my_role() IN ('school_staff','parent')
  );

CREATE POLICY "staff/parent: manage guardian_students" ON guardian_students
  FOR ALL USING (my_role() IN ('school_staff','parent'));

-- --- pickup_requests ---
CREATE POLICY "parent: own requests" ON pickup_requests
  FOR SELECT USING (requested_by = auth.uid());

CREATE POLICY "parent: create request" ON pickup_requests
  FOR INSERT WITH CHECK (requested_by = auth.uid());

CREATE POLICY "staff: view school requests" ON pickup_requests
  FOR SELECT USING (
    my_role() = 'school_staff'
    AND student_id IN (SELECT id FROM students WHERE school_id = my_school_id())
  );

CREATE POLICY "staff: update requests" ON pickup_requests
  FOR UPDATE USING (
    student_id IN (SELECT id FROM students WHERE school_id = my_school_id())
    AND my_role() = 'school_staff'
  );

-- --- daily_schedules ---
CREATE POLICY "school members: view schedules" ON daily_schedules
  FOR SELECT USING (school_id = my_school_id());

CREATE POLICY "staff: manage schedules" ON daily_schedules
  FOR ALL USING (school_id = my_school_id() AND my_role() = 'school_staff');

-- --- notifications ---
CREATE POLICY "own notifications" ON notifications
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "staff: send school notifications" ON notifications
  FOR INSERT WITH CHECK (
    my_role() = 'school_staff'
    AND user_id IN (SELECT id FROM profiles WHERE school_id = my_school_id())
  );

-- --- operational_alerts ---
CREATE POLICY "staff/driver: view alerts" ON operational_alerts
  FOR SELECT USING (school_id = my_school_id());

CREATE POLICY "staff: manage alerts" ON operational_alerts
  FOR ALL USING (school_id = my_school_id() AND my_role() = 'school_staff');

-- --- driver_scan_logs ---
CREATE POLICY "driver: insert scan" ON driver_scan_logs
  FOR INSERT WITH CHECK (driver_id = auth.uid());

CREATE POLICY "driver/staff: view scans" ON driver_scan_logs
  FOR SELECT USING (
    driver_id = auth.uid()
    OR bus_id IN (SELECT id FROM buses WHERE school_id = my_school_id())
  );

-- --- gate_verification_logs ---
CREATE POLICY "staff: manage gate logs" ON gate_verification_logs
  FOR ALL USING (verified_by = auth.uid());
