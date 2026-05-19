import 'dart:math';

import 'package:flutter/material.dart';

import '../../storage/local_store.dart';

class DigitSpanScreen extends StatefulWidget {
  const DigitSpanScreen({
    super.key,
  });

  @override
  State<DigitSpanScreen> createState() =>
      _DigitSpanScreenState();
}

class _DigitSpanScreenState
    extends State<DigitSpanScreen> {
  final Random _random = Random();

  final TextEditingController
      inputController =
      TextEditingController();

  List<int> currentDigits = [];

  int currentSpan = 3;

  bool showingDigits = true;

  bool testFinished = false;

  int maxSpanAchieved = 0;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    generateDigits();
  }

  @override
  void dispose() {
    inputController.dispose();

    super.dispose();
  }

  void generateDigits() {
    currentDigits = List.generate(
      currentSpan,
      (_) => _random.nextInt(9) + 1,
    );

    showingDigits = true;

    inputController.clear();

    Future.delayed(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;

        setState(() {
          showingDigits = false;
        });
      },
    );
  }

  Future<void> submitAnswer() async {

  if (saving) return;

  FocusScope.of(context).unfocus();

  final userInput =
      inputController.text
          .replaceAll(" ", "");

  final correct =
      currentDigits.join("");

  bool endTest = false;

  // =========================
  // CORRECT ANSWER
  // =========================

  if (userInput == correct) {

    maxSpanAchieved =
        currentSpan;

    currentSpan++;

  }

  // =========================
  // WRONG ANSWER
  // =========================

  else {

    endTest = true;
  }

  // =========================
  // MAX LIMIT REACHED
  // =========================

  if (currentSpan > 5) {
    endTest = true;
  }

  // =========================
  // FINISH TEST
  // =========================

  if (endTest) {

    setState(() {
      saving = true;
    });

    final currentUser =
        await LocalStore
            .getCurrentUser();

    if (currentUser == null) {

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      return;
    }

    await LocalStore
        .saveDigitSpanScore(
      currentUser,
      maxSpanAchieved,
    );

    if (!mounted) return;

    setState(() {
      testFinished = true;
      saving = false;
    });

    return;
  }

  // =========================
  // NEXT ROUND
  // =========================

  generateDigits();

  if (mounted) {
    setState(() {});
  }
}

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true,
      appBar: AppBar(
        title: const Text(
          "Digit Span Activity",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child: testFinished
              ? _resultView()
              : _testView(),
        ),
      ),
    );
  }

  Widget _testView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          const Text(
            "Remember the numbers in the same order.",
            style: TextStyle(
              fontSize: 18,
            ),
            textAlign:
                TextAlign.center,
          ),

          const SizedBox(height: 32),

          if (showingDigits)
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                18,
              ),
              decoration:
                  BoxDecoration(
                border: Border.all(
                  color:
                      Colors.grey,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
              ),
              child: Text(
                currentDigits.join(
                  " ",
                ),
                style:
                    const TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight
                          .bold,
                ),
                textAlign:
                    TextAlign.center,
              ),
            )
          else
            Column(
              children: [
                TextField(
                  controller:
                      inputController,
                  keyboardType:
                      TextInputType
                          .number,
                  textInputAction:
                      TextInputAction
                          .done,
                  onSubmitted:
                      (_) async {
                    await submitAnswer();
                  },
                  decoration:
                      const InputDecoration(
                    border:
                        OutlineInputBorder(),
                    hintText:
                        "Enter numbers",
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 52,
                  child:
                      ElevatedButton(
                    onPressed:
                        saving
                            ? null
                            : () async {
                                await submitAnswer();
                              },
                    child: saving
                        ? const SizedBox(
                            height:
                                22,
                            width:
                                22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                            ),
                          )
                        : const Text(
                            "Submit",
                          ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _resultView() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment
                .center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 70,
            color: Colors.green,
          ),

          const SizedBox(
            height: 24,
          ),

          const Text(
            "Activity completed",
            style: TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            "Maximum span achieved: $maxSpanAchieved",
            style:
                const TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          const Text(
            "Your responses have been recorded.",
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign:
                TextAlign.center,
          ),

          const SizedBox(
            height: 32,
          ),

          SizedBox(
            width: 220,
            child:
                ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                "Return to Home",
              ),
            ),
          ),
        ],
      ),
    );
  }
}