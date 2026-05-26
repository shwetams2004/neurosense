import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
import '../../storage/local_store.dart';
import 'dart:math';
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

  final Random random =
    Random();

late int current;

  int correct = 0;

  int errors = 0;

  bool finished = false;

  String currentLanguage =
      "English";

  final TextEditingController
      controller =
      TextEditingController();
  @override
void initState() {

  super.initState();

  loadLanguage();

  generateStartingNumber();
}
void generateStartingNumber() {

  current =
      90 +
      random.nextInt(31);

  // Generates:
  // 90 → 120
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

  void submit() {

    if (finished) return;

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

      setState(() {

        finished = true;
      });

      finish();

      return;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> finish()
      async {

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

          duration:
              const Duration(
            seconds: 3,
          ),

          content: Text(

            "${AppStrings.text(
              "test_completed",
              currentLanguage,
            )}\n"

            "${AppStrings.text(
              "score",
              currentLanguage,
            )}: $correct / 5\n"

            "${AppStrings.text(
              "errors",
              currentLanguage,
            )}: $errors",
          ),
        ),
      );
    }

    Future.delayed(

      const Duration(
        seconds: 3,
      ),

      () {

        if (!mounted) return;

        Navigator.pop(
          context,
        );
      },
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(

          AppStrings.text(
            "mental_calculation_title",
            currentLanguage,
          ),
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
          24,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            
            Column(

  crossAxisAlignment:
      CrossAxisAlignment.start,

  children: [

    Text(

      "${AppStrings.text(
        "serial_instruction",
        currentLanguage,
      )}\n\n"

      "${AppStrings.text(
        "complete_5_attempts",
        currentLanguage,
      )}",

      style: const TextStyle(
        fontSize: 18,
        height: 1.5,
      ),
    ),

    const SizedBox(
      height: 24,
    ),

    Center(

      child: Container(

        padding:
            const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 22,
        ),

        decoration: BoxDecoration(

          color:
              Colors.indigo
                  .withOpacity(0.08),

          borderRadius:
              BorderRadius.circular(
            18,
          ),

          border: Border.all(
            color:
                Colors.indigo.shade100,
          ),
        ),

        child: Text(

          current.toString(),

          style:
              const TextStyle(

            fontSize: 42,

            fontWeight:
                FontWeight.bold,

            color:
                Colors.indigo,
          ),
        ),
      ),
    ),
  ],
),

            const SizedBox(
              height: 24,
            ),

            TextField(

              controller:
                  controller,

              enabled:
                  !finished,

              keyboardType:
                  TextInputType.number,

              decoration:
                  InputDecoration(

                labelText:
                    AppStrings.text(
                  "your_answer",
                  currentLanguage,
                ),

                border:
                    const OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(

              "${AppStrings.text(
  "attempt",
  currentLanguage,
)}: ${correct + errors} / 5\n"

              "${AppStrings.text(
                "correct",
                currentLanguage,
              )}: $correct | "

              "${AppStrings.text(
                "errors",
                currentLanguage,
              )}: $errors",

              style:
                  const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 40,
            ),

            SizedBox(

              width:
                  double.infinity,

              child:
                  ElevatedButton(

                onPressed:
                    finished
                        ? null
                        : submit,

                child: Text(

                  AppStrings.text(
                    "submit",
                    currentLanguage,
                  ),
                ),
              ),
            ),

            if (finished)

              Padding(

                padding:
                    const EdgeInsets.only(
                  top: 30,
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(

                      AppStrings.text(
                        "test_completed",
                        currentLanguage,
                      ),

                      style:
                          const TextStyle(
                        fontSize: 24,
                        color: Colors.green,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Text(

                      "${AppStrings.text(
                        "score",
                        currentLanguage,
                      )}: $correct / 5",

                      style:
                          const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(

                      "${AppStrings.text(
                        "errors",
                        currentLanguage,
                      )}: $errors",

                      style:
                          const TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}