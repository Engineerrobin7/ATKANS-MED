import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/widgets/glass_card.dart';

class PatientReportsScreen extends ConsumerStatefulWidget {
  const PatientReportsScreen({super.key});

  @override
  ConsumerState<PatientReportsScreen> createState() => _PatientReportsScreenState();
}

class _PatientReportsScreenState extends ConsumerState<PatientReportsScreen> {
  final List<MedicalReport> _reports = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    // Demo data - will be replaced with Firestore
    setState(() {
      _reports.addAll([
        MedicalReport(
          id: '1',
          title: 'Blood Test Results',
          type: 'Lab Report',
          date: DateTime.now().subtract(const Duration(days: 2)),
          doctorName: 'Dr. Sarah Johnson',
          fileUrl: 'demo_file_1.pdf',
          hasFile: true,
        ),
        MedicalReport(
          id: '2',
          title: 'X-Ray Chest',
          type: 'Radiology',
          date: DateTime.now().subtract(const Duration(days: 15)),
          doctorName: 'Dr. Michael Chen',
          fileUrl: 'demo_file_2.pdf',
          hasFile: true,
        ),
      ]);
    });
  }

  Future<void> _uploadReport() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Upload Medical Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildUploadOption(
              icon: Icons.camera_alt,
              title: 'Take Photo',
              subtitle: 'Capture with camera',
              onTap: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 12),
            _buildUploadOption(
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              subtitle: 'Select image',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 12),
            _buildUploadOption(
              icon: Icons.description,
              title: 'Upload PDF',
              subtitle: 'Select PDF document',
              onTap: _pickPDF,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    
    if (image != null) {
      _showReportDetailsDialog(File(image.path), 'image');
    }
  }

  Future<void> _pickPDF() async {
    Navigator.pop(context);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      _showReportDetailsDialog(File(result.files.single.path!), 'pdf');
    }
  }

  void _showReportDetailsDialog(File file, String type) {
    final titleController = TextEditingController();
    final doctorController = TextEditingController();
    String reportType = 'Lab Report';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Report Details', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Report Title',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: doctorController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Doctor Name',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: reportType,
              dropdownColor: const Color(0xFF2C2C2C),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Report Type',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['Lab Report', 'Radiology', 'Prescription', 'Discharge Summary']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => reportType = val!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _saveReport(
                  titleController.text,
                  doctorController.text,
                  reportType,
                  file,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.black,
            ),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _saveReport(String title, String doctor, String type, File file) {
    setState(() {
      _reports.insert(0, MedicalReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        type: type,
        date: DateTime.now(),
        doctorName: doctor.isEmpty ? 'Self Uploaded' : doctor,
        fileUrl: file.path,
        hasFile: true,
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✓ Report uploaded successfully!'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewReport(MedicalReport report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.description, size: 64, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                report.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                report.type,
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _shareReport(report);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening file... (Demo)')),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareReport(MedicalReport report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share with Doctor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Doctor Email or ID',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Text('Access Duration:', style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildDurationChip('24 Hours'),
                _buildDurationChip('7 Days'),
                _buildDurationChip('30 Days'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('✓ Report shared successfully!'),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Share Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChip(String duration) {
    return Chip(
      label: Text(duration, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF2C2C2C),
      side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _reports.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text('No reports yet', style: TextStyle(fontSize: 18, color: Colors.grey[400])),
                  const SizedBox(height: 8),
                  Text('Upload your first medical report', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                return _buildReportCard(report);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadReport,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Upload Report', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildReportCard(MedicalReport report) {
    return GestureDetector(
      onTap: () => _viewReport(report),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getTypeColor(report.type).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getTypeIcon(report.type), color: _getTypeColor(report.type), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(report.type, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(report.doctorName, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(_formatDate(report.date), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _shareReport(report),
              icon: Icon(Icons.share, color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Lab Report':
        return Icons.science;
      case 'Radiology':
        return Icons.medical_services;
      case 'Prescription':
        return Icons.medication;
      default:
        return Icons.description;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Lab Report':
        return Colors.blue;
      case 'Radiology':
        return Colors.purple;
      case 'Prescription':
        return Colors.green;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class MedicalReport {
  final String id;
  final String title;
  final String type;
  final DateTime date;
  final String doctorName;
  final String fileUrl;
  final bool hasFile;

  MedicalReport({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.doctorName,
    required this.fileUrl,
    this.hasFile = false,
  });
}
