-- Guardian authorization RLS
BEGIN;
\ir _helpers.sql

SELECT plan(5);

SELECT tests.clear_auth();

SELECT tests.create_school('Guardian School') AS school_id \gset
SELECT tests.create_user('parent',       :'school_id'::uuid, 'g-parent@test.local') AS parent_id \gset
SELECT tests.create_user('school_staff', :'school_id'::uuid, 'g-staff@test.local') AS staff_id \gset
SELECT tests.create_user('parent',       :'school_id'::uuid, 'g-outsider@test.local') AS outsider \gset

INSERT INTO students (id, name, grade, school_id, status, transport_type)
VALUES (gen_random_uuid(), 'Guardian Child', 'Grade 2', :'school_id'::uuid, 'at_school', 'car')
RETURNING id AS student_id \gset

INSERT INTO parent_students (parent_id, student_id)
VALUES (:'parent_id'::uuid, :'student_id'::uuid);

-- Parent submits guardian
SELECT tests.authenticate_as(:'parent_id'::uuid);
INSERT INTO guardians (parent_id, full_name, relationship, status, national_id)
VALUES (
  :'parent_id'::uuid,
  'Uncle Test',
  'Uncle',
  'pending',
  '1111222233'
) RETURNING id AS guardian_id \gset

SELECT ok(
  EXISTS (SELECT 1 FROM guardians WHERE id = :'guardian_id'::uuid AND status = 'pending'),
  'parent can INSERT guardian invite'
);

-- Outsider parent cannot see guardian row
SELECT tests.authenticate_as(:'outsider'::uuid);
SELECT ok(
  NOT EXISTS (SELECT 1 FROM guardians WHERE id = :'guardian_id'::uuid),
  'outsider parent cannot SELECT foreign guardian'
);

-- Staff can see and approve
SELECT tests.authenticate_as(:'staff_id'::uuid);
SELECT ok(
  EXISTS (SELECT 1 FROM guardians WHERE id = :'guardian_id'::uuid),
  'staff can SELECT school guardian'
);

UPDATE guardians
SET status = 'approved', authorized_by = :'staff_id'::uuid, authorized_at = now()
WHERE id = :'guardian_id'::uuid;

SELECT ok(
  (SELECT status::text FROM guardians WHERE id = :'guardian_id'::uuid) = 'approved',
  'staff can UPDATE guardian to approved'
);

-- Parent can link guardian to student
SELECT tests.authenticate_as(:'parent_id'::uuid);
INSERT INTO guardian_students (guardian_id, student_id)
VALUES (:'guardian_id'::uuid, :'student_id'::uuid);

SELECT ok(
  EXISTS (
    SELECT 1 FROM guardian_students
    WHERE guardian_id = :'guardian_id'::uuid AND student_id = :'student_id'::uuid
  ),
  'parent can link guardian to student'
);

SELECT * FROM finish();
ROLLBACK;
