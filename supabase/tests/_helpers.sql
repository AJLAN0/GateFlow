-- =============================================================================
-- GateFlow · pgTAP shared helpers
-- -----------------------------------------------------------------------------
-- Each test file BEGINs a transaction, sources this helper, runs its plan,
-- then ROLLBACKs. Helpers therefore live only for the test transaction and
-- never persist on the remote database.
--
-- Provides:
--   * tests_make_school(name)               → uuid          (creates a school)
--   * tests_create_user(role, school_id)    → uuid          (auth.user + profile)
--   * tests_authenticate_as(user_id)        → void          (impersonates user)
--   * tests_logout()                        → void          (clears JWT)
--
-- The session role is flipped to `authenticated` so RLS policies apply, and
-- `request.jwt.claims` is set so `auth.uid()`, `my_role()` and `my_school_id()`
-- resolve correctly.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- tests_make_school
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tests_make_school(p_name text DEFAULT 'pgTAP School')
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.schools (name) VALUES (p_name) RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- tests_create_user
--   * inserts an auth.users row (the on_auth_user_created trigger then
--     populates profiles, see fn_handle_new_user).
--   * we additionally backfill the school_id/national_id/phone after the fact
--     so the profile is fully populated regardless of trigger version.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tests_create_user(
  p_role         text,           -- 'parent' | 'school_staff' | 'bus_driver' | 'guardian'
  p_school_id    uuid DEFAULT NULL,
  p_full_name    text DEFAULT NULL,
  p_national_id  text DEFAULT NULL,
  p_phone        text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id   uuid := gen_random_uuid();
  v_name text := COALESCE(p_full_name, p_role || ' #' || substr(v_id::text, 1, 8));
BEGIN
  -- Minimal auth.users row.  We bypass the auth API entirely and rely on the
  -- on_auth_user_created trigger to populate public.profiles via metadata.
  INSERT INTO auth.users (id, email, raw_user_meta_data, aud, role, created_at, updated_at)
  VALUES (
    v_id,
    v_id::text || '@pgtap.test',
    jsonb_build_object(
      'full_name',   v_name,
      'role',        p_role,
      'school_id',   COALESCE(p_school_id::text, ''),
      'phone',       COALESCE(p_phone, ''),
      'national_id', COALESCE(p_national_id, '')
    ),
    'authenticated',
    'authenticated',
    now(),
    now()
  );

  -- Belt-and-braces: ensure the resulting profile row carries the school
  -- regardless of which version of fn_handle_new_user is live.
  UPDATE public.profiles
     SET school_id   = COALESCE(p_school_id, school_id),
         national_id = COALESCE(p_national_id, national_id),
         phone       = COALESCE(p_phone, phone),
         full_name   = v_name
   WHERE id = v_id;

  RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- tests_authenticate_as
--   Sets the local session role to `authenticated` and writes a synthetic JWT
--   claims object so auth.uid() returns p_user_id.  All RLS helpers
--   (my_role(), my_school_id()) build on top of this.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tests_authenticate_as(p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM set_config(
    'request.jwt.claims',
    json_build_object('sub', p_user_id::text, 'role', 'authenticated')::text,
    true
  );
  EXECUTE 'SET LOCAL role authenticated';
END;
$$;

-- ---------------------------------------------------------------------------
-- tests_logout
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tests_logout()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM set_config('request.jwt.claims', '', true);
  EXECUTE 'RESET ROLE';
END;
$$;
