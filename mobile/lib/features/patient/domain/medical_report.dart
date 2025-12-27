class MedicalReport {
  final String id;
  final String patientId;
  final String title;
  final String type; // 'prescription', 'lab_report', 'radiology', 'discharge_summary'
  final String doctorId;
  final String doctorName;
  final DateTime createdAt;
  final List<String> fileUrls;
  final List<String> tags;
  final Map<String, dynamic>? metadata;

  MedicalReport({
    required this.id,
    required this.patientId,
    required this.title,
    required this.type,
    required this.doctorId,
    required this.doctorName,
    required this.createdAt,
    required this.fileUrls,
    this.tags = const [],
    this.metadata,
  });

  factory MedicalReport.fromFirestore(Map<String, dynamic> data, String id) {
    return MedicalReport(
      id: id,
      patientId: data['patientId'] as String,
      title: data['title'] as String,
      type: data['type'] as String,
      doctorId: data['doctorId'] as String,
      doctorName: data['doctorName'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      fileUrls: List<String>.from(data['fileUrls'] as List),
      tags: List<String>.from(data['tags'] as List? ?? []),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'title': title,
      'type': type,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'createdAt': createdAt.toIso8601String(),
      'fileUrls': fileUrls,
      'tags': tags,
      'metadata': metadata,
    };
  }
}
