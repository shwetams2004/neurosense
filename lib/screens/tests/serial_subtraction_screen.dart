import 'package:flutter/material.dart';
import '../../storage/local_store.dart';

class SerialSubtractionScreen extends StatefulWidget {
  const SerialSubtractionScreen({super.key});

  @override
  State<SerialSubtractionScreen> createState() =>
      _SerialSubtractionScreenState();
}

class _SerialSubtractionScreenState
    extends State<SerialSubtractionScreen> {
  int current = 100;
  int correct = 0;
  int errors = 0;
  final TextEditingController controller =
      TextEditingController();

  void submit() {
    final input = int.tryParse(controller.text);
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
  }

  Future<void> finish() async {
    await LocalStore.saveSerialSubtractionResult(
      correct: correct,
      errors: errors,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mental Calculation")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "Starting from $current, subtract 7 each time",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Your answer"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submit,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
