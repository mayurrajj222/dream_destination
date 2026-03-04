-- ============================================
-- Fix PSI Import Database Issues
-- ============================================
-- This script fixes the database schema issues preventing Excel imports
-- Run this in your Supabase SQL Editor

-- 1. Add missing company_name column
-- ============================================
ALTER TABLE psi_records 
ADD COLUMN IF NOT EXISTS company_name TEXT;

COMMENT ON COLUMN psi_records.company_name IS 'Company or business name associated with the PSI record (e.g., R. N. INDUSTRIES)';

-- 2. Make train_id nullable (recommended)
-- ============================================
-- This allows records to be imported even if train lookup fails temporarily
-- The import process will still validate and create trains, but this prevents hard failures

ALTER TABLE psi_records 
ALTER COLUMN train_id DROP NOT NULL;

-- 3. Verify the changes
-- ============================================
-- Run this to confirm the changes were applied:

SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'psi_records' 
    AND column_name IN ('company_name', 'train_id')
ORDER BY column_name;

-- Expected output:
-- company_name | text | YES | NULL
-- train_id     | text | YES | NULL  (or uuid | YES | NULL)

-- 4. Optional: Add index for company_name for better query performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_psi_records_company_name 
ON psi_records(company_name) 
WHERE company_name IS NOT NULL;

-- ============================================
-- Verification Queries
-- ============================================

-- Check if any existing records have NULL train_id
SELECT COUNT(*) as records_with_null_train_id
FROM psi_records
WHERE train_id IS NULL;

-- Check if company_name column exists and has data
SELECT 
    COUNT(*) as total_records,
    COUNT(company_name) as records_with_company_name,
    COUNT(*) - COUNT(company_name) as records_without_company_name
FROM psi_records;

-- ============================================
-- Notes
-- ============================================
-- After running this script:
-- 1. The company_name field will be available for storing company information
-- 2. The train_id field will be nullable, preventing import failures
-- 3. Existing records are not affected
-- 4. You can now retry the Excel import

-- If you prefer to keep train_id as NOT NULL:
-- Comment out step 2 above and ensure your import process
-- always successfully creates trains before importing records
