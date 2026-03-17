-- Delete all PSI records for Trip ID 60
-- Run this in Supabase SQL Editor before re-importing

DELETE FROM psi_records
WHERE trip_id = '60';

-- Verify deletion
SELECT COUNT(*) FROM psi_records WHERE trip_id = '60';
