-- =============================================================================
-- GateFlow · Backend Wiring migration
-- -----------------------------------------------------------------------------
-- 1. Let bus drivers update their own bus's status.
-- 2. Add a DELETE policy on pickup_requests (parent cancels own pending; staff
--    manage their school's requests).
-- 3. Let drivers raise operational alerts (e.g. the triple-scan warning).
-- 4. Extend fn_handle_new_user to also read school_id / phone / national_id from
--    the auth user's metadata so the admin-create-user Edge Function produces a
--    fully-populated profile atomically.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Driver: update own bus status
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "driver: update own bus status" ON buses;
CREATE POLICY "driver: update own bus status" ON buses
  FOR UPDATE USING (driver_id = auth.uid());

-- ---------------------------------------------------------------------------
-- 2. pickup_requests DELETE policy
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "parent: delete own pending request" ON pickup_requests;
CREATE POLICY "parent: delete own pending request" ON pickup_requests
  FOR DELETE USING (
    requested_by = auth.uid() AND status = 'pending'
  );

DROP POLICY IF EXISTS "staff: delete school requests" ON pickup_requests;
CREATE POLICY "staff: delete school requests" ON pickup_requests
  FOR DELETE USING (
    my_role() = 'school_staff'
    AND student_id IN (SELECT id FROM students WHERE school_id = my_school_id())
  );

-- ---------------------------------------------------------------------------
-- 3. Driver: insert operational alerts for their school
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "driver: raise alerts" ON operational_alerts;
CREATE POLICY "driver: raise alerts" ON operational_alerts
  FOR INSERT WITH CHECK (
    school_id = my_school_id()
    AND my_role() IN ('bus_driver', 'school_staff')
  );

-- ---------------------------------------------------------------------------
-- 4. Richer profile auto-creation from auth metadata
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role, school_id, phone, national_id)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'parent'),
    NULLIF(NEW.raw_user_meta_data->>'school_id', '')::uuid,
    NULLIF(NEW.raw_user_meta_data->>'phone', ''),
    NULLIF(NEW.raw_user_meta_data->>'national_id', '')
  );
  RETURN NEW;
END;
$$;
