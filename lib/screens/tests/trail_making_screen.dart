import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../storage/local_store.dart';

class TrailMakingScreen extends StatefulWidget {
  const TrailMakingScreen({
    super.key,
  });

  @override
  State<TrailMakingScreen> createState() =>
      _TrailMakingScreenState();
}

class _TrailMakingScreenState
    extends State<TrailMakingScreen> {
  static const int totalNodes = 12;

  List<int> nodes = List.generate(
    totalNodes,
    (i) => i + 1,
  );

  int currentTarget = 1;

  int mistakes = 0;

  late Stopwatch stopwatch;

  Timer? timer;

  int elapsedSeconds = 0;

  bool completed = false;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    nodes.shuffle(Random());

    stopwatch = Stopwatch()
      ..start();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        setState(() {
          elapsedSeconds =
              stopwatch.elapsed.inSeconds;
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();

    stopwatch.stop();

    super.dispose();
  }

  Future<void> onNodeTap(
    int value,
  ) async {
    if (completed || saving) return;

    if (value == currentTarget) {
      // =========================
      // LAST NODE
      // =========================

      if (currentTarget ==
          totalNodes) {
        setState(() {
          completed = true;
          saving = true;
        });

        stopwatch.stop();

        timer?.cancel();

        final currentUser =
            await LocalStore
                .getCurrentUser();

        if (currentUser != null) {
          await LocalStore
              .saveTrailMakingResult(
            currentUser,
            elapsedSeconds,
            mistakes,
          );
        }

        if (!mounted) return;

        setState(() {
          saving = false;
        });
      }

      // =========================
      // NEXT NODE
      // =========================

      else {
        setState(() {
          currentTarget++;
        });
      }
    }

    // =========================
    // WRONG TAP
    // =========================

    else {
      setState(() {
        mistakes++;
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true,
      appBar: AppBar(
        title: const Text(
          "Sequencing Activity",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(
            20,
          ),
          child: completed
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
            CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          const Text(
            "Tap the numbers in order, starting from 1.",
            style: TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            "Time: $elapsedSeconds s   |   Mistakes: $mistakes",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 620,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount:
                    nodes.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1,
                ),
                itemBuilder:
                    (context, index) {
                  return _node(
                    nodes[index],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _node(int number) {
    final bool completedNode =
        number < currentTarget;

    final bool activeNode =
        number == currentTarget;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        onTap: () async {
          await onNodeTap(
            number,
          );
        },
        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 200,
          ),
          alignment:
              Alignment.center,
          decoration:
              BoxDecoration(
            color: completedNode
                ? Colors.green
                    .withOpacity(
                    0.6,
                  )
                : activeNode
                    ? Colors.indigo
                        .withOpacity(
                        0.25,
                      )
                    : Colors.indigo
                        .withOpacity(
                        0.12,
                      ),
            borderRadius:
                BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: activeNode
                  ? Colors.indigo
                  : Colors.indigo
                      .shade100,
              width: activeNode
                  ? 2
                  : 1,
            ),
          ),
          child: Text(
            number.toString(),
            style:
                const TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
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
            size: 72,
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
            height: 20,
          ),

          Text(
            "Time Taken: $elapsedSeconds seconds",
            style:
                const TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            "Mistakes: $mistakes",
            style:
                const TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(
            height: 28,
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