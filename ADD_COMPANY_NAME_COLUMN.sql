-- Add company_name column to psi_records table
-- This field stores the company/business name (e.g., "R. N. INDUSTRIES")

ALTER TABLE psi_records 
ADD COLUMN IF NOT EXISTS company_name TEXT;

-- Add comment to document the column
COMMENT ON COLUMN psi_records.company_name IS 'Company or business name associated with the PSI record';
