# ATKANS MED - Secure Digital Health Locker

**ATKANS MED** is a premium, secure digital health locker platform designed to give patients complete ownership of their medical records. Built with a modern tech stack focusing on security, privacy, and seamless user experience.

## 🚀 Project Overview

Atkans Med serves as a bridge between patients and healthcare providers, ensuring that medical history is always accessible to the owner while maintaining strict access controls for doctors and executives.

## 🏗️ Project Structure

- **mobile/**: High-performance Flutter application for Patients and Doctors.
  - **Features**: Biometric-ready auth, OTP verification, PDF medical reports, secure doctor access control.
  - **Tech Stack**: Flutter, Riverpod (State Management), GoRouter (Navigation), SharedPreferences.
- **backend/**: Core API service handling business logic and security.
  - **Features**: JWT Authentication, Role-Based Access Control (RBAC), OTP Generation (Email/SMS), Firestore integration.
  - **Tech Stack**: Node.js, Express, Firebase Admin SDK, Nodemailer, Twilio.
- **admin-dashboard/**: React-based management portal for system administrators.

## 🛠️ Key Implementation Details

- **Database**: Migrated to **Firebase Firestore** for real-time data sync and high availability.
- **Storage**: Medical records are stored using Firebase Storage with secure access links.
- **Authentication**: Dual-layer security with Firebase Auth (Phone) and custom backend OTP (Email/SMS).
- **Security**: Robust environment variable management to protect sensitive API keys and service account credentials.

## 🚦 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Node.js (v18+)
- Firebase Account

### Mobile Installation
```bash
cd mobile
flutter pub get
flutter run
```

### Backend Setup
1. Navigate to `backend/`
2. Install dependencies: `npm install`
3. Configure `.env` with:
   - `FIREBASE_SERVICE_ACCOUNT` (JSON string)
   - `JWT_SECRET`
   - `EMAIL_USER` & `EMAIL_PASS` (App Password)
4. Start the server: `npm start`

## 🛡️ Recent Fixes & Optimizations
- **Firebase Initialization**: Robust parsing for environment-based service accounts.
- **Network Reliability**: Switched to Port 587 with STARTTLS for stable email delivery on cloud hosting (Render).
- **Error Handling**: Implemented detailed diagnostic logging and "Developer Debug Mode" for OTP verification.
- **API Observability**: Added status health-checks for all core modules.

## 📅 Roadmap
- [x] Firestore Migration
- [x] Hybrid Authentication (OTP + Google)
- [x] Secure Report Uploads
- [ ] Prescription Management
- [ ] End-to-End Encryption for Reports
- [ ] Doctor Appointment Integration

---
© 2025 ATKANS MED. All rights reserved.
