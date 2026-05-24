-- =============================================================================
-- Fix: infinite recursion in RLS helper functions
-- =============================================================================
-- my_role() and my_school_id() query the `profiles` table.
-- `profiles` has RLS policies that call those same functions → infinite loop.
-- Adding SECURITY DEFINER + SET search_path makes them bypass RLS entirely.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Fix helper functions (SECURITY DEFINER bypasses RLS on the profiles table)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION my_school_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT school_id FROM profiles WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION my_role()
RETURNS user_role
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$;

-- ---------------------------------------------------------------------------
-- Also harden the signup trigger (explicit search_path avoids enum cast issues)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO profiles (id, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'parent')
  );
  RETURN NEW;
END;
$$;
