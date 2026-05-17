import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../storage/local_store.dart';

class TrailMakingScreen extends StatefulWidget {
  const TrailMakingScreen({
    super.key,
  });

  @override
  State<TrailMakingScreen>
      createState() =>
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
              stopwatch
                  .elapsed
                  .inSeconds;
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

  void onNodeTap(
      int value) async {
    if (completed) return;

    final currentUser =
        await LocalStore
            .getCurrentUser();

    if (currentUser == null) {
      return;
    }

    if (value == currentTarget) {
      if (currentTarget ==
          totalNodes) {
        completed = true;

        stopwatch.stop();

        timer?.cancel();

        // =========================
        // SAVE USER-SPECIFIC RESULT
        // =========================

        await LocalStore
            .saveTrailMakingResult(
          currentUser,
          elapsedSeconds,
          mistakes,
        );

        setState(() {});
      } else {
        setState(() {
          currentTarget++;
        });
      }
    } else {
      setState(() {
        mistakes++;
      });
    }
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sequencing Activity",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(24),

        child: completed
            ? _resultView()
            : _testView(),
      ),
    );
  }

  Widget _testView() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          "Tap the numbers in order, starting from 1.",
          style: TextStyle(
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          "Time: $elapsedSeconds s   |   Mistakes: $mistakes",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 24),

        Expanded(
          child: GridView.count(
            crossAxisCount: 4,

            crossAxisSpacing: 12,

            mainAxisSpacing: 12,

            children: nodes
                .map(
                  (n) => _node(n),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _node(int number) {
    final bool completedNode =
        number < currentTarget;

    return GestureDetector(
      onTap: () =>
          onNodeTap(number),

      child: Container(
        alignment:
            Alignment.center,

        decoration: BoxDecoration(
          color: completedNode
              ? Colors.green
                  .withOpacity(0.6)
              : Colors.indigo
                  .withOpacity(0.15),

          borderRadius:
              BorderRadius.circular(
                  12),
        ),

        child: Text(
          number.toString(),

          style: const TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _resultView() {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [
        const Icon(
          Icons.check_circle,
          size: 64,
          color: Colors.green,
        ),

        const SizedBox(height: 24),

        const Text(
          "Activity completed",
          style: TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          "Your responses have been recorded.",
          style: TextStyle(
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: () =>
              Navigator.pop(
                  context),

          child: const Text(
            "Return to Home",
          ),
        ),
      ],
    );
  }
}