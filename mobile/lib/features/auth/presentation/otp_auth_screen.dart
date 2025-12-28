import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import 'package:go_router/go_router.dart';

// OTP Service Provider
final otpServiceProvider = Provider((ref) => OTPService());

class OTPService {
  static const String baseUrl = ApiConstants.authUrl;
  
  // Send OTP via email
  Future<Map<String, dynamic>> sendOTPEmail({
    required String email,
    required String role,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/send-otp');
      print('🚀 Sending OTP (Email) to: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'role': role,
          'method': 'email',
        }),
      ).timeout(const Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'OTP sent to your email',
          'email': email,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      print('❌ Send OTP Email Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Send OTP via phone (SMS)
  Future<Map<String, dynamic>> sendOTPPhone({
    required String phone,
    required String role,
  }) async {
    try {
      if (!phone.startsWith('+')) {
        return {
          'success': false,
          'message': 'Phone must start with + (e.g., +919876543210)',
        };
      }

      final url = Uri.parse('$baseUrl/send-otp');
      print('🚀 Sending OTP (Phone) to: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'role': role,
          'method': 'sms',
        }),
      ).timeout(const Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'OTP sent to your phone',
          'phone': phone,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      print('❌ Send OTP Phone Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP({
    required String? email,
    required String? phone,
    required String otp,
    required String name,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/verify-otp');
      print('🚀 Verifying OTP at: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'phone': phone,
          'otp': otp,
          'name': name,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        if (data['user']['email'] != null) await prefs.setString('user_email', data['user']['email']);
        if (data['user']['role'] != null) await prefs.setString('user_role', data['user']['role']);
        if (data['user']['name'] != null) await prefs.setString('user_name', data['user']['name']);
        
        final image = data['user']['profileImage'] ?? data['user']['photoUrl'];
        if (image != null) await prefs.setString('user_profile_image', image);
        
        await prefs.setString('user_id', data['user']['id']);
        
        return {
          'success': true,
          'message': 'Logged in successfully',
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid OTP',
        };
      }
    } catch (e) {
      print('❌ Verify OTP Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}

class OTPAuthScreen extends ConsumerStatefulWidget {
  const OTPAuthScreen({super.key});

  @override
  ConsumerState<OTPAuthScreen> createState() => _OTPAuthScreenState();
}

class _OTPAuthScreenState extends ConsumerState<OTPAuthScreen> {
  String _selectedMethod = 'email';
  String _selectedRole = 'patient';
  
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  
  int _currentStep = 1;
  String? _errorMessage;
  bool _isLoading = false;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final otpService = ref.read(otpServiceProvider);
      final result = _selectedMethod == 'email'
          ? await otpService.sendOTPEmail(
              email: _emailController.text.trim(),
              role: _selectedRole,
            )
          : await otpService.sendOTPPhone(
              phone: _phoneController.text.trim(),
              role: _selectedRole,
            );

      setState(() {
        _isLoading = false;
        if (result['success']) {
          _successMessage = result['message'];
          _currentStep = 2;
        } else {
          _errorMessage = result['message'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    if (_otpController.text.isEmpty || _nameController.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter OTP and name';
      });
      return;
    }

    try {
      final otpService = ref.read(otpServiceProvider);
      final result = await otpService.verifyOTP(
        email: _selectedMethod == 'email' ? _emailController.text.trim() : null,
        phone: _selectedMethod == 'phone' ? _phoneController.text.trim() : null,
        otp: _otpController.text.trim(),
        name: _nameController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        if (result['success']) {
          _successMessage = 'Successfully logged in!';
          final user = result['user'];
          final role = user['role'] ?? 'patient';
          
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              if (role == 'doctor') {
                context.go('/doctor-home');
              } else {
                context.go('/patient-home');
              }
            }
          });
        } else {
          _errorMessage = result['message'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Verification error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ATKANS MED - Login'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const Icon(Icons.verified_user, size: 60, color: Colors.teal),
                  const SizedBox(height: 10),
                  Text(
                    _currentStep == 1 ? 'Verify Your Identity' : 'Enter OTP',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _currentStep == 1
                        ? 'Choose how you want to receive the OTP'
                        : 'We sent an OTP to your ${_selectedMethod == 'email' ? 'email' : 'phone'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),

            if (_currentStep == 1) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Your Role',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Patient'),
                            value: 'patient',
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() => _selectedRole = value!);
                            },
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Doctor'),
                            value: 'doctor',
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() => _selectedRole = value!);
                            },
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Verification Method',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedMethod = 'email'),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedMethod == 'email'
                                      ? Colors.teal
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: _selectedMethod == 'email'
                                    ? Colors.teal.withValues(alpha: 0.1)
                                    : Colors.transparent,
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.email, color: Colors.teal, size: 30),
                                  const SizedBox(height: 5),
                                  const Text('Email OTP'),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Faster',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedMethod = 'phone'),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedMethod == 'phone'
                                      ? Colors.teal
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: _selectedMethod == 'phone'
                                    ? Colors.teal.withValues(alpha: 0.1)
                                    : Colors.transparent,
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.phone, color: Colors.teal, size: 30),
                                  const SizedBox(height: 5),
                                  const Text('Phone OTP'),
                                  const SizedBox(height: 3),
                                  Text(
                                    'SMS',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (_selectedMethod == 'email')
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'you@example.com',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabled: !_isLoading,
                  ),
                ),

              if (_selectedMethod == 'phone')
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+919876543210',
                    prefixIcon: const Icon(Icons.phone),
                    helperText: 'Include country code (e.g., +91 for India)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabled: !_isLoading,
                  ),
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Send OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],

            if (_currentStep == 2) ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  hintText: '000000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabled: !_isLoading,
                ),
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Santosh Kumar',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabled: !_isLoading,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Verify & Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 1;
                    _otpController.clear();
                    _nameController.clear();
                  });
                },
                child: const Text('Back to Email/Phone selection'),
              ),

              const SizedBox(height: 15),

              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _sendOTP,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
