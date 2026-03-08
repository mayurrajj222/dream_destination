-- DELETE OLD Trip 11 records with wrong dates (2020)
-- These are preventing the new records from showing

-- Step 1: Check how many old records exist
SELECT 
    COUNT(*) as old_records,
    MIN(date) as earliest_date,
    MAX(date) as latest_date
FROM psi_records
WHERE trip_id = '11' 
  AND date < '2025-01-01';

-- Step 2: DELETE all old Trip 11 records with dates before 2025
DELETE FROM psi_records
WHERE trip_id = '11' 
  AND date < '2025-01-01';

-- Step 3: Verify only new records remain
SELECT 
    trip_id,
    train_no,
    date,
    COUNT(*) as record_count
FROM psi_records
WHERE trip_id = '11'
GROUP BY trip_id, train_no, date
ORDER BY date, train_no;

-- Expected result: Only records with dates in 2025 should remain
