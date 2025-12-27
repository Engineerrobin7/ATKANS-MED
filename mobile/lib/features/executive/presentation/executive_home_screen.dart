
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_theme.dart';

class ExecutiveHomeScreen extends ConsumerWidget {
  const ExecutiveHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              theme.primaryColor.withOpacity(0.08),
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Executive Dashboard', 
                          style: GoogleFonts.outfit(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black
                          )
                        ),
                        Text('Tracking your platform growth', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        ref.read(authControllerProvider.notifier).signOut();
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(child: _buildStatCard(context, 'Referrals', '124', Icons.people_outline)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(context, 'Earnings', '\$450', Icons.account_balance_wallet_outlined)),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                Text('Growth Actions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                _buildActionTile(
                  context,
                  title: 'Onboard New User',
                  subtitle: 'Register a new clinic or patient',
                  icon: Icons.person_add_outlined,
                  onTap: () => context.go('/executive-home/onboard'),
                ),
                
                _buildActionTile(
                  context,
                  title: 'Referral Link',
                  subtitle: 'Share your unique referral code',
                  icon: Icons.share_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Referral link copied to clipboard!')));
                  },
                ),
                
                const SizedBox(height: 32),
                
                Text('Recent Payouts', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                _buildActivityList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.limeGreen, size: 28),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.limeGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Icon(Icons.add, color: AppTheme.limeGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                   ],
                )
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    final activities = [
      {'title': 'Weekly Bonus', 'time': '2h ago', 'amount': '+\$50'},
      {'title': 'Doctor Referral', 'time': '5h ago', 'amount': '+\$20'},
      {'title': 'Clinic Onboarding', 'time': '1d ago', 'amount': '+\$100'},
    ];

    return Column(
      children: activities.map((activity) {
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.05), 
                child: const Icon(Icons.history, color: Colors.grey, size: 18)
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(activity['time']!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Text(activity['amount']!, style: const TextStyle(color: AppTheme.limeGreen, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
