import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/access_request.dart';

class AccessRequestRepository {
  final FirebaseFirestore _firestore;

  AccessRequestRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // Get all access requests for a doctor
  Stream<List<AccessRequest>> getDoctorRequests(String doctorId) {
    return _firestore
        .collection('access_requests')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AccessRequest.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get all access requests for a patient
  Stream<List<AccessRequest>> getPatientRequests(String patientId) {
    return _firestore
        .collection('access_requests')
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AccessRequest.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Create a new access request
  Future<void> createRequest(AccessRequest request) async {
    await _firestore.collection('access_requests').add(request.toFirestore());
  }

  // Approve access request
  Future<void> approveRequest(String requestId, int durationHours) async {
    final now = DateTime.now();
    final expiresAt = now.add(Duration(hours: durationHours));
    
    await _firestore.collection('access_requests').doc(requestId).update({
      'status': 'approved',
      'approvedAt': now.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    });
  }

  // Reject access request
  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('access_requests').doc(requestId).update({
      'status': 'rejected',
    });
  }

  // Check if doctor has active access to patient
  Future<bool> hasActiveAccess(String doctorId, String patientId) async {
    final snapshot = await _firestore
        .collection('access_requests')
        .where('doctorId', isEqualTo: doctorId)
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'approved')
        .get();

    for (final doc in snapshot.docs) {
      final request = AccessRequest.fromFirestore(doc.data(), doc.id);
      if (request.isActive) return true;
    }
    return false;
  }
}

// Provider
final accessRequestRepositoryProvider = Provider<AccessRequestRepository>((ref) {
  return AccessRequestRepository(
    firestore: FirebaseFirestore.instance,
  );
});
