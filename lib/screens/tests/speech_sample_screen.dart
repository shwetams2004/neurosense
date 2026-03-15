import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import '../../storage/local_store.dart';

class SpeechSampleScreen extends StatefulWidget {
  const SpeechSampleScreen({super.key});

  @override
  State<SpeechSampleScreen> createState() => _SpeechSampleScreenState();
}

class _SpeechSampleScreenState extends State<SpeechSampleScreen> {
  final Record recorder = Record();
  bool recording = false;

  @override
  Future<void> startRecording() async {
    if (await recorder.hasPermission()) {
      await recorder.start();
      setState(() => recording = true);
    }
  }

  @override
  Future<void> stopRecording() async {
    final path = await recorder.stop();
    setState(() => recording = false);

    if (path != null) {
      // MOCK FEATURE EXTRACTION (v1)
      await LocalStore.saveSpeechMetrics({
        "pause_ratio": 0.32,
        "speech_rate": 110,
        "hesitation_events": 5,
      });
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Speech Activity")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Please describe the picture shown below for 30 seconds.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            Container(
              height: 180,
              color: Colors.grey.shade300,
              child: const Center(child: Text("Picture Placeholder")),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: recording ? stopRecording : startRecording,
              child: Text(recording ? "Stop Recording" : "Start Recording"),
            ),
          ],
        ),
      ),
    );
  }
}
