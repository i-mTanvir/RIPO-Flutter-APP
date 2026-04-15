// lib\Common_Screens\splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ripo/Common_Screens/welcome_screen.dart';
import 'package:ripo/core/auth_service.dart';
import 'package:ripo/core/role_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        final session = AuthService.currentSession;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) {
              if (session == null) {
                return const WelcomeScreen();
              }

              final roleValue =
                  session.user.userMetadata?['role'] as String? ?? 'customer';
              final role = AppUserRole.values.firstWhere(
                (item) => item.name == roleValue,
                orElse: () => AppUserRole.customer,
              );
              return screenForRole(role);
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF6950F4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: const BoxDecoration(
                color: Color(0xFF8773F6),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.06),
                child: Image.asset(
                  'lib/media/splash_image.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.04),
            const Text(
              'RIPO - Service APP',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
