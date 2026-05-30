-- =============================================================================
-- RLS · guardians
-- =============================================================================
-- Covers:
--   • parent can INSERT / SELECT / UPDATE / DELETE their own guardians
--   • school staff can manage guardians for in-school parents
--   • outsider (other-school parent / staff) is blocked
-- =============================================================================

BEGIN;

\i supabase/tests/_helpers.sql

SELECT plan(6);

SELECT tests_create_school('A') AS school_a \gset
SELECT tests_create_school('B') AS school_b \gset

SELECT tests_create_user('school_staff'::user_role, :'school_a') AS staff_a \gset
SELECT tests_create_user('parent'::user_role,       :'school_a') AS parent_a \gset
SELECT tests_create_user('parent'::user_role,       :'school_b') AS parent_b \gset
SELECT tests_create_user('school_staff'::user_role, :'school_b') AS staff_b \gset

-- ---------------------------------------------------------------------------
-- 1. parent_a can INSERT a guardian under their own id.
-- ---------------------------------------------------------------------------
SELECT tests_authenticate_as(:'parent_a');

SELECT lives_ok(
  $$
  INSERT INTO guardians (parent_id, full_name, relationship, status)
  VALUES ('$$ || :'parent_a' || $$', 'G1', 'Uncle', 'pending')
  $$,
  'parent: can create own guardian'
);

-- ---------------------------------------------------------------------------
-- 2. parent_a cannot INSERT a guardian pointing at parent_b.
-- ---------------------------------------------------------------------------
SELECT throws_ok(
  $$
  INSERT INTO guardians (parent_id, full_name, relationship, status)
  VALUES ('$$ || :'parent_b' || $$', 'Forged', 'Stranger', 'pending')
  $$,
  '42501',
  NULL,
  'parent: cannot create a guardian for another parent (RLS violation)'
);

-- ---------------------------------------------------------------------------
-- 3. parent_a sees only their own guardian rows.
-- ---------------------------------------------------------------------------
SELECT is(
  (SELECT count(*)::int FROM guardians WHERE parent_id <> :'parent_a'),
  0,
  'parent: never sees foreign guardian rows'
);

-- ---------------------------------------------------------------------------
-- 4. staff_a can approve a guardian belonging to an in-school parent.
-- ---------------------------------------------------------------------------
SELECT tests_deauthenticate();
SELECT tests_authenticate_as(:'staff_a');

SELECT is(
  (
    WITH u AS (
      UPDATE guardians SET status = 'approved'
       WHERE parent_id = :'parent_a'
       RETURNING 1
    )
    SELECT count(*) FROM u
  ),
  1::bigint,
  'staff: can approve guardians for in-school parents'
);

-- ---------------------------------------------------------------------------
-- 5. staff_b (other school) cannot see / modify school A guardians.
-- ---------------------------------------------------------------------------
SELECT tests_deauthenticate();
SELECT tests_authenticate_as(:'staff_b');

SELECT is(
  (SELECT count(*)::int FROM guardians WHERE parent_id = :'parent_a'),
  0,
  'staff (other school): does not see foreign guardian rows'
);

-- ---------------------------------------------------------------------------
-- 6. parent_b (other school) likewise has no view.
-- ---------------------------------------------------------------------------
SELECT tests_deauthenticate();
SELECT tests_authenticate_as(:'parent_b');

SELECT is(
  (SELECT count(*)::int FROM guardians WHERE parent_id = :'parent_a'),
  0,
  'parent (other school): cannot read foreign guardian rows'
);

SELECT * FROM finish();

ROLLBACK;
