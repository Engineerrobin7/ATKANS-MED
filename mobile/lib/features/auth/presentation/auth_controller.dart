
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final authStateProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

final userDataProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return Stream.value(null);
  return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((doc) => doc.data());
});

class AuthController extends AsyncNotifier<void> {
  late final AuthRepository _authRepository;

  @override
  Future<void> build() async {
    _authRepository = ref.watch(authRepositoryProvider);
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signInWithEmail(email, password));
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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signUpWithEmail(
      email: email, 
      password: password,
      name: name,
      role: role,
      phoneNumber: phoneNumber,
      age: age,
      gender: gender,
      bloodGroup: bloodGroup,
      medicalHistory: medicalHistory,
    ));
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
