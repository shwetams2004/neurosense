import 'package:flutter/material.dart';
import 'profile_screen.dart';

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
            ElevatedButton(
              onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ProfileScreen(),
    ),
  );
},

              child: const Text("I Understand"),
            ),
          ],
        ),
      ),
    );
  }
}
