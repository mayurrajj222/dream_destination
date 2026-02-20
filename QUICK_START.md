# Quick Start Guide - Dream Destination

## 🚀 Get Started in 5 Minutes

### Step 1: Enable Firebase Services (2 minutes)

1. **Enable Authentication**
   - Go to: https://console.firebase.google.com/project/dream-destination-b664a/authentication/providers
   - Click "Email/Password"
   - Toggle "Enable"
   - Click "Save"

2. **Enable Firestore**
   - Go to: https://console.firebase.google.com/project/dream-destination-b664a/firestore
   - Click "Create database"
   - Select "Start in test mode"
   - Choose location
   - Click "Enable"

### Step 2: Install Dependencies (1 minute)

```bash
flutter pub get
```

### Step 3: Run the App (1 minute)

```bash
flutter run
```

### Step 4: Create First User (1 minute)

Since there's no sign-up button, you need to create a user manually:

**Option A: Using Firebase Console**
1. Go to Firebase Console → Authentication → Users
2. Click "Add user"
3. Email format: `CUSTOMERID_USERID@dreamdestination.com`
   - Example: `CUST001_admin@dreamdestination.com`
4. Set password (min 6 characters)
5. Click "Add user"

**Option B: Temporarily enable signup**
1. Uncomment the signup import in `login_screen.dart`
2. Add back the signup button
3. Create account through app
4. Remove signup button again

### Step 5: Login and Explore

1. **Login**
   - Customer ID: `CUST001`
   - User ID: `admin`
   - Password: (what you set)

2. **Try Employee Management**
   - Click "Employee Management"
   - Click "Create" to add an employee
   - Fill in the form and submit
   - Try searching, editing, and exporting

3. **Try Train Management**
   - Click "Train Management"
   - Click "Add Train" in app bar
   - Fill in train details
   - Select operational days
   - Select coach types
   - Submit and view in list

## 📱 Main Features

### Employee Management
- **Search**: Type in search box to filter employees
- **Export**: Click "Export Excel" to download data
- **Create**: Click "Create" button to add new employee
- **Edit**: Click edit icon in table row
- **Delete**: Click delete button in table row

### Train Management
- **Add**: Click "Add Train" in app bar
- **View**: See all trains in card format
- **Edit**: Click edit icon on train card
- **Delete**: Click delete icon on train card

## 🎯 Quick Tips

1. **Employee Codes** must be unique (e.g., EMP001, EMP002)
2. **Train Numbers** must be unique (e.g., 12345, 12346)
3. **Time Format** is HH:MM:SS (e.g., 09:30:00)
4. **Required Fields** are marked with *
5. **Pull to Refresh** works on all list screens

## 🔧 Common Issues

### "User not found"
- Create user in Firebase Console first
- Use correct Customer ID and User ID format

### "No employees/trains found"
- Add your first record using Create/Add button
- Check internet connection
- Verify Firestore is enabled

### Excel export not working
- Check storage permissions
- File saves to documents directory
- Look for success notification

## 📚 Learn More

- `README.md` - Full project documentation
- `EMPLOYEE_USAGE_GUIDE.md` - Detailed employee features
- `TRAIN_DATABASE.md` - Train system details
- `PROJECT_SUMMARY.md` - Complete overview

## 🎨 UI Overview

```
┌─────────────────────────────────┐
│         Login Screen            │
│  [Train Icon]                   │
│  Customer ID: [________]        │
│  User ID:     [________]        │
│  Password:    [________]        │
│  [Submit Button]                │
└─────────────────────────────────┘
              ↓
┌─────────────────────────────────┐
│         Home Screen             │
│  Welcome!                       │
│  [User Info Card]               │
│  [Employee Management] (Blue)   │
│  [Train Management] (Green)     │
└─────────────────────────────────┘
       ↓                    ↓
┌──────────────┐    ┌──────────────┐
│  Employee    │    │    Train     │
│  Details     │    │   Details    │
│  (Table)     │    │   (Cards)    │
└──────────────┘    └──────────────┘
```

## 🚂 Sample Data

### Sample Employee
```
Employee Code: EMP001
Employee Name: John Doe
Father Name: Robert Doe
Phone Number: 9876543210
ESI No: ESI123456
PF No: PF789012
Pancard No: ABCDE1234F
Aadhar No: 123456789012
Category: User
```

### Sample Train
```
Train No Going: 12345
Train Name Going: Rajdhani Express
Station From: Delhi
Station To: Mumbai
Total Janitor: 5
Departure Time: 16:00:00
Journey Duration: 16:30:00
Train No Coming: 12346
Train Name Coming: Rajdhani Return
Departure Time: 17:00:00
Journey Duration: 16:30:00
Going On: Mon, Wed, Fri
Coming On: Tue, Thu, Sat
Coaches: Sleeper, AC 2 Tier, AC 3 Tier
```

## ✅ Success Checklist

After setup, you should be able to:
- [ ] Login successfully
- [ ] See home screen with two buttons
- [ ] Access Employee Management
- [ ] Create a new employee
- [ ] Search for employees
- [ ] Export employees to Excel
- [ ] Access Train Management
- [ ] Create a new train
- [ ] View train details
- [ ] Edit and delete records
- [ ] Logout successfully

## 🆘 Need Help?

1. Check the error message in the app
2. Look at Flutter console output
3. Verify Firebase Console for data
4. Review documentation files
5. Check internet connection

## 🎉 You're Ready!

Your Dream Destination app is now set up and ready to use. Start by adding some employees and trains to see the full functionality in action!
