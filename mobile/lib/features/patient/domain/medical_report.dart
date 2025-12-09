
class MedicalReport {
  final String id;
  final String title;
  final String doctorName;
  final DateTime date;
  final String type; // e.g., 'Lab Result', 'X-Ray', 'Prescription'
  final String fileUrl;
  final List<String> tags;

  MedicalReport({
    required this.id,
    required this.title,
    required this.doctorName,
    required this.date,
    required this.type,
    required this.fileUrl,
    required this.tags,
  });

  factory MedicalReport.dummy() {
    return MedicalReport(
      id: '1',
      title: 'Blood Test Results',
      doctorName: 'Dr. Smith',
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: 'Lab Result',
      fileUrl: '',
      tags: ['blood', 'routine'],
    );
  }
}
