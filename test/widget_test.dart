import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ripo/Common_Screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SplashScreen()),
    );

    // Verify app name text is present on the splash screen
    expect(find.text('RIPO - Service APP'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsOneWidget);
  });
}
