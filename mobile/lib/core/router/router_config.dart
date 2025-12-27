
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/presentation/otp_verification_screen.dart';
import '../../features/auth/presentation/otp_auth_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';

// New Screens
import '../../features/patient/presentation/screens/patient_home_screen.dart';
import '../../features/patient/presentation/screens/patient_profile_screen.dart';
import '../../features/patient/presentation/screens/access_control_screen.dart';
import '../../features/patient/presentation/screens/patient_reports_screen.dart';
import '../../features/patient/presentation/screens/file_upload_screen.dart';
import '../../features/patient/presentation/screens/subscription_plans_screen.dart';
import '../../features/patient/presentation/screens/health_analytics_screen.dart';
import '../../features/patient/presentation/screens/firestore_example_screen.dart'; 
import '../../features/chat/presentation/screens/chat_room_screen.dart';
import '../../features/doctor/presentation/screens/doctor_dashboard_screen.dart';
import '../../features/executive/presentation/executive_home_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';


final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final isAuthenticated = token != null && token.isNotEmpty;
      final role = prefs.getString('user_role') ?? 'patient';

      final isAuthenticating = state.uri.path == '/login' || state.uri.path == '/signup' || state.uri.path == '/' || state.uri.path == '/welcome';

      // If not authenticated and not on an authentication screen, go to welcome
      if (!isAuthenticated && !isAuthenticating) {
        return '/welcome';
      }
      // If authenticated and on an authentication screen, go to home
      if (isAuthenticated && isAuthenticating) {
        return role == 'doctor' ? '/doctor-home' : '/patient-home';
      }
      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const OTPAuthScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const OTPAuthScreen(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OTPVerificationScreen(
            phoneNumber: extra['phoneNumber'] as String? ?? '',
            verificationId: extra['verificationId'] as String? ?? 'demoid',
          );
        },
      ),
      GoRoute(
        path: '/patient-home',
        builder: (context, state) => const PatientHomeScreen(),
        routes: [
           GoRoute(
            path: 'reports',
            builder: (context, state) => const PatientReportsScreen(),
            routes: [
              GoRoute(
                path: 'upload',
                builder: (context, state) => const FileUploadScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const PatientProfileScreen(),
          ),
          GoRoute(
            path: 'access',
            builder: (context, state) => const AccessControlScreen(),
          ),
          GoRoute(
            path: 'subscription',
            builder: (context, state) => const SubscriptionPlansScreen(),
          ),
          GoRoute(
            path: 'analytics',
            builder: (context, state) => const HealthAnalyticsScreen(),
          ),
        ]
      ),
      GoRoute(
        path: '/doctor-home',
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/executive-home',
        builder: (context, state) => const ExecutiveHomeScreen(),
      ),
       GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/chat-room/:id/:name',
        builder: (context, state) {
          return ChatRoomScreen(
            receiverId: state.pathParameters['id']!,
            receiverName: state.pathParameters['name']!,
          );
        },
      ),
      // Firestore Example Screen
      GoRoute(
        path: '/firestore-example',
        builder: (context, state) => const FirestoreExampleScreen(),
      ),
    ],
  );
});
