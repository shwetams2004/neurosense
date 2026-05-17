import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../risk/risk_engine.dart';
import '../../reports/clinician_pdf.dart';
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

  Map<String, double> explanations =
      {};

  String currentUserName = "";
  String currentUserId = "";

  // 🔹 Timeline data
  List<double> memoryTimeline = [];
  List<double> attentionTimeline = [];
  List<double> executiveTimeline = [];

  @override
  void initState() {
    super.initState();
    loadRisk();
  }

  Future<void> loadRisk() async {
    try {
      final currentUser =
          await LocalStore
              .getCurrentUser();

      if (currentUser == null) {
        return;
      }

      currentUserId = currentUser;

      final prefs =
          await SharedPreferences
              .getInstance();

      final storedUsers =
          prefs.getStringList(
                  "user_profiles") ??
              [];

      final users = storedUsers
          .map((e) =>
              jsonDecode(e)
                  as Map<String, dynamic>)
          .toList();

      final user = users.firstWhere(
        (u) =>
            u["userId"] ==
            currentUser,
        orElse: () => {},
      );

      currentUserName =
          user["name"] ?? "User";

      final result =
          await RiskEngine.computeRisk()
              .timeout(
        const Duration(seconds: 3),
      );

      // =========================
      // USER-SPECIFIC SCORES
      // =========================

      final memory =
          await LocalStore
              .getMemoryScores(
        currentUser,
      );

      // TODO:
      // convert these later to user-specific too
      final digit =
    await LocalStore.getDigitSpanScores(
  currentUser,
);

      final trail =
    await LocalStore.getTrailTimes(
  currentUser,
);

      if (!mounted) return;

      setState(() {
        riskLevel =
            result["risk_level"];

        riskScore =
            result["score"];

        explanations = Map<
            String,
            double>.from(
          result["explanation"] ??
              {},
        );

        memoryTimeline =
            RiskEngine.toZTimeline(
          memory,
          inverse: true,
        );

        attentionTimeline =
            RiskEngine.toZTimeline(
          digit,
        );

        executiveTimeline =
            RiskEngine.toZTimeline(
          trail,
        );

        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        riskLevel =
            "insufficient_data";
      });
    }
  }

  // =========================
  // UI HELPERS
  // =========================

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
        return "Low risk (stable patterns observed)";

      case "medium":
        return "Moderate risk (mild deviations detected)";

      case "high":
        return "Elevated risk (sustained deviations detected)";

      default:
        return "Baseline in progress";
    }
  }

  String featureLabel(
      String key) {
    switch (key) {
      case "memory":
        return "Episodic memory";

      case "attention":
        return "Attention / working memory";

      case "executive":
        return "Executive function";

      default:
        return key;
    }
  }

  // =========================
  // BASELINE VIEW
  // =========================

  Widget _buildBaselineInProgress() {
    return Padding(
      padding:
          const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "NeuroSense Summary\n$currentUserName",
            style: const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding:
                const EdgeInsets.all(
                    16),

            decoration: BoxDecoration(
              color: Colors.blueGrey
                  .withOpacity(0.1),

              borderRadius:
                  BorderRadius.circular(
                      12),
            ),

            child: const Text(
              "Baseline in progress.\n\n"
              "NeuroSense is currently learning personal cognitive patterns. "
              "After more activities, trend insights will appear.",
              style:
                  TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // FULL SUMMARY
  // =========================

  Widget _buildSummary() {
    return Padding(
      padding:
          const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            "NeuroSense Cognitive Summary\n$currentUserName",
            style: const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // =========================
          // RISK BANNER
          // =========================

          Container(
            padding:
                const EdgeInsets.all(
                    16),

            decoration: BoxDecoration(
              color: riskColor()
                  .withOpacity(0.1),

              borderRadius:
                  BorderRadius.circular(
                      12),

              border: Border.all(
                color: riskColor(),
              ),
            ),

            child: Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: riskColor(),
                ),

                const SizedBox(
                    width: 12),

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

          const SizedBox(height: 24),

          // =========================
          // TIMELINE
          // =========================

          const Text(
            "Cognitive trends over time",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          TimelineChart(
            memory: memoryTimeline,
            attention:
                attentionTimeline,
            executive:
                executiveTimeline,
          ),

          const SizedBox(height: 24),

          // =========================
          // FACTORS
          // =========================

          const Text(
            "Contributing factors",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...explanations.entries.map(
            (e) => Padding(
              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 6,
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      featureLabel(
                          e.key),
                      style:
                          const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),

                  Text(
                    e.value
                        .abs()
                        .toStringAsFixed(
                            2),

                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // =========================
          // PDF
          // =========================

          SizedBox(
            width: double.infinity,

            child:
                ElevatedButton.icon(
              icon: const Icon(
                Icons.picture_as_pdf,
              ),

              label: const Text(
                "Generate Clinician PDF Report",
              ),

              onPressed: () async {
                await ClinicianPDF
                    .generate();

                if (mounted) {
                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Clinician report generated successfully",
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Clinician Summary",
        ),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: riskLevel ==
                      "insufficient_data"
                  ? _buildBaselineInProgress()
                  : _buildSummary(),
            ),
    );
  }
}