import 'dart:math';
import 'package:flutter/material.dart';
import '../../storage/local_store.dart';

class DigitSpanScreen extends StatefulWidget {
  const DigitSpanScreen({super.key});

  @override
  State<DigitSpanScreen> createState() => _DigitSpanScreenState();
}

class _DigitSpanScreenState extends State<DigitSpanScreen> {
  final Random _random = Random();
  final TextEditingController inputController = TextEditingController();

  List<int> currentDigits = [];
  int currentSpan = 3;
  bool showingDigits = true;
  bool testFinished = false;
  int maxSpanAchieved = 0;

  @override
  void initState() {
    super.initState();
    generateDigits();
  }

  void generateDigits() {
    currentDigits =
        List.generate(currentSpan, (_) => _random.nextInt(9) + 1);
    showingDigits = true;
    inputController.clear();

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        showingDigits = false;
      });
    });
  }

  void submitAnswer() async {
    final userInput = inputController.text.replaceAll(" ", "");
    final correct = currentDigits.join("");

    if (userInput == correct) {
      maxSpanAchieved = currentSpan;
      currentSpan++;
      generateDigits();
    } else {
      testFinished = true;
      await LocalStore.saveDigitSpanScore(maxSpanAchieved);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Digit Span Activity")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: testFinished ? _resultView() : _testView(),
      ),
    );
  }

  Widget _testView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Remember the numbers in the same order.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        if (showingDigits)
          Text(
            currentDigits.join(" "),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          TextField(
            controller: inputController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter numbers",
            ),
          ),

        const Spacer(),

        if (!showingDigits)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: submitAnswer,
              child: const Text("Submit"),
            ),
          ),
      ],
    );
  }

  Widget _resultView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 64, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          "Activity completed",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          "Your responses have been recorded.",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Return to Home"),
        ),
      ],
    );
  }
}
