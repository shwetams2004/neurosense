import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../../storage/local_store.dart';

class SpeechSampleScreen
    extends StatefulWidget {
  const SpeechSampleScreen({
    super.key,
  });

  @override
  State<SpeechSampleScreen>
      createState() =>
          _SpeechSampleScreenState();
}

class _SpeechSampleScreenState
    extends State<
        SpeechSampleScreen> {
  final Record recorder = Record();

  bool recording = false;

  Future<void> startRecording() async {
    if (await recorder.hasPermission()) {
      await recorder.start();

      if (mounted) {
        setState(() {
          recording = true;
        });
      }
    }
  }

  Future<void> stopRecording() async {
    final path =
        await recorder.stop();

    if (mounted) {
      setState(() {
        recording = false;
      });
    }

    final currentUser =
        await LocalStore
            .getCurrentUser();

    if (currentUser == null) {
      return;
    }

    if (path != null) {
      await LocalStore
          .saveSpeechMetrics(
        userId: currentUser,
        metrics: {
          "pause_ratio": 0.32,
          "speech_rate": 110,
          "hesitation_events": 5,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Speech sample saved successfully.",
            ),
          ),
        );
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Speech Activity",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(24),

        child: Column(
          children: [
            const Text(
              "Please describe the picture shown below for 30 seconds.",
              style: TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(
                height: 24),

            Container(
              height: 180,

              color:
                  Colors.grey.shade300,

              child: const Center(
                child: Text(
                  "Picture Placeholder",
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(
                onPressed: recording
                    ? stopRecording
                    : startRecording,

                child: Text(
                  recording
                      ? "Stop Recording"
                      : "Start Recording",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}