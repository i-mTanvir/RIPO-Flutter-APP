// lib\Common_Screens\signup_screen.dart
import 'package:flutter/material.dart';
import 'package:ripo/Common_Screens/login_screen.dart';
import 'package:ripo/core/app_snackbar.dart';
import 'package:ripo/core/auth_service.dart';
import 'package:ripo/core/role_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static final RegExp _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _nidController = TextEditingController();
  final _licenseController = TextEditingController();
  final _ageController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  AppUserRole _selectedRole = AppUserRole.customer;
  String? _selectedGender = 'Male';

  bool get _isProvider => _selectedRole == AppUserRole.provider;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    _nidController.dispose();
    _licenseController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Widget _fieldLabel(String label, {bool required = true}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        children: [
          TextSpan(text: label),
          if (required)
            const TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.black38,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6950F4)),
        ),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black45,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F1FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleButton(
              label: 'Customer',
              role: AppUserRole.customer,
            ),
          ),
          Expanded(
            child: _buildRoleButton(
              label: 'Service Provider',
              role: AppUserRole.provider,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required String label,
    required AppUserRole role,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6950F4) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6950F4)),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: (value) => setState(() => _selectedGender = value),
    );
  }

  Future<void> _signUp() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPassController.text.trim();
    final nid = _nidController.text.trim();
    final license = _licenseController.text.trim();
    final ageText = _ageController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      context.showAppSnackBar('Full name, email, and password are required.',
          isError: true);
      return;
    }

    if (!_emailPattern.hasMatch(email)) {
      context.showAppSnackBar('Enter a valid email address.', isError: true);
      return;
    }

    if (password != confirmPassword) {
      context.showAppSnackBar('Password and confirm password do not match.',
          isError: true);
      return;
    }

    if (password.length < 6) {
      context.showAppSnackBar('Password must be at least 6 characters.',
          isError: true);
      return;
    }

    int? age;
    if (_isProvider) {
      if (nid.isEmpty ||
          license.isEmpty ||
          ageText.isEmpty ||
          _selectedGender == null) {
        context.showAppSnackBar(
          'Provider signup requires NID, license number, gender, and age.',
          isError: true,
        );
        return;
      }
      age = int.tryParse(ageText);
      if (age == null || age <= 0) {
        context.showAppSnackBar('Enter a valid age.', isError: true);
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final result = await AuthService.signUp(
        role: _selectedRole,
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        gender: _isProvider ? _selectedGender : null,
        age: age,
        nidNumber: _isProvider ? nid : null,
        tradeLicenseNumber: _isProvider ? license : null,
      );

      if (!mounted) return;
      if (result.needsEmailConfirmation) {
        context.showAppSnackBar(
            'Account created. Please verify your email before login.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => screenForRole(result.userRole)),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      context.showAppSnackBar(error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      context.showAppSnackBar('Could not create account.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.04),
              Image.asset(
                'lib/media/splash_image.png',
                width: size.width * 0.38,
                fit: BoxFit.contain,
              ),
              SizedBox(height: size.height * 0.035),
              Align(
                alignment: Alignment.centerLeft,
                child: _fieldLabel('Sign Up As'),
              ),
              const SizedBox(height: 8),
              _buildRoleSelector(),
              SizedBox(height: size.height * 0.022),
              Align(
                alignment: Alignment.centerLeft,
                child: _fieldLabel('Full Name'),
              ),
              const SizedBox(height: 8),
              _buildField(
                controller: _fullNameController,
                hint: 'Enter Full Name',
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: size.height * 0.022),
              Align(
                alignment: Alignment.centerLeft,
                child: _fieldLabel('Email Address'),
              ),
              const SizedBox(height: 8),
              _buildField(
                controller: _emailController,
                hint: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: size.height * 0.022),
              Align(
                alignment: Alignment.centerLeft,
                child: _fieldLabel('Phone Number', required: false),
              ),
              const SizedBox(height: 8),
              _buildField(
                controller: _phoneController,
                hint: 'Enter phone number',
                keyboardType: TextInputType.phone,
              ),
              if (_isProvider) ...[
                SizedBox(height: size.height * 0.022),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _fieldLabel('NID Number'),
                ),
                const SizedBox(height: 8),
                _buildField(
                  controller: _nidController,
                  hint: 'Enter NID number',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: size.height * 0.022),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _fieldLabel('License Number'),
                ),
                const SizedBox(height: 8),
                _buildField(
                  controller: _licenseController,
                  hint: 'Enter trade license number',
                ),
                SizedBox(height: size.height * 0.022),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Gender'),
                          const SizedBox(height: 8),
                          _buildGenderDropdown(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Age'),
                          const SizedBox(height: 8),
                          _buildField(
                            controller: _ageController,
                            hint: 'Enter age',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: size.height * 0.022),
              Align(
                alignment: Alignment.centerLeft,
                child: _fieldLabel('Password'),
              ),
              const SizedBox(height: 8),
              _buildField(
                controller: _passwordController,
                hint: '••••••••••••',
                obscure: _obscurePassword,
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              SizedBox(height: size.height * 0.022),
              Align(
                alignment: Alignment.centerLeft,
                child: _fieldLabel('Confirm Password'),
              ),
              const SizedBox(height: 8),
              _buildField(
                controller: _confirmPassController,
                hint: '••••••••••••',
                obscure: _obscureConfirmPassword,
                onToggleObscure: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
              SizedBox(height: size.height * 0.04),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6950F4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isLoading ? 'Creating Account...' : 'Sign Up',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6950F4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
