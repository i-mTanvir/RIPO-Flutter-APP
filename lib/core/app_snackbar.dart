import 'package:flutter/material.dart';

extension AppSnackbar on BuildContext {
  void showAppSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFD32F2F) : Colors.green,
      ),
    );
  }
}
