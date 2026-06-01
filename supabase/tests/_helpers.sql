-- GateFlow pgTAP helpers (included by each *_test.sql file).
-- All test files wrap execution in BEGIN … ROLLBACK.

CREATE SCHEMA IF NOT EXISTS tests;
GRANT USAGE ON SCHEMA tests TO postgres, authenticated, service_role;

-- Switch JWT/role GUCs for RLS simulation. Must NOT be SECURITY DEFINER
-- (Postgres forbids set_config('role', …) inside definer functions).
CREATE OR REPLACE FUNCTION tests.authenticate_as(p_uid uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM set_config('role', 'authenticated', true);
  PERFORM set_config(
    'request.jwt.claim.sub',
    p_uid::text,
    true
  );
  PERFORM set_config(
    'request.jwt.claims',
    json_build_object('sub', p_uid)::text,
    true
  );
END;
$$;

CREATE OR REPLACE FUNCTION tests.clear_auth()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM set_config('role', 'postgres', true);
  PERFORM set_config('request.jwt.claim.sub', '', true);
  PERFORM set_config('request.jwt.claims', '', true);
END;
$$;

-- Creates an auth.users row; fn_handle_new_user trigger stamps profiles.
CREATE OR REPLACE FUNCTION tests.create_user(
  p_role       user_role,
  p_school_id  uuid,
  p_email      text DEFAULT NULL,
  p_full_name  text DEFAULT 'Test User'
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
DECLARE
  v_uid   uuid := gen_random_uuid();
  v_email text := COALESCE(p_email, v_uid::text || '@test.gateflow.local');
BEGIN
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
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    v_uid,
    'authenticated',
    'authenticated',
    v_email,
    crypt('GateFlow@Test1', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    json_build_object(
      'full_name',  p_full_name,
      'role',       p_role::text,
      'school_id',  p_school_id::text
    )::jsonb,
    now(),
    now(),
    '',
    ''
  );

  UPDATE public.profiles
  SET role = p_role,
      school_id = p_school_id,
      full_name = p_full_name,
      is_active = true
  WHERE id = v_uid;

  RETURN v_uid;
END;
$$;

CREATE OR REPLACE FUNCTION tests.create_school(p_name text DEFAULT 'Test School')
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id uuid := gen_random_uuid();
BEGIN
  INSERT INTO public.schools (id, name, address, phone, email)
  VALUES (v_id, p_name, 'Test Address', '+966000000000', 'test@gateflow.local');
  RETURN v_id;
END;
$$;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA tests TO postgres, authenticated, service_role;
