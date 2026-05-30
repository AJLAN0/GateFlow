-- =============================================================================
-- pgTAP · RBAC for `profiles`
-- -----------------------------------------------------------------------------
-- Covers the policies added by 20240104000000_staff_update_profiles.sql plus
-- the baseline self-update / cross-school isolation rules.
-- =============================================================================
BEGIN;

\i supabase/tests/_helpers.sql

SELECT plan(6);

-- Two schools so we can prove cross-school isolation.
DO $$
DECLARE
  v_school_a uuid := tests_make_school('School A');
  v_school_b uuid := tests_make_school('School B');

  v_staff_a  uuid := tests_create_user('school_staff', v_school_a, 'Staff A');
  v_parent_a uuid := tests_create_user('parent',       v_school_a, 'Parent A');
  v_staff_b  uuid := tests_create_user('school_staff', v_school_b, 'Staff B');
  v_parent_b uuid := tests_create_user('parent',       v_school_b, 'Parent B');
BEGIN
  -- 1. Staff can UPDATE a same-school profile.
  PERFORM tests_authenticate_as(v_staff_a);

  UPDATE public.profiles SET full_name = 'Updated by Staff A'
   WHERE id = v_parent_a;

  PERFORM ok(
    (SELECT full_name FROM public.profiles WHERE id = v_parent_a)
      = 'Updated by Staff A',
    'staff CAN update a profile in their own school'
  );

  -- 2. Staff CANNOT update a cross-school profile (RLS hides the row).
  UPDATE public.profiles SET full_name = 'Cross-school attempt'
   WHERE id = v_parent_b;

  PERFORM ok(
    (SELECT full_name FROM public.profiles WHERE id = v_parent_b)
      <> 'Cross-school attempt',
    'staff CANNOT update a profile in another school'
  );

  -- 3. Parent CAN update their own profile.
  PERFORM tests_authenticate_as(v_parent_a);

  UPDATE public.profiles SET full_name = 'Renamed by Parent A'
   WHERE id = v_parent_a;

  PERFORM ok(
    (SELECT full_name FROM public.profiles WHERE id = v_parent_a)
      = 'Renamed by Parent A',
    'parent CAN update their own profile'
  );

  -- 4. Parent CANNOT update another parent's profile.
  UPDATE public.profiles SET full_name = 'Hostile rename'
   WHERE id = v_parent_b;

  PERFORM ok(
    (SELECT full_name FROM public.profiles WHERE id = v_parent_b)
      <> 'Hostile rename',
    'parent CANNOT update another user''s profile'
  );

  -- 5. my_role() resolves correctly under impersonation.
  PERFORM tests_authenticate_as(v_staff_a);
  PERFORM is(my_role()::text, 'school_staff', 'my_role() reflects current JWT');

  -- 6. my_school_id() resolves correctly under impersonation.
  PERFORM is(my_school_id(), v_school_a, 'my_school_id() reflects current JWT');
END $$;

SELECT * FROM finish();
ROLLBACK;
