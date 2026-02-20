# Employee Management - Quick Usage Guide

## Accessing Employee Management

1. Login to the app with your credentials
2. On the home screen, click "Employee Management" button
3. You'll see the Employee Details screen

## Employee Details Screen Layout

The screen has three main sections:

### 1. Header Section (Top)
- Title: "Employee Details" in red
- Search field: "Search Employee*"
- Three green buttons: Search, Export Excel, Create

### 2. Data Table (Main Area)
A scrollable table with these columns:
- S.No - Serial number
- Paycode - Employee code
- EmpName - Employee name
- FatherName - Father's name
- PhoneNo - Phone number
- AadharNo - Aadhar number
- PhotoName - Employee photo thumbnail
- AllDocument - Download link for documents
- Edit - Edit button with icon
- Delete - Delete button (blue text)

## Common Tasks

### Search for an Employee

1. Type in the "Search Employee" field
2. You can search by:
   - Employee name
   - Employee code (Paycode)
   - Phone number
   - Aadhar number
3. Results filter automatically as you type
4. Click "Search" button to apply
5. Clear the field to see all employees again

### Export Data to Excel

1. Use the search to filter employees (optional)
2. Click "Export Excel" button
3. Wait for the success message
4. The message shows where the file is saved
5. Excel file includes all filtered employees with all their data

### Add a New Employee

1. Click the "Create" button (green)
2. Fill in the form:
   - Required fields: Employee Code*, Employee Name*
   - Optional fields: Father Name, Phone Number, ESI No, PF No, Pancard No, Aadhar No
   - Select Employee Category from dropdown
   - Choose "Is Photo Upload" (Yes/No)
3. Click "Submit" at the bottom
4. You'll return to the Employee Details screen
5. Your new employee appears in the table

### Edit an Employee

1. Find the employee in the table
2. Click the "Edit" button in the Edit column
3. The form opens with all current data filled in
4. Note: Employee Code cannot be changed
5. Modify any other fields as needed
6. Click "Submit"
7. Changes are saved and you return to the table

### Delete an Employee

1. Find the employee in the table
2. Click the "Delete" button in the Delete column
3. A confirmation dialog appears
4. Click "Delete" to confirm or "Cancel" to abort
5. If confirmed, the employee is removed
6. The table refreshes automatically

## Tips

- **Scrolling**: The table scrolls both horizontally and vertically for large datasets
- **Real-time Updates**: Any changes are immediately reflected in the table
- **Search Before Export**: Filter employees before exporting to get only the data you need
- **Unique Codes**: Each employee must have a unique Employee Code
- **Required Fields**: Only Employee Code and Employee Name are required; all other fields are optional

## Excel Export Details

The exported Excel file contains these columns:
1. S.No
2. Paycode
3. EmpName
4. FatherName
5. PhoneNo
6. AadharNo
7. ESI No
8. PF No
9. Pancard No
10. Category

File naming: `employee_data_[timestamp].xlsx`

## Troubleshooting

### "Employee code already exists"
- Each employee must have a unique code
- Try a different code or check if the employee already exists

### "No employees found"
- Your search didn't match any employees
- Clear the search field to see all employees
- Check your spelling

### Excel export not working
- Make sure you have storage permissions
- Check the success message for the file location
- The file is saved in your device's documents directory

### Can't edit employee code
- This is by design - employee codes are permanent identifiers
- If you need to change it, delete the employee and create a new one

## Photo and Document Features

Currently, these are placeholders:
- Photo upload button is visible but not functional yet
- Document upload button is visible but not functional yet
- "Download" links in the table are placeholders

These features will be implemented in future updates.
