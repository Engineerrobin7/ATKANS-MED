import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../domain/medical_report.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final storageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

class MedicalReportsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  MedicalReportsRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  // Get all reports for a patient
  Stream<List<MedicalReport>> getPatientReports(String patientId) {
    return _firestore
        .collection('medical_reports')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MedicalReport.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Upload a file to Firebase Storage
  Future<String> uploadFile(String patientId, File file, String fileName) async {
    final ref = _storage.ref().child('medical_reports/$patientId/$fileName');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  // Create a new medical report
  Future<void> createReport(MedicalReport report) async {
    await _firestore.collection('medical_reports').add(report.toFirestore());
  }

  // Update a medical report
  Future<void> updateReport(String reportId, Map<String, dynamic> updates) async {
    await _firestore.collection('medical_reports').doc(reportId).update(updates);
  }

  // Delete a medical report
  Future<void> deleteReport(String reportId) async {
    final doc = await _firestore.collection('medical_reports').doc(reportId).get();
    if (doc.exists) {
      final report = MedicalReport.fromFirestore(doc.data()!, reportId);
      
      // Delete files from storage
      for (final url in report.fileUrls) {
        try {
          final ref = _storage.refFromURL(url);
          await ref.delete();
        } catch (e) {
          print('Error deleting file: $e');
        }
      }
      
      // Delete Firestore document
      await doc.reference.delete();
    }
  }

  // Share report with doctor (creates access log)
  Future<void> shareReportWithDoctor(String reportId, String doctorId, DateTime expiresAt) async {
    await _firestore.collection('report_shares').add({
      'reportId': reportId,
      'doctorId': doctorId,
      'sharedAt': DateTime.now().toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    });
  }
}

// Provider
final medicalReportsRepositoryProvider = Provider<MedicalReportsRepository>((ref) {
  return MedicalReportsRepository(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(storageProvider),
  );
});
