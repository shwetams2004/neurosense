import 'package:flutter/material.dart';

import 'user_selection_screen.dart';

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Before We Begin"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "NeuroSense is a pre-clinical cognitive tracking tool.\n\n"
              "It does NOT diagnose Alzheimer’s disease or any medical condition.\n\n"
              "The purpose of this app is to track changes over time and help decide "
              "when a clinical evaluation may be useful.\n\n"
              "Data will be stored securely and shared only with your permission.",
              style: TextStyle(fontSize: 18),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const UserSelectionScreen(),
                    ),
                  );
                },
                child: const Text("I Understand"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}