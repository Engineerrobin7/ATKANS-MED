
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/auth_controller.dart';

class PatientSettingsScreen extends ConsumerStatefulWidget {
  const PatientSettingsScreen({super.key});

  @override
  ConsumerState<PatientSettingsScreen> createState() => _PatientSettingsScreenState();
}

class _PatientSettingsScreenState extends ConsumerState<PatientSettingsScreen> {
  Map<String, dynamic>? _localUser;

  @override
  void initState() {
    super.initState();
    _loadLocalUser();
  }

  Future<void> _loadLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');
    final role = prefs.getString('user_role');
    final profileImage = prefs.getString('user_profile_image');
    
    if (name != null) {
      setState(() {
        _localUser = {
          'name': name,
          'email': email ?? '',
          'role': role ?? 'Patient',
          'profileImage': profileImage, 
          'subscriptionStatus': 'free', // Default/Fallback
          'subscriptionPlan': 'Basic',
        };
      });
    }
  }

  Future<void> _handleLogout() async {
    print("DEBUG: Logout requested");
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print("DEBUG: Prefs cleared");
      
      // Also sign out from Firebase if linked
      await ref.read(authControllerProvider.notifier).signOut();
      
      if (mounted) {
        print("DEBUG: Navigating to /login");
        context.go('/login');
      }
    } catch (e) {
      print("DEBUG: Logout Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userDataAsync = ref.watch(userDataProvider);
    
    final user = userDataAsync.valueOrNull ?? _localUser;

    if (user != null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _buildContent(context, user, isDark),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: userDataAsync.when(
        data: (user) => _buildContent(context, user, isDark),
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.primaryColor),
        ),
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error loading profile: $e', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleLogout,
                child: const Text('Logout / Reset'),
              ),
              TextButton(
                onPressed: () => ref.refresh(userDataProvider),
                child: Text('Try Again', style: TextStyle(color: theme.primaryColor)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic>? user, bool isDark) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.grey;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off_outlined, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            Text('Profile Data Missing', style: GoogleFonts.outfit(color: textColor, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Please check your internet or log in again.', style: TextStyle(color: subTextColor)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleLogout,
              child: const Text('Go to Login'),
            )
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.05),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Profile',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  _buildThemeToggle(ref, isDark, theme),
                ],
              ),
              const SizedBox(height: 32),
              
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primary, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.cardTheme.color,
                            backgroundImage: (user['profileImage'] != null)
                                ? NetworkImage(user['profileImage'])
                                : (user['photoUrl'] != null) 
                                    ? NetworkImage(user['photoUrl'])
                                    : null,
                            child: (user['profileImage'] == null && user['photoUrl'] == null)
                                ? Icon(Icons.person_outline, size: 50, color: primary)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile picture upload coming soon!')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.edit, size: 16, color: theme.colorScheme.onPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user['name'] ?? 'User',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      user['email'] ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        user['subscriptionStatus'] == 'active' ? 'GOLD MEMBER' : 'FREE PLAN',
                        style: TextStyle(
                          color: primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              _buildSectionTitle('Membership', subTextColor),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingTile(
                      context,
                      icon: Icons.star_outline,
                      title: 'My Subscription & Plans',
                      subtitle: user['subscriptionPlan'] ?? 'Basic',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('UPGRADE', style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                      onTap: () => context.push('/patient-home/subscription'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Account Details', subTextColor),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingTile(
                      context,
                      icon: Icons.person_outline,
                      title: 'Edit Profile Info',
                      onTap: () {},
                    ),
                    _buildDivider(isDark),
                    _buildSettingTile(
                      context,
                      icon: Icons.medical_services_outlined,
                      title: 'Medical Information',
                      subtitle: 'Age, Blood, History',
                      onTap: () => context.push('/patient-home/profile'), 
                    ),
                    _buildDivider(isDark),
                    _buildSettingTile(
                      context,
                      icon: Icons.history_outlined,
                      title: 'Recent Activity Log',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Security & Privacy', subTextColor),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingTile(
                      context,
                      icon: Icons.notifications_none_outlined,
                      title: 'Notification Settings',
                      onTap: () {},
                    ),
                    _buildDivider(isDark),
                    _buildSettingTile(
                      context,
                      icon: Icons.security_outlined,
                      title: 'Privacy Controls',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Support', subTextColor),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingTile(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & FAQ',
                      onTap: () {},
                    ),
                    _buildDivider(isDark),
                    _buildSettingTile(
                      context,
                      icon: Icons.info_outline,
                      title: 'Terms & Conditions',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  label: Text(
                    'Logout Account',
                    style: GoogleFonts.outfit(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          color: theme.textTheme.bodyLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 13))
          : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200],
      indent: 72,
    );
  }

  Widget _buildThemeToggle(WidgetRef ref, bool isDark, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        print("DEBUG: Toggling theme");
        ref.read(themeProvider.notifier).toggleTheme();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
        ),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          color: theme.primaryColor,
          size: 22,
        ),
      ),
    );
  }
}
