-- IMMEDIATE FIX: Update Trip 11 records to have BOTH train numbers
-- This will make Trip 11 appear when selecting Train 15228

-- Step 1: Check current state
SELECT 
    trip_id,
    train_no,
    COUNT(*) as record_count,
    MIN(date) as earliest_date,
    MAX(date) as latest_date
FROM psi_records
WHERE trip_id = '11'
GROUP BY trip_id, train_no
ORDER BY train_no;

-- Step 2: Update records with date 09-06-2025 and 10-06-2025 to use Train 15228
-- (These are the going journey records)
UPDATE psi_records
SET train_no = '15228'
WHERE trip_id = '11' 
  AND train_no = '15227'
  AND date IN ('2025-06-09', '2025-06-10');

-- Step 3: Keep records with date 12-06-2025 and 13-06-2025 as Train 15227
-- (These are the return journey records - no update needed)

-- Step 4: Verify the result
SELECT 
    trip_id,
    train_no,
    date,
    COUNT(*) as record_count
FROM psi_records
WHERE trip_id = '11'
GROUP BY trip_id, train_no, date
ORDER BY date, train_no;

-- Expected result:
-- Trip 11 should now have:
-- - Train 15228 records for dates 09-06-2025 and 10-06-2025
-- - Train 15227 records for dates 12-06-2025 and 13-06-2025
