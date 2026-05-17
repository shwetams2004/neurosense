import 'package:flutter/material.dart';

import '../../storage/local_store.dart';
import '../../passive/keyboard_tracker.dart';

class MemoryTestScreen extends StatefulWidget {
  const MemoryTestScreen({super.key});

  @override
  State<MemoryTestScreen> createState() =>
      _MemoryTestScreenState();
}

class _MemoryTestScreenState
    extends State<MemoryTestScreen> {
  final List<String> words = const [
    "Apple",
    "River",
    "Chair",
    "Doctor",
    "Clock",
  ];

  bool showingWords = true;

  final TextEditingController recallController =
      TextEditingController();

  String _previousText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memory Activity"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: showingWords
            ? _learningPhase()
            : _recallPhase(),
      ),
    );
  }

  /* ==============================
     LEARNING PHASE
     ============================== */

  Widget _learningPhase() {
    return Column(
      children: [
        const Text(
          "Please read and remember these words.",
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        ...words.map(
          (w) => Padding(
            padding:
                const EdgeInsets.symmetric(
              vertical: 6,
            ),
            child: Text(
              w,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                showingWords = false;
              });
            },
            child: const Text("Continue"),
          ),
        ),
      ],
    );
  }

  /* ==============================
     RECALL PHASE
     ============================== */

  Widget _recallPhase() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Please type the words you remember.\n"
          "(Any order, separated by spaces)",
          style: TextStyle(fontSize: 18),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: recallController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText:
                "Type remembered words here",
          ),
          maxLines: 3,
          onChanged: (value) {
            final isBackspace =
                value.length <
                    _previousText.length;

            KeyboardTracker.onKeyPress(
              isBackspace: isBackspace,
            );

            _previousText = value;
          },
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final currentUser =
                  await LocalStore
                      .getCurrentUser();

              if (currentUser == null) {
                return;
              }

              final input = recallController.text
                  .toLowerCase();

              final recalledWords =
                  input.split(
                RegExp(r'\s+'),
              );

              int score = 0;

              for (final word in words) {
                if (recalledWords.contains(
                  word.toLowerCase(),
                )) {
                  score++;
                }
              }

              // =========================
              // SAVE USER-SPECIFIC SCORE
              // =========================

              await LocalStore
                  .saveMemoryScore(
                currentUser,
                score,
              );

              // =========================
              // PASSIVE KEYBOARD METRICS
              // =========================

              final metrics =
                  KeyboardTracker
                      .exportDailyMetrics();

              await LocalStore
                  .saveKeyboardMetrics(
                metrics,
              );

              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      "Memory score saved for current user.\nScore: $score/${words.length}",
                    ),
                  ),
                );
              }

              Navigator.pop(context);
            },
            child: const Text("Finish"),
          ),
        ),
      ],
    );
  }
}