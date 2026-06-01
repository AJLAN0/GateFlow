-- Student pickup / home location (GPS + readable label)
ALTER TABLE students
  ADD COLUMN IF NOT EXISTS pickup_location_label TEXT,
  ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;
