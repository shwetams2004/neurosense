import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

import 'screens/onboarding/welcome_screen.dart';

class NeuroSenseApp
    extends StatelessWidget {

  const NeuroSenseApp({
    super.key,
  });

  @override
  Widget build(
      BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner:
          false,

      title: 'NeuroSense',

      theme: AppTheme.lightTheme,

      home: const WelcomeScreen(),
    );
  }
}