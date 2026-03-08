# Fix: Trip 11 Not Showing in Dropdown

## Problem
Trip 11 (Ritik Ranjan Excel) was imported successfully with 64 records for Train 15228 with date 2025-06-09, but it doesn't appear in the trips dropdown.

## Root Cause
There are likely OLD records for Trip 11 in the database with WRONG dates (2020) from previous imports. These old records are interfering with the trip loading logic.

## Evidence from Logs
```
✓ Saved: Kundan Kumar 
Loading trains...
Loaded 8 trains
_loadTripsForTrain: Loading trips for train ID: 87909ecb-c765-4025-b0cc-f69cf592e180
_loadTripsForTrain: Selected train: 15228
_loadTripsForTrain: Total PSI records fetched: 1000
_loadTripsForTrain: Records for this train: 126
_loadTripsForTrain: Unique trips found: 5
_loadTripsForTrain: Trips loaded successfully. Available trips: 6
```

The system found 126 records for Train 15228 but only 5 unique trips. Trip 11 is NOT among them.

## Solution Steps

### Step 1: Check Database for Old Records
Run this SQL in Supabase SQL Editor:

```sql
-- Check all Trip 11 records
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
```

### Step 2: Delete Old Records with Wrong Dates
If you see records with dates before 2025, delete them:

```sql
-- Delete old Trip 11 records with wrong dates
DELETE FROM psi_records 
WHERE trip_id = '11' 
  AND date < '2025-01-01';
```

### Step 3: Re-import Ritik Ranjan Excel
1. Open the app in Edge browser
2. Go to "Tripwise PSI Reports"
3. Click "Import Excel"
4. Select the Ritik Ranjan Excel file
5. Wait for import to complete

### Step 4: Verify Trip 11 Appears
1. Train 15228 should be auto-selected
2. Click the "Select Trips" dropdown
3. You should now see: `11 | 2025-06-09 | 15228 | [EHK Name]`
4. Select Trip 11 and click "Show"
5. All 64 passenger records should display

## Alternative: Check Date Range Filter
If Trip 11 still doesn't show after cleanup, the issue might be with the date range filter in `_loadPSIData`:

The current code uses `_fromDate` and `_toDate` which default to today's date. If Trip 11 has date 2025-06-09 but today is 2025-03-08, it won't show.

**Solution**: Set the date range to include Trip 11's date:
- From Date: 2025-01-01 (or earlier)
- To Date: 2025-12-31 (or later)

## Technical Details

### Date Parsing (Fixed)
The date parser now correctly handles DD-MM-YYYY format:
- Excel shows: "09-06-2025"
- Parsed as: DateTime(2025, 6, 9)
- Validates year >= 2000

### Trip Loading Logic
`_loadTripsForTrain` method:
1. Fetches ALL records with date range 2020-2030
2. Filters by selected train number
3. Groups by `tripId + ehkName` to create unique trips
4. Creates display strings: "TripID | Date | TrainNo | EHK Name"

### Why Trip 11 Might Not Show
1. **Old records with wrong dates**: Previous imports saved Trip 11 with date 2020-06-13 instead of 2025-06-09
2. **Date range filter**: The `_loadPSIData` method filters by `_fromDate` and `_toDate` which might exclude Trip 11
3. **Duplicate trip IDs**: Multiple trips with same ID but different dates/trains causing grouping issues

## Verification SQL
After cleanup, verify Trip 11 is correct:

```sql
SELECT 
    COUNT(*) as total_records,
    train_no,
    date,
    ehk_name
FROM psi_records
WHERE trip_id = '11'
GROUP BY train_no, date, ehk_name
ORDER BY train_no, date;
```

Expected result:
- 64 records for Train 15228
- Date: 2025-06-09
- EHK Name: [from Excel]

## Next Steps
1. Run the SQL queries in `DEBUG_TRIP_11_ISSUE.sql`
2. Delete old records if found
3. Re-import Ritik Ranjan Excel
4. Verify Trip 11 appears in dropdown
5. Test clicking "Show" to display all records
