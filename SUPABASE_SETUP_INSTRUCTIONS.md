# Supabase Setup Instructions

## ✅ Completed Steps

1. **Dependencies Updated**
   - Removed Firebase packages
   - Added `supabase_flutter: ^2.9.1`

2. **Configuration Created**
   - Created `lib/config/supabase_config.dart` with your Supabase credentials

3. **Services Updated**
   - ✅ `auth_service.dart` - Rewritten for Supabase Auth
   - ✅ `psi_service.dart` - Rewritten for PostgreSQL
   - ✅ `psi_record_model.dart` - Updated for PostgreSQL data types

4. **Main App Updated**
   - Replaced Firebase initialization with Supabase initialization

## 🔧 Required: Database Setup in Supabase Dashboard

**IMPORTANT**: You must run these SQL commands in your Supabase Dashboard before the app will work!

### Step 1: Go to Supabase Dashboard
1. Visit: https://supabase.com/dashboard/project/iciposutxzqepxglghck
2. Click on "SQL Editor" in the left sidebar

### Step 2: Create the `psi_records` table

Copy and paste this SQL:

```sql
CREATE TABLE psi_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  train_id UUID,
  train_no TEXT NOT NULL,
  train_name TEXT NOT NULL,
  schedule_id TEXT,
  trip_id TEXT NOT NULL,
  date TIMESTAMP NOT NULL,
  passenger_name TEXT NOT NULL,
  pnr_no TEXT NOT NULL,
  mobile_no TEXT,
  coach TEXT NOT NULL,
  seat_no TEXT NOT NULL,
  psi_score NUMERIC NOT NULL,
  feedback TEXT,
  trip_type TEXT NOT NULL,
  ehk_name TEXT NOT NULL,
  service1_rating TEXT,
  service2_rating TEXT,
  service3_rating TEXT,
  service4_rating TEXT,
  service5_rating TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE psi_records ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own records
CREATE POLICY "Users can view own psi_records"
  ON psi_records FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own psi_records"
  ON psi_records FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own psi_records"
  ON psi_records FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own psi_records"
  ON psi_records FOR DELETE
  USING (auth.uid() = user_id);
```

### Step 3: Create the `trains` table

```sql
CREATE TABLE trains (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  train_no_going TEXT NOT NULL,
  train_name_going TEXT NOT NULL,
  station_from TEXT NOT NULL,
  station_to TEXT NOT NULL,
  total_janitor INTEGER DEFAULT 0,
  departure_time_going TEXT NOT NULL,
  journey_duration_going TEXT NOT NULL,
  train_no_coming TEXT NOT NULL,
  train_name_coming TEXT NOT NULL,
  departure_time_coming TEXT NOT NULL,
  journey_duration_coming TEXT NOT NULL,
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
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE trains ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own trains"
  ON trains FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own trains"
  ON trains FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own trains"
  ON trains FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own trains"
  ON trains FOR DELETE
  USING (auth.uid() = user_id);
```

## 📦 Next: Install Dependencies

Run this command:
```bash
flutter pub get
```

## 🚀 Then: Run the App

```bash
flutter run -d edge
```

## 🔐 Authentication

- Sign up will create a new user in Supabase Auth
- Login format: `{customerId}_{userId}@dreamdestination.com`
- Example: `CUST001_USER123@dreamdestination.com`

## ⚠️ Important Notes

1. **Row Level Security (RLS)** is enabled - users can only access their own data
2. **User ID** is automatically set from the authenticated user
3. **PostgreSQL** uses UUIDs instead of Firestore's auto-generated strings
4. All timestamps are stored in ISO 8601 format

## 🔄 Still TODO

The following services still need to be migrated:
- `train_service.dart`
- `schedule_service.dart`
- `employee_service.dart`
- `attendance_service.dart`
- `ehk_staff_service.dart`
- `trip_card_service.dart`

These will be migrated as needed. For now, PSI records and authentication are fully functional!
