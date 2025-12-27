import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/widgets/glass_card.dart';

class DoctorHomeScreen extends ConsumerWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Portal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text('Logout', style: TextStyle(color: Colors.white)),
                  content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(authControllerProvider.notifier).signOut();
                        Navigator.pop(context);
                        context.go('/login');
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.08),
              Colors.black,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome Card
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.medical_services, color: Theme.of(context).primaryColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. Sarah Johnson', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Cardiology Specialist', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                Expanded(child: _buildStatCard(context, '12', 'Active Patients', Icons.people, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, '5', 'Pending Access', Icons.pending, Colors.orange)),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            
            _buildActionCard(
              context,
              icon: Icons.search,
              title: 'Search Patients',
              subtitle: 'Find and request access',
              color: Colors.blue,
              onTap: () => context.go('/doctor-home/search'),
            ),
            _buildActionCard(
              context,
              icon: Icons.access_time,
              title: 'Access Requests',
              subtitle: 'Manage pending requests',
              color: Colors.purple,
              onTap: () => _showAccessRequests(context),
            ),
            _buildActionCard(
              context,
              icon: Icons.calendar_today,
              title: 'Appointments',
              subtitle: 'View your schedule',
              color: Colors.green,
              onTap: () => _showAppointments(context),
            ),
            _buildActionCard(
              context,
              icon: Icons.message,
              title: 'Messages',
              subtitle: 'Patient communications',
              color: Colors.cyan,
              onTap: () => _showMessages(context),
            ),

            const SizedBox(height: 24),

            // Recent Activity
            const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            
            _buildActivityItem(context, 'Access granted to John Doe', '10 minutes ago', Icons.check_circle, Colors.green),
            _buildActivityItem(context, 'New report from Jane Smith',  '1 hour ago', Icons.description, Colors.blue),
            _buildActivityItem(context, 'Prescription issued', '3 hours ago', Icons.medication, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String title, String time, IconData icon, Color color) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAccessRequests(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Access Requests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildRequestCard(context, 'John Doe', 'Follow-up consultation', 'Pending', Colors.orange),
                  _buildRequestCard(context, 'Jane Smith', 'Treatment review', 'Approved', Colors.green),
                  _buildRequestCard(context, 'Bob Wilson', 'Lab results discussion', 'Pending', Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, String patient, String reason, String status, Color color) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(reason, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
              ),
              Chip(
                label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 11)),
                backgroundColor: color,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          if (status == 'Pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Access request for $patient approved'), backgroundColor: Colors.green),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Request from $patient denied'), backgroundColor: Colors.red),
                      );
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                    child: const Text('Deny'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showAppointments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Today\'s Appointments', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildAppointmentCard('John Doe', '10:00 AM', 'Consultation'),
                  _buildAppointmentCard('Jane Smith', '11:30 AM', 'Follow-up'),
                  _buildAppointmentCard('Bob Wilson', '02:00 PM', 'Checkup'),
                  _buildAppointmentCard('Alice Brown', '03:30 PM', 'Lab Review'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(String patient, String time, String type) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.calendar_today, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(type, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showMessages(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Messages', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildMessageCard(context, 'John Doe', 'When should I take the medication?', '10 min ago'),
                  _buildMessageCard(context, 'Jane Smith', 'Lab results uploaded', '1 hour ago'),
                  _buildMessageCard(context, 'Bob Wilson', 'Can we reschedule?', '3 hours ago'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context, String patient, String message, String time) {
    return InkWell(
      onTap: () => context.push('/chat-room/demo_patient_id_${patient.replaceAll(' ', '_')}/$patient'),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.cyan.withOpacity(0.2),
              child: Text(patient[0], style: const TextStyle(color: Colors.cyan, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(message, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
