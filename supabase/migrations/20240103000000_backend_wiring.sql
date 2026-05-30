-- =============================================================================
-- Backend wiring — pickup_requests DELETE policies
-- =============================================================================
-- Parents may delete their OWN requests, but only while still pending.
-- Staff may delete any request that belongs to a student in their school.
-- =============================================================================

CREATE POLICY "parent: delete own pending requests" ON pickup_requests
  FOR DELETE USING (
    requested_by = auth.uid()
    AND status   = 'pending'
  );

CREATE POLICY "staff: delete school requests" ON pickup_requests
  FOR DELETE USING (
    my_role() = 'school_staff'
    AND student_id IN (
      SELECT id FROM students WHERE school_id = my_school_id()
    )
  );
