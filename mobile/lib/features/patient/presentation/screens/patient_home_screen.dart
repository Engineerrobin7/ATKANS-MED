
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'patient_prescriptions_screen.dart';
import 'patient_timeline_screen.dart';
import 'patient_settings_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/auth_controller.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PatientDashboardTab(),
    PatientPrescriptionsScreen(),
    PatientTimelineScreen(),
    PatientSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.scaffoldBackgroundColor,
        selectedItemColor: isDark ? AppTheme.limeGreen : Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medication_liquid), label: 'Meds'),
          BottomNavigationBarItem(icon: Icon(Icons.history_toggle_off), label: 'Timeline'),
          BottomNavigationBarItem(icon: Icon(Icons.person_pin), label: 'Profile'),
        ],
      ),
    );
  }
}

class PatientDashboardTab extends ConsumerStatefulWidget {
  const PatientDashboardTab({super.key});

  @override
  ConsumerState<PatientDashboardTab> createState() => _PatientDashboardTabState();
}

class _PatientDashboardTabState extends ConsumerState<PatientDashboardTab> {
  Map<String, dynamic>? _localUser;

  @override
  void initState() {
    super.initState();
    _loadLocalUser();
  }

  Future<void> _loadLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    final profileImage = prefs.getString('user_profile_image');
    
    if (name != null) {
      if (mounted) {
        setState(() {
          _localUser = {
            'name': name,
            'profileImage': profileImage,
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userDataAsync = ref.watch(userDataProvider);
    
    final user = userDataAsync.valueOrNull ?? _localUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              theme.primaryColor.withValues(alpha: 0.05),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: user != null 
            ? _buildDashboard(context, user, isDark)
            : userDataAsync.when(
                data: (data) => _buildDashboard(context, data, isDark),
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.limeGreen)),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, Map<String, dynamic>? user, bool isDark) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final subTextColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello,', style: GoogleFonts.outfit(color: subTextColor, fontSize: 14)),
                    Text(
                      user?['name'] ?? 'User',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.limeGreen.withValues(alpha: 0.2),
                backgroundImage: (user?['profileImage'] != null)
                    ? NetworkImage(user!['profileImage'])
                    : (user?['photoUrl'] != null)
                        ? NetworkImage(user!['photoUrl'])
                        : null,
                child: (user?['profileImage'] == null && user?['photoUrl'] == null)
                    ? const Icon(Icons.person_outline, color: AppTheme.limeGreen)
                    : null,
              )
            ],
          ),
          const SizedBox(height: 32),
          Text('Quick Services', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildServiceCard(
                context,
                title: 'Doctor Access',
                icon: Icons.security_outlined,
                color: Colors.teal,
                path: '/patient-home/access'
              ),
              _buildServiceCard(
                context,
                title: 'Reports',
                icon: Icons.file_present_outlined,
                color: Colors.orange,
                path: '/patient-home/reports'
              ),
              _buildServiceCard(
                context,
                title: 'Analytics',
                icon: Icons.analytics_outlined,
                color: AppTheme.limeGreen,
                onTap: () => context.push('/patient-home/analytics'),
              ),
              _buildServiceCard(
                context,
                title: 'Video Call',
                icon: Icons.videocam_outlined,
                color: Colors.blueAccent,
                onTap: () => context.push('/chat-room/demo_doctor_id/Dr._Sarah_Johnson'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('More Options', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          _buildActionTile(
            context,
            title: 'E-Pharmacy',
            subtitle: 'Order medicines online',
            icon: Icons.shopping_bag_outlined,
            color: Colors.purpleAccent,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('E-Pharmacy coming soon!')),
            ),
          ),
          _buildActionTile(
            context,
            title: 'Insurance',
            subtitle: 'Claims and policy help',
            icon: Icons.verified_user_outlined,
            color: Colors.pinkAccent,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Insurance integration coming soon!')),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon for Silver/Gold members.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, {required String title, required IconData icon, required Color color, String? path, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap ?? () { if (path != null) context.push(path); },
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 4),
            Text('Manage now', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
                    Text(subtitle, style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: theme.iconTheme.color?.withValues(alpha: 0.5) ?? Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
