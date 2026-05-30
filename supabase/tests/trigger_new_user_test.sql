-- =============================================================================
-- pgTAP · on_auth_user_created → fn_handle_new_user
-- -----------------------------------------------------------------------------
-- Inserting into auth.users with raw_user_meta_data must atomically create a
-- public.profiles row populated from that metadata.
-- =============================================================================
BEGIN;

\i supabase/tests/_helpers.sql

SELECT plan(5);

DO $$
DECLARE
  v_school uuid := tests_make_school('Trigger School');
  v_user_id uuid := gen_random_uuid();
BEGIN
  INSERT INTO auth.users (id, email, raw_user_meta_data, aud, role, created_at, updated_at)
  VALUES (
    v_user_id,
    'newuser@pgtap.test',
    jsonb_build_object(
      'full_name',   'New Parent',
      'role',        'parent',
      'school_id',   v_school::text,
      'phone',       '+966500000000',
      'national_id', 'TEST-NID-1'
    ),
    'authenticated',
    'authenticated',
    now(),
    now()
  );

  PERFORM ok(
    EXISTS (SELECT 1 FROM public.profiles WHERE id = v_user_id),
    'trigger creates a public.profiles row'
  );
  PERFORM is(
    (SELECT full_name FROM public.profiles WHERE id = v_user_id),
    'New Parent',
    'profile.full_name comes from metadata'
  );
  PERFORM is(
    (SELECT role::text FROM public.profiles WHERE id = v_user_id),
    'parent',
    'profile.role comes from metadata'
  );
  PERFORM is(
    (SELECT school_id FROM public.profiles WHERE id = v_user_id),
    v_school,
    'profile.school_id comes from metadata'
  );
  PERFORM is(
    (SELECT national_id FROM public.profiles WHERE id = v_user_id),
    'TEST-NID-1',
    'profile.national_id comes from metadata'
  );
END $$;

SELECT * FROM finish();
ROLLBACK;
