import 'package:flutter/material.dart';
import 'consent_screen.dart';

class CaregiverIntroScreen extends StatelessWidget {
  const CaregiverIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              const Text(
                "NeuroSense",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Designed to be used together by\nan older adult and a family caregiver.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ConsentScreen(),
                        ),
                    );
                    },

                  child: const Text("Get Started"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
