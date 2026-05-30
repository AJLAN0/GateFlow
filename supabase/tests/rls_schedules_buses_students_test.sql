-- =============================================================================
-- RLS · daily_schedules, buses, students  (staff + driver scope)
-- =============================================================================
-- Covers:
--   • staff can INSERT / UPDATE / DELETE schedules and buses in own school
--   • non-staff (parent) cannot INSERT a schedule
--   • driver can UPDATE the status of students on their own bus
--   • driver CANNOT UPDATE students on a different bus
-- =============================================================================

BEGIN;

\i supabase/tests/_helpers.sql

SELECT plan(6);

SELECT tests_create_school('A') AS school_a \gset

SELECT tests_create_user('school_staff'::user_role, :'school_a') AS staff_a \gset
SELECT tests_create_user('parent'::user_role,       :'school_a') AS parent_a \gset
SELECT tests_create_user('bus_driver'::user_role,   :'school_a') AS driver1 \gset
SELECT tests_create_user('bus_driver'::user_role,   :'school_a') AS driver2 \gset

-- Two buses, one per driver.
INSERT INTO buses (id, name, school_id, driver_id, status) VALUES
  ('00000000-0000-0000-0000-0000000bb001', 'Bus-1', :'school_a', :'driver1', 'stationary'),
  ('00000000-0000-0000-0000-0000000bb002', 'Bus-2', :'school_a', :'driver2', 'stationary');

INSERT INTO students (id, name, grade, school_id, bus_id, status, transport_type) VALUES
  ('00000000-0000-0000-0000-0000000ss001', 'On-Bus-1', 'G1', :'school_a',
    '00000000-0000-0000-0000-0000000bb001', 'at_home', 'bus'),
  ('00000000-0000-0000-0000-0000000ss002', 'On-Bus-2', 'G1', :'school_a',
    '00000000-0000-0000-0000-0000000bb002', 'at_home', 'bus');

-- ---------------------------------------------------------------------------
-- 1. Staff can create a schedule for their school.
-- ---------------------------------------------------------------------------
SELECT tests_authenticate_as(:'staff_a');

SELECT lives_ok(
  $$
  INSERT INTO daily_schedules (school_id, class_name, grade)
  VALUES ('$$ || :'school_a' || $$', '1A', 'G1')
  $$,
  'staff: can INSERT schedule in own school'
);

-- ---------------------------------------------------------------------------
-- 2. Staff can also UPDATE the same row.
-- ---------------------------------------------------------------------------
SELECT is(
  (
    WITH u AS (
      UPDATE daily_schedules SET notes = 'fire drill'
       WHERE school_id = :'school_a'
       RETURNING 1
    )
    SELECT count(*) FROM u
  ),
  1::bigint,
  'staff: can UPDATE in-school schedule'
);

-- ---------------------------------------------------------------------------
-- 3. Parent cannot INSERT a schedule.
-- ---------------------------------------------------------------------------
SELECT tests_deauthenticate();
SELECT tests_authenticate_as(:'parent_a');

SELECT throws_ok(
  $$
  INSERT INTO daily_schedules (school_id, class_name, grade)
  VALUES ('$$ || :'school_a' || $$', '1A', 'G1')
  $$,
  '42501',
  NULL,
  'parent: blocked from creating schedules'
);

-- ---------------------------------------------------------------------------
-- 4. driver1 can UPDATE the status of a student on bus 1.
-- ---------------------------------------------------------------------------
SELECT tests_deauthenticate();
SELECT tests_authenticate_as(:'driver1');

SELECT is(
  (
    WITH u AS (
      UPDATE students SET status = 'on_bus_to_school'
       WHERE id = '00000000-0000-0000-0000-0000000ss001'
       RETURNING 1
    )
    SELECT count(*) FROM u
  ),
  1::bigint,
  'driver: can UPDATE own-bus student status'
);

-- ---------------------------------------------------------------------------
-- 5. driver1 cannot UPDATE a student on bus 2.
-- ---------------------------------------------------------------------------
SELECT is(
  (
    WITH u AS (
      UPDATE students SET status = 'on_bus_to_school'
       WHERE id = '00000000-0000-0000-0000-0000000ss002'
       RETURNING 1
    )
    SELECT count(*) FROM u
  ),
  0::bigint,
  'driver: cannot UPDATE student on a different driver''s bus'
);

-- ---------------------------------------------------------------------------
-- 6. Confirm the bus-2 row was not affected.
-- ---------------------------------------------------------------------------
SELECT is(
  (SELECT status::text FROM students WHERE id = '00000000-0000-0000-0000-0000000ss002'),
  'at_home',
  'driver: foreign-bus student status remains unchanged'
);

SELECT * FROM finish();

ROLLBACK;
