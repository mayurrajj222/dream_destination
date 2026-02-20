# Schedule Management System Documentation

## Overview

The schedule management system stores train schedules in Firestore under the collection name `schedules`. It allows creating, viewing, and managing train schedules with date ranges.

## Database Structure

### Collection: `schedules`

Each schedule document contains the following fields:

| Field Name | Type | Required | Description |
|------------|------|----------|-------------|
| `trainId` | String | Yes | Reference to train document ID |
| `trainNo` | String | Yes | Train number (for display) |
| `trainName` | String | Yes | Train name (for display) |
| `fromDate` | Timestamp | Yes | Schedule start date |
| `toDate` | Timestamp | Yes | Schedule end date |
| `createdAt` | Timestamp | Auto | Document creation timestamp |
| `updatedAt` | Timestamp | Auto | Last update timestamp |

## Features Implemented

### 1. Schedule Model (`lib/models/schedule_model.dart`)
- Data model for schedule information
- Methods for Firestore conversion
- Helper methods:
  - `getDateRange()` - Returns formatted date range string
  - `getDurationInDays()` - Calculates schedule duration
- Copy method for updates

### 2. Schedule Service (`lib/services/schedule_service.dart`)
Complete CRUD operations with smart features:

- `createSchedule()` - Add new schedule with overlap detection
- `getScheduleById()` - Get schedule by document ID
- `getAllSchedules()` - Get all schedules
- `getSchedulesByTrain()` - Filter by train
- `getActiveSchedules()` - Get currently active schedules
- `getUpcomingSchedules()` - Get future schedules
- `updateSchedule()` - Update schedule information
- `deleteSchedule()` - Remove schedule
- `searchSchedules()` - Search by train number or name
- `getSchedulesStream()` - Real-time updates
- `getTotalScheduleCount()` - Count all schedules

### 3. Schedule Creation Screen (`lib/screens/schedule_creation_screen.dart`)
Clean and simple interface:
- Train selection dropdown (populated from trains database)
- From Date picker (calendar interface)
- To Date picker (calendar interface)
- Date validation (To Date must be after From Date)
- Overlap detection (prevents double-booking trains)
- Form validation
- Loading states
- Success/error notifications

### 4. Schedule Details Screen (`lib/screens/schedule_details_screen.dart`)
Comprehensive view with tabs:
- Three tabs: All, Active, Upcoming
- Card-based list view
- Status badges (Active/Upcoming/Completed)
- Date range display
- Duration calculation
- Delete functionality
- Create schedule button in app bar
- Pull to refresh
- Empty state handling

## Usage

### From Home Screen
After logging in, click the "Schedule Management" button (orange) to access the schedule system.

### Creating a Schedule

1. Click "Create Schedule" button in the app bar
2. Select a train from the dropdown
   - Shows train number and name
   - Example: "12557 - SAPT KRANTI EXP"
3. Select From Date
   - Click the date field
   - Choose date from calendar
   - Cannot select past dates
4. Select To Date
   - Click the date field
   - Choose date from calendar
   - Must be same or after From Date
5. Click "Creation" button
6. System validates:
   - Train is selected
   - Both dates are selected
   - No overlapping schedules exist
7. Schedule is created and you return to details screen

### Viewing Schedules

The Schedule Details screen has three tabs:

#### All Tab
- Shows all schedules (past, present, future)
- Sorted by From Date (newest first)

#### Active Tab
- Shows only currently active schedules
- Today's date falls within the date range

#### Upcoming Tab
- Shows future schedules
- From Date is after today

### Schedule Card Information

Each schedule card displays:
- Train name and number
- Status badge (color-coded):
  - Green: Active (currently running)
  - Blue: Upcoming (starts in future)
  - Grey: Completed (ended)
- From Date and To Date
- Duration in days
- Delete button

### Deleting a Schedule

1. Find the schedule in any tab
2. Click "Delete" button on the card
3. Confirm deletion in the dialog
4. Schedule is removed from database

## Schedule Status Logic

### Active
- Current date is between From Date and To Date (inclusive)
- Example: Today is 15/02/2026, schedule is 10/02/2026 to 20/02/2026

### Upcoming
- From Date is in the future
- Example: Today is 15/02/2026, schedule starts 20/02/2026

### Completed
- To Date is in the past
- Example: Today is 15/02/2026, schedule ended 10/02/2026

## Overlap Detection

The system prevents creating overlapping schedules for the same train:

### Example of Overlap
```
Existing Schedule: 01/03/2026 to 10/03/2026
New Schedule: 05/03/2026 to 15/03/2026
Result: REJECTED (overlaps on 05-10 March)
```

### Example of No Overlap
```
Existing Schedule: 01/03/2026 to 10/03/2026
New Schedule: 11/03/2026 to 20/03/2026
Result: ACCEPTED (no overlap)
```

## Date Format

All dates are displayed in DD/MM/YYYY format:
- 16/02/2026 - 16th February 2026
- 01/01/2026 - 1st January 2026
- 31/12/2026 - 31st December 2026

## UI Features

### Schedule Creation Screen
- Clean, minimal design
- Red title "Schedule Creation"
- White input fields with grey borders
- Calendar icon for date pickers
- Green "Creation" button
- Loading spinner during submission
- Validation messages

### Schedule Details Screen
- Blue app bar with tabs
- White "Create Schedule" button in app bar
- Card-based layout with shadows
- Color-coded status badges
- Calendar icon for duration
- Red delete button
- Pull-to-refresh support
- Empty state with icon and message

## Firestore Rules (For Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /schedules/{scheduleId} {
      // Only authenticated users can read
      allow read: if request.auth != null;
      
      // Only authenticated users can create/update/delete
      allow create, update, delete: if request.auth != null;
      
      // Validate dates
      allow create, update: if request.resource.data.fromDate <= request.resource.data.toDate;
    }
  }
}
```

## API Examples

### Create Schedule
```dart
final schedule = Schedule(
  trainId: 'train_doc_id',
  trainNo: '12557',
  trainName: 'SAPT KRANTI EXP',
  fromDate: DateTime(2026, 3, 1),
  toDate: DateTime(2026, 3, 10),
  createdAt: DateTime.now(),
);

final result = await scheduleService.createSchedule(schedule);
```

### Get All Schedules
```dart
List<Schedule> schedules = await scheduleService.getAllSchedules();
```

### Get Active Schedules
```dart
List<Schedule> active = await scheduleService.getActiveSchedules();
```

### Get Upcoming Schedules
```dart
List<Schedule> upcoming = await scheduleService.getUpcomingSchedules();
```

### Delete Schedule
```dart
await scheduleService.deleteSchedule(scheduleId);
```

## Integration with Train Management

- Schedule creation requires existing trains
- Train dropdown is populated from trains database
- Stores train ID for reference
- Stores train number and name for display
- If a train is deleted, its schedules remain (orphaned)
- Consider adding cascade delete in production

## Best Practices

### Creating Schedules
1. Create trains first before creating schedules
2. Plan schedules in advance
3. Avoid overlapping dates for same train
4. Use reasonable date ranges
5. Review active schedules regularly

### Managing Schedules
1. Check Active tab for current operations
2. Use Upcoming tab for planning
3. Delete completed schedules periodically
4. Monitor for conflicts
5. Keep train information updated

## Common Use Cases

### Daily Operations
1. Check Active tab to see today's running trains
2. Verify schedules are correct
3. Handle any conflicts

### Planning
1. Check Upcoming tab for future schedules
2. Create new schedules for next month
3. Ensure no gaps in coverage

### Maintenance
1. Review All tab periodically
2. Delete old completed schedules
3. Update schedules if train details change

## Error Messages

### "Schedule overlaps with existing schedule for this train"
- Another schedule exists for this train with overlapping dates
- Check existing schedules for this train
- Adjust dates to avoid overlap

### "Please select a tra