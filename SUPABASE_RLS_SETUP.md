# Supabase Row Level Security (RLS) Setup

Your project is active! Now you need to configure Row Level Security policies (similar to Firebase security rules).

## What is RLS?

Row Level Security (RLS) is Supabase's way of controlling data access - similar to Firebase Security Rules. It ensures:
- Users can only see their own data
- Authenticated users can create/read/update/delete their records
- Unauthenticated users cannot access data

## Step 1: Check Your Tables

In your Supabase dashboard, I can see you have **3 tables**. Let's verify which tables exist:

1. Go to **Table Editor** (left sidebar)
2. Check if you have these tables:
   - `psi_records` ✓ (needed for PSI functionality)
   - `trains` (optional, for future use)
   - Any other tables?

## Step 2: Enable RLS on PSI Records Table

### Option A: Using SQL Editor (Recommended)

1. Go to **SQL Editor** in the left sidebar
2. Click **New Query**
3. Copy and paste this SQL:

```sql
-- Enable RLS on psi_records table
ALTER TABLE psi_records ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any (to avoid conflicts)
DROP POLICY IF EXISTS "Users can manage their own PSI records" ON psi_records;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON psi_records;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON psi_records;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON psi_records;
DROP POLICY IF EXISTS "Enable delete for users based on user_id" ON psi_records;

-- Create comprehensive policies for user-specific access
CREATE POLICY "Users can read their own PSI records"
  ON psi_records
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own PSI records"
  ON psi_records
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own PSI records"
  ON psi_records
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own PSI records"
  ON psi_records
  FOR DELETE
  USING (auth.uid() = user_id);
```

4. Click **Run** (or press Ctrl+Enter)
5. You should see "Success. No rows returned"

### Option B: Using Authentication → Policies UI

1. Go to **Authentication** → **Policies** in the left sidebar
2. Find the `psi_records` table
3. Click **Enable RLS** if not already enabled
4. Click **New Policy**
5. Choose **For full customization**
6. Create 4 policies (one for each operation):

**Policy 1: SELECT (Read)**
- Policy name: `Users can read their own PSI records`
- Target roles: `authenticated`
- USING expression: `auth.uid() = user_id`

**Policy 2: INSERT (Create)**
- Policy name: `Users can insert their own PSI records`
- Target roles: `authenticated`
- WITH CHECK expression: `auth.uid() = user_id`

**Policy 3: UPDATE (Edit)**
- Policy name: `Users can update their own PSI records`
- Target roles: `authenticated`
- USING expression: `auth.uid() = user_id`
- WITH CHECK expression: `auth.uid() = user_id`

**Policy 4: DELETE (Remove)**
- Policy name: `Users can delete their own PSI records`
- Target roles: `authenticated`
- USING expression: `auth.uid() = user_id`

## Step 3: Verify Table Structure

Make sure your `psi_records` table has all required columns:

1. Go to **Table Editor** → **psi_records**
2. Check if these columns exist:

```
id                  uuid (primary key)
user_id             uuid (references auth.users)
train_id            text
train_no            text
train_name          text
schedule_id         text
trip_id             text
date                timestamptz
passenger_name      text
pnr_no              text
mobile_no           text
coach               text
seat_no             text
psi_score           float8 (double precision)
feedback            text (nullable)
trip_type           text
ehk_name            text
service1_rating     text (nullable)
service2_rating     text (nullable)
service3_rating     text (nullable)
service4_rating     text (nullable)
service5_rating     text (nullable)
created_at          timestamptz
updated_at          timestamptz
```

### If Table Doesn't Exist or Missing Columns:

Run this SQL in **SQL Editor**:

```sql
-- Create psi_records table
CREATE TABLE IF NOT EXISTS psi_records (
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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_psi_records_user_id ON psi_records(user_id);
CREATE INDEX IF NOT EXISTS idx_psi_records_trip_id ON psi_records(trip_id);
CREATE INDEX IF NOT EXISTS idx_psi_records_date ON psi_records(date);
```

## Step 4: Configure Email Authentication

Make sure email authentication is enabled:

1. Go to **Authentication** → **Providers**
2. Find **Email** provider
3. Make sure it's **Enabled**
4. Settings to check:
   - ✅ Enable email provider
   - ✅ Confirm email (optional - can disable for testing)
   - ✅ Enable email confirmations (optional)

For testing, you can disable email confirmation:
- Uncheck "Confirm email"
- This allows immediate signup without email verification

## Step 5: Test the Connection

Now test if your app can connect:

1. Make sure your app is still running (or restart it):
   ```bash
   flutter run -d edge
   ```

2. Try to sign up with a test account:
   - Email: `test@example.com`
   - Password: `Test123456!`

3. Check for errors in:
   - Browser console (F12)
   - Flutter terminal output
   - Supabase Dashboard → Logs

## Step 6: Verify RLS is Working

After signing up successfully:

1. Go to **Table Editor** → **psi_records**
2. You should see any records you create
3. Each record should have `user_id` matching your auth user

To verify RLS:
1. Go to **Authentication** → **Users**
2. Copy your user's UUID
3. Go to **Table Editor** → **psi_records**
4. Check that records have matching `user_id`

## Common Issues & Solutions

### Issue 1: "new row violates row-level security policy"
**Solution:** Make sure the INSERT policy WITH CHECK uses `auth.uid() = user_id`

### Issue 2: "permission denied for table psi_records"
**Solution:** RLS is enabled but no policies exist. Create the policies above.

### Issue 3: "null value in column user_id violates not-null constraint"
**Solution:** The app isn't setting user_id. Check that `PSIService` is using `currentUserId`.

### Issue 4: Can't see any data after creating records
**Solution:** SELECT policy might be wrong. Verify USING clause is `auth.uid() = user_id`

## Comparison with Firebase Rules

If you're familiar with Firebase, here's how they compare:

**Firebase Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /psi_records/{record} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.userId;
    }
  }
}
```

**Supabase RLS (equivalent):**
```sql
-- Read policy
CREATE POLICY "Users can read own records"
  ON psi_records FOR SELECT
  USING (auth.uid() = user_id);

-- Write policy  
CREATE POLICY "Users can write own records"
  ON psi_records FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

## Next Steps

Once RLS is configured:

1. ✅ Sign up works
2. ✅ Login works
3. ✅ Can create PSI records
4. ✅ Can view only your own records
5. ✅ Cannot see other users' data

Then you can:
- Import Excel files with PSI data
- Create manual PSI records
- Generate reports
- All data will be user-specific and secure!

## Need Help?

If you encounter issues:
1. Check **Supabase Dashboard → Logs** for detailed errors
2. Check browser console (F12) for client-side errors
3. Verify your policies in **Authentication → Policies**
4. Test with SQL Editor to see if you can query the table directly
