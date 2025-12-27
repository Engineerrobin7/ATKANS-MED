
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _loginTypeTabController;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpPhoneController = TextEditingController();
  final _signUpAgeController = TextEditingController();
  final _signUpMedicalController = TextEditingController();
  
  String _selectedRole = 'Patient';
  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'O+';
  final _signUpFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _loginTypeTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _loginTypeTabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpPhoneController.dispose();
    _signUpAgeController.dispose();
    _signUpMedicalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next.hasValue && !next.isLoading && (previous?.isLoading == true)) {
        final role = _selectedRole.toLowerCase();
        context.go(role == 'admin' ? '/admin-dashboard' : '/$role-home');
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppTheme.limeGreen.withOpacity(0.05),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Logo & Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.limeGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.shield_moon_outlined, size: 32, color: AppTheme.limeGreen),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'ATKANS MED',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Main Tabs: Login & Sign Up
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TabBar(
                  controller: _mainTabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorWeight: 0,
                  indicator: BoxDecoration(
                    color: AppTheme.limeGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Login'),
                    Tab(text: 'Sign Up'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Expanded(
                child: TabBarView(
                  controller: _mainTabController,
                  children: [
                    _buildLoginTab(isLoading),
                    _buildSignUpTab(isLoading),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          TabBar(
            controller: _loginTypeTabController,
            labelColor: AppTheme.limeGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.limeGreen,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Phone'),
              Tab(text: 'Email'),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 450,
            child: TabBarView(
              controller: _loginTypeTabController,
              children: [
                _buildPhoneLoginView(isLoading),
                _buildEmailLoginView(isLoading),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLoginView(bool isLoading) {
    return Column(
      children: [
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone_android_outlined,
          type: TextInputType.phone,
          hint: '99999 88888',
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handlePhoneLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.limeGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text('Send Verification Code', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailLoginView(bool isLoading) {
    return Column(
      children: [
        _buildDropdownField(
          label: 'I am a',
          value: _selectedRole,
          items: ['Patient', 'Doctor', 'Executive', 'Admin'],
          onChanged: (val) => setState(() => _selectedRole = val!),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.alternate_email_outlined,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_open_outlined,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: isLoading ? null : () {
              ref.read(authControllerProvider.notifier).signInWithEmail(
                _emailController.text.trim(),
                _passwordController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.limeGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : () {
              ref.read(authControllerProvider.notifier).signInWithGoogle();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            icon: Image.asset('assets/icons/google.png', height: 24), // Ensure you have this asset
            label: const Text('Sign in with Google'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: isLoading ? null : () {
            ref.read(authControllerProvider.notifier).signOut();
          },
          child: const Text('Sign Out', style: TextStyle(color: AppTheme.limeGreen)),
        ),
      ],
    );
  }

  Widget _buildSignUpTab(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _signUpFormKey,
        child: Column(
          children: [
            _buildDropdownField(
              label: 'Sign up as',
              value: _selectedRole,
              items: ['Patient', 'Doctor', 'Executive'],
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signUpNameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 16),
             _buildTextField(
              controller: _signUpEmailController,
              label: 'Email Address',
              icon: Icons.alternate_email,
              type: TextInputType.emailAddress,
              validator: (v) => v!.contains('@') ? null : 'Invalid email',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signUpPhoneController,
              label: 'Phone Number',
              icon: Icons.phone_android_outlined,
              type: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Enter phone number' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signUpPasswordController,
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _signUpAgeController,
                    label: 'Age',
                    icon: Icons.cake_outlined,
                    type: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Gender',
                    value: _selectedGender,
                    items: ['Male', 'Female', 'Other'],
                    onChanged: (val) => setState(() => _selectedGender = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Blood Group',
              value: _selectedBloodGroup,
              items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
              onChanged: (val) => setState(() => _selectedBloodGroup = val!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.limeGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Complete Registration', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _handleSignUp() {
    if (_signUpFormKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).signUpWithEmail(
        email: _signUpEmailController.text.trim(),
        password: _signUpPasswordController.text.trim(),
        name: _signUpNameController.text.trim(),
        role: _selectedRole,
        phoneNumber: _signUpPhoneController.text.trim().startsWith('+') 
            ? _signUpPhoneController.text.trim() 
            : '+91${_signUpPhoneController.text.trim()}',
        age: int.tryParse(_signUpAgeController.text),
        gender: _selectedGender,
        bloodGroup: _selectedBloodGroup,
        medicalHistory: _signUpMedicalController.text.trim(),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: type,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: const Color(0xFF1A1A1A),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: const Icon(Icons.people_outline, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _handlePhoneLogin() async {
    if (_phoneController.text.isEmpty) return;
    
    final phoneNumber = _phoneController.text.trim();
    final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';

    // Reg Check
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: formattedPhone)
        .get();

    if (userQuery.docs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Number not registered. Please sign up!'), backgroundColor: Colors.red),
      );
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
      },
      codeSent: (verificationId, resendToken) {
        context.push('/otp-verify', extra: {
          'phoneNumber': formattedPhone,
          'verificationId': verificationId,
        });
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }
}
