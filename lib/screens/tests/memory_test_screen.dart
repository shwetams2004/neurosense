import 'package:flutter/material.dart';
import '../../localization/app_strings.dart';
import '../../localization/app_strings.dart';
import '../../passive/keyboard_tracker.dart';
import '../../services/firestore_service.dart';
import '../../storage/current_patient.dart';
import '../../storage/local_store.dart';

class MemoryTestScreen
    extends StatefulWidget {

  const MemoryTestScreen({
    super.key,
  });

  @override
  State<MemoryTestScreen>
      createState() =>
          _MemoryTestScreenState();
}

class _MemoryTestScreenState
    extends State<
        MemoryTestScreen> {

  final List<String> words = const [

    "Apple",

    "River",

    "Chair",

    "Doctor",

    "Clock",
  ];

  bool showingWords = true;

  String currentLanguage =
      "English";

  final TextEditingController
      recallController =
      TextEditingController();

  String _previousText = "";

  @override
  void initState() {

    super.initState();

    loadLanguage();
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
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(

          AppStrings.text(
            "memory_title",
            currentLanguage,
          ),
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
          24,
        ),

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

        Text(

          AppStrings.text(
            "memory_instruction",
            currentLanguage,
          ),

          style:
              const TextStyle(
            fontSize: 20,
          ),

          textAlign:
              TextAlign.center,
        ),

        const SizedBox(
          height: 24,
        ),

        ...words.map(

          (w) => Padding(

            padding:
                const EdgeInsets.symmetric(
              vertical: 6,
            ),

            child: Text(

              w,

              style:
                  const TextStyle(

                fontSize: 22,

                fontWeight:
                    FontWeight.w500,
              ),
            ),
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

            onPressed: () {

              setState(() {

                showingWords = false;
              });
            },

            child: Text(

              AppStrings.text(
                "submit",
                currentLanguage,
              ),
            ),
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

        Text(

          AppStrings.text(
            "type_words",
            currentLanguage,
          ),

          style:
              const TextStyle(
            fontSize: 18,
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        TextField(

          controller:
              recallController,

          decoration:
              InputDecoration(

            border:
                const OutlineInputBorder(),

            hintText:
                AppStrings.text(
              "type_words",
              currentLanguage,
            ),
          ),

          maxLines: 3,

          onChanged: (value) {

            final isBackspace =
                value.length <
                    _previousText
                        .length;

            KeyboardTracker
                .onKeyPress(

              isBackspace:
                  isBackspace,
            );

            _previousText = value;
          },
        ),

        const SizedBox(
          height: 40,
        ),

        SizedBox(

          width:
              double.infinity,

          child:
              ElevatedButton(

            onPressed: () async {

              final input =
                  recallController
                      .text
                      .toLowerCase();

              final recalledWords =
                  input.split(

                RegExp(r'\s+'),
              );

              int score = 0;

              for (final word
                  in words) {

                if (recalledWords
                    .contains(

                  word.toLowerCase(),
                )) {

                  score++;
                }
              }

              // =========================
              // SAVE USER-SPECIFIC SCORE
              // =========================

              await FirestoreService
                  .saveMemoryResult(

                patientId:
                    CurrentPatient
                        .patientId!,

                score: score,
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

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(

                  SnackBar(

                    content: Text(

                      "${AppStrings.text(
                        "test_completed",
                        currentLanguage,
                      )}\n"

                      "${AppStrings.text(
                        "score",
                        currentLanguage,
                      )}: $score/${words.length}",
                    ),
                  ),
                );
              }

              Navigator.pop(
                context,
              );
            },

            child: Text(

              AppStrings.text(
                "submit",
                currentLanguage,
              ),
            ),
          ),
        ),
      ],
    );
  }
}