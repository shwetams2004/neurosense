import 'dart:math';

import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
import '../../storage/local_store.dart';

class DigitSpanScreen
    extends StatefulWidget {

  const DigitSpanScreen({
    super.key,
  });

  @override
  State<DigitSpanScreen>
      createState() =>
          _DigitSpanScreenState();
}

class _DigitSpanScreenState
    extends State<
        DigitSpanScreen> {

  final Random _random = Random();

  final TextEditingController
      inputController =
      TextEditingController();

  List<int> currentDigits = [];

  int currentSpan = 3;

  bool showingDigits = true;

  bool testFinished = false;

  bool saving = false;

  int maxSpanAchieved = 0;

  int currentRound = 1;

  static const int totalRounds = 3;

  int correctAnswers = 0;

  int wrongAnswers = 0;

  String currentLanguage =
      "English";

  @override
  void initState() {

    super.initState();

    loadLanguage();

    generateDigits();
  }

  Future<void> loadLanguage()
      async {

    currentLanguage =
        await LocalStore
            .getLanguage();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {

    inputController.dispose();

    super.dispose();
  }

  // =========================
  // GENERATE DIGITS
  // =========================

  void generateDigits() {

    currentDigits = List.generate(

      currentSpan,

      (_) => _random.nextInt(9) + 1,
    );

    showingDigits = true;

    inputController.clear();

    Future.delayed(

      const Duration(
        seconds: 3,
      ),

      () {

        if (!mounted) return;

        setState(() {

          showingDigits = false;
        });
      },
    );
  }

  // =========================
  // SUBMIT ANSWER
  // =========================

  Future<void> submitAnswer()
      async {

    if (saving ||
        testFinished) {
      return;
    }

    FocusScope.of(context)
        .unfocus();

    final userInput =
        inputController.text
            .replaceAll(
              " ",
              "",
            );

    final correct =
        currentDigits.join("");

    // =====================
    // CORRECT
    // =====================

    if (userInput == correct) {

      correctAnswers++;

      maxSpanAchieved =
          currentSpan;

      currentSpan++;
    }

    // =====================
    // WRONG
    // =====================

    else {

      wrongAnswers++;
    }

    // =====================
    // TEST FINISHED
    // =====================

    if (currentRound >=
        totalRounds) {

      await finishTest();

      return;
    }

    // =====================
    // NEXT ROUND
    // =====================

    currentRound++;

    generateDigits();

    if (mounted) {
      setState(() {});
    }
  }

  // =========================
  // FINISH TEST
  // =========================

  Future<void> finishTest()
      async {

    setState(() {

      saving = true;
    });

    final currentUser =
        await LocalStore
            .getCurrentUser();

    if (currentUser != null) {

      await LocalStore
          .saveDigitSpanScore(

        currentUser,

        maxSpanAchieved,
      );
    }

    if (!mounted) return;

    setState(() {

      saving = false;

      testFinished = true;
    });
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      resizeToAvoidBottomInset:
          true,

      appBar: AppBar(

        title: Text(

          AppStrings.text(
            "digit_span_title",
            currentLanguage,
          ),
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

  // =========================
  // TEST VIEW
  // =========================

  Widget _testView() {

    return SingleChildScrollView(

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.center,

        children: [

          const SizedBox(
            height: 20,
          ),

          Text(

            "${AppStrings.text(
  "round",
  currentLanguage,
)} $currentRound / $totalRounds",

            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          Text(

            AppStrings.text(
              "digit_instruction",
              currentLanguage,
            ),

            style:
                const TextStyle(
              fontSize: 18,
            ),

            textAlign:
                TextAlign.center,
          ),

          const SizedBox(
            height: 32,
          ),

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
                      InputDecoration(

                    border:
                        const OutlineInputBorder(),

                    hintText:
                        AppStrings.text(
                      "your_answer",
                      currentLanguage,
                    ),
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

                            height: 22,
                            width: 22,

                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                            ),
                          )

                        : Text(

                            AppStrings.text(
                              "submit",
                              currentLanguage,
                            ),
                          ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // =========================
  // RESULT VIEW
  // =========================

  Widget _resultView() {

    return Center(

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment
                .center,

        children: [

          const Icon(

            Icons.check_circle,

            size: 72,

            color: Colors.green,
          ),

          const SizedBox(
            height: 24,
          ),

          Text(

            AppStrings.text(
              "test_completed",
              currentLanguage,
            ),

            style:
                const TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          Text(

            "${AppStrings.text(
              "correct_answer",
              currentLanguage,
            )}: $correctAnswers",

            style:
                const TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(

            "${AppStrings.text(
  "wrong_answers",
  currentLanguage,
)}: $wrongAnswers",

            style:
                const TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(

            "${AppStrings.text(
              "score",
              currentLanguage,
            )}: $maxSpanAchieved",

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(
            height: 32,
          ),

          SizedBox(

            width: 220,

            child:
                ElevatedButton(

  onPressed: () {

    Navigator.pop(context);
  },

  child: Text(

    AppStrings.text(
      "return_home",
      currentLanguage,
    ),
  ),
),
          ),
        ],
      ),
    );
  }
}