# Firebase Setup Guide for ATKANS MED

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `atkans-med`
4. Enable Google Analytics (optional)
5. Create project

## Step 2: Add Android App

1. Click "Add app" → Select Android (robot icon)
2. **Android package name**: `com.atkansmed.mobile`
   - IMPORTANT: This must match the `applicationId` in your `android/app/build.gradle.kts`
3. **App nickname**: ATKANS MED (optional)
4. Click "Register app"
5. **Download `google-services.json`**
6. Place the file in: `mobile/android/app/google-services.json`

## Step 3: Enable Firebase Services

### Authentication
1. Go to "Authentication" → "Get Started"
2. Enable **Phone** authentication
3. Enable **Email/Password** authentication

### Firestore Database
1. Go to "Firestore Database" → "Create Database"
2. **Start in production mode** (we'll add rules later)
3. Choose location: `asia-south1` (or nearest to India)

### Storage
1. Go to "Storage" → "Get Started"
2. Start in **production mode**
3. Rules will be updated via code

### Cloud Functions
1. Go to "Functions" → "Get Started"
2. Upgrade to **Blaze Plan** (pay-as-you-go, free tier is generous)

## Step 4: Run FlutterFire CLI

Open terminal in the `mobile` directory and run:

```bash
# Install FlutterFire CLI (if not already installed)
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=atkans-med
```

This will:
- Auto-generate `firebase_options.dart`
- Link your Flutter app to Firebase
- Configure iOS (if you want iOS support later)

## Step 5: Firestore Security Rules

Go to Firestore → Rules and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function hasRole(role) {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isOwner(userId) || hasRole('admin');
    }
    
    // Medical reports
    match /medical_reports/{reportId} {
      allow read: if isOwner(resource.data.patientId) 
                  || hasRole('doctor') 
                  || hasRole('admin');
      allow create: if isSignedIn();
      allow update, delete: if isOwner(resource.data.patientId) || hasRole('admin');
    }
    
    // Access requests
    match /access_requests/{requestId} {
      allow read, create: if isSignedIn();
      allow update: if isOwner(resource.data.patientId) || hasRole('admin');
    }
    
    // Executive referrals
    match /referrals/{referralId} {
      allow read, write: if hasRole('executive') || hasRole('admin');
    }
  }
}
```

## Step 6: Storage Security Rules

Go to Storage → Rules and paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /medical_reports/{userId}/{allPaths=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /profile_pictures/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 7: Deploy Cloud Functions

In the `backend/functions` directory:

```bash
# Login to Firebase
firebase login

# Initialize Firebase (if not done)
firebase init functions

# Deploy
firebase deploy --only functions
```

## Verification

After setup, you should have:
- ✅ `mobile/android/app/google-services.json`
- ✅ `mobile/lib/firebase_options.dart`
- ✅ Firebase Authentication enabled
- ✅ Firestore Database created
- ✅ Cloud Storage configured
- ✅ Security rules deployed
