import 'dart:math';

import 'package:flutter/material.dart';

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

  final List<int> reactionTimes =
      [];

  DateTime? stimulusTime;

  @override
  void initState() {
    super.initState();

    _runTrial();
  }

  // =========================
  // RUN TRIALS
  // =========================

  Future<void> _runTrial() async {

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

    await Future.delayed(
      Duration(
        seconds:
            Random().nextInt(3) +
                2,
      ),
    );

    if (!mounted) return;

    setState(() {

      showTarget =
          Random().nextBool();

      responded = false;

      stimulusTime =
          DateTime.now();

      currentTrial++;
    });

    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );

    if (showTarget &&
        !responded) {

      misses++;
    }

    if (!mounted) return;

    setState(() {

      showTarget = false;

      stimulusTime = null;
    });

    if (mounted &&
        currentTrial <
            totalTrials) {

      _runTrial();
    }
  }

  // =========================
  // TAP RESPONSE
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

    if (showTarget) {

      hits++;

      reactionTimes.add(rt);

    } else {

      falseAlarms++;
    }
  }

  // =========================
  // FINISH TEST
  // =========================

  Future<void> _finish() async {

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

    if (currentUser == null) {
      return;
    }

    await LocalStore
        .saveVigilanceResult(
      userId: currentUser,
      hits: hits,
      misses: misses,
      falseAlarms: falseAlarms,
      avgRtMs: avgRt,
    );

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
        title: const Text(
          "Vigilance Task",
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

                      const Padding(

                        padding:
                            EdgeInsets.symmetric(
                          horizontal: 24,
                        ),

                        child: Text(

                          "Tap the screen ONLY when the black dot appears.\nDo not tap when the '+' sign is shown.",

                          textAlign:
                              TextAlign.center,

                          style: TextStyle(
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
                          fontSize: 64,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      Text(

                        "Trial $currentTrial / $totalTrials",

                        style:
                            const TextStyle(
                          fontSize: 16,
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

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          const Icon(
            Icons.check_circle,
            size: 72,
            color: Colors.green,
          ),

          const SizedBox(
            height: 24,
          ),

          const Text(

            "Vigilance Test Completed",

            style: TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          Text(
            "Correct Hits: $hits",

            style: const TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            "Misses: $misses",

            style: const TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            "False Alarms: $falseAlarms",

            style: const TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            "Average Reaction Time: ${avgRt} ms",

            style: const TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(
            height: 32,
          ),

          SizedBox(

            width: 220,

            child: ElevatedButton(

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