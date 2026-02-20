# Dream Destination - Firebase Authentication App

A Flutter application with Firebase authentication featuring Customer ID, User ID, and Password fields with a beautiful, modern UI.

## Features

- Firebase Authentication integration
- Custom authentication with 3 fields:
  - Customer ID
  - User ID  
  - Password
- Beautiful gradient UI design
- Sign In screen (no sign up required)
- Form validation
- Password visibility toggle
- Loading states
- Error handling with user-friendly messages
- Firestore integration for storing user data

### Employee Management System

- Comprehensive employee database with Firestore
- Employee Details screen with data table view
- Search functionality (by name, code, phone, Aadhar)
- Export to Excel (.xlsx format)
- Create, Read, Update, Delete (CRUD) operations
- Professional table layout with all employee fields
- Real-time data updates
- Form validation
- Confirmation dialogs for deletions

### Train Management System

- Complete train database with Firestore
- Train Details screen with card-based list view
- Going and coming train information
- Operational days selection (Mon-Sun for both directions)
- 11 different coach types configuration
- Journey time and duration tracking
- Station route management
- Create, Read, Update, Delete (CRUD) operations
- Real-time data updates
- Form validation

### Employee Fields

- Employee Code (unique identifier)
- Employee Name
- Father Name
- Phone Number
- ESI No.
- PF No.
- Pancard No.
- Aadhar No.
- Employee Category (User/Admin/Manager/Staff)
- Photo Upload status
- Photo and Document URLs (for future file uploads)

### Train Fields

- Train Number Going (unique identifier)
- Train Name Going
- Station From
- Station To
- Total Janitor
- Departure Time Going (HH:MM:SS)
- Journey Duration Going (HH:MM:SS)
- Train Number Coming
- Train Name Coming
- Departure Time Coming (HH:MM:SS)
- Journey Duration Coming (HH:MM:SS)
- Going On Days (Mon-Sun checkboxes)
- Coming On Days (Mon-Sun checkboxes)
- Coach Types (11 different types):
  - AC 1st Tier, AC 2 Tier, AC 3 Tier
  - Sleeper, AC Chair Car, Chair Car
  - Shatabdi 1st & 2nd Tier
  - M1, CE, General Class

## Setup Instructions

### 1. Install Dependencies

Run the following command to install all required packages:

```bash
flutter pub get
```

### 2. Firebase Configuration

The Firebase configuration is already set up in `lib/firebase_options.dart` with your credentials.

### 3. Enable Firebase Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `dream-destination-b664a`
3. Navigate to **Authentication** → **Sign-in method**
4. Enable **Email/Password** authentication

### 4. Enable Firestore Database

1. In Firebase Console, navigate to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location and click **Enable**

### 5. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── firebase_options.dart               # Firebase configuration
├── models/
│   ├── employee_model.dart            # Employee data model
│   └── train_model.dart               # Train data model
├── services/
│   ├── auth_service.dart              # Authentication service
│   ├── employee_service.dart          # Employee CRUD operations
│   └── train_service.dart             # Train CRUD operations
└── screens/
    ├── login_screen.dart              # Sign in screen
    ├── signup_screen.dart             # Sign up screen (not used)
    ├── home_screen.dart               # Home screen with navigation
    ├── employee_details_screen.dart   # Employee management (table view)
    ├── employee_list_screen.dart      # Alternative employee list (card view)
    ├── employee_form_screen.dart      # Add/Edit employee form
    ├── train_details_screen.dart      # Train management (card view)
    └── train_form_screen.dart         # Add/Edit train form
```

## How It Works

### Authentication

1. **Sign In**: Users log in using their Customer ID, User ID, and Password
   - The system combines Customer ID and User ID to create a unique email format
   - Credentials are validated against Firebase Authentication
   - No sign-up button (admin creates accounts)

2. **Authentication**: Firebase handles secure authentication and session management

### Employee Management

1. **Employee Details Screen**: Main interface with data table
   - Search employees by name, code, phone, or Aadhar
   - View all employees in a professional table layout
   - Export filtered data to Excel
   - Create new employees
   - Edit existing employees (click Edit button)
   - Delete employees (click Delete button with confirmation)

2. **Employee Form**: Add or update employee information
   - All 11 fields available
   - Form validation for required fields
   - Employee code is unique and cannot be changed after creation
   - Photo and document upload placeholders (for future implementation)

3. **Data Storage**: All employee data stored in Firestore
   - Collection name: `employee`
   - Automatic timestamps for creation and updates
   - Real-time synchronization

### Train Management

1. **Train Details Screen**: Card-based list view
   - View all trains with complete information
   - Going and coming train details displayed
   - Operational days shown for both directions
   - Edit trains (click edit icon)
   - Delete trains (click delete icon with confirmation)
   - Add new trains (button in app bar)

2. **Train Form**: Add or update train information
   - Going train details (number, name, route, times)
   - Coming train details (return journey)
   - Day selection for both directions (Mon-Sun)
   - Coach type selection (11 types)
   - Total janitor count
   - Form validation for required fields
   - Train number is unique and cannot be changed after creation

3. **Data Storage**: All train data stored in Firestore
   - Collection name: `trains`
   - Automatic timestamps for creation and updates
   - Real-time synchronization

## UI Features

### Login Screen
- Blue gradient background with train icon
- Rounded input fields with icons
- Password visibility toggle
- Loading indicators during authentication
- Error messages with styled snackbars

### Home Screen
- Welcome message with user info
- Two management buttons:
  - Employee Management (blue)
  - Train Management (green)
- Logout button in app bar

### Employee Details Screen
- Professional data table layout
- Search bar with real-time filtering
- Three action buttons: Search, Export Excel, Create
- Scrollable table (horizontal and vertical)
- Edit and Delete buttons for each employee
- Photo thumbnail display
- Document download links
- Responsive design

### Employee Form Screen
- Clean form layout with all fields
- Dropdown selectors for categories
- File upload buttons (placeholders)
- Form validation
- Loading states
- Success/error notifications

### Train Details Screen
- Card-based list view
- Each card shows complete train information
- Going and coming train details
- Operational days display
- Edit and delete icons
- Add train button in app bar
- Pull to refresh
- Empty state message

### Train Form Screen
- Comprehensive form with all train fields
- Time input fields (HH:MM:SS format)
- Day selection checkboxes (Going and Coming)
- Coach type checkboxes (11 types)
- Section headers for organization
- Form validation
- Loading states
- Success/error notifications

## Notes

- Passwords must be at least 6 characters
- Customer ID and User ID must be at least 3 characters
- The app uses Firebase Auth email/password method internally
- User data is stored in Firestore for additional profile information
- Employee codes must be unique and cannot be changed after creation
- Excel exports are saved to the device's documents directory
- Search is case-insensitive and searches across multiple fields
- All employee operations require authentication
- Photo and document upload features are placeholders for future implementation
