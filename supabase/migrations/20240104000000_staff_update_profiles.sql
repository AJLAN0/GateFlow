-- =============================================================================
-- Staff may update profiles within their own school
-- =============================================================================
-- The initial schema allowed only `own profile: update` (id = auth.uid()).
-- This policy lets school_staff edit any in-school profile (e.g. to set role,
-- link to school, deactivate accounts) without crossing school boundaries.
-- =============================================================================

CREATE POLICY "staff: update same-school profiles" ON profiles
  FOR UPDATE
  USING (
    my_role()  = 'school_staff'
    AND school_id = my_school_id()
  )
  WITH CHECK (
    my_role()  = 'school_staff'
    AND school_id = my_school_id()
  );
