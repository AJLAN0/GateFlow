-- =============================================================================
-- Trigger · fn_handle_new_user
-- =============================================================================
-- Verifies that inserting into auth.users with role metadata atomically
-- stamps out a public.profiles row with the correct role and full_name.
-- =============================================================================

BEGIN;

SELECT plan(5);

-- Default-role path (no role in metadata → 'parent').
WITH ins AS (
  INSERT INTO auth.users (id, email, raw_user_meta_data)
  VALUES (
    gen_random_uuid(),
    'tt_default@tests.local',
    jsonb_build_object('full_name', 'Test Default')
  )
  RETURNING id
)
SELECT id AS uid_default FROM ins \gset

SELECT is(
  (SELECT count(*)::int FROM profiles WHERE id = :'uid_default'),
  1,
  'trigger: profile row was created for the new auth user'
);

SELECT is(
  (SELECT role::text FROM profiles WHERE id = :'uid_default'),
  'parent',
  'trigger: defaults to parent when no role in metadata'
);

SELECT is(
  (SELECT full_name FROM profiles WHERE id = :'uid_default'),
  'Test Default',
  'trigger: full_name copied from raw_user_meta_data'
);

-- Explicit-role path.
WITH ins AS (
  INSERT INTO auth.users (id, email, raw_user_meta_data)
  VALUES (
    gen_random_uuid(),
    'tt_staff@tests.local',
    jsonb_build_object('full_name', 'Test Staff', 'role', 'school_staff')
  )
  RETURNING id
)
SELECT id AS uid_staff FROM ins \gset

SELECT is(
  (SELECT role::text FROM profiles WHERE id = :'uid_staff'),
  'school_staff',
  'trigger: respects an explicit school_staff role'
);

-- Empty-metadata path: full_name = '' is allowed (NOT NULL on profiles
-- requires a value; COALESCE in the trigger supplies '').
WITH ins AS (
  INSERT INTO auth.users (id, email, raw_user_meta_data)
  VALUES (
    gen_random_uuid(),
    'tt_empty@tests.local',
    '{}'::jsonb
  )
  RETURNING id
)
SELECT id AS uid_empty FROM ins \gset

SELECT is(
  (SELECT full_name FROM profiles WHERE id = :'uid_empty'),
  '',
  'trigger: empty metadata yields full_name = ""'
);

SELECT * FROM finish();

ROLLBACK;
