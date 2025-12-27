
# ATKANS MED

**ATKANS MED** is a patient-owned digital medical record platform built entirely with **Flutter**.

## Project Structure

- **mobile/**: The complete Flutter application for Android, iOS, and Web (Admin).
  - **Shared Codebase**: One codebase for Patient, Doctor, Executive, and Admin apps.
  - **Tech Stack**: Flutter, Riverpod, GoRouter, Firebase.
  
- **backend/**: Firebase Cloud Functions and configuration.

## Getting Started

### Application
1. Navigate to `mobile/`
2. Run `flutter pub get`
3. Run `flutter run` (Choose Windows, Chrome, or Simulator)

### Backend
- Configure Firebase project and update `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the `mobile` app.
- Initialize Firebase Functions in `backend/`.

## Progress
- [x] Initial Project Setup
- [ ] Authentication Implementation
- [ ] Patient Module
- [ ] Doctor Access Control
- [ ] Executive Module
- [ ] Admin Dashboard (Flutter Web)
