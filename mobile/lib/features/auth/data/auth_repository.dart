import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  Stream<String?> get authStateChanges => _auth.authStateChanges().map((user) => user?.uid);

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
    required String phoneNumber,
    int? age,
    String? gender,
    String? bloodGroup,
    String? medicalHistory,
  }) async {
    // 1. Create Auth User
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // 2. Add to Firestore
    if (userCredential.user != null) {
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'role': role,
        'phoneNumber': phoneNumber,
        'age': age,
        'gender': gender,
        'bloodGroup': bloodGroup,
        'medicalHistory': medicalHistory,
        'createdAt': FieldValue.serverTimestamp(),
        'subscriptionStatus': 'inactive',
        'subscriptionPlan': 'Basic',
        'subscriptionStartDate': null,
        'subscriptionEndDate': null,
      });
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  Future<void> updateSubscription({
    required String uid,
    required String subscriptionStatus,
    required String subscriptionPlan,
    required Timestamp subscriptionStartDate,
    required Timestamp subscriptionEndDate,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'subscriptionStatus': subscriptionStatus,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStartDate': subscriptionStartDate,
      'subscriptionEndDate': subscriptionEndDate,
    });
  }
}


