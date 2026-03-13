# PSI Form - Excel-Style Layout

## Overview
The "Add PSI Record" form has been redesigned to exactly match the Excel format shown in the screenshot. Users can now enter data in the same structure as the Excel file.

## Form Structure

### Section 1: Header Information (Blue Box)
**Matches Excel top section:**
- **Company Name** - e.g., "R. N. INDUSTRIES"
- **EHK Name** * (Required) - e.g., "akash Kumar"
- **Trip Period** - Start Date and End Date (e.g., "06-06-2025 To 07-06-2025")
- **Trip ID** * (Required) - e.g., "2"
- **Train No** * (Required) - e.g., "05284"

### Section 2: Passenger Record (White Box)
**Matches Excel data row:**
- **Date** * (Required) - e.g., "07-06-2025"
- **Passenger Name** * (Required) - e.g., "VINAYAK"
- **PNR No** * (Required) - e.g., "2542585955"
- **Mobile No** * (Required) - e.g., "9310103114"
- **Coach** * (Required) - e.g., "M1"
- **Seat No** * (Required) - e.g., "39"
- **PSI Score** * (Required) - e.g., "100" (0-100)

## Features

### 1. Excel-Like Layout
- Header section at top (blue background) - exactly like Excel header
- Passenger record section below (white background) - exactly like Excel data row
- Same field order as Excel
- Same field names as Excel

### 2. Smart Auto-Fill
- Train No auto-selects train from database if it exists
- Date defaults to current date
- PSI Score defaults to 100

### 3. Date Pickers
- Trip Period: Start and End dates
- Passenger Date: Individual record date
- All dates shown in DD-MM-YYYY format (matching Excel)

### 4. Validation
- All required fields marked with *
- PSI Score must be between 0-100
- Mobile and PNR numbers use numeric keyboard
- Train No must be 5 digits

### 5. Responsive Design
- Works on mobile and desktop
- Adjusts font sizes and padding
- Side-by-side fields on wider screens

## Usage Flow

1. **Fill Header Information**
   - Enter company name (optional)
   - Enter EHK name (required)
   - Select trip start and end dates
   - Enter trip ID
   - Enter train number (auto-selects if exists)

2. **Fill Passenger Record**
   - Select date
   - Enter passenger name
   - Enter PNR number
   - Enter mobile number
   - Enter coach and seat number
   - Enter PSI score (0-100)

3. **Save**
   - Click "Add PSI Record" button
   - Record is saved to database
   - Returns to previous screen

## Comparison with Excel

### Excel Format:
```
Passenger Feedback
Trainwise PSI Report
    R. N. INDUSTRIES
    OBHS Activity in AC / NON-AC Coaches
    in primary based Train at Muzaffarpur Division
    EHK Name: akash Kumar
    Trip Period: 06-06-2025 To 07-06-2025
    Trip ID: 2

Date        Passenger-Name  PNR-No      Mobile-No    Coach  Seat-No  PSI
Train No: 05284
07-06-2025  VINAYAK        2542585955  9310103114   M1     39       83.33
```

### App Form:
```
┌─────────────────────────────────────────┐
│ Passenger Feedback                      │
│ Trainwise PSI Report                    │
│                                         │
│ Company Name: [R. N. INDUSTRIES      ] │
│ EHK Name: [akash Kumar              ] │
│ Trip Start: [06-06-2025] End: [07-06-2025] │
│ Trip ID: [2]  Train No: [05284]        │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Passenger Record                        │
│                                         │
│ Date: [07-06-2025]                     │
│ Passenger Name: [VINAYAK]              │
│ PNR No: [2542585955]                   │
│ Mobile No: [9310103114]                │
│ Coach: [M1]  Seat No: [39]             │
│ PSI Score: [83.33]                     │
└─────────────────────────────────────────┘

[Add PSI Record]
```

## Benefits

1. **Familiar Interface** - Users who work with Excel will immediately understand the form
2. **Same Field Order** - No confusion about which field goes where
3. **Visual Separation** - Header vs. Data clearly separated
4. **Easy Data Entry** - All fields in logical order
5. **Validation** - Prevents invalid data entry
6. **Mobile Friendly** - Works on phones and tablets

## Files Modified
- `lib/screens/psi_form_screen.dart`
  - Completely redesigned layout
  - Added header section (blue box)
  - Added passenger record section (white box)
  - Removed service ratings (simplified)
  - Matched Excel field order
  - Added responsive design

## Access
- From Home Screen: Click "Add PSI Record" button
- From Tripwise PSI Report: Click edit icon on any record

## Notes
- Form is simplified compared to previous version
- Focuses on essential fields matching Excel
- Service ratings removed for simplicity
- PSI score entered directly (0-100)
- All fields match Excel column names exactly
