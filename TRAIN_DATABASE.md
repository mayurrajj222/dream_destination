# Train Management System Documentation

## Overview

The train management system stores train information in Firestore under the collection name `trains`. It includes comprehensive train details for both going and coming journeys, operational days, and coach configurations.

## Database Structure

### Collection: `trains`

Each train document contains the following fields:

| Field Name | Type | Required | Description |
|------------|------|----------|-------------|
| `trainNoGoing` | String | Yes | Train number for going journey (unique) |
| `trainNameGoing` | String | Yes | Train name for going journey |
| `stationFrom` | String | Yes | Departure station |
| `stationTo` | String | Yes | Arrival station |
| `totalJanitor` | Number | Yes | Total number of janitors |
| `departureTimeGoing` | String | Yes | Departure time (HH:MM:SS format) |
| `journeyDurationGoing` | String | Yes | Journey duration (HH:MM:SS format) |
| `trainNoComing` | String | Yes | Train number for return journey |
| `trainNameComing` | String | Yes | Train name for return journey |
| `departureTimeComing` | String | Yes | Return departure time (HH:MM:SS) |
| `journeyDurationComing` | String | Yes | Return journey duration (HH:MM:SS) |

### Going On Days (Boolean fields)
- `goingOnMon` - Operates on Monday
- `goingOnTue` - Operates on Tuesday
- `goingOnWed` - Operates on Wednesday
- `goingOnThu` - Operates on Thursday
- `goingOnFri` - Operates on Friday
- `goingOnSat` - Operates on Saturday
- `goingOnSun` - Operates on Sunday

### Coming On Days (Boolean fields)
- `comingOnMon` - Returns on Monday
- `comingOnTue` - Returns on Tuesday
- `comingOnWed` - Returns on Wednesday
- `comingOnThu` - Returns on Thursday
- `comingOnFri` - Returns on Friday
- `comingOnSat` - Returns on Saturday
- `comingOnSun` - Returns on Sunday

### Coach Details (Boolean fields)
- `coachWGFACC` - WGF ACC W - H A H1 - AC 1st Tier
- `coachWGACCWA1` - WGACCW(A1) - AC 2 Tier
- `coachWGACCNB1` - WGACCN(B1) - AC 3 Tier
- `coachWGSCNSL` - WGSCN SL (SL) - Sleeper
- `coachWGCZAC` - WGCZAC(CC) - AC Chair Car
- `coachWGSCZD` - WGSCZ(D) - Chair Car
- `coachLWFCZAC` - LWFCZAC (E) - Shatabdi 2nd Tier
- `coachWGFCNAC` - WGFCNAC (HB) - Shatabdi 1st Tier
- `coachM1` - M1 Coach
- `coachCE` - CE Coach
- `coachGS` - GS - General Class

### Automatic Fields
- `createdAt` - Timestamp of creation
- `updatedAt` - Timestamp of last update

## Features Implemented

### 1. Train Model (`lib/models/train_model.dart`)
- Comprehensive data model with all train fields
- Methods for Firestore conversion
- Copy method for updates
- Support for all coach types and operational days

### 2. Train Service (`lib/services/train_service.dart`)
Complete CRUD operations:
- `createTrain()` - Add new train
- `getTrainById()` - Get train by document ID
- `getTrainByNumber()` - Get train by train number
- `getAllTrains()` - Get all trains
- `getTrainsByStation()` - Filter by station
- `updateTrain()` - Update train information
- `deleteTrain()` - Remove train
- `searchTrains()` - Search by number, name, or station
- `getTrainsStream()` - Real-time updates
- `getTotalTrainCount()` - Count all trains

### 3. Train Form Screen (`lib/screens/train_form_screen.dart`)
Comprehensive form with:
- Going train details (number, name, stations, times)
- Coming train details (return journey info)
- Day selection checkboxes for both directions
- Coach type selection (11 different coach types)
- Total janitor count
- Form validation
- Add and update modes

### 4. Train Details Screen (`lib/screens/train_details_screen.dart`)
- Card-based list view of all trains
- Going and coming train information display
- Operational days display
- Edit and delete actions
- Pull to refresh
- Add train button in app bar
- Empty state message

## Usage

### From Home Screen
After logging in, click the "Train Management" button (green) to access the train system.

### Adding a Train

1. Click "Add Train" button in the app bar
2. Fill in Going Train Details:
   - Train No. (required, unique)
   - Train Name (required)
   - Station From (required)
   - Station To (required)
   - Total Janitor (required)
   - Departure Time Going (HH:MM:SS format)
   - Journey Duration Going (HH:MM:SS format)
3. Select Going On days (Mon-Sun checkboxes)
4. Fill in Coming Train Details:
   - Train No Coming (required)
   - Train Name (required)
   - Departure Time Coming (HH:MM:SS)
   - Journey Duration Coming (HH:MM:SS)
5. Select Coming On days (Mon-Sun checkboxes)
6. Select applicable Coach Types (checkboxes)
7. Click "Submit"

### Updating a Train

1. Find the train in the list
2. Click the Edit icon (blue pencil)
3. Modify fields as needed
4. Note: Train number cannot be changed
5. Click "Submit"

### Deleting a Train

1. Find the train in the list
2. Click the Delete icon (red trash)
3. Confirm deletion in the dialog
4. Train is removed from database

### Viewing Train Details

Each train card displays:
- Train name and number
- Going route (Station From → Station To)
- Going departure time and duration
- Going operational days
- Coming train number and name
- Coming departure time and duration
- Coming operational days
- Total janitor count

## Time Format

All time fields use 24-hour format: `HH:MM:SS`

Examples:
- `09:30:00` - 9:30 AM
- `14:45:00` - 2:45 PM
- `23:59:00` - 11:59 PM

Duration examples:
- `02:30:00` - 2 hours 30 minutes
- `05:15:00` - 5 hours 15 minutes
- `12:00:00` - 12 hours

## Coach Types Reference

1. **WGF ACC W - H A H1** - AC 1st Tier (First Class AC)
2. **WGACCW(A1)** - AC 2 Tier (Second Class AC)
3. **WGACCN(B1)** - AC 3 Tier (Third Class AC)
4. **WGSCN SL (SL)** - Sleeper Class
5. **WGCZAC(CC)** - AC Chair Car
6. **WGSCZ(D)** - Chair Car (Non-AC)
7. **LWFCZAC (E)** - Shatabdi 2nd Tier
8. **WGFCNAC (HB)** - Shatabdi 1st Tier
9. **M1 Coach** - Special coach type
10. **CE Coach** - Special coach type
11. **GS** - General Class (Unreserved)

## Firestore Rules (For Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /trains/{trainId} {
      // Only authenticated users can read
      allow read: if request.auth != null;
      
      // Only authenticated users can create/update/delete
      allow create, update, delete: if request.auth != null;
      
      // Ensure trainNoGoing is unique on create
      allow create: if !exists(/databases/$(database)/documents/trains/$(request.resource.data.trainNoGoing));
    }
  }
}
```

## API Examples

### Create Train
```dart
final train = Train(
  trainNoGoing: '12345',
  trainNameGoing: 'Express Train',
  stationFrom: 'Delhi',
  stationTo: 'Mumbai',
  totalJanitor: 5,
  departureTimeGoing: '09:30:00',
  journeyDurationGoing: '16:00:00',
  trainNoComing: '12346',
  trainNameComing: 'Express Return',
  departureTimeComing: '10:00:00',
  journeyDurationComing: '16:30:00',
  goingOnMon: true,
  goingOnWed: true,
  goingOnFri: true,
  comingOnTue: true,
  comingOnThu: true,
  comingOnSat: true,
  coachWGSCNSL: true,
  coachWGCZAC: true,
  coachGS: true,
);

final result = await trainService.createTrain(train);
```

### Get All Trains
```dart
List<Train> trains = await trainService.getAllTrains();
```

### Search Trains
```dart
List<Train> results = await trainService.searchTrains('Express');
```

### Update Train
```dart
final updatedTrain = train.copyWith(
  totalJanitor: 6,
  departureTimeGoing: '10:00:00',
);

await trainService.updateTrain(train.id!, updatedTrain);
```

### Delete Train
```dart
await trainService.deleteTrain(trainId);
```

## Notes

- Train numbers (trainNoGoing) must be unique
- Train numbers cannot be changed after creation
- All time fields must be in HH:MM:SS format
- At least one operational day should be selected for both going and coming
- At least one coach type should be selected
- All timestamps are automatically managed by Firestore
- The system validates required fields before submission
