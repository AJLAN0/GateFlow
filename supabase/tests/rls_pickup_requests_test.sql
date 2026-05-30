-- =============================================================================
-- RLS · pickup_requests
-- =============================================================================
-- Covers:
--   • parent sees only their own requests
--   • staff sees school-wide requests
--   • parent can DELETE only their own pending requests  (20240103 policy)
--   • parent cannot DELETE an approved request
--   • staff can DELETE any school request                (20240103 policy)
-- =============================================================================

BEGIN;

\i supabase/tests/_helpers.sql

SELECT plan(7);

SELECT tests_create_school('A') AS school_a \gset
SELECT tests_create_school('B') AS school_b \gset

SELECT tests_create_user('school_staff'::user_role, :'school_a') AS staff_a \gset
SELECT tests_create_user('parent'::user_role,       :'school_a') AS parent_a \gset
SELECT tests_create_user('parent'::user_role,       :'school_a') AS parent_a2 \gset
SELECT tests_create_user('parent'::user_role,       :'school_b') AS parent_b \gset

-- A student in each school + parent links.
INSERT INTO students (id, name, grade, school_id, status)
VALUES
  ('00000000-0000-0000-0000-000000000a01', 'Stu A', 'G1', :'school_a', 'at_home'),
  ('00000000-0000-0000-0000-000000000b01', 'Stu B', 'G1', :'school_b', 'at_home');

INSERT INTO parent_students (parent_id, student_id) VALUES
  (:'parent_a', '00000000-0000-0000-0000-000000000a01'),
  (:'parent_b', '00000000-0000-0000-0000-000000000b01');

-- Seed a pending request from each parent.
INSERT INTO pickup_requests (id, student_id, requested_by, type, status)
VALUES
  ('00000000-0000-0000-0000-00000000aaa1', '00000000-0000-0000-0000-000000000a01', :'parent_a',  'Early Pickup', 'pending'),
  ('00000000-0000-0000-0000-00000000aaa2', '00000000-0000-0000-0000-000000000a01', :'parent_a',  'Late Drop-off','approved'),
  ('00000000-0000-0000-0000-00000000bbb1', '00000000-0000-0000-0000-000000000b01', :'parent_b',  'Early Pickup', 'pending');

-- ---------------------------------------------------------------------------
-- 1. parent_a only sees their own requests
-- ---------------------------------------------------------------------------
SELECT tests_authenticate_as(:'parent_a');

SELECT is(
  (SELECT count(*)::int FROM pickup_requests),
  2,
  'parent: sees only their own requests'
);

SELECT is(
  (SELECT count(*)::int FROM pickup_requests WHERE requested_by <> :'parent_a'),
  0,
  'parent: never sees foreign requests'
);

-- ---------------------------------------------------------------------------
-- 2. parent_a CAN delete a pending request, CANNOT delete an approved one.
-- ---------------------------------------------------------------------------
SELECT is(
  (
    WITH d AS (
      DELETE FROM pickup_requests
       WHERE id = '00000000-0000-0000-0000-00000000aaa1'
       RETURNING 1
    )
    SELECT count(*) FROM d
  ),
  1::bigint,
  'parent: can delete own pending request'
);

SELECT is(
  (
    WITH d AS (
      DELETE FROM pickup_requests
       WHERE id = '00000000-0000-0000-0000-00000000aaa2'
       RETURNING 1
    )
    SELECT count(*) FROM d
  ),
  0::bigint,
  'parent: cannot delete own approved request'
);

-- And cannot touch another parent's pending request.
SELECT is(
  (
    WITH d AS (
      DELETE FROM pickup_requests
       WHERE id = '00000000-0000-0000-0000-00000000bbb1'
       RETURNING 1
    )
    SELECT count(*) FROM d
  ),
  0::bigint,
  'parent: cannot delete another parent''s request'
);

-- ---------------------------------------------------------------------------
-- 3. staff_a sees only school_a requests.
-- ---------------------------------------------------------------------------
SELECT tests_deauthenticate();
SELECT tests_authenticate_as(:'staff_a');

SELECT is(
  (SELECT count(*)::int FROM pickup_requests),
  2,
  'staff: sees all requests for in-school students only'
);

-- ---------------------------------------------------------------------------
-- 4. staff_a deletes the remaining approved request.
-- ---------------------------------------------------------------------------
SELECT is(
  (
    WITH d AS (
      DELETE FROM pickup_requests
       WHERE id = '00000000-0000-0000-0000-00000000aaa2'
       RETURNING 1
    )
    SELECT count(*) FROM d
  ),
  1::bigint,
  'staff: can delete a school request regardless of status'
);

SELECT * FROM finish();

ROLLBACK;
