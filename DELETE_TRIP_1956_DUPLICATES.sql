-- Delete Trip 1956 duplicate records (uploaded 3 times)
-- Run this in Supabase SQL Editor

-- Step 1: Check how many Trip 1956 records exist
SELECT 
    COUNT(*) as total_records,
    train_no,
    ehk_name,
    MIN(created_at) as first_import,
    MAX(created_at) as last_import
FROM psi_records
WHERE trip_id = '1956'
GROUP BY train_no, ehk_name;

-- Step 2: Check all Trip 1956 records with details
SELECT 
    id,
    trip_id,
    train_no,
    ehk_name,
    passenger_name,
    date,
    created_at
FROM psi_records
WHERE trip_id = '1956'
ORDER BY created_at DESC, train_no;

-- Step 3: DELETE all Trip 1956 records
DELETE FROM psi_records
WHERE trip_id = '1956';

-- Step 4: Verify deletion
SELECT COUNT(*) as remaining_trip_1956_records
FROM psi_records
WHERE trip_id = '1956';

-- Expected result: 0 records remaining

-- After running this SQL:
-- 1. Reload your app
-- 2. Re-import the Ranjeet Kumar Excel ONE time
-- 3. The date parser is now fixed, so it will parse dates correctly
-- 4. Trip 1956 should appear in the dropdown
