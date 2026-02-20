# Employee Database Documentation

## Overview

The employee database is stored in Firestore under the collection name `employee`. It features a comprehensive employee management system with search, export, and CRUD operations.

## Main Features

### Employee Details Screen (`lib/screens/employee_details_screen.dart`)

This is the main interface for managing employees with the following features:

1. **Search Functionality**
   - Search by employee name, code, phone number, or Aadhar number
   - Real-time filtering as you type
   - Clear visual feedback for search results

2. **Export to Excel**
   - Export all filtered employee data to Excel format (.xlsx)
   - Includes all employee fields in the export
   - File saved to device's documents directory
   - Success notification with file path

3. **Create New Employee**
   - Opens the employee form to add new employees
   - All fields validated before submission
   - Automatic refresh after creation

4. **Data Table View**
   - Displays all employees in a scrollable table
   - Columns: S.No, Paycode, EmpName, FatherName, PhoneNo, AadharNo, PhotoName, AllDocument, Edit, Delete
   - Horizontal and vertical scrolling for large datasets
   - Professional table styling with borders

5. **Edit Employee**
   - Click the Edit button/icon in the table
   - Opens pre-filled form with employee data
   - Employee code cannot be changed
   - Automatic refresh after update

6. **Delete Employee**
   - Click Delete button in the table
   - Confirmation dialog before deletion
   - Automatic refresh after deletion

## Database Structure

### Collection: `employee`

Each employee document contains the following fields:

| Field Name | Type | Required | Description |
|------------|------|----------|-------------|
| `employeeCode` | String | Yes | Unique identifier for the employee |
| `employeeName` | String | Yes | Full name of the employee |
| `fatherName` | String | No | Father's name |
| `phoneNumber` | String | No | Contact phone number |
| `esiNo` | String | No | ESI (Employee State Insurance) number |
| `pfNo` | String | No | PF (Provident Fund) number |
| `pancardNo` | String | No | PAN card number |
| `aadharNo` | String | No | Aadhar card number |
| `employeeCategory` | String | Yes | Category (User, Admin, Manager, Staff) |
| `isPhotoUpload` | Boolean | Yes | Whether photo is uploaded |
| `photoUrl` | String | No | URL to employee photo (for future use) |
| `documentUrl` | String | No | URL to employee documents (for future use) |
| `createdAt` | Timestamp | Auto | Document creation timestamp |
| `updatedAt` | Timestamp | Auto | Last update timestamp |

## Features Implemented

### 1. Employee Model (`lib/models/employee_model.dart`)
- Data class representing an employee
- Methods for converting to/from Firestore format
- Copy method for updates

### 2. Employee Service (`lib/services/employee_service.dart`)
Provides complete CRUD operations:

- `createEmployee()` - Add new employee
- `getEmployeeById()` - Get employee by document ID
- `getEmployeeByCode()` - Get employee by employee code
- `getAllEmployees()` - Get all employees
- `getEmployeesByCategory()` - Filter by category
- `updateEmployee()` - Update employee information
- `deleteEmployee()` - Remove employee
- `searchEmployeesByName()` - Search functionality
- `getEmployeesStream()` - Real-time updates
- `getTotalEmployeeCount()` - Count all employees
- `getEmployeeCountByCategory()` - Count by category

### 3. Employee Details Screen (`lib/screens/employee_details_screen.dart`) - MAIN INTERFACE
- Search employees with real-time filtering
- Export to Excel functionality
- Create new employee button
- Data table with all employee information
- Edit and delete actions for each employee
- Professional UI matching your design
- Responsive layout with scrolling

### 4. Employee Form Screen (`lib/screens/employee_form_screen.dart`)
- Add new employee
- Update existing employee
- Form validation
- All fields from your design
- Dropdown for category selection
- Placeholder for photo/document upload

### 5. Employee List Screen (`lib/screens/employee_list_screen.dart`) - ALTERNATIVE VIEW
- Card-based list view of employees
- Edit and delete options
- Pull to refresh
- Floating action button to add new employee

## Usage

### From Home Screen
After logging in, click the "Employee Management" button to access the Employee Details screen.

### Searching Employees
1. Type in the "Search Employee" field
2. Search works on: Employee Name, Employee Code, Phone Number, Aadhar Number
3. Results filter automatically as you type
4. Click "Search" button to apply the filter
5. Clear the search field to show all employees

### Exporting to Excel
1. Click the "Export Excel" button
2. The system will create an Excel file with all filtered employees
3. File is saved to your device's documents directory
4. A notification shows the file path
5. Excel includes: S.No, Paycode, EmpName, FatherName, PhoneNo, AadharNo, ESI No, PF No, Pancard No, Category

### Adding an Employee
1. Click the "Create" button
2. Fill in the required fields (Employee Code, Employee Name)
3. Fill in optional fields as needed
4. Select employee category from dropdown
5. Click "Submit"
6. You'll be returned to the Employee Details screen with the new employee visible

### Updating an Employee
1. Find the employee in the table
2. Click the "Edit" button/icon in the Edit column
3. Modify the fields (Employee Code cannot be changed)
4. Click "Submit"
5. Changes are saved and table refreshes automatically

### Deleting an Employee
1. Find the employee in the table
2. Click the "Delete" button in the Delete column
3. Confirm the deletion in the dialog
4. Employee is removed and table refreshes automatically

## Firestore Rules (For Production)

Add these rules to secure your employee data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /employee/{employeeId} {
      // Only authenticated users can read
      allow read: if request.auth != null;
      
      // Only authenticated users can create/update/delete
      allow create, update, delete: if request.auth != null;
      
      // Ensure employeeCode is unique on create
      allow create: if !exists(/databases/$(database)/documents/employee/$(request.resource.data.employeeCode));
    }
  }
}
```

## Future Enhancements

1. **Photo Upload**: Integrate Firebase Storage for employee photos
2. **Document Upload**: Store employee documents in Firebase Storage
3. **Advanced Search**: Search by multiple fields
4. **Export Data**: Export employee list to CSV/Excel
5. **Bulk Operations**: Import multiple employees at once
6. **Employee Details View**: Dedicated screen showing all employee information
7. **Audit Trail**: Track who made changes and when
8. **Role-based Access**: Different permissions for different user types

## API Examples

### Create Employee
```dart
final employee = Employee(
  employeeCode: 'EMP001',
  employeeName: 'John Doe',
  fatherName: 'Robert Doe',
  phoneNumber: '1234567890',
  esiNo: 'ESI123',
  pfNo: 'PF456',
  pancardNo: 'ABCDE1234F',
  aadharNo: '123456789012',
  employeeCategory: 'User',
  isPhotoUpload: false,
);

final result = await employeeService.createEmployee(employee);
```

### Get All Employees
```dart
List<Employee> employees = await employeeService.getAllEmployees();
```

### Update Employee
```dart
final updatedEmployee = employee.copyWith(
  employeeName: 'John Smith',
  phoneNumber: '9876543210',
);

await employeeService.updateEmployee(employee.id!, updatedEmployee);
```

### Delete Employee
```dart
await employeeService.deleteEmployee(employeeId);
```

## Notes

- Employee Code must be unique
- Employee Code cannot be changed after creation
- All timestamps are automatically managed by Firestore
- The system validates required fields before submission
- Photo and document upload features are placeholders for future implementation
