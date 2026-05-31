-- Restrict school-wide pickup_requests SELECT to staff only (not all same-school parents).
DROP POLICY IF EXISTS "staff: view school requests" ON pickup_requests;
CREATE POLICY "staff: view school requests" ON pickup_requests
  FOR SELECT USING (
    my_role() = 'school_staff'
    AND student_id IN (SELECT id FROM students WHERE school_id = my_school_id())
  );
