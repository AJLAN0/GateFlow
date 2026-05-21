-- =============================================================================
-- GateFlow · Seed Data
-- Run after migrations. Creates a demo school and test accounts.
-- NOTE: replace passwords before using in production.
-- =============================================================================

-- Demo school
INSERT INTO schools (id, name, address, phone, email)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'GateFlow Demo School',
  '123 School Street, Riyadh, Saudi Arabia',
  '+966 11 000 0000',
  'admin@gateflow.demo'
);

-- NOTE: Auth users must be created via Supabase Dashboard or Auth API first.
-- Then run the SQL below to update their profiles after signup.
-- Example demo accounts to create in Auth dashboard:
--   admin@gateflow.demo       / password: GateFlow2024!  → role: school_staff
--   parent@gateflow.demo      / password: GateFlow2024!  → role: parent
--   driver@gateflow.demo      / password: GateFlow2024!  → role: bus_driver
--   guardian@gateflow.demo    / password: GateFlow2024!  → role: guardian

-- After creating auth users, update their profiles (replace UUIDs accordingly):
-- UPDATE profiles SET role='school_staff', school_id='00000000-0000-0000-0000-000000000001', full_name='School Admin'
--   WHERE id = '<admin-uuid>';
-- UPDATE profiles SET role='parent',       school_id='00000000-0000-0000-0000-000000000001', full_name='Khalid Al-Otaibi', national_id='1234567890', phone='+966501112233'
--   WHERE id = '<parent-uuid>';
-- UPDATE profiles SET role='bus_driver',   school_id='00000000-0000-0000-0000-000000000001', full_name='Hassan Driver'
--   WHERE id = '<driver-uuid>';
-- UPDATE profiles SET role='guardian',     school_id='00000000-0000-0000-0000-000000000001', full_name='Mohammed Ali', national_id='9876543210', phone='+96650004411'
--   WHERE id = '<guardian-uuid>';

-- Demo buses (run after driver profile exists)
-- INSERT INTO buses (id, name, route_label, plate_number, school_id, status)
-- VALUES (
--   '00000000-0000-0000-0000-000000000010',
--   'Bus 12A',
--   'North Route · Zones A–D',
--   'ABC-1234',
--   '00000000-0000-0000-0000-000000000001',
--   'stationary'
-- );

-- Demo students (run after school + bus exist)
-- INSERT INTO students (name, grade, school_id, status, transport_type, bus_id)
-- VALUES
--   ('Saad Khaled',  'Grade 6', '00000000-0000-0000-0000-000000000001', 'at_school',      'car',  NULL),
--   ('Sara Khaled',  'Grade 6', '00000000-0000-0000-0000-000000000001', 'at_school',      'car',  NULL),
--   ('Noah Khaled',  'Grade 1', '00000000-0000-0000-0000-000000000001', 'on_bus_to_home', 'bus',  '00000000-0000-0000-0000-000000000010'),
--   ('Lama Khaled',  'Grade 1', '00000000-0000-0000-0000-000000000001', 'at_school',      'bus',  '00000000-0000-0000-0000-000000000010'),
--   ('Khalid Jr.',   'Grade 3', '00000000-0000-0000-0000-000000000001', 'at_school',      'bus',  '00000000-0000-0000-0000-000000000010');
