-- =============================================================================
-- RLS · profiles
-- =============================================================================
-- Covers the RBAC core for the profiles table:
--   • staff can UPDATE in-school profiles  (20240104 policy)
--   • staff CANNOT cross school boundaries
--   • non-staff CANNOT update someone else's profile
-- =============================================================================

BEGIN;

\i supabase/tests/_helpers.sql

SELECT plan(5);

-- Two distinct schools so the cross-school case is meaningful.
SELECT tests_create_school('A') AS school_a \gset
SELECT tests_create_school('B') AS school_b \gset

-- Build a cast of characters.
SELECT tests_create_user('school_staff'::user_role, :'school_a') AS staff_a \gset
SELECT tests_create_user('parent'::user_role,       :'school_a') AS parent_a \gset
SELECT tests_create_user('school_staff'::user_role, :'school_b') AS staff_b \gset
SELECT tests_create_user('parent'::user_role,       :'school_b') AS parent_b \gset

-- ---------------------------------------------------------------------------
-- 1. Staff updates an in-school profile → success.
-- ---------------------------------------------------------------------------
SELECT tests_authenticate_as(:'staff_a');

SELECT lives_ok(
  $$ UPDATE profiles SET full_name = 'Renamed by staff' WHERE id = '$$ || :'parent_a' || $$' $$,
  'staff: update same-school profile is permitted'
);

SELECT is(
  (SELECT full_name FROM profiles WHERE id = :'parent_a'),
  'Renamed by staff',
  'staff: the update actually took effect'
);

-- ---------------------------------------------------------------------------
-- 2. Staff tries to update a profile from a different school → blocked.
-- ---------------------------------------------------------------------------
SELECT is(
  (
    WITH attempt AS (
      UPDATE profiles SET full_name = 'CROSS_SCHOOL_HACK'
       WHERE id = :'parent_b'
       RETURNING 1
    )
    SELECT count(*) FROM attempt
  ),
  0::bigint,
  'staff: cross-school UPDATE is silently filtered out by RLS'
);

SELECT isnt(
  (SELECT full_name FROM profiles WHERE id = :'parent_b'),
  'CROSS_SCHOOL_HACK',
  'staff: cross-school target was not modified'
);

-- ---------------------------------------------------------------------------
-- 3. A parent trying to update another parent's profile → blocked.
-- ---------------------------------------------------------------------------
SELECT tests_deauthenticate();
SELECT tests_authenticate_as(:'parent_a');

SELECT is(
  (
    WITH attempt AS (
      UPDATE profiles SET full_name = 'PEER_HACK'
       WHERE id = :'parent_b'
       RETURNING 1
    )
    SELECT count(*) FROM attempt
  ),
  0::bigint,
  'parent: cannot UPDATE another parent''s profile'
);

SELECT * FROM finish();

ROLLBACK;
