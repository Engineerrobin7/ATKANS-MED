# ATKANS MED - Quick Start Guide

## 🎯 Current Status

✅ **Frontend**: Complete with dark theme, animations, and 3D effects  
✅ **Backend**: Cloud Functions implemented  
✅ **Data Models**: Firestore models created  
✅ **Repositories**: Firebase integration ready  
⏳ **Firebase Setup**: Requires configuration (see below)

---

## 🚀 To Activate Firebase (Do This Next!)

### Step 1: Create Firebase Project
1. Visit: https://console.firebase.google.com/
2. Click "Add Project" → Name it `atkans-med`
3. Follow the wizard (Google Analytics is optional)

### Step 2: Add Android App
1. In Firebase Console, click ⚙️ → Project Settings
2. Scroll to "Your apps" → Click Android icon
3. **Android package name**: `com.atkansmed.mobile` (CRITICAL!)
4. Click "Register app"
5. **Download `google-services.json`**
6. Place it here: `mobile/android/app/google-services.json`

### Step 3: Generate Firebase Options
```bash
cd mobile

# Install FlutterFire CLI (one-time)
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=atkans-med
```

This will auto-create `lib/firebase_options.dart`

### Step 4: Enable Firebase Services
In Firebase Console:

**Authentication**:
- Go to Authentication → Sign-in providers
- Enable "Phone" and "Email/Password"

**Firestore Database**:
- Go to Firestore Database → Create Database
- Select "Production mode"
- Choose region: `asia-south1` (Mumbai)

**Cloud Storage**:
- Go to Storage → Get Started
- Use default rules (we'll update via code)

### Step 5: Update Security Rules
**Firestore Rules** (Console → Firestore → Rules):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isOwner(userId);
    }
    
    match /medical_reports/{reportId} {
      allow read, write: if isSignedIn();
    }
    
    match /access_requests/{requestId} {
      allow read, create: if isSignedIn();
      allow update: if isSignedIn();
    }
  }
}
```

**Storage Rules** (Console → Storage → Rules):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /medical_reports/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Step 6: Switch to Real Firebase Auth
In `mobile/lib/features/auth/data/auth_repository.dart`:

Change line 165 from:
```dart
return MockAuthRepository();
```

To:
```dart
return FirebaseAuthRepository(auth: auth, firestore: firestore);
```

### Step 7: Initialize Firebase in App
In `mobile/lib/main.dart`, update to:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}
```

### Step 8: Deploy Cloud Functions
```bash
cd backend/functions

# Login to Firebase
firebase login

# Deploy
firebase deploy --only functions
```

---

## 🧪 Testing

### Test Phone Authentication:
1. Run app on emulator
2. Go to Login → Phone tab
3. Enter: `+1 650-555-1234` (test number)
4. In Firebase Console → Authentication → Phone → Add test number

### Test Email Authentication:
1. Login → Email tab
2. Use any email/password
3. Check Firebase Console → Authentication → Users

### Test File Upload:
1. Login as Patient
2. Go to Reports → Add (+) button
3. Upload a PDF/image
4. Check Firebase Console → Storage

---

## 📱 Permissions (Android)

Add to `mobile/android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <!-- After package declaration -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    
    <application ...>
        ...
    </application>
</manifest>
```

---

## 🎨 Features Implemented

### Patient Module
- ✅ Health record dashboard
- ✅ Medical reports list
- ✅ File upload (ready for Firebase Storage)
- ✅ Logout functionality

### Doctor Module
- ✅ Access request system
- ✅ Patient search
- ✅ Time-limited access control

### Executive Module
- ✅ 3D tilt card dashboard
- ✅ Referral tracking
- ✅ Onboarding workflow

### Admin Module
- ✅ Responsive dashboard
- ✅ Custom analytics charts
- ✅ User approval system

---

## 🔥 What Happens After Firebase Setup

Once you complete the setup above:

1. **Real Authentication**: Users can sign up with phone/email
2. **Data Persistence**: Medical reports saved to Firestore
3. **File Storage**: PDFs and images uploaded to Cloud Storage
4. **Access Control**: Doctors can request patient access
5. **Real-time Updates**: Dashboard updates live with Firestore streams
6. **Cloud Functions**: Auto-create user profiles, expire access, etc.

---

## 🐛 Troubleshooting

**App crashes on startup?**
- Ensure `google-services.json` is in correct location
- Run `flutter clean && flutter pub get`

**"default Firebase app has not been initialized"?**
- Check `main.dart` has `Firebase.initializeApp()`
- Verify `firebase_options.dart` exists

**Build fails with Gradle errors?**
- Update `android/build.gradle`:
  ```gradle
  buildscript {
      dependencies {
          classpath 'com.google.gms:google-services:4.4.0'
      }
  }
  ```
- In `android/app/build.gradle`, add:
  ```gradle
  apply plugin: 'com.google.gms.google-services'
  ```

---

## 📚 Further Reading

- [FlutterFire Docs](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

**Need Help?** Check `FIREBASE_SETUP.md` for detailed instructions.
