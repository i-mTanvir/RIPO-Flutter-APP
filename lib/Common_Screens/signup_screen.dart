import 'package:flutter/material.dart';
import 'package:ripo/Common_Screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController    = TextEditingController();
  final _emailController       = TextEditingController();
  final _phoneController       = TextEditingController();
  final _passwordController    = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // ── Reusable label with optional required asterisk ──
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

  // ── Reusable text field ──
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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

              // ── Top image ──
              SizedBox(height: size.height * 0.04),
              Image.asset(
                'lib/media/splash_image.png',
                width: size.width * 0.38,
                fit: BoxFit.contain,
              ),

              SizedBox(height: size.height * 0.035),

              // ── Full Name ──
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

              // ── Email Address ──
              Align(
                alignment: Alignment.centerLeft,
                child: _fieldLabel('Email Address'),
              ),
              const SizedBox(height: 8),
              _buildField(
                controller: _emailController,
                hint: 'Enter email or phone number',
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: size.height * 0.022),

              // ── Phone Number (optional) ──
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

              SizedBox(height: size.height * 0.022),

              // ── Password ──
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

              // ── Confirm Password ──
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
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),

              SizedBox(height: size.height * 0.04),

              // ── Sign Up button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6950F4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // ── Already have an account? ──
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
