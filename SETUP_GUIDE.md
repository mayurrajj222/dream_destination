# Quick Setup Guide

## Before Running the App

### Important: Enable Firebase Services

Your Firebase project is configured, but you need to enable two services:

#### 1. Enable Email/Password Authentication

1. Visit: https://console.firebase.google.com/project/dream-destination-b664a/authentication/providers
2. Click on **Email/Password** provider
3. Click **Enable** toggle
4. Click **Save**

#### 2. Enable Firestore Database

1. Visit: https://console.firebase.google.com/project/dream-destination-b664a/firestore
2. Click **Create database**
3. Select **Start in test mode** (for development)
4. Choose your preferred location
5. Click **Enable**

### Run the App

After enabling both services, run:

```bash
flutter run
```

## Testing the App

### Sign Up Flow
1. Launch the app (opens Login screen)
2. Click "Sign Up" at the bottom
3. Enter:
   - Customer ID: `CUST001` (or any ID)
   - User ID: `user123` (or any ID)
   - Password: `password123` (min 6 characters)
   - Confirm Password: `password123`
4. Click "Create Account"
5. You'll be redirected to the Home screen

### Sign In Flow
1. From Login screen, enter the same credentials:
   - Customer ID: `CUST001`
   - User ID: `user123`
   - Password: `password123`
2. Click "Submit"
3. You'll be redirected to the Home screen

## UI Features

- **Login Screen**: Blue gradient with flight icon
- **Sign Up Screen**: Purple gradient with person icon
- **Password Toggle**: Click eye icon to show/hide password
- **Validation**: Real-time form validation
- **Loading States**: Spinner shows during authentication
- **Error Messages**: User-friendly error notifications

## Troubleshooting

### "Email already in use" error
- This means an account with that Customer ID + User ID combination already exists
- Try signing in instead, or use different IDs

### "User not found" error
- The account doesn't exist yet
- Click "Sign Up" to create a new account

### Firebase not initialized
- Make sure you've enabled Authentication and Firestore in Firebase Console
- Check your internet connection

## Security Notes

For production:
1. Update Firestore rules to secure your database
2. Add email verification
3. Implement password reset functionality
4. Add rate limiting
5. Use environment variables for sensitive data
