-- Check what's actually in the database for Trip 11
-- Run this in Supabase SQL Editor

-- 1. Check if Trip 11 records exist at all
SELECT COUNT(*) as total_trip_11_records
FROM psi_records
WHERE trip_id = '11';

-- 2. Check what train numbers Trip 11 has
SELECT DISTINCT
    train_no,
    COUNT(*) as record_count,
    MIN(date) as earliest_date,
    MAX(date) as latest_date,
    ehk_name
FROM psi_records
WHERE trip_id = '11'
GROUP BY train_no, ehk_name
ORDER BY train_no;

-- 3. Check the most recent Trip 11 records (last 10)
SELECT 
    id,
    trip_id,
    train_no,
    train_id,
    date,
    ehk_name,
    passenger_name,
    created_at
FROM psi_records
WHERE trip_id = '11'
ORDER BY created_at DESC
LIMIT 10;

-- 4. Check if train_no is NULL or empty
SELECT 
    COUNT(*) as records_with_null_or_empty_train_no
FROM psi_records
WHERE trip_id = '11' 
  AND (train_no IS NULL OR train_no = '');

-- 5. Check all records created in the last 5 minutes (recent import)
SELECT 
    trip_id,
    train_no,
    ehk_name,
    passenger_name,
    date,
    created_at
FROM psi_records
WHERE created_at > NOW() - INTERVAL '5 minutes'
ORDER BY created_at DESC
LIMIT 20;
