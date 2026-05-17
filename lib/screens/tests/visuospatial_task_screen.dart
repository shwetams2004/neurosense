import 'package:flutter/material.dart';

import '../../storage/local_store.dart';

class VisuospatialTaskScreen
    extends StatefulWidget {
  const VisuospatialTaskScreen({
    super.key,
  });

  @override
  State<VisuospatialTaskScreen>
      createState() =>
          _VisuospatialTaskScreenState();
}

class _VisuospatialTaskScreenState
    extends State<
        VisuospatialTaskScreen> {
  final List<String> targetOrder =
      [
    "circle",
    "square",
    "triangle",
    "star",
    "hexagon",
  ];

  late List<String> shuffled;

  int currentIndex = 0;

  int errors = 0;

  int taps = 0;

  late DateTime startTime;

  bool showingTarget = true;

  bool finished = false;

  @override
  void initState() {
    super.initState();

    shuffled =
        List.from(targetOrder)
          ..shuffle();

    startTime = DateTime.now();

    Future.delayed(
      const Duration(seconds: 4),
      () {
        if (mounted) {
          setState(() {
            showingTarget =
                false;
          });
        }
      },
    );
  }

  void handleTap(
      String shape) {
    if (finished) return;

    setState(() {
      taps++;

      if (shape ==
          targetOrder[
              currentIndex]) {
        currentIndex++;
      } else {
        errors++;
      }

      if (currentIndex ==
          targetOrder.length) {
        finished = true;

        finishTask();
      }
    });
  }

  Future<void> finishTask() async {
    final currentUser =
        await LocalStore
            .getCurrentUser();

    if (currentUser == null) {
      return;
    }

    final seconds =
        DateTime.now()
            .difference(startTime)
            .inSeconds;

    // =========================
    // SAVE USER-SPECIFIC RESULT
    // =========================

    await LocalStore
        .saveVisuospatialResult(
      userId: currentUser,
      seconds: seconds,
      errors: errors,
      taps: taps,
    );

    if (mounted) {
      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Visuospatial activity saved.\nErrors: $errors",
          ),
        ),
      );
    }

    if (mounted) {
      Future.delayed(
        const Duration(
            milliseconds: 800),
        () {
          Navigator.pop(context);
        },
      );
    }
  }

  Widget shapeButton(
      String shape) {
    return InkWell(
      onTap: () =>
          handleTap(shape),

      borderRadius:
          BorderRadius.circular(
              12),

      child: Container(
        width: 80,

        height: 80,

        margin:
            const EdgeInsets.all(8),

        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.indigo,
          ),

          borderRadius:
              BorderRadius.circular(
                  12),

          color: Colors.white,
        ),

        alignment:
            Alignment.center,

        child: Text(
          shape.toUpperCase(),

          style: const TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.w500,
          ),

          textAlign:
              TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Shape Sequencing Activity",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(24),

        child: Column(
          children: [
            Text(
              showingTarget
                  ? "Remember this order"
                  : "Tap the shapes in the same order",

              style: const TextStyle(
                fontSize: 18,
              ),

              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
                height: 16),

            if (!showingTarget)
              Text(
                "Progress: $currentIndex / ${targetOrder.length}",

                style:
                    const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

            const SizedBox(
                height: 20),

            Expanded(
              child: Center(
                child: Wrap(
                  alignment:
                      WrapAlignment
                          .center,

                  children:
                      (showingTarget
                              ? targetOrder
                              : shuffled)
                          .map(
                              shapeButton)
                          .toList(),
                ),
              ),
            ),

            if (finished)
              const Padding(
                padding:
                    EdgeInsets.only(
                        top: 12),

                child: Text(
                  "Completed",

                  style: TextStyle(
                    fontSize: 16,
                    color:
                        Colors.green,
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}