import 'package:flutter/material.dart';
import 'package:ripo/Common_Screens/forget_password.dart';
import 'package:ripo/Common_Screens/signup_screen.dart';
import 'package:ripo/core/app_snackbar.dart';
import 'package:ripo/core/auth_service.dart';
import 'package:ripo/core/role_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      context.showAppSnackBar('Email and password are required.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final role = await AuthService.signIn(email: email, password: password);
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => screenForRole(role)),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      context.showAppSnackBar(error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      context.showAppSnackBar('Invalid email or password. Try again.', isError: true);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RIPO - Logo',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.language, size: 16, color: Colors.black54),
                    label: const Text(
                      'English',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.04),
              Image.asset(
                'lib/media/splash_image.png',
                width: size.width * 0.4,
                fit: BoxFit.contain,
              ),
              SizedBox(height: size.height * 0.04),
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(text: 'Email Address'),
                      TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter email address',
                  hintStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black38,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              ),
              SizedBox(height: size.height * 0.025),
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(text: 'Password'),
                      TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                decoration: InputDecoration(
                  hintText: '••••••••••••',
                  hintStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black38,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.black45,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.015),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (val) => setState(() => _rememberMe = val ?? false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        side: const BorderSide(color: Colors.black45),
                        activeColor: const Color(0xFF6950F4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Text(
                        'Remember me',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgetPasswordScreen()),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6950F4),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6950F4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isLoading ? 'Logging In...' : 'Log in',
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
                    const TextSpan(text: "Don't have an account? "),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
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
