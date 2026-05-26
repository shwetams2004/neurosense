import 'dart:math';

import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
import '../../storage/local_store.dart';

class VigilanceTestScreen
    extends StatefulWidget {

  const VigilanceTestScreen({
    super.key,
  });

  @override
  State<VigilanceTestScreen>
      createState() =>
          _VigilanceTestScreenState();
}

class _VigilanceTestScreenState
    extends State<
        VigilanceTestScreen> {

  static const int totalTrials = 20;

  bool showTarget = false;

  bool responded = false;

  bool completed = false;

  int currentTrial = 0;

  int hits = 0;

  int misses = 0;

  int falseAlarms = 0;

  String currentLanguage =
      "English";

  final List<int> reactionTimes =
      [];

  DateTime? stimulusTime;

  @override
  void initState() {

    super.initState();

    loadLanguage();

    _runTrial();
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

  // =========================
  // RUN TRIALS
  // =========================

  Future<void> _runTrial()
      async {

    // TEST COMPLETE
    if (currentTrial >=
        totalTrials) {

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );

      await _finish();

      return;
    }

    // RANDOM WAIT
    await Future.delayed(

      Duration(
        seconds:
            Random().nextInt(3) +
                2,
      ),
    );

    if (!mounted) return;

    // SHOW STIMULUS
    setState(() {

      showTarget =
          Random().nextBool();

      responded = false;

      stimulusTime =
          DateTime.now();

      currentTrial++;
    });

    // SHOW FOR 1 SECOND
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );

    // MISSED TARGET
    if (showTarget &&
        !responded) {

      misses++;
    }

    if (!mounted) return;

    // HIDE STIMULUS
    setState(() {

      showTarget = false;

      stimulusTime = null;
    });

    // NEXT TRIAL
    if (mounted) {

      _runTrial();
    }
  }

  // =========================
  // USER TAP
  // =========================

  void _onTap() {

    if (stimulusTime == null ||
        responded ||
        completed) {
      return;
    }

    responded = true;

    final rt = DateTime.now()
        .difference(
          stimulusTime!,
        )
        .inMilliseconds;

    // CORRECT HIT
    if (showTarget) {

      hits++;

      reactionTimes.add(rt);

    } else {

      // WRONG TAP
      falseAlarms++;
    }
  }

  // =========================
  // FINISH TEST
  // =========================

  Future<void> _finish()
      async {

    if (completed) return;

    final avgRt =
        reactionTimes.isEmpty
            ? 0
            : reactionTimes.reduce(
                      (a, b) => a + b,
                    ) ~/
                reactionTimes.length;

    final currentUser =
        await LocalStore
            .getCurrentUser();

    if (currentUser != null) {

      await LocalStore
          .saveVigilanceResult(

        userId: currentUser,

        hits: hits,

        misses: misses,

        falseAlarms:
            falseAlarms,

        avgRtMs: avgRt,
      );
    }

    if (!mounted) return;

    setState(() {

      completed = true;
    });
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(

          AppStrings.text(
            "vigilance_title",
            currentLanguage,
          ),
        ),
      ),

      body: Material(

        color: Colors.transparent,

        child: InkWell(

          onTap: _onTap,

          child: completed

              ? _resultView()

              : Center(

                  child: Column(

                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [

                      Padding(

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),

                        child: Text(

                          AppStrings.text(
                            "vigilance_instruction",
                            currentLanguage,
                          ),

                          textAlign:
                              TextAlign.center,

                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 40,
                      ),

                      Text(

                        showTarget
                            ? "●"
                            : "+",

                        style:
                            const TextStyle(
                          fontSize: 72,
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      Text(

                        "${AppStrings.text(
                          "trial",
                          currentLanguage,
                        )} $currentTrial / $totalTrials",

                        style:
                            const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // =========================
  // RESULT VIEW
  // =========================

  Widget _resultView() {

    final avgRt =
        reactionTimes.isEmpty
            ? 0
            : reactionTimes.reduce(
                      (a, b) => a + b,
                    ) ~/
                reactionTimes.length;

    return Center(

      child: Padding(

        padding:
            const EdgeInsets.all(
          24,
        ),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            const Icon(

              Icons.check_circle,

              size: 80,

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

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            Text(

              "${AppStrings.text(
                "correct_taps",
                currentLanguage,
              )}: $hits",

              style:
                  const TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(

              "${AppStrings.text(
  "misses",
  currentLanguage,
)}: $misses",

              style:
                  const TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(

              "${AppStrings.text(
                "wrong_taps",
                currentLanguage,
              )}: $falseAlarms",

              style:
                  const TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(

              "${AppStrings.text(
  "average_reaction_time",
  currentLanguage,
)}:\n${avgRt} ms",

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(
              height: 40,
            ),

            SizedBox(

              width: 240,

              child:
                  ElevatedButton(

                onPressed: () {

                  Navigator.pop(
                    context,
                  );
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
      ),
    );
  }
}