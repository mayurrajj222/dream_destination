-- Create trains table for Supabase
CREATE TABLE IF NOT EXISTS trains (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  train_no_going TEXT NOT NULL,
  train_name_going TEXT NOT NULL,
  station_from TEXT NOT NULL,
  station_to TEXT NOT NULL,
  total_janitor INTEGER NOT NULL DEFAULT 0,
  departure_time_going TEXT NOT NULL DEFAULT '00:00:00',
  journey_duration_going TEXT NOT NULL DEFAULT '00:00:00',
  train_no_coming TEXT NOT NULL DEFAULT '',
  train_name_coming TEXT NOT NULL DEFAULT '',
  departure_time_coming TEXT NOT NULL DEFAULT '00:00:00',
  journey_duration_coming TEXT NOT NULL DEFAULT '00:00:00',
  going_on_mon BOOLEAN DEFAULT FALSE,
  going_on_tue BOOLEAN DEFAULT FALSE,
  going_on_wed BOOLEAN DEFAULT FALSE,
  going_on_thu BOOLEAN DEFAULT FALSE,
  going_on_fri BOOLEAN DEFAULT FALSE,
  going_on_sat BOOLEAN DEFAULT FALSE,
  going_on_sun BOOLEAN DEFAULT FALSE,
  coming_on_mon BOOLEAN DEFAULT FALSE,
  coming_on_tue BOOLEAN DEFAULT FALSE,
  coming_on_wed BOOLEAN DEFAULT FALSE,
  coming_on_thu BOOLEAN DEFAULT FALSE,
  coming_on_fri BOOLEAN DEFAULT FALSE,
  coming_on_sat BOOLEAN DEFAULT FALSE,
  coming_on_sun BOOLEAN DEFAULT FALSE,
  coach_wgfacc BOOLEAN DEFAULT FALSE,
  coach_wgaccwa1 BOOLEAN DEFAULT FALSE,
  coach_wgaccnb1 BOOLEAN DEFAULT FALSE,
  coach_wgscnsl BOOLEAN DEFAULT FALSE,
  coach_wgczac BOOLEAN DEFAULT FALSE,
  coach_wgsczd BOOLEAN DEFAULT FALSE,
  coach_lwfczac BOOLEAN DEFAULT FALSE,
  coach_wgfcnac BOOLEAN DEFAULT FALSE,
  coach_m1 BOOLEAN DEFAULT FALSE,
  coach_ce BOOLEAN DEFAULT FALSE,
  coach_gs BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE trains ENABLE ROW LEVEL SECURITY;

-- Create policies for user-specific access
CREATE POLICY "Users can read their own trains"
  ON trains FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own trains"
  ON trains FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own trains"
  ON trains FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own trains"
  ON trains FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_trains_user_id ON trains(user_id);
CREATE INDEX IF NOT EXISTS idx_trains_train_no ON trains(train_no_going);
CREATE INDEX IF NOT EXISTS idx_trains_station_from ON trains(station_from);

-- Insert a sample train for testing (Train 05220 from your import)
-- This will be inserted for the current user when they first log in
-- You can manually insert it or let users create trains through the UI
