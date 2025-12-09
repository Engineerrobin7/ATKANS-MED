
# ATKANS MED - Implemented Features

## 1. Authentication
- **Login Screen**: Phone and Email login options.
- **Role Selection**: Patient, Doctor, Executive, Admin.
- **Sign Up**: Basic registration form.
- **Mock Authentication**: Simulated login/signup delay for demo purposes.

## 2. Patient Module
- **Home Dashboard**: Quick access to Reports, Prescriptions, Timeline.
- **Medical Reports**: View a list of dummy medical reports (Lab Results, X-Rays) with tags and dates.

## 3. Doctor Module
- **Home Dashboard**: View active access requests.
- **Patient Search**: Search for patients by phone/ID.
- **Access Request**: Simulate sending a time-limited access request.

## 4. Executive Module
- **Home Dashboard**: Track referrals and earnings.
- **Onboarding**: Multi-step form to upload ID and address proof for new users.

## 5. Admin Module
- **Dashboard**: Responsive layout with navigation rail (placeholder).

## Architecture
- **State Management**: Riverpod.
- **Navigation**: GoRouter (Deep linking capable).
- **Theme**: Premium Teal/White healthcare theme.
- **Codebase**: Modular feature-based structure (`features/patient`, `features/doctor`, etc.).
