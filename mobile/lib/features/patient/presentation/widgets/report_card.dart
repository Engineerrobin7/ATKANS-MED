
import 'package:flutter/material.dart';
import '../../domain/models/report_model.dart';
import '../../../../core/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description_outlined, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  report.type,
                  style: GoogleFonts.outfit(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Colors.grey),
            onPressed: () {
              // Handle download/view
            },
          ),
        ],
      ),
    );
  }
}
