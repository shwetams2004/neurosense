import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/app_strings.dart';
import '../../reports/clinician_pdf.dart';
import '../../risk/risk_engine.dart';
import '../../storage/local_store.dart';

import 'timeline_chart.dart';

class ClinicianSummaryScreen
    extends StatefulWidget {

  const ClinicianSummaryScreen({
    super.key,
  });

  @override
  State<ClinicianSummaryScreen>
      createState() =>
          _ClinicianSummaryScreenState();
}

class _ClinicianSummaryScreenState
    extends State<
        ClinicianSummaryScreen> {

  bool loading = true;

  String riskLevel =
      "insufficient_data";

  double riskScore = 0.0;

  Map<String, double>
      explanations = {};

  String currentUserName =
    "";

  String currentUserId = "";

  String currentLanguage =
      "English";

  List<double> memoryTimeline =
      [];

  List<double>
      attentionTimeline = [];

  List<double>
      executiveTimeline = [];

  Map<String, double>
      latestKeyboardMetrics = {};

  @override
  void initState() {

    super.initState();

    loadLanguage();

    loadKeyboardMetrics();

    loadRisk();
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

  Future<void>
      loadKeyboardMetrics()
      async {

    final latest =
        await LocalStore
            .getLatestKeyboardMetrics();

    if (!mounted) return;

    setState(() {

      latestKeyboardMetrics =
          latest;
    });
  }

  Future<void> loadRisk()
      async {

    try {

      final currentUser =
          await LocalStore
              .getCurrentUser();

      if (currentUser ==
          null) {

        if (!mounted) return;

        setState(() {

          loading = false;
        });

        return;
      }

      currentUserId =
          currentUser;

      final prefs =
          await SharedPreferences
              .getInstance();

      final storedUsers =
          prefs.getStringList(
                "user_profiles",
              ) ??
              [];

      final users =
          storedUsers
              .map(
                (e) => jsonDecode(e)
                    as Map<
                        String,
                        dynamic>,
              )
              .toList();

      Map<String, dynamic>?
          foundUser;

      try {

        foundUser =
            users.firstWhere(

          (u) =>
              u["userId"] ==
              currentUser,
        );

      } catch (_) {

        foundUser = null;
      }

      currentUserName =
    foundUser?["name"] ??

    AppStrings.text(
      "user",
      currentLanguage,
    );

      final result =
          await RiskEngine
              .computeRisk();

      final memory =
          await LocalStore
              .getMemoryScores(
        currentUser,
      );

      final digit =
          await LocalStore
              .getDigitSpanScores(
        currentUser,
      );

      final trail =
          await LocalStore
              .getTrailTimes(
        currentUser,
      );

      if (!mounted) return;

      setState(() {

        riskLevel =
            result["risk_level"] ??
                "insufficient_data";

        riskScore =
            (result["score"] ??
                    0.0)
                .toDouble();

        explanations =
            Map<String,
                double>.from(

          result["explanation"] ??
              {},
        );

        memoryTimeline =
            RiskEngine
                .toZTimeline(
          memory,
          inverse: true,
        );

        attentionTimeline =
            RiskEngine
                .toZTimeline(
          digit,
        );

        executiveTimeline =
            RiskEngine
                .toZTimeline(
          trail,
        );

        loading = false;
      });

    } catch (e) {

      debugPrint(
        "SUMMARY ERROR: $e",
      );

      if (!mounted) return;

      setState(() {

        loading = false;

        riskLevel =
            "insufficient_data";
      });
    }
  }

  Color riskColor() {

    switch (riskLevel) {

      case "low":
        return Colors.green;

      case "medium":
        return Colors.orange;

      case "high":
        return Colors.red;

      default:
        return Colors.blueGrey;
    }
  }

  String riskText() {

    switch (riskLevel) {

      case "low":

        return AppStrings.text(
          "low_risk",
          currentLanguage,
        );

      case "medium":

        return AppStrings.text(
          "medium_risk",
          currentLanguage,
        );

      case "high":

        return AppStrings.text(
          "high_risk",
          currentLanguage,
        );

      default:

        return AppStrings.text(
          "baseline_progress",
          currentLanguage,
        );
    }
  }

  String featureLabel(
    String key,
  ) {

    switch (key) {

      case "memory":

        return AppStrings.text(
          "memory_function",
          currentLanguage,
        );

      case "attention":

        return AppStrings.text(
          "attention_span",
          currentLanguage,
        );

      case "executive":

        return AppStrings.text(
          "executive_function",
          currentLanguage,
        );

      default:
        return key;
    }
  }

  Widget _passiveMetric(

    String title,

    String value,

    IconData icon,
  ) {

    return Row(

      children: [

        Container(

          padding:
              const EdgeInsets.all(
            12,
          ),

          decoration:
              BoxDecoration(

            color: Colors
                .indigo
                .withOpacity(
              0.1,
            ),

            borderRadius:
                BorderRadius
                    .circular(
              12,
            ),
          ),

          child: Icon(

            icon,

            color:
                Colors.indigo,
          ),
        ),

        const SizedBox(
          width: 16,
        ),

        Expanded(

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [

              Text(

                title,

                style:
                    const TextStyle(

                  fontSize: 15,

                  color:
                      Colors.grey,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(

                value,

                style:
                    const TextStyle(

                  fontSize: 18,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _demoScoreCard(

    String title,

    double score,

    IconData icon,
  ) {

    return Container(

      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        20,
      ),

      decoration:
          BoxDecoration(

        color:
            Colors.grey.shade100,

        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      child: Row(

        children: [

          CircleAvatar(

            radius: 28,

            child: Icon(icon),
          ),

          const SizedBox(
            width: 18,
          ),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(

                  title,

                  style:
                      const TextStyle(

                    fontSize: 18,

                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                LinearProgressIndicator(

                  value:
                      score / 100,

                  minHeight: 10,

                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(

                  "${score.toStringAsFixed(1)}%",

                  style:
                      const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {

    return Padding(

      padding:
          const EdgeInsets.all(
        24,
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          Text(

            AppStrings.text(
  "cognitive_summary",
  currentLanguage,
),

            style:
                const TextStyle(

              fontSize: 22,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          Container(

            padding:
                const EdgeInsets.all(
              16,
            ),

            decoration:
                BoxDecoration(

              color:
                  riskColor()
                      .withOpacity(
                0.1,
              ),

              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              border: Border.all(
                color:
                    riskColor(),
              ),
            ),

            child: Row(

              children: [

                Icon(

                  Icons.analytics,

                  color:
                      riskColor(),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(

                  child: Text(

                    riskText(),

                    style:
                        const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 30,
          ),

          _demoScoreCard(

            AppStrings.text(
              "memory_function",
              currentLanguage,
            ),

            87,

            Icons.memory,
          ),

          const SizedBox(
            height: 16,
          ),

          _demoScoreCard(

            AppStrings.text(
              "attention_span",
              currentLanguage,
            ),

            68,

            Icons.visibility,
          ),

          const SizedBox(
            height: 16,
          ),

          _demoScoreCard(

            AppStrings.text(
              "executive_function",
              currentLanguage,
            ),

            72,

            Icons.psychology,
          ),

          const SizedBox(
            height: 16,
          ),

          _demoScoreCard(

            AppStrings.text(
              "speech_stability",
              currentLanguage,
            ),

            85,

            Icons.mic,
          ),

          const SizedBox(
            height: 30,
          ),

          Container(

            width:
                double.infinity,

            padding:
                const EdgeInsets.all(
              20,
            ),

            decoration:
                BoxDecoration(

              color: Colors
                  .indigo
                  .withOpacity(
                0.08,
              ),

              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(

                  AppStrings.text(
                    "ai_insights",
                    currentLanguage,
                  ),

                  style:
                      const TextStyle(

                    fontSize: 22,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                Text(
                  AppStrings.text(
                    "insight_memory_decline",
                    currentLanguage,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  AppStrings.text(
                    "insight_attention",
                    currentLanguage,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  AppStrings.text(
                    "insight_executive",
                    currentLanguage,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  AppStrings.text(
                    "insight_monitoring",
                    currentLanguage,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 30,
          ),

          Text(

            AppStrings.text(
              "cognitive_trends",
              currentLanguage,
            ),

            style:
                const TextStyle(

              fontSize: 18,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          SizedBox(

            height: 300,

            child: TimelineChart(

              memory:
                  memoryTimeline,

              attention:
                  attentionTimeline,

              executive:
                  executiveTimeline,
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          Text(

            AppStrings.text(
              "passive_biomarkers",
              currentLanguage,
            ),

            style:
                const TextStyle(

              fontSize: 18,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Container(

            width:
                double.infinity,

            padding:
                const EdgeInsets.all(
              20,
            ),

            decoration:
                BoxDecoration(

              color:
                  Colors.white,

              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),

            child: Column(

              children: [

                _passiveMetric(

                  AppStrings.text(
                    "typing_speed",
                    currentLanguage,
                  ),

                  "${(latestKeyboardMetrics["typing_speed_keys_per_sec"] ?? 0).toStringAsFixed(2)} keys/sec",

                  Icons.speed,
                ),

                const SizedBox(
                  height: 18,
                ),

                _passiveMetric(

                  AppStrings.text(
                    "correction_ratio",
                    currentLanguage,
                  ),

                  "${((latestKeyboardMetrics["correction_ratio"] ?? 0) * 100).toStringAsFixed(1)}%",

                  Icons.keyboard_return,
                ),

                const SizedBox(
                  height: 18,
                ),

                _passiveMetric(

                  AppStrings.text(
                    "hesitation_pauses",
                    currentLanguage,
                  ),

                  "${(latestKeyboardMetrics["hesitation_pauses"] ?? 0).toInt()} events",

                  Icons.pause_circle_outline,
                ),

                const SizedBox(
                  height: 18,
                ),

                _passiveMetric(

                  AppStrings.text(
                    "long_inactivity",
                    currentLanguage,
                  ),

                  "${(latestKeyboardMetrics["long_pauses"] ?? 0).toInt()} detected",

                  Icons.timelapse,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          Text(

            AppStrings.text(
              "contributing_factors",
              currentLanguage,
            ),

            style:
                const TextStyle(

              fontSize: 18,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          ...explanations.entries
              .map(

            (e) => Padding(

              padding:
                  const EdgeInsets.symmetric(
                vertical: 8,
              ),

              child: Row(

                children: [

                  Expanded(

                    child: Text(

                      featureLabel(
                        e.key,
                      ),
                    ),
                  ),

                  Text(

                    e.value
                        .abs()
                        .toStringAsFixed(
                          2,
                        ),

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 32,
          ),

          SizedBox(

            width:
                double.infinity,

            child:
                ElevatedButton.icon(

              icon: const Icon(
                Icons.picture_as_pdf,
              ),

              label: Text(

                AppStrings.text(
                  "generate_pdf",
                  currentLanguage,
                ),
              ),

              onPressed:
                  () async {

                try {

                  await ClinicianPDF
                      .generate();

                  if (!mounted)
                    return;

                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(

                    SnackBar(

                      content: Text(

                        AppStrings.text(
                          "pdf_success",
                          currentLanguage,
                        ),
                      ),
                    ),
                  );

                } catch (e) {

                  if (!mounted)
                    return;

                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(

                    SnackBar(

                      content: Text(

                        "${AppStrings.text(
                          "pdf_failed",
                          currentLanguage,
                        )}: $e",
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(

        title: Text(

          AppStrings.text(
            "clinician_summary",
            currentLanguage,
          ),
        ),
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(
              child:
                  _buildSummary(),
            ),
    );
  }
}