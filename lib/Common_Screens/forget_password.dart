import 'package:flutter/material.dart';
import 'package:ripo/core/app_snackbar.dart';
import 'package:ripo/core/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Top bar: back arrow + title ──
              SizedBox(height: size.height * 0.02),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.04),

              // ── Heading ──
              const Text(
                'Forgot Password',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              // ── Subtitle ──
              const Text(
                'Enter your email address and we will\nsend you code',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black45,
                  height: 1.5,
                ),
              ),

              SizedBox(height: size.height * 0.035),

              // ── Email label ──
              const Text(
                'Email',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // ── Email field ──
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter email',
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
                ),
              ),

              SizedBox(height: size.height * 0.035),

              // ── Verify button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6950F4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Send Reset Email',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      context.showAppSnackBar('Enter your email address first.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.resetPassword(email);
      if (!mounted) return;
      context.showAppSnackBar('Password reset email sent.');
      Navigator.pop(context);
    } on AuthException catch (error) {
      if (!mounted) return;
      context.showAppSnackBar(error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      context.showAppSnackBar('Could not send reset email.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
