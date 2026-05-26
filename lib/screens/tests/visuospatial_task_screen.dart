import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
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

  final List<String> targetOrder = [

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

  bool showingTarget = true;

  bool finished = false;

  String currentLanguage =
      "English";

  final List<String>
      selectedShapes = [];

  late DateTime startTime;

  @override
  void initState() {

    super.initState();

    loadLanguage();

    shuffled =
        List.from(targetOrder)
          ..shuffle();

    startTime = DateTime.now();

    Future.delayed(

      const Duration(
        seconds: 4,
      ),

      () {

        if (!mounted) return;

        setState(() {

          showingTarget = false;
        });
      },
    );
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

  void handleTap(
    String shape,
  ) {

    if (finished) return;

    setState(() {

      taps++;

      if (shape ==
          targetOrder[
              currentIndex]) {

        selectedShapes.add(
          shape,
        );

        currentIndex++;

      } else {

        errors++;
      }
    });

    if (currentIndex ==
        targetOrder.length) {

      setState(() {

        finished = true;
      });

      finishTask();
    }
  }

  Future<void> finishTask()
      async {

    final seconds =
        DateTime.now()
            .difference(
              startTime,
            )
            .inSeconds;

    final currentUser =
        await LocalStore
            .getCurrentUser();

    if (currentUser == null) {
      return;
    }

    await LocalStore
        .saveVisuospatialResult(

      userId: currentUser,

      seconds: seconds,

      errors: errors,

      taps: taps,
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
            )}: ${targetOrder.length - errors}/${targetOrder.length}\n"

            "${AppStrings.text(
              "errors",
              currentLanguage,
            )}: $errors",
          ),
        ),
      );
    }

    if (mounted) {

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
  }

  Widget shapeButton(
      String shape) {

    return Material(

      color: Colors.transparent,

      child: InkWell(

        onTap: () =>
            handleTap(shape),

        borderRadius:
            BorderRadius.circular(
          12,
        ),

        child: Container(

          width: 80,

          height: 80,

          margin:
              const EdgeInsets.all(
            8,
          ),

          decoration: BoxDecoration(

            border: Border.all(
              color:
                  Colors.indigo,
            ),

            borderRadius:
                BorderRadius
                    .circular(
              12,
            ),

            color: selectedShapes
                    .contains(shape)

                ? Colors.green
                    .shade200

                : Colors.white,
          ),

          alignment:
              Alignment.center,

          child: Text(

            shape.toUpperCase(),

            style:
                const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w500,
            ),

            textAlign:
                TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(

          AppStrings.text(
            "shape_title",
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

          children: [

            Text(

              showingTarget

                  ? AppStrings.text(
  "remember_order",
  currentLanguage,
)

                  : AppStrings.text(
                      "shape_instruction",
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
              height: 16,
            ),

            if (!showingTarget)

              Text(

                "${AppStrings.text(
  "progress",
  currentLanguage,
)}: $currentIndex / ${targetOrder.length}",

                style:
                    const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

            const SizedBox(
              height: 20,
            ),

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
                            shapeButton,
                          )

                          .toList(),
                ),
              ),
            ),

            if (finished)

              Padding(

                padding:
                    const EdgeInsets.only(
                  top: 12,
                ),

                child: Column(

                  children: [

                    Text(

                      AppStrings.text(
                        "test_completed",
                        currentLanguage,
                      ),

                      style:
                          const TextStyle(
                        fontSize: 20,
                        color:
                            Colors.green,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(

                      "${AppStrings.text(
                        "score",
                        currentLanguage,
                      )}: ${targetOrder.length - errors} / ${targetOrder.length}",

                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(

                      "${AppStrings.text(
                        "errors",
                        currentLanguage,
                      )}: $errors",

                      style:
                          const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(

                      "${AppStrings.text(
                        "correct_sequences",
                        currentLanguage,
                      )}: $currentIndex",

                      style:
                          const TextStyle(
                        fontSize: 16,
                        color:
                            Colors.black87,
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