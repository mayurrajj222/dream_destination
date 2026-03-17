-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS attendance_records (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  train_no TEXT NOT NULL,
  s_date DATE NOT NULL,
  emp_code TEXT NOT NULL,
  emp_name TEXT NOT NULL,
  punch1 TIMESTAMP WITH TIME ZONE,
  punch1_lat DOUBLE PRECISION,
  punch1_long DOUBLE PRECISION,
  punch1_location TEXT,
  punch2 TIMESTAMP WITH TIME ZONE,
  punch2_lat DOUBLE PRECISION,
  punch2_long DOUBLE PRECISION,
  punch2_location TEXT,
  punch3 TIMESTAMP WITH TIME ZONE,
  punch3_lat DOUBLE PRECISION,
  punch3_long DOUBLE PRECISION,
  punch3_location TEXT,
  total INTEGER DEFAULT 0,
  import_batch_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE attendance_records ENABLE ROW LEVEL SECURITY;

-- Policy: users can only see/edit their own records
CREATE POLICY "Users can manage own attendance records"
  ON attendance_records
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Index for fast queries
CREATE INDEX idx_attendance_user_date ON attendance_records(user_id, s_date);
CREATE INDEX idx_attendance_train ON attendance_records(user_id, train_no);
