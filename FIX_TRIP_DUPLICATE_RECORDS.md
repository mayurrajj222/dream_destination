# Fix: Trip Showing Duplicate Records (90 instead of 42)

## Problem
Trip ID "2" was showing 90 records instead of the expected 42 records from the Excel import. This happened because:
1. Trip IDs are being reused across multiple different imports
2. The same Trip ID "2" exists in the database from different import sessions
3. Previous filtering logic couldn't distinguish between different imports with the same Trip ID

## Root Cause
When users import Excel files, they often reuse Trip IDs (like "2", "5", etc.) for different trips. Without a way to track which import session each record came from, the app would show ALL records with that Trip ID, even if they were from completely different imports on different dates.

## Solution Implemented

### 1. Added `import_batch_id` Field
- Added a new `import_batch_id` field to the PSIRecord model
- This field stores a unique identifier for each import session
- Format: `batch_<timestamp>` (e.g., `batch_1710432000000`)
- This allows the app to distinguish between records from different imports

### 2. Updated Excel Import Service
- Modified `excel_import_service.dart` to generate a unique `import_batch_id` for each import
- All records imported in the same session get the same `import_batch_id`
- This creates a permanent link between records from the same import

### 3. Enhanced Filtering Logic
The app now uses a smart 3-tier filtering approach:

**Tier 1 (Best):** If `import_batch_id` is available (new imports)
- Filter by: Trip ID + EHK Name + import_batch_id
- This gives 100% accurate results

**Tier 2 (Good):** If `import_batch_id` is not available (old records)
- Filter by: Trip ID + EHK Name + Date (±2 days)
- This works for most cases where imports are separated by time

**Tier 3 (Fallback):** If date parsing fails
- Filter by: Trip ID + EHK Name only
- May show more records than expected if multiple imports exist

### 4. Updated Trip Display
- Trip dropdown now groups by: Trip ID + EHK Name + import_batch_id
- This ensures each import session appears as a separate trip option
- Old records (without batch ID) are grouped by date instead

## Files Modified

1. `lib/models/psi_record_model.dart`
   - Added `importBatchId` field
   - Updated constructor, toMap(), fromMap(), and copyWith()

2. `lib/services/excel_import_service.dart`
   - Generate unique `import_batch_id` for each import session
   - Assign batch ID to all records during import

3. `lib/screens/tripwise_psi_report_screen.dart`
   - Updated `_loadTripsForTrain()` to group by batch ID
   - Updated `_loadPSIData()` to filter using batch ID when available
   - Added fallback logic for old records without batch ID

4. `ADD_IMPORT_BATCH_ID_COLUMN.sql` (NEW)
   - SQL script to add the column to Supabase database

## Database Migration Required

Run this SQL in Supabase SQL Editor:

```sql
-- Add import_batch_id column to psi_records table
ALTER TABLE psi_records 
ADD COLUMN IF NOT EXISTS import_batch_id TEXT;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_psi_records_import_batch_id 
ON psi_records(import_batch_id);

CREATE INDEX IF NOT EXISTS idx_psi_records_trip_batch 
ON psi_records(trip_id, import_batch_id);
```

## Testing

1. Run the SQL migration in Supabase
2. Import a new Excel file with Trip ID "2"
3. Verify that only the 42 records from the new import are shown
4. Old records with Trip ID "2" should appear as separate trip options in the dropdown

## Benefits

1. **Accurate Record Counts:** Each import session is tracked separately
2. **No Data Loss:** Old records without batch ID still work with fallback logic
3. **Better Organization:** Users can see which records came from which import
4. **Future-Proof:** All new imports will have batch IDs automatically

## Backward Compatibility

- Old records without `import_batch_id` will continue to work
- Fallback logic uses date-based filtering for old records
- No data migration needed for existing records
- New imports automatically get batch IDs

## Notes

- The `import_batch_id` is generated using timestamp: `batch_<milliseconds>`
- This ensures uniqueness even if multiple imports happen quickly
- The batch ID is set during import and never changes
- Users don't need to manually enter or manage batch IDs
