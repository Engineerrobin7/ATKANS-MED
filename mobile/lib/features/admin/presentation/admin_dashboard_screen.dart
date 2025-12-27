
import 'package:flutter/material.dart';
import '../../auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:math';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin Console', 
                          style: GoogleFonts.outfit(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black
                          )
                        ),
                        Text('System health and growth', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
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
                
                LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: isWide ? 1 : 0, child: _buildStatCard(context, 'Total Users', '1,240', Icons.people_outline)),
                      SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
                      Expanded(flex: isWide ? 1 : 0, child: _buildStatCard(context, 'Doctors', '45', Icons.medical_services_outlined)),
                      SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
                      Expanded(flex: isWide ? 1 : 0, child: _buildStatCard(context, 'Revenue', '\$12,450', Icons.account_balance_wallet_outlined)),
                    ],
                  );
                }),
                
                const SizedBox(height: 32),
                
                Text('Growth Analytics', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Monthly Users', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('+12% vs last month', style: TextStyle(color: AppTheme.limeGreen, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: ChartPainter(color: AppTheme.limeGreen),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text('Pending Approvals', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                _buildApprovalList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.limeGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.limeGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalList(BuildContext context) {
    final requests = [
      {'name': 'Dr. Emily Stone', 'type': 'Doctor', 'status': 'Pending'},
      {'name': 'LifeCare Clinic', 'type': 'Organization', 'status': 'Pending'},
      {'name': 'James Bond', 'type': 'Executive', 'status': 'Verified'},
    ];

    return Column(
      children: requests.map((req) => GlassCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.limeGreen.withOpacity(0.1),
            child: Text(req['name']![0], style: const TextStyle(color: AppTheme.limeGreen))
          ),
          title: Text(req['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(req['type']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          trailing: req['status'] == 'Pending' 
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.check_circle_outline, color: AppTheme.limeGreen), onPressed: (){}),
                  IconButton(icon: const Icon(Icons.highlight_off_rounded, color: Colors.redAccent), onPressed: (){}),
                ],
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.limeGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: const Text('Verified', style: TextStyle(color: AppTheme.limeGreen, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
        ),
      )).toList(),
    );
  }
}

class ChartPainter extends CustomPainter {
  final Color color;
  ChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    final random = Random(42);
    
    path.moveTo(0, size.height * 0.8);
    for (int i = 1; i <= 8; i++) {
      final x = size.width * (i / 8);
      final y = size.height * 0.8 - (random.nextDouble() * size.height * 0.6);
      path.lineTo(x, y);
    }

    // Gradient below path
    final shadowPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    
    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
