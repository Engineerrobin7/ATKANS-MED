import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile.dart';

// Provider for FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Abstract repository interface
abstract class BaseAuthRepository {
  Stream<User?> authStateChanges();
  Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password, String role);
  Future<void> signInWithPhoneNumber(String phoneNumber);
  Future<UserCredential> verifyOTP(String verificationId, String otp);
  Future<UserProfile?> getUserProfile(String uid);
  Future<void> createUserProfile(UserProfile profile);
  Future<void> signOut();
}

// Firebase implementation
class FirebaseAuthRepository implements BaseAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password, String role) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    
    // Create user profile in Firestore
    if (credential.user != null) {
      final profile = UserProfile(
        uid: credential.user!.uid,
        name: email.split('@')[0], // Temporary, should be updated
        email: email,
        role: role.toLowerCase(),
        createdAt: DateTime.now(),
      );
      await createUserProfile(profile);
    }
    
    return credential;
  }

  String? _verificationId;

  @override
  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (Android only)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e.message ?? 'Phone verification failed';
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  @override
  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc.data()!, uid);
  }

  @override
  Future<void> createUserProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.uid).set(profile.toFirestore());
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

// Mock repository for development
class MockAuthRepository implements BaseAuthRepository {
  User? _currentUser;

  @override
  Stream<User?> authStateChanges() {
    return Stream.value(_currentUser);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    // Return mock success
    return Future.value(null as UserCredential);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password, String role) async {
    await Future.delayed(const Duration(seconds: 1));
    return Future.value(null as UserCredential);
  }

  @override
  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    return Future.value(null as UserCredential);
  }

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UserProfile(
      uid: uid,
      name: 'Test User',
      email: 'test@example.com',
      role: 'patient',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> createUserProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}

// Provider for repository
final authRepositoryProvider = Provider<BaseAuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  
  // TODO: Switch to FirebaseAuthRepository when Firebase is configured
  // return FirebaseAuthRepository(auth: auth, firestore: firestore);
  return MockAuthRepository();
});
