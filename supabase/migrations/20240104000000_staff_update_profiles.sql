-- =============================================================================
-- GateFlow · Staff profile management
-- -----------------------------------------------------------------------------
-- The initial schema only allowed a user to UPDATE their own profile
-- (id = auth.uid()). School staff therefore could not edit or deactivate the
-- parent / bus-driver accounts they manage — those UPDATEs matched zero rows
-- under RLS and silently did nothing. This adds an UPDATE policy so staff can
-- manage profiles that belong to their own school.
-- =============================================================================

DROP POLICY IF EXISTS "staff: update school profiles" ON profiles;
CREATE POLICY "staff: update school profiles" ON profiles
  FOR UPDATE USING (
    my_role() = 'school_staff'
    AND school_id = my_school_id()
  )
  WITH CHECK (
    my_role() = 'school_staff'
    AND school_id = my_school_id()
  );
