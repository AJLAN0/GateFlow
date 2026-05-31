-- =============================================================================
-- GateFlow · Integration demo seed (idempotent)
-- Creates sign-in-capable demo accounts for Tier 3 integration tests.
--
-- Usage:
--   psql "$GATEFLOW_DB_URL" -v ON_ERROR_STOP=1 -f supabase/seed_demo_integration.sql
--
-- Credentials (all roles):
--   Password: GateFlow@2024
--   staff@demo.gateflow.app | parent@demo.gateflow.app
--   driver@demo.gateflow.app | guardian@demo.gateflow.app
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Upsert auth.users + auth.identities + profiles for email/password login.
CREATE OR REPLACE FUNCTION public.seed_demo_auth_user(
  p_id          uuid,
  p_email       text,
  p_password    text,
  p_full_name   text,
  p_role        public.user_role,
  p_school_id   uuid,
  p_national_id text DEFAULT NULL,
  p_phone       text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
DECLARE
  v_email text := lower(trim(p_email));
  v_uid   uuid;
  v_pw    text;
BEGIN
  v_pw := crypt(p_password, gen_salt('bf'));

  SELECT id INTO v_uid FROM auth.users WHERE email = v_email;

  IF v_uid IS NULL THEN
    v_uid := p_id;
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      recovery_token,
      email_change_token_new,
      email_change,
      email_change_token_current
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      v_uid,
      'authenticated',
      'authenticated',
      v_email,
      v_pw,
      now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object(
        'full_name',  p_full_name,
        'role',       p_role::text,
        'school_id',  p_school_id::text,
        'email_verified', true
      ),
      now(),
      now(),
      '',
      '',
      '',
      '',
      ''
    );
  ELSE
    UPDATE auth.users
    SET encrypted_password = v_pw,
        email_confirmed_at = COALESCE(email_confirmed_at, now()),
        confirmation_token = COALESCE(confirmation_token, ''),
        recovery_token = COALESCE(recovery_token, ''),
        email_change_token_new = COALESCE(email_change_token_new, ''),
        email_change = COALESCE(email_change, ''),
        email_change_token_current = COALESCE(email_change_token_current, ''),
        raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb)
          || '{"provider":"email","providers":["email"]}'::jsonb,
        raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb)
          || jsonb_build_object(
            'full_name', p_full_name,
            'role',      p_role::text,
            'school_id', p_school_id::text,
            'email_verified', true
          )
    WHERE id = v_uid;
  END IF;

  -- Always replace identity: GoTrue expects id = user_id and provider_id = user_id
  -- (email as provider_id breaks sign-in with HTTP 400 on many Supabase versions).
  DELETE FROM auth.identities
  WHERE user_id = v_uid AND provider = 'email';

  INSERT INTO auth.identities (
    id,
    user_id,
    provider_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    v_uid,
    v_uid,
    v_uid::text,
    jsonb_build_object(
      'sub',            v_uid::text,
      'email',          v_email,
      'email_verified', true,
      'phone_verified', false
    ),
    'email',
    now(),
    now(),
    now()
  );

  INSERT INTO public.profiles (
    id, full_name, role, school_id, national_id, phone, is_active, login_email
  ) VALUES (
    v_uid, p_full_name, p_role, p_school_id, p_national_id, p_phone, true, v_email
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name   = EXCLUDED.full_name,
    role        = EXCLUDED.role,
    school_id   = EXCLUDED.school_id,
    national_id = COALESCE(EXCLUDED.national_id, profiles.national_id),
    phone       = COALESCE(EXCLUDED.phone, profiles.phone),
    is_active   = true,
    login_email = EXCLUDED.login_email;

  RETURN v_uid;
END;
$$;

DO $$
DECLARE
  v_school   uuid := '00000000-0000-0000-0000-000000000001';
  v_staff    uuid;
  v_parent   uuid;
  v_driver   uuid;
  v_guardian uuid;
  v_bus      uuid := '00000000-0000-0000-0000-000000000010';
  v_student  uuid := '00000000-0000-0000-0000-000000000021';
  v_pw       text := 'GateFlow@2024';
BEGIN
  INSERT INTO public.schools (id, name, address, phone, email)
  VALUES (
    v_school,
    'GateFlow Demo School',
    '123 School Street, Riyadh',
    '+966110000000',
    'admin@gateflow.demo'
  )
  ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

  v_staff := public.seed_demo_auth_user(
    '00000000-0000-0000-0000-000000000011',
    'staff@demo.gateflow.app', v_pw,
    'Noura Al-Zahrani', 'school_staff', v_school
  );

  v_parent := public.seed_demo_auth_user(
    '00000000-0000-0000-0000-000000000012',
    'parent@demo.gateflow.app', v_pw,
    'Khaled Al-Otaibi', 'parent', v_school,
    '1234567890', '+966501112233'
  );

  v_driver := public.seed_demo_auth_user(
    '00000000-0000-0000-0000-000000000013',
    'driver@demo.gateflow.app', v_pw,
    'Omar Bin Saleh', 'bus_driver', v_school
  );

  v_guardian := public.seed_demo_auth_user(
    '00000000-0000-0000-0000-000000000014',
    'guardian@demo.gateflow.app', v_pw,
    'Mohammed Ali', 'guardian', v_school,
    '9876543210', '+96650004411'
  );

  INSERT INTO public.buses (id, name, route_label, plate_number, school_id, driver_id, status)
  VALUES (
    v_bus,
    'Bus 12A',
    'North Route · Zones A–D',
    'ABC-1234',
    v_school,
    v_driver,
    'stationary'
  )
  ON CONFLICT (id) DO UPDATE SET
    driver_id = EXCLUDED.driver_id,
    school_id = EXCLUDED.school_id;

  INSERT INTO public.students (
    id, name, grade, school_id, status, transport_type, bus_id
  ) VALUES (
    v_student,
    'Noah Khaled',
    'Grade 1',
    v_school,
    'at_school',
    'bus',
    v_bus
  )
  ON CONFLICT (id) DO UPDATE SET
    school_id = EXCLUDED.school_id,
    bus_id    = EXCLUDED.bus_id;

  INSERT INTO public.parent_students (parent_id, student_id)
  VALUES (v_parent, v_student)
  ON CONFLICT (parent_id, student_id) DO NOTHING;

  RAISE NOTICE 'Demo seed OK — staff=%, parent=%, driver=%, guardian=%',
    v_staff, v_parent, v_driver, v_guardian;
END;
$$;
