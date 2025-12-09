
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Abstract class for easier mocking
abstract class BaseAuthRepository {
  Stream<String?> get authStateChanges;
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signOut();
}

final authRepositoryProvider = Provider<BaseAuthRepository>((ref) {
  // Return MockAuthRepository since Firebase is not initialized
  return MockAuthRepository();
});

class MockAuthRepository implements BaseAuthRepository {
  @override
  Stream<String?> get authStateChanges => Stream.value(null); // Always logged out initially

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    // Allow any login for demo
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
