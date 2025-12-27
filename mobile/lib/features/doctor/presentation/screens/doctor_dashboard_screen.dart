
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/auth_controller.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock Patients
    final patients = [
        {'name': 'Robin Singh', 'id': 'ATK-001', 'lastVisit': '2 Days ago'},
        {'name': 'Sarah Connor', 'id': 'ATK-002', 'lastVisit': '1 Week ago'},
        {'name': 'John Doe', 'id': 'ATK-003', 'lastVisit': '3 Days ago'},
    ];

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14)),
                        Text('Dr. Strange', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () {
                           ref.read(authControllerProvider.notifier).signOut();
                           context.go('/login');
                        }, 
                        icon: const Icon(Icons.logout_rounded, color: Colors.grey)
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Stats Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                       _buildStatItem('12', 'Patients', Icons.people_outline),
                       const SizedBox(width: 40),
                       _buildStatItem('5', 'Pending', Icons.pending_actions_outlined),
                       const SizedBox(width: 40),
                       _buildStatItem('8', 'Visits today', Icons.calendar_today_outlined),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Active Patients', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                        final p = patients[index];
                        return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                                leading: CircleAvatar(
                                    backgroundColor: AppTheme.limeGreen.withOpacity(0.2), 
                                    child: Text(p['name'].toString()[0], style: const TextStyle(color: AppTheme.limeGreen))
                                ),
                                title: Text(p['name'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                                subtitle: Text('ID: ${p['id']} • Last: ${p['lastVisit']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                onTap: () {
                                    // Navigate to Patient Detail
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Viewing ${p['name']} details...')));
                                },
                            ),
                        );
                    }
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRequestDialog(context),
        label: const Text('Access Request', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_link),
        backgroundColor: AppTheme.limeGreen,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.limeGreen, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  void _showRequestDialog(BuildContext context) {
    final phoneController = TextEditingController();
    showDialog(
        context: context, 
        builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text('Request Patient Access', style: TextStyle(color: Colors.white)),
            content: TextField(
                controller: phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Patient Phone Number',
                    prefixText: '+91 ',
                ),
                keyboardType: TextInputType.phone,
            ),
            actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access Request Sent Successfully!')));
                    }, 
                    child: const Text('Send Request')
                )
            ],
        )
    );
  }
}
