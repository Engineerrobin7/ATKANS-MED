
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/patient/presentation/patient_home_screen.dart';
import '../../features/patient/presentation/patient_reports_screen.dart';
import '../../features/doctor/presentation/doctor_home_screen.dart';
import '../../features/doctor/presentation/patient_search_screen.dart';
import '../../features/executive/presentation/executive_home_screen.dart';
import '../../features/executive/presentation/executive_onboarding_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/patient-home',
        builder: (context, state) => const PatientHomeScreen(),
        routes: [
           GoRoute(
            path: 'reports',
            builder: (context, state) => const PatientReportsScreen(),
          ),
        ]
      ),
      GoRoute(
        path: '/doctor-home',
        builder: (context, state) => const DoctorHomeScreen(),
        routes: [
           GoRoute(
            path: 'search',
            builder: (context, state) => const PatientSearchScreen(),
          ),
        ]
      ),
      GoRoute(
        path: '/executive-home',
        builder: (context, state) => const ExecutiveHomeScreen(),
        routes: [
           GoRoute(
            path: 'onboard',
            builder: (context, state) => const ExecutiveOnboardingScreen(),
          ),
        ]
      ),
       GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
});
