import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';
import 'package:mobile/features/auth/domain/user_profile.dart';

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(null) {
    _ref.watch(authRepositoryProvider).authStateChanges.listen((uid) {
      if (uid != null) {
        _fetchUserProfile(uid);
      } else {
        state = null;
      }
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    final userData = await _ref.read(authRepositoryProvider).getUserData(uid);
    if (userData != null) {
      state = UserProfile.fromFirestore(userData, uid);
    }
  }
}
