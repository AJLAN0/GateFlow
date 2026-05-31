-- fn_handle_new_user trigger: profile stamped from auth metadata
BEGIN;
\ir _helpers.sql

SELECT plan(4);

SELECT tests.clear_auth();

SELECT tests.create_school('Trigger School') AS school_id \gset

SELECT tests.create_user(
  'parent',
  :'school_id'::uuid,
  'trigger-parent@test.local',
  'Trigger Parent'
) AS user_id \gset

SELECT ok(
  EXISTS (SELECT 1 FROM profiles WHERE id = :'user_id'::uuid),
  'profile row created for new auth user'
);

SELECT is(
  (SELECT role::text FROM profiles WHERE id = :'user_id'::uuid),
  'parent',
  'profile role matches metadata'
);

SELECT is(
  (SELECT school_id FROM profiles WHERE id = :'user_id'::uuid),
  :'school_id'::uuid,
  'profile school_id matches metadata'
);

SELECT is(
  (SELECT full_name FROM profiles WHERE id = :'user_id'::uuid),
  'Trigger Parent',
  'profile full_name matches metadata'
);

SELECT * FROM finish();
ROLLBACK;
