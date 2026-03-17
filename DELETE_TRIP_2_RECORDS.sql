-- Delete all PSI records for Trip ID 2
-- Run this in Supabase SQL Editor before re-importing trip 2

DELETE FROM psi_records
WHERE trip_id = '2';

-- Verify deletion
SELECT COUNT(*) FROM psi_records WHERE trip_id = '2';
