-- Add import_batch_id column to psi_records table
-- This column will help track which import session each record came from
-- Run this in Supabase SQL Editor

-- Add the column (nullable for existing records)
ALTER TABLE psi_records 
ADD COLUMN IF NOT EXISTS import_batch_id TEXT;

-- Create an index for better query performance
CREATE INDEX IF NOT EXISTS idx_psi_records_import_batch_id 
ON psi_records(import_batch_id);

-- Optional: Create a composite index for common queries
CREATE INDEX IF NOT EXISTS idx_psi_records_trip_batch 
ON psi_records(trip_id, import_batch_id);

-- Verify the column was added
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'psi_records' 
AND column_name = 'import_batch_id';
