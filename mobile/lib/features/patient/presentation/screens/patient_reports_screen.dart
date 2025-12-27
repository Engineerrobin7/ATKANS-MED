import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/patient/data/medical_reports_repository.dart';
import 'package:mobile/features/patient/domain/models/report_model.dart';
import 'package:mobile/features/patient/presentation/widgets/report_card.dart';

class PatientReportsScreen extends ConsumerWidget {
  const PatientReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsStream = ref.watch(medicalReportsRepositoryProvider).getReports();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medical Reports',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: StreamBuilder<List<ReportModel>>(
        stream: reportsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: theme.textTheme.bodySmall?.color)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.file_copy, size: 80, color: theme.disabledColor),
                  const SizedBox(height: 20),
                  Text(
                    'No medical reports yet.',
                    style: GoogleFonts.outfit(fontSize: 18, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                  ),
                  Text(
                    'Tap the + button to upload your first report!',
                    style: GoogleFonts.outfit(fontSize: 14, color: theme.textTheme.bodySmall?.color),
                  ),
                ],
              ),
            );
          } else {
            final reports = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ReportCard(report: report); // Assuming ReportCard widget exists
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to upload report screen
          context.go('/patient-home/reports/upload');
        },
        label: Text('Upload Report', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.limeGreen,
        foregroundColor: Colors.black,
      ),
    );
  }
}
