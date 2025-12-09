# ATKANS MED 🏥✨

**ATKANS MED** is a premium, secure, and futuristic Medical Records Platform designed to bridge the gap between Patients, Doctors, and Healthcare Executives. Built with a focus on privacy, speed, and a stunning "Dark/Lime" aesthetic, it redefines how medical history is accessed and managed.

---

## 📸 Screenshots
*(Add screenshots of Login, Patient Dashboard, and Doctor Portal here)*

---

## 🌟 Key Features

### 🔐 For Patients
- **Secure Health Vault**: Store and manage prescriptions, lab reports, and radiology images.
- **Privacy First**: Granular control over who accesses your data.
- **One-Tap Sharing**: Grant temporary access to doctors via a search-and-approve system.
- **Timeline View**: Visual history of your medical journey.

### 👨‍⚕️ For Doctors
- **Efficient Patient Access**: Request access to patient records instantly via phone number or ID.
- **Time-Limited Access**: Access expires automatically (1h, 24h, 7d) to ensure patient privacy.
- **Digital Prescriptions**: Issue cryptographically secure prescriptions directly to the patient's app.

### 💼 For Executives
- **Onboarding & Referrals**: Seamlessly onboard new clinics and labs.
- **Commission Tracking**: Real-time dashboard for referral earnings and network growth.

---

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (iOS, Android, Web)
- **State Management**: [Riverpod](https://riverpod.dev) (v2.x) specifically `AsyncNotifier` for robust state handling.
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) for deep linking and seamless page transitions.
- **Backend (Planned/In-Progress)**: 
  - **Firebase Auth**: Custom Claims for Role-Based Access Control (RBAC).
  - **Cloud Firestore**: NoSQL DB for scalable record keeping.
  - **Cloud Functions**: NodeJS triggers for creating user profiles and handling secure access handshakes.
- **UI/UX**: 
  - **Theme**: High-contrast "Cyber-Health" Dark Mode (Black/Lime Green).
  - **Animations**: Custom `TweenAnimationBuilder` and implicit animations for smooth transitions.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.x)
- VS Code or Android Studio

### Installation

1. **Clone the repo**
   ```bash
   git clone https://github.com/yourusername/atkans-med.git
   cd atkans-med/mobile
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```
   *Note: Firebase configuration (`google-services.json`) is required for full backend functionality.*

---

## 🤝 Contribution

We welcome contributions! Please follow the steps below:
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
