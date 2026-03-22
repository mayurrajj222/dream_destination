-- Run this in Supabase SQL Editor to add trip_id column to attendance_records

ALTER TABLE attendance_records ADD COLUMN IF NOT EXISTS trip_id TEXT;

-- Index for fast trip queries
CREATE INDEX IF NOT EXISTS idx_attendance_trip ON attendance_records(user_id, trip_id);
