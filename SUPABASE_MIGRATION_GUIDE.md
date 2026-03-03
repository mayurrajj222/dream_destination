# Firebase to Supabase Migration Guide

## Overview
Migrating from Firebase to Supabase due to storage limitations.

## Supabase Configuration
- **Project URL**: https://iciposutxzqepxglghck.supabase.co
- **Anon Key**: Stored in `lib/config/supabase_config.dart`

## Migration Steps

### 1. Dependencies Updated ✅
- Removed: `firebase_core`, `firebase_auth`, `cloud_firestore`
- Added: `supabase_flutter: ^2.9.1`

### 2. Database Schema Setup (Required in Supabase Dashboard)

You need to create these tables in Supabase:

#### `psi_records` table
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

-- Policy: Users can insert their own records
CREATE POLICY "Users can insert own psi_records"
  ON psi_records FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own records
CREATE POLICY "Users can update own psi_records"
  ON psi_records FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users can delete their own records
CREATE POLICY "Users can delete own psi_records"
  ON psi_records FOR DELETE
  USING (auth.uid() = user_id);
```

#### `trains` table
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

-- Enable RLS
ALTER TABLE trains ENABLE ROW LEVEL SECURITY;

-- Policies for trains
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

### 3. Authentication Setup

Supabase uses email/password authentication by default. The custom login (customerId + userId) will be converted to email format:
- Format: `{customerId}_{userId}@dreamdestination.com`
- Example: `CUST001_USER123@dreamdestination.com`

### 4. Files to Update

The following service files need to be rewritten for Supabase:
- ✅ `lib/services/auth_service.dart` - Authentication
- ⏳ `lib/services/psi_service.dart` - PSI records CRUD
- ⏳ `lib/services/train_service.dart` - Train CRUD
- ⏳ `lib/services/schedule_service.dart` - Schedule CRUD
- ⏳ `lib/services/employee_service.dart` - Employee CRUD
- ⏳ `lib/services/attendance_service.dart` - Attendance CRUD

### 5. Key Differences

| Feature | Firebase | Supabase |
|---------|----------|----------|
| Database | Firestore (NoSQL) | PostgreSQL (SQL) |
| Auth | Firebase Auth | Supabase Auth (built on PostgreSQL) |
| Real-time | Firestore listeners | PostgreSQL real-time subscriptions |
| Security | Security Rules | Row Level Security (RLS) |
| Queries | Collection queries | SQL queries |
| IDs | Auto-generated strings | UUIDs |

### 6. Benefits of Supabase

- ✅ More storage space
- ✅ SQL database (more powerful queries)
- ✅ Built-in Row Level Security
- ✅ Open source
- ✅ Better pricing for your use case

## Next Steps

1. Run SQL scripts in Supabase Dashboard to create tables
2. Update all service files to use Supabase
3. Test authentication
4. Test data operations
5. Migrate existing data (if needed)
