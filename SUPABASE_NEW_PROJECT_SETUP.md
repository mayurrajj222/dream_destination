# Setting Up a New Supabase Project

If your current Supabase project is not accessible, follow these steps to create a new one:

## Step 1: Create New Project

1. Go to https://supabase.com/dashboard
2. Click "New Project"
3. Fill in:
   - **Name:** Dream Destination (or any name)
   - **Database Password:** Choose a strong password (save it!)
   - **Region:** Choose closest to you
4. Click "Create new project"
5. Wait 2-3 minutes for setup to complete

## Step 2: Get Your Credentials

Once the project is created:

1. Go to **Settings** → **API**
2. Copy these values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJhbGc...`)

## Step 3: Update Your App Configuration

Update `lib/config/supabase_config.dart` with your new credentials:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_NEW_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_NEW_ANON_KEY';
}
```

## Step 4: Create Database Tables

Go to **SQL Editor** in Supabase dashboard and run this SQL:

### PSI Records Table

```sql
-- Create PSI records table
CREATE TABLE psi_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  train_id TEXT NOT NULL,
  train_no TEXT NOT NULL,
  train_name TEXT NOT NULL,
  schedule_id TEXT,
  trip_id TEXT NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  passenger_name TEXT NOT NULL,
  pnr_no TEXT NOT NULL,
  mobile_no TEXT NOT NULL,
  coach TEXT NOT NULL,
  seat_no TEXT NOT NULL,
  psi_score DOUBLE PRECISION NOT NULL,
  feedback TEXT,
  trip_type TEXT NOT NULL,
  ehk_name TEXT NOT NULL,
  service1_rating TEXT,
  service2_rating TEXT,
  service3_rating TEXT,
  service4_rating TEXT,
  service5_rating TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE psi_records ENABLE ROW LEVEL SECURITY;

-- Create policy for user-specific access
CREATE POLICY "Users can manage their own PSI records"
  ON psi_records
  FOR ALL
  USING (auth.uid() = user_id);

-- Create index for better query performance
CREATE INDEX idx_psi_records_user_id ON psi_records(user_id);
CREATE INDEX idx_psi_records_trip_id ON psi_records(trip_id);
CREATE INDEX idx_psi_records_date ON psi_records(date);
```

### Trains Table (Optional - for future use)

```sql
CREATE TABLE trains (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  train_no_going TEXT NOT NULL,
  train_name_going TEXT NOT NULL,
  station_from TEXT NOT NULL,
  station_to TEXT NOT NULL,
  total_janitor INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE trains ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own trains"
  ON trains
  FOR ALL
  USING (auth.uid() = user_id);
```

## Step 5: Test the Connection

1. Save all changes
2. Stop the running app (press `q` in the terminal)
3. Run: `flutter run -d edge`
4. Try to sign up with a new account

## Troubleshooting

### If you still get connection errors:

1. **Check Firewall/Antivirus:**
   - Temporarily disable firewall
   - Try from a different network

2. **Verify Project Status:**
   - Make sure project shows "Active" in dashboard
   - Check project health in Settings → General

3. **Test API Directly:**
   - Open browser
   - Go to: `https://YOUR_PROJECT_URL/rest/v1/`
   - Should see a response (not an error page)

### If signup works but data doesn't save:

1. **Check RLS Policies:**
   - Go to Authentication → Policies
   - Make sure policies are enabled for psi_records table

2. **Check Table Structure:**
   - Go to Table Editor
   - Verify psi_records table exists with all columns

## Need Help?

If you're still having issues:
1. Check the browser console for specific error messages
2. Check Supabase logs in Dashboard → Logs
3. Verify your internet connection allows HTTPS to *.supabase.co
