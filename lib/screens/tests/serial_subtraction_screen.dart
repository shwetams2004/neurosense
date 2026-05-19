import 'package:flutter/material.dart';

import '../../storage/local_store.dart';

class SerialSubtractionScreen
    extends StatefulWidget {
  const SerialSubtractionScreen({
    super.key,
  });

  @override
  State<SerialSubtractionScreen>
      createState() =>
          _SerialSubtractionScreenState();
}

class _SerialSubtractionScreenState
    extends State<
        SerialSubtractionScreen> {
  int current = 100;

  int correct = 0;

  int errors = 0;

  final TextEditingController
      controller =
      TextEditingController();

  void submit() {
    final input = int.tryParse(
      controller.text,
    );

    if (input == null) return;

    if (input == current - 7) {
      correct++;

      current = input;
    } else {
      errors++;
    }

    controller.clear();

    if (correct + errors >= 5) {
      finish();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> finish() async {
    final currentUser =
        await LocalStore
            .getCurrentUser();

    if (currentUser == null) {
      return;
    }

    await LocalStore
        .saveSerialSubtractionResult(
      userId: currentUser,
      correct: correct,
      errors: errors,
    );

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Calculation activity saved.\nCorrect: $correct | Errors: $errors",
          ),
        ),
      );
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
          "Mental Calculation",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              "Starting from $current, subtract 7 and enter ONE answer at a time.",
              style:
                  const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(
                height: 24),

            TextField(
              controller:
                  controller,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(
                labelText:
                    "Your answer",

                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
                height: 20),

            Text(
              "Correct: $correct | Errors: $errors",
              style:
                  const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(
                onPressed: submit,

                child: const Text(
                  "Submit",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}