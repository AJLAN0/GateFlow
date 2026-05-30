-- =============================================================================
-- pgTAP · RBAC for `daily_schedules`, `buses`, `students`
-- -----------------------------------------------------------------------------
--   * staff: manage in-school schedules / buses / students
--   * driver: update own-bus status + own-bus student status (only)
-- =============================================================================
BEGIN;

\i supabase/tests/_helpers.sql

SELECT plan(7);

DO $$
DECLARE
  v_school   uuid := tests_make_school('SBS School');
  v_school_x uuid := tests_make_school('Other School');

  v_staff    uuid := tests_create_user('school_staff', v_school);
  v_driver_1 uuid := tests_create_user('bus_driver',   v_school);
  v_driver_2 uuid := tests_create_user('bus_driver',   v_school);

  v_bus_1    uuid;
  v_bus_2    uuid;
  v_stu_1    uuid;
  v_stu_2    uuid;
  v_sched    uuid;
BEGIN
  -- Staff creates buses + students.
  PERFORM tests_authenticate_as(v_staff);
  INSERT INTO public.buses (name, school_id, driver_id, status)
       VALUES ('Bus 1', v_school, v_driver_1, 'stationary')
    RETURNING id INTO v_bus_1;
  INSERT INTO public.buses (name, school_id, driver_id, status)
       VALUES ('Bus 2', v_school, v_driver_2, 'stationary')
    RETURNING id INTO v_bus_2;

  INSERT INTO public.students (name, grade, school_id, status, transport_type, bus_id)
       VALUES ('Stu One', 'G1', v_school, 'at_home', 'bus', v_bus_1)
    RETURNING id INTO v_stu_1;
  INSERT INTO public.students (name, grade, school_id, status, transport_type, bus_id)
       VALUES ('Stu Two', 'G1', v_school, 'at_home', 'bus', v_bus_2)
    RETURNING id INTO v_stu_2;

  -- Staff creates a schedule.
  INSERT INTO public.daily_schedules (school_id, class_name, grade, date)
       VALUES (v_school, '1A', 'G1', CURRENT_DATE)
    RETURNING id INTO v_sched;

  PERFORM ok(v_sched IS NOT NULL,
            'staff CAN insert a daily_schedule in their school');

  -- 1. Driver 1 CAN update their own bus status.
  PERFORM tests_authenticate_as(v_driver_1);
  UPDATE public.buses SET status = 'on_route_to_school' WHERE id = v_bus_1;
  PERFORM is(
    (SELECT status::text FROM public.buses WHERE id = v_bus_1),
    'on_route_to_school',
    'driver CAN update their own bus status'
  );

  -- 2. Driver 1 CANNOT update another bus's status.
  UPDATE public.buses SET status = 'on_route_to_home' WHERE id = v_bus_2;
  PERFORM is(
    (SELECT status::text FROM public.buses WHERE id = v_bus_2),
    'stationary',
    'driver CANNOT update another driver''s bus'
  );

  -- 3. Driver 1 CAN update a student on their own bus.
  UPDATE public.students SET status = 'on_bus_to_school' WHERE id = v_stu_1;
  PERFORM is(
    (SELECT status::text FROM public.students WHERE id = v_stu_1),
    'on_bus_to_school',
    'driver CAN update a student on their own bus'
  );

  -- 4. Driver 1 CANNOT update a student on a different bus.
  UPDATE public.students SET status = 'on_bus_to_school' WHERE id = v_stu_2;
  PERFORM is(
    (SELECT status::text FROM public.students WHERE id = v_stu_2),
    'at_home',
    'driver CANNOT update a student on a different bus'
  );

  -- 5. Daily schedules visible to school members; deletable by staff.
  PERFORM tests_authenticate_as(v_staff);
  DELETE FROM public.daily_schedules WHERE id = v_sched;
  PERFORM ok(
    NOT EXISTS (SELECT 1 FROM public.daily_schedules WHERE id = v_sched),
    'staff CAN delete an in-school schedule'
  );

  -- 6. Non-staff role (driver) CANNOT delete a schedule.
  PERFORM tests_authenticate_as(v_staff);
  INSERT INTO public.daily_schedules (school_id, class_name, grade, date)
       VALUES (v_school, '2A', 'G2', CURRENT_DATE)
    RETURNING id INTO v_sched;

  PERFORM tests_authenticate_as(v_driver_1);
  DELETE FROM public.daily_schedules WHERE id = v_sched;
  PERFORM ok(
    EXISTS (SELECT 1 FROM public.daily_schedules WHERE id = v_sched),
    'driver CANNOT delete a schedule (staff-only manage)'
  );
END $$;

SELECT * FROM finish();
ROLLBACK;
