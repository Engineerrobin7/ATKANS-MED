import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class PatientPrescriptionsScreen extends StatelessWidget {
  const PatientPrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Mock Data
    final prescriptions = [
      {
        'doctor': 'Dr. Sarah Smith',
        'specialty': 'Dermatology',
        'date': '12 Dec 2025',
        'medicines': ['Isotretinoin 20mg', 'Vitamin C Serum'],
        'active': true,
      },
      {
        'doctor': 'Dr. John Doe',
        'specialty': 'Cardiology',
        'date': '10 Nov 2025',
        'medicines': ['Aspirin 75mg', 'Atorvastatin 10mg'],
        'active': false,
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('My Prescriptions', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? AppTheme.limeGreen : Colors.black)),
        automaticallyImplyLeading: false,
      ),
      // Theme handles background
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prescriptions.length,
        itemBuilder: (context, index) {
          final p = prescriptions[index];
          final isActive = p['active'] as bool;
          final medicines = p['medicines'] as List<String>;

          return Card(
            // Theme handles card color (Dark Surface)
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['doctor'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
                          Text(p['specialty'] as String, style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2), // Adjusted for dark mode
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isActive ? Colors.green.shade400 : Colors.grey.shade600)
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Past',
                          style: GoogleFonts.outfit(
                            color: isActive ? Colors.greenAccent : Colors.grey, // Brighter for dark mode
                            fontWeight: FontWeight.w500,
                            fontSize: 12
                          ),
                        ),
                      )
                    ],
                  ),
                  const Divider(height: 24, color: Colors.grey),
                  Text('Medicines:', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  ...medicines.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.medication, size: 16, color: AppTheme.limeGreen), // Theme color
                        const SizedBox(width: 8),
                        Text(m, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)), // Theme handles color
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(p['date'] as String, style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
