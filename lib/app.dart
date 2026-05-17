import 'screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding/caregiver_intro_screen.dart';

class NeuroSenseApp extends StatelessWidget {
  const NeuroSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeuroSense',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
