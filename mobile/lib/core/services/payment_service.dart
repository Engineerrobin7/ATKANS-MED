import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';

class PaymentService {
  late Razorpay _razorpay;
  final Function(PaymentSuccessResponse) onSuccess;
  final Function(PaymentFailureResponse) onFailure;
  final Function(ExternalWalletResponse) onExternalWallet;

  // Test Key (Replace with Live Key in production)
  static const String _keyId = 'rzp_test_1DP5mmOlF5G5ag'; 

  PaymentService({
    required this.onSuccess,
    required this.onFailure,
    required this.onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  Future<void> openCheckout({
    required double amount, // Amount in INR
    required String planId, // "silver" or "gold"
    required String name,
    required String description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final email = prefs.getString('user_email') ?? 'user@example.com';
      final phone = prefs.getString('user_phone') ?? '9999999999';
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        debugPrint('User not logged in');
        return;
      }

      // 1. Create Subscription on Server
      final response = await http.post(
        Uri.parse(ApiConstants.subscriptionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'plan': planId,
          'userId': userId,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to create subscription: ${response.body}');
        // Fallback or error handling
        return;
      }

      final data = jsonDecode(response.body);
      final subscriptionId = data['subscriptionId']; // Razorpay Subscription ID

      // 2. Open Razorpay
      var options = {
        'key': _keyId,
        'subscription_id': subscriptionId, // Important!
        'name': name,
        'description': description,
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'prefill': {
          'contact': phone,
          'email': email
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
