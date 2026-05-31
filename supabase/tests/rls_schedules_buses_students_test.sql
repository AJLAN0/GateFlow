-- Schedules, buses, students RLS (staff manage, driver update own bus/students)
BEGIN;
\ir _helpers.sql

SELECT plan(6);

SELECT tests.clear_auth();

SELECT tests.create_school('Ops School') AS school_id \gset
SELECT tests.create_user('school_staff', :'school_id'::uuid, 'ops-staff@test.local') AS staff_id \gset
SELECT tests.create_user('bus_driver',   :'school_id'::uuid, 'ops-driver@test.local') AS driver_id \gset
SELECT tests.create_user('parent',       :'school_id'::uuid, 'ops-parent@test.local') AS parent_id \gset

-- Staff creates schedule
SELECT tests.authenticate_as(:'staff_id'::uuid);
INSERT INTO daily_schedules (school_id, class_name, grade, date, created_by)
VALUES (
  :'school_id'::uuid,
  'Class 1A',
  'Grade 1',
  CURRENT_DATE,
  :'staff_id'::uuid
) RETURNING id AS schedule_id \gset

SELECT ok(
  EXISTS (SELECT 1 FROM daily_schedules WHERE id = :'schedule_id'::uuid),
  'staff can INSERT schedule'
);

-- Parent can view schedule (school member)
SELECT tests.authenticate_as(:'parent_id'::uuid);
SELECT ok(
  EXISTS (SELECT 1 FROM daily_schedules WHERE id = :'schedule_id'::uuid),
  'parent can SELECT school schedule'
);

-- Parent cannot insert schedule (RLS raises insufficient_privilege)
SELECT throws_ok(
  format(
    $sql$INSERT INTO daily_schedules (school_id, class_name, grade, date)
      VALUES (%L::uuid, 'Blocked', 'Grade 9', CURRENT_DATE)$sql$,
    :'school_id'
  ),
  '42501',
  'parent cannot INSERT schedule'
);

-- Staff creates bus assigned to driver
SELECT tests.authenticate_as(:'staff_id'::uuid);
INSERT INTO buses (name, school_id, driver_id, status, route_label)
VALUES ('Test Bus', :'school_id'::uuid, :'driver_id'::uuid, 'stationary', 'Route T')
RETURNING id AS bus_id \gset

INSERT INTO students (id, name, grade, school_id, status, transport_type, bus_id)
VALUES (
  gen_random_uuid(),
  'Bus Student',
  'Grade 3',
  :'school_id'::uuid,
  'at_school',
  'bus',
  :'bus_id'::uuid
) RETURNING id AS student_id \gset

-- Driver updates own bus status
SELECT tests.authenticate_as(:'driver_id'::uuid);
UPDATE buses SET status = 'on_route_to_home' WHERE id = :'bus_id'::uuid;
SELECT ok(
  (SELECT status::text FROM buses WHERE id = :'bus_id'::uuid) = 'on_route_to_home',
  'driver can UPDATE own bus status'
);

-- Driver updates student on own bus
UPDATE students SET status = 'on_bus_to_home' WHERE id = :'student_id'::uuid;
SELECT ok(
  (SELECT status::text FROM students WHERE id = :'student_id'::uuid) = 'on_bus_to_home',
  'driver can UPDATE student on assigned bus'
);

-- Driver cannot update unassigned bus (create second bus without driver)
SELECT tests.authenticate_as(:'staff_id'::uuid);
INSERT INTO buses (name, school_id, status)
VALUES ('Other Bus', :'school_id'::uuid, 'stationary')
RETURNING id AS other_bus_id \gset

SELECT tests.authenticate_as(:'driver_id'::uuid);
UPDATE buses SET status = 'on_route_to_school' WHERE id = :'other_bus_id'::uuid;
SELECT ok(
  (SELECT status::text FROM buses WHERE id = :'other_bus_id'::uuid) = 'stationary',
  'driver cannot UPDATE bus they are not assigned to'
);

SELECT * FROM finish();
ROLLBACK;
