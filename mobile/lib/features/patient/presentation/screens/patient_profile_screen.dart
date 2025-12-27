import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Mock Data (In real app, fetch from provider)
    final patient = {
      'name': 'Robin Singh',
      'age': '28',
      'gender': 'Male',
      'blood': 'O+',
      'height': "5'11\"",
      'weight': '78 kg',
      'allergies': ['Peanuts', 'Penicillin'],
      'conditions': ['Hypertension'],
      'insurance': 'LIC Health Plus #882910',
    };

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Health ID', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: theme.colorScheme.error),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                   CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person, size: 50, color: theme.primaryColor),
                   ),
                   const SizedBox(height: 10),
                   Text(patient['name'] as String, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                   Text('ID: ATK-9928-11', style: GoogleFonts.outfit(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            _buildSection(
              context,
              title: 'Vitals',
              children: [
                _buildInfoRow(context, Icons.cake, 'Age', '${patient['age']} yrs'),
                _buildInfoRow(context, Icons.male, 'Gender', patient['gender'] as String),
                _buildInfoRow(context, Icons.bloodtype, 'Blood Group', patient['blood'] as String),
                _buildInfoRow(context, Icons.height, 'Height', patient['height'] as String),
                _buildInfoRow(context, Icons.monitor_weight, 'Weight', patient['weight'] as String),
              ]
            ),
            
            const SizedBox(height: 20),

            _buildSection(
              context,
              title: 'Medical History',
              children: [
                _buildListRow(context, 'Allergies', (patient['allergies'] as List<String>).join(', ')),
                _buildListRow(context, 'Chronic Conditions', (patient['conditions'] as List<String>).join(', ')),
              ]
            ),

            const SizedBox(height: 20),
             _buildSection(
              context,
              title: 'Insurance',
              children: [
                _buildInfoRow(context, Icons.shield, 'Provider', 'LIC Health'),
                _buildInfoRow(context, Icons.numbers, 'Policy No', '88291022'),
              ]
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: theme.primaryColor)),
          const SizedBox(height: 16),
          ...children
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.outfit(color: Colors.grey[600])),
          const Spacer(),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 16, color: theme.textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  Widget _buildListRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 16, color: theme.textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }
}
