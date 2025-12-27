import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class PatientTimelineScreen extends StatelessWidget {
  const PatientTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final events = [
      {'title': 'Annual Checkup', 'date': 'Today, 10:00 AM', 'type': 'visit', 'doctor': 'Dr. Sharma'},
      {'title': 'Blood Test Report Uploaded', 'date': 'Yesterday, 4:20 PM', 'type': 'report', 'doctor': 'Lab Corp'},
      {'title': 'Prescription Renewed', 'date': '10 Dec, 2025', 'type': 'rx', 'doctor': 'Dr. John Doe'},
      {'title': 'Access Granted to Dr. Who', 'date': '01 Dec, 2025', 'type': 'access', 'doctor': 'System'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Health Timeline', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        automaticallyImplyLeading: false,
      ),
      // Theme handles background
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final e = events[index];
          final isLast = index == events.length - 1;
          
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getColor(e['type'] as String).withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: _getColor(e['type'] as String).withOpacity(0.5))
                      ),
                      child: Icon(_getIcon(e['type'] as String), color: _getColor(e['type'] as String), size: 20),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                        ),
                      )
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e['date'] as String, style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(e['title'] as String, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                        const SizedBox(height: 4),
                        Text('By ${e['doctor']}', style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color, fontSize: 13)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getColor(String type) {
    // Keep these distinct as they represent data types, but ensure visibility
    switch (type) {
      case 'visit': return Colors.blueAccent;
      case 'report': return Colors.orangeAccent;
      case 'rx': return AppTheme.limeGreen;
      case 'access': return Colors.purpleAccent;
      default: return Colors.grey;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'visit': return Icons.medical_services;
      case 'report': return Icons.file_present;
      case 'rx': return Icons.medication;
      case 'access': return Icons.lock_open;
      default: return Icons.circle;
    }
  }
}
