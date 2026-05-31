-- Store login email + staff-visible initial password on profiles so school
-- admins can view credentials on the parent/driver details screen.
-- (Auth passwords are hashed and cannot be read back from auth.users.)

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS login_email      TEXT,
  ADD COLUMN IF NOT EXISTS initial_password TEXT;
