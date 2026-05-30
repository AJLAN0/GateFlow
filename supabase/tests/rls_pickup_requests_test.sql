-- =============================================================================
-- pgTAP · RBAC for `pickup_requests`
-- -----------------------------------------------------------------------------
-- Covers the SELECT / DELETE / UPDATE policies from 20240101 + 20240103.
--   * parent: see/insert/delete-own-pending
--   * staff:  see/update/delete in their own school
-- =============================================================================
BEGIN;

\i supabase/tests/_helpers.sql

SELECT plan(7);

DO $$
DECLARE
  v_school   uuid := tests_make_school('PR School');

  v_staff    uuid := tests_create_user('school_staff', v_school);
  v_parent_a uuid := tests_create_user('parent',       v_school);
  v_parent_b uuid := tests_create_user('parent',       v_school);

  v_student  uuid;
  v_req_a    uuid;
  v_req_b    uuid;
BEGIN
  -- Need a student row to attach requests to (created as staff).
  PERFORM tests_authenticate_as(v_staff);
  INSERT INTO public.students (name, grade, school_id, status, transport_type)
       VALUES ('Test Student', 'G1', v_school, 'at_home', 'car')
    RETURNING id INTO v_student;

  -- Parent A submits a request.
  PERFORM tests_authenticate_as(v_parent_a);
  INSERT INTO public.pickup_requests
    (student_id, requested_by, type, status, date)
       VALUES (v_student, v_parent_a, 'Early Pickup', 'pending', CURRENT_DATE)
    RETURNING id INTO v_req_a;

  -- Parent B submits a request.
  PERFORM tests_authenticate_as(v_parent_b);
  INSERT INTO public.pickup_requests
    (student_id, requested_by, type, status, date)
       VALUES (v_student, v_parent_b, 'Late Drop-off', 'pending', CURRENT_DATE)
    RETURNING id INTO v_req_b;

  -- 1. Parent A only sees their own request.
  PERFORM tests_authenticate_as(v_parent_a);
  PERFORM is(
    (SELECT count(*) FROM public.pickup_requests)::int,
    1,
    'parent SELECT scoped to own rows'
  );

  -- 2. Parent A cannot DELETE Parent B's pending request (RLS hides it).
  DELETE FROM public.pickup_requests WHERE id = v_req_b;
  PERFORM ok(
    EXISTS (SELECT 1 FROM public.pickup_requests WHERE id = v_req_b),
    'parent CANNOT delete another parent''s request'
  );

  -- 3. Parent A CAN delete their own pending request.
  DELETE FROM public.pickup_requests WHERE id = v_req_a;
  PERFORM ok(
    NOT EXISTS (SELECT 1 FROM public.pickup_requests WHERE id = v_req_a),
    'parent CAN delete their own pending request'
  );

  -- 4. Once approved, parent can no longer delete it.
  --    Re-create as parent A, then approve as staff.
  INSERT INTO public.pickup_requests
    (student_id, requested_by, type, status, date)
       VALUES (v_student, v_parent_a, 'Early Pickup', 'pending', CURRENT_DATE)
    RETURNING id INTO v_req_a;

  PERFORM tests_authenticate_as(v_staff);
  UPDATE public.pickup_requests SET status = 'approved', reviewed_by = v_staff
   WHERE id = v_req_a;

  PERFORM is(
    (SELECT status::text FROM public.pickup_requests WHERE id = v_req_a),
    'approved',
    'staff CAN update request status school-wide'
  );

  PERFORM tests_authenticate_as(v_parent_a);
  DELETE FROM public.pickup_requests WHERE id = v_req_a;
  PERFORM ok(
    EXISTS (SELECT 1 FROM public.pickup_requests WHERE id = v_req_a),
    'parent CANNOT delete an APPROVED request (parent-delete only pending)'
  );

  -- 5. Staff sees both rows in their school.
  PERFORM tests_authenticate_as(v_staff);
  PERFORM ok(
    (SELECT count(*) FROM public.pickup_requests)::int >= 2,
    'staff SELECT scoped school-wide (sees every request)'
  );

  -- 6. Staff CAN delete any request in their school.
  DELETE FROM public.pickup_requests WHERE id = v_req_b;
  PERFORM ok(
    NOT EXISTS (SELECT 1 FROM public.pickup_requests WHERE id = v_req_b),
    'staff CAN delete a school-scoped request'
  );
END $$;

SELECT * FROM finish();
ROLLBACK;
