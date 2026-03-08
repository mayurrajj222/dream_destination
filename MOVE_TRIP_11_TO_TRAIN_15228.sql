-- Move Trip 11 from Train 15227 to Train 15228
-- Run this in Supabase SQL Editor

-- First, check current state
SELECT 
    COUNT(*) as record_count,
    train_no,
    ehk_name
FROM psi_records
WHERE trip_id = '11'
GROUP BY train_no, ehk_name;

-- Update Trip 11 records to use Train 15228 instead of 15227
UPDATE psi_records
SET train_no = '15228',
    train_id = '87909ecb-c765-4025-b0cc-f69cf592e180'  -- This is the ID for Train 15228
WHERE trip_id = '11' 
  AND train_no = '15227';

-- Verify the update
SELECT 
    COUNT(*) as record_count,
    train_no,
    ehk_name
FROM psi_records
WHERE trip_id = '11'
GROUP BY train_no, ehk_name;

-- Check a few sample records
SELECT 
    trip_id,
    train_no,
    train_id,
    ehk_name,
    passenger_name,
    date
FROM psi_records
WHERE trip_id = '11'
LIMIT 10;
