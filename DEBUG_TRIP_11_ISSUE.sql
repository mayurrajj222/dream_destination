-- Debug Trip 11 Issue
-- This SQL will help identify why Trip 11 is not showing in the dropdown

-- 1. Check all Trip 11 records in the database
SELECT 
    id,
    trip_id,
    train_no,
    date,
    ehk_name,
    passenger_name,
    created_at
FROM psi_records
WHERE trip_id = '11'
ORDER BY train_no, date;

-- 2. Check if there are old Trip 11 records with wrong dates (before 2025)
SELECT 
    COUNT(*) as old_records_count,
    train_no,
    MIN(date) as earliest_date,
    MAX(date) as latest_date
FROM psi_records
WHERE trip_id = '11'
GROUP BY train_no;

-- 3. Delete old Trip 11 records with wrong dates (before 2025-01-01)
-- IMPORTANT: Run this to clean up old records with wrong dates
DELETE FROM psi_records 
WHERE trip_id = '11' 
  AND date < '2025-01-01';

-- 4. Verify Trip 11 records after cleanup
SELECT 
    COUNT(*) as total_records,
    train_no,
    date,
    ehk_name
FROM psi_records
WHERE trip_id = '11'
GROUP BY train_no, date, ehk_name
ORDER BY train_no, date;

-- 5. Check all trips for Train 15228 to see what's available
SELECT DISTINCT
    trip_id,
    date,
    train_no,
    ehk_name,
    COUNT(*) as record_count
FROM psi_records
WHERE train_no = '15228'
GROUP BY trip_id, date, train_no, ehk_name
ORDER BY date DESC;
