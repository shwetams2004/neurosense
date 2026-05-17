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

  Future<void> _runTrial() async {
    if (currentTrial >=
        totalTrials) {
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
      const Duration(seconds: 1),
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

    _runTrial();
  }

  void _onTap() {
    if (stimulusTime == null ||
        responded) {
      return;
    }

    responded = true;

    final rt = DateTime.now()
        .difference(stimulusTime!)
        .inMilliseconds;

    if (showTarget) {
      hits++;

      reactionTimes.add(rt);
    } else {
      falseAlarms++;
    }
  }

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

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Vigilance task completed.\nHits: $hits | Misses: $misses",
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
          "Vigilance Task",
        ),
      ),

      body: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onTap,
          child: Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,
              children: [
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
                    height: 20),

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
}