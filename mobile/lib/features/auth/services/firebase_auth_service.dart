
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/otp_verification_screen.dart';
import '../../../core/services/auth_service.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(FirebaseAuth.instance, ref);
});

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final Ref _ref;

  FirebaseAuthService(this._firebaseAuth, this._ref);

  Future<void> signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android only feature
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          context.push('/otp-verify', extra: {
            'phoneNumber': phoneNumber,
            'verificationId': verificationId,
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message.toString()),
          ),
        );
      }
    }
  }

  Future<void> verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      String? idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        // Sign in with backend if needed
        // Note: authServiceProvider in core/services/auth_service.dart 
        // doesn't have signInWithBackend yet. 
        // You might need to add it or use an API service.
        if (context.mounted) context.go('/patient-home');
      } else {
        throw Exception("Couldn't get ID token");
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message.toString()),
          ),
        );
      }
    }
  }
}
