import 'package:flutter/material.dart';
import '../../auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/tilt_3d_card.dart';
import 'dart:math';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform Overview', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: isWide ? 1 : 0, child: _buildStatCard(context, 'Total Users', '1,240', Icons.people, Colors.blue)),
                  SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
                  Expanded(flex: isWide ? 1 : 0, child: _buildStatCard(context, 'Doctors', '45', Icons.medical_services, Colors.purple)),
                  SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
                  Expanded(flex: isWide ? 1 : 0, child: _buildStatCard(context, 'Revenue', '\$12,450', Icons.attach_money, Theme.of(context).primaryColor)),
                ],
              );
            }),
            const SizedBox(height: 32),
            Text('Growth Analytics', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 250,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: CustomPaint(
                painter: ChartPainter(color: Theme.of(context).primaryColor),
              ),
            ),
             const SizedBox(height: 32),
             Text('Recent Approvals', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildApprovalList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Tilt3DCard(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(title, style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          ],
        ),
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
      children: requests.map((req) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          tileColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: CircleAvatar(child: Text(req['name']![0])),
          title: Text(req['name']!, style: const TextStyle(color: Colors.white)),
          subtitle: Text(req['type']!, style: const TextStyle(color: Colors.grey)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (req['status'] == 'Pending') ...[
                IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: (){}),
                IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: (){}),
              ] else
                const Chip(label: Text('Verified'), backgroundColor: Colors.green, visualDensity: VisualDensity.compact)
            ],
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
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    final random = Random(42);
    
    path.moveTo(0, size.height * 0.8);
    for (int i = 1; i <= 10; i++) {
      final x = size.width * (i / 10);
      final y = size.height * 0.8 - (random.nextDouble() * size.height * 0.6); // Random height
      path.lineTo(x, y);
    }

    // Shadow
    final shadowPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    
    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
