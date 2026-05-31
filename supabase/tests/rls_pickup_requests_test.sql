-- RBAC: pickup_requests SELECT / INSERT / DELETE policies
BEGIN;
\ir _helpers.sql

SELECT plan(6);

SELECT tests.clear_auth();

SELECT tests.create_school('Req School') AS school_id \gset
SELECT tests.create_user('school_staff', :'school_id'::uuid, 'staff-req@test.local') AS staff_id \gset
SELECT tests.create_user('parent',       :'school_id'::uuid, 'parent-req@test.local') AS parent_id \gset
SELECT tests.create_user('parent',       :'school_id'::uuid, 'other-parent@test.local') AS other_parent \gset

-- Student linked to school
INSERT INTO students (id, name, grade, school_id, status, transport_type)
VALUES (
  gen_random_uuid(),
  'Test Student',
  'Grade 1',
  :'school_id'::uuid,
  'at_school',
  'car'
) RETURNING id AS student_id \gset

INSERT INTO parent_students (parent_id, student_id)
VALUES (:'parent_id'::uuid, :'student_id'::uuid);

-- Parent creates pending request
SELECT tests.authenticate_as(:'parent_id'::uuid);
INSERT INTO pickup_requests (student_id, requested_by, type, status, date)
VALUES (
  :'student_id'::uuid,
  :'parent_id'::uuid,
  'Early Pickup',
  'pending',
  CURRENT_DATE
) RETURNING id AS req_id \gset

SELECT ok(
  EXISTS (SELECT 1 FROM pickup_requests WHERE id = :'req_id'::uuid),
  'parent can insert own pending request'
);

-- Other parent cannot see the request
SELECT tests.authenticate_as(:'other_parent'::uuid);
SELECT ok(
  NOT EXISTS (SELECT 1 FROM pickup_requests WHERE id = :'req_id'::uuid),
  'other parent cannot SELECT foreign request'
);

-- Staff can see school request
SELECT tests.authenticate_as(:'staff_id'::uuid);
SELECT ok(
  EXISTS (SELECT 1 FROM pickup_requests WHERE id = :'req_id'::uuid),
  'staff can SELECT school request'
);

-- Parent can delete own pending request
SELECT tests.authenticate_as(:'parent_id'::uuid);
DELETE FROM pickup_requests WHERE id = :'req_id'::uuid;
SELECT ok(
  NOT EXISTS (SELECT 1 FROM pickup_requests WHERE id = :'req_id'::uuid),
  'parent can DELETE own pending request'
);

-- Re-create for staff delete test
INSERT INTO pickup_requests (id, student_id, requested_by, type, status, date)
VALUES (
  gen_random_uuid(),
  :'student_id'::uuid,
  :'parent_id'::uuid,
  'Late Drop-off',
  'pending',
  CURRENT_DATE
) RETURNING id AS req2_id \gset

SELECT tests.authenticate_as(:'staff_id'::uuid);
DELETE FROM pickup_requests WHERE id = :'req2_id'::uuid;
SELECT ok(
  NOT EXISTS (SELECT 1 FROM pickup_requests WHERE id = :'req2_id'::uuid),
  'staff can DELETE school pending request'
);

-- Re-create approved request as superuser (staff cannot INSERT pickup_requests)
SELECT tests.clear_auth();
INSERT INTO pickup_requests (id, student_id, requested_by, type, status, date)
VALUES (
  gen_random_uuid(),
  :'student_id'::uuid,
  :'parent_id'::uuid,
  'Early Pickup',
  'approved',
  CURRENT_DATE
) RETURNING id AS req3_id \gset

SELECT tests.authenticate_as(:'parent_id'::uuid);
DELETE FROM pickup_requests WHERE id = :'req3_id'::uuid;
SELECT ok(
  EXISTS (SELECT 1 FROM pickup_requests WHERE id = :'req3_id'::uuid),
  'parent cannot DELETE approved request'
);

SELECT * FROM finish();
ROLLBACK;
