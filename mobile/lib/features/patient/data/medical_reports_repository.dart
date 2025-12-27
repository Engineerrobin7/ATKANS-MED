import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'package:mobile/core/utils/app_logger.dart'; // Assuming an AppLogger utility exists
import 'package:mobile/features/patient/domain/models/report_model.dart';

final medicalReportsRepositoryProvider = Provider<MedicalReportsRepository>((ref) {
  return MedicalReportsRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

class MedicalReportsRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  MedicalReportsRepository(this._auth, this._firestore, this._storage);

  Future<void> uploadReport(String title, String type, String filePath) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final file = File(filePath);
      final fileName = '${const Uuid().v4()}_${file.path.split('/').last}';
      final storageRef = _storage.ref().child('users/${user.uid}/reports/$fileName');

      // Upload file to Firebase Storage
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Store report metadata in Firestore
      final reportRef = _firestore.collection('users').doc(user.uid).collection('reports');
      await reportRef.add(ReportModel(
        id: '', // Firestore generates ID
        title: title,
        type: type,
        downloadUrl: downloadUrl,
        createdAt: DateTime.now(),
        userId: user.uid,
      ).toMap());

      AppLogger.logInfo('Report uploaded successfully: $title');
    } catch (e, stack) {
      AppLogger.logError('Error uploading report: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Stream<List<ReportModel>> getReports() {
    final user = _auth.currentUser;
    if (user == null) {
      // Return an empty stream if user is not logged in
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList());
  }
}

