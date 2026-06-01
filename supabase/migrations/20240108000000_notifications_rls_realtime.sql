-- Staff can send in-app notifications to users in their school.
DROP POLICY IF EXISTS "staff: send school notifications" ON notifications;
CREATE POLICY "staff: send school notifications" ON notifications
  FOR INSERT WITH CHECK (
    my_role() = 'school_staff'
    AND user_id IN (SELECT id FROM profiles WHERE school_id = my_school_id())
  );

-- Realtime: bus status stream (driver dashboard / integration tests).
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.buses;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;
