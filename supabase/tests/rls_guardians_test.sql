-- =============================================================================
-- pgTAP · RBAC for `guardians`
-- -----------------------------------------------------------------------------
-- Policies under test:
--   * "parent: manage own guardians"          (parent_id = auth.uid())
--   * "staff: manage all guardians in school" (parent in my school)
-- =============================================================================
BEGIN;

\i supabase/tests/_helpers.sql

SELECT plan(5);

DO $$
DECLARE
  v_school_a uuid := tests_make_school('Guard School A');
  v_school_b uuid := tests_make_school('Guard School B');

  v_staff_a  uuid := tests_create_user('school_staff', v_school_a);
  v_parent_a uuid := tests_create_user('parent',       v_school_a);
  v_parent_b uuid := tests_create_user('parent',       v_school_b);

  v_g_a uuid;
  v_g_b uuid;
BEGIN
  -- Parent A submits a guardian invite.
  PERFORM tests_authenticate_as(v_parent_a);
  INSERT INTO public.guardians (parent_id, full_name, relationship, status)
       VALUES (v_parent_a, 'Uncle A', 'uncle', 'pending')
    RETURNING id INTO v_g_a;

  -- Parent B (different school) submits a guardian invite.
  PERFORM tests_authenticate_as(v_parent_b);
  INSERT INTO public.guardians (parent_id, full_name, relationship, status)
       VALUES (v_parent_b, 'Uncle B', 'uncle', 'pending')
    RETURNING id INTO v_g_b;

  -- 1. Parent A only sees their own guardian rows.
  PERFORM tests_authenticate_as(v_parent_a);
  PERFORM is(
    (SELECT count(*) FROM public.guardians)::int,
    1,
    'parent SELECT scoped to their own guardians'
  );

  -- 2. Parent A can manage (update) their own guardian.
  UPDATE public.guardians SET notes = 'parent edited' WHERE id = v_g_a;
  PERFORM is(
    (SELECT notes FROM public.guardians WHERE id = v_g_a),
    'parent edited',
    'parent CAN update their own guardian'
  );

  -- 3. Staff in School A sees Uncle A but NOT Uncle B (cross-school isolation).
  PERFORM tests_authenticate_as(v_staff_a);
  PERFORM ok(
    EXISTS (SELECT 1 FROM public.guardians WHERE id = v_g_a),
    'staff sees in-school guardian row'
  );
  PERFORM ok(
    NOT EXISTS (SELECT 1 FROM public.guardians WHERE id = v_g_b),
    'staff CANNOT see a guardian from another school'
  );

  -- 4. Staff approves the in-school guardian.
  UPDATE public.guardians SET status = 'approved', authorized_by = v_staff_a
   WHERE id = v_g_a;
  PERFORM is(
    (SELECT status::text FROM public.guardians WHERE id = v_g_a),
    'approved',
    'staff CAN approve an in-school guardian'
  );
END $$;

SELECT * FROM finish();
ROLLBACK;
