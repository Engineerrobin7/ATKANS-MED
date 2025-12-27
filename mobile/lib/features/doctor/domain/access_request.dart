class AccessRequest {
  final String id;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final String reason;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final DateTime? expiresAt;
  final String status; // 'pending', 'approved', 'rejected', 'expired'
  final int durationHours;

  AccessRequest({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.reason,
    required this.requestedAt,
    this.approvedAt,
    this.expiresAt,
    required this.status,
    required this.durationHours,
  });

  factory AccessRequest.fromFirestore(Map<String, dynamic> data, String id) {
    return AccessRequest(
      id: id,
      doctorId: data['doctorId'] as String,
      doctorName: data['doctorName'] as String,
      patientId: data['patientId'] as String,
      patientName: data['patientName'] as String,
      reason: data['reason'] as String,
      requestedAt: DateTime.parse(data['requestedAt'] as String),
      approvedAt: data['approvedAt'] != null ? DateTime.parse(data['approvedAt'] as String) : null,
      expiresAt: data['expiresAt'] != null ? DateTime.parse(data['expiresAt'] as String) : null,
      status: data['status'] as String,
      durationHours: data['durationHours'] as int,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'reason': reason,
      'requestedAt': requestedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status,
      'durationHours': durationHours,
    };
  }

  bool get isActive {
    if (status != 'approved') return false;
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt!);
  }
}
