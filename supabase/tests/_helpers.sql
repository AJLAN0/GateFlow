-- =============================================================================
-- pgTAP test helpers
-- =============================================================================
-- These helpers run from a privileged psql session (the connection string from
-- the Supabase dashboard, which connects as postgres/superuser). Every test
-- file begins with BEGIN and ends with ROLLBACK, so the rows we manufacture
-- here are discarded as soon as the test file finishes — nothing leaks into
-- the real database.
--
-- Usage inside a test:
--   SELECT tests_create_user('staff'::user_role, '<school_uuid>')
--     AS staff_id \gset
--   SELECT tests_authenticate_as(:'staff_id');
--   ... run assertions ...
--
-- After tests_authenticate_as(uuid), every query in the same transaction is
-- evaluated as that user: my_role(), my_school_id() and auth.uid() return
-- the matching values, and RLS policies kick in.
-- =============================================================================

SET search_path = public, extensions;

-- ---------------------------------------------------------------------------
-- Create a fresh auth.user + matching profile in the given school.
-- Returns the new user uuid.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tests_create_user(
  p_role      user_role,
  p_school_id UUID,
  p_full_name TEXT DEFAULT NULL,
  p_national  TEXT DEFAULT NULL,
  p_phone     TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_id   UUID := gen_random_uuid();
  v_name TEXT := COALESCE(p_full_name, 'tests_user_' || left(v_id::text, 8));
BEGIN
  -- Minimal columns required by auth.users; the rest default.
  INSERT INTO auth.users (id, email, raw_user_meta_data)
  VALUES (
    v_id,
    v_name || '@tests.local',
    jsonb_build_object('full_name', v_name, 'role', p_role::text)
  );

  -- fn_handle_new_user fires on the insert above. It creates a profiles row
  -- with role=p_role but no school_id / national_id / phone. Patch those.
  UPDATE profiles
     SET school_id   = p_school_id,
         national_id = p_national,
         phone       = p_phone,
         full_name   = v_name
   WHERE id = v_id;

  RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- Impersonate the given user for the remainder of the current transaction.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tests_authenticate_as(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM set_config('role', 'authenticated', true);
  PERFORM set_config(
    'request.jwt.claims',
    json_build_object(
      'sub',  p_user_id::text,
      'role', 'authenticated'
    )::text,
    true
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- Drop back to superuser within the transaction (e.g. to seed extra rows).
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tests_deauthenticate()
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM set_config('role', 'postgres', true);
  PERFORM set_config('request.jwt.claims', '', true);
END;
$$;

-- ---------------------------------------------------------------------------
-- Create a throwaway school. Returns its id.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tests_create_school(p_label TEXT DEFAULT 'tests')
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_id UUID := gen_random_uuid();
BEGIN
  INSERT INTO schools (id, name) VALUES (v_id, p_label || '_' || left(v_id::text, 8));
  RETURN v_id;
END;
$$;
