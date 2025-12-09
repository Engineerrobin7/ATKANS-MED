
import 'package:flutter/material.dart';
import '../domain/medical_report.dart';
import '../../../core/theme/app_theme.dart';

class PatientReportsScreen extends StatelessWidget {
  const PatientReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final reports = List.generate(
      5,
      (index) => MedicalReport(
        id: '$index',
        title: index % 2 == 0 ? 'General Checkup' : 'X-Ray Report',
        doctorName: 'Dr. Sarah Wilson',
        date: DateTime.now().subtract(Duration(days: index * 5)),
        type: index % 2 == 0 ? 'Prescription' : 'Radiology',
        fileUrl: '',
        tags: index % 2 == 0 ? ['routine'] : ['critical', 'bones'],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('My Medical Reports')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        report.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      Chip(
                        label: Text(report.type, style: const TextStyle(fontSize: 10, color: Colors.black)),
                        backgroundColor: AppTheme.limeGreen,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(report.doctorName, style: const TextStyle(color: Colors.grey)),
                      const Spacer(),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "${report.date.day}/${report.date.month}/${report.date.year}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: report.tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF333333),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('#$tag', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ))
                        .toList(),
                  ),
                  const Divider(height: 24, color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility),
                        label: const Text('View'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Upload new report
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
