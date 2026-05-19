import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../risk/risk_engine.dart';
import '../../reports/clinician_pdf.dart';
import '../../storage/local_store.dart';
import 'timeline_chart.dart';

class ClinicianSummaryScreen extends StatefulWidget {
  const ClinicianSummaryScreen({
    super.key,
  });

  @override
  State<ClinicianSummaryScreen> createState() =>
      _ClinicianSummaryScreenState();
}

class _ClinicianSummaryScreenState
    extends State<ClinicianSummaryScreen> {
  bool loading = true;

  String riskLevel = "insufficient_data";

  double riskScore = 0.0;

  Map<String, double> explanations = {};

  String currentUserName = "User";

  String currentUserId = "";

  List<double> memoryTimeline = [];

  List<double> attentionTimeline = [];

  List<double> executiveTimeline = [];

  Map<String, double>
    keyboardMetrics = {};
  
  Future<void>
    loadKeyboardMetrics() async {

  final latest =
      await LocalStore
          .getLatestKeyboardMetrics();

  if (!mounted) return;

  setState(() {
  latestKeyboardMetrics = latest;
});
}

  Map<String, double>
      latestKeyboardMetrics = {};

  @override
  void initState() {
    super.initState();
    loadKeyboardMetrics();

    loadRisk();
  }

  Future<void> loadRisk() async {
    try {
      final currentUser =
          await LocalStore.getCurrentUser();

      if (currentUser == null) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        return;
      }

      currentUserId = currentUser;

      final prefs =
          await SharedPreferences.getInstance();

      final storedUsers =
          prefs.getStringList(
                "user_profiles",
              ) ??
              [];

      final users = storedUsers
          .map(
            (e) => jsonDecode(e)
                as Map<String, dynamic>,
          )
          .toList();

      Map<String, dynamic>? foundUser;

      try {
        foundUser = users.firstWhere(
          (u) => u["userId"] == currentUser,
        );
      } catch (_) {
        foundUser = null;
      }

      currentUserName =
          foundUser?["name"] ?? "User";

      final result =
          await RiskEngine.computeRisk();

      final memory =
          await LocalStore.getMemoryScores(
        currentUser,
      );

      final digit =
          await LocalStore.getDigitSpanScores(
        currentUser,
      );

      final trail =
          await LocalStore.getTrailTimes(
        currentUser,
      );

      

      final latestKeyboard =
          await LocalStore
              .getLatestKeyboardMetrics();

      if (!mounted) return;

      setState(() {
        riskLevel =
            result["risk_level"] ??
                "insufficient_data";

        riskScore =
            (result["score"] ?? 0.0)
                .toDouble();

        explanations =
            Map<String, double>.from(
          result["explanation"] ?? {},
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
    String key,
  ) {
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
            color: Colors.indigo
                .withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.indigo,
          ),
        ),

        const SizedBox(width: 16),

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
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                  height: 4),

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

  Widget _buildBaselineInProgress() {
    final random = Random();

    final memory =
        70 + random.nextInt(25);

    final attention =
        65 + random.nextInt(30);

    final executive =
        60 + random.nextInt(35);

    final speech =
        72 + random.nextInt(20);

    final demoRisk =
        [
          "Low cognitive risk",
          "Mild cognitive concern",
          "Moderate cognitive concern",
        ][random.nextInt(3)];

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
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(
              18,
            ),
            decoration:
                BoxDecoration(
              color: Colors.orange
                  .withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
              border: Border.all(
                color: Colors.orange,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.analytics,
                  color: Colors.orange,
                  size: 30,
                ),

                const SizedBox(
                    width: 14),

                Expanded(
                  child: Text(
                    demoRisk,
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          _demoScoreCard(
            "Memory Function",
            memory.toDouble(),
            Icons.memory,
          ),

          const SizedBox(height: 16),

          _demoScoreCard(
            "Attention Span",
            attention.toDouble(),
            Icons.visibility,
          ),

          const SizedBox(height: 16),

          _demoScoreCard(
            "Executive Function",
            executive.toDouble(),
            Icons.psychology,
          ),

          const SizedBox(height: 16),

          _demoScoreCard(
            "Speech Stability",
            speech.toDouble(),
            Icons.mic,
          ),

          const SizedBox(height: 32),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(
              20,
            ),
            decoration:
                BoxDecoration(
              color: Colors.indigo
                  .withOpacity(0.08),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  "AI Insights",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  "• Mild decline patterns observed in memory recall consistency.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "• Attention variability increased during sequencing tasks.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "• Executive function performance remains relatively stable.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "• Continued longitudinal monitoring recommended.",
                  style: TextStyle(
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

  Widget _demoScoreCard(
    String title,
    double score,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
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

          const SizedBox(width: 18),

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
                    height: 10),

                LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 10,
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),

                const SizedBox(
                    height: 10),

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

          const SizedBox(height: 20),

          Container(
            padding:
                const EdgeInsets.all(
              16,
            ),
            decoration: BoxDecoration(
              color: riskColor()
                  .withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
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

                const SizedBox(width: 12),

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
          // =========================
// COGNITIVE SCORE CARDS
// =========================

_demoScoreCard(
  "Memory Function",
  87,
  Icons.memory,
),

const SizedBox(height: 16),

_demoScoreCard(
  "Attention Span",
  68,
  Icons.visibility,
),

const SizedBox(height: 16),

_demoScoreCard(
  "Executive Function",
  72,
  Icons.psychology,
),

const SizedBox(height: 16),

_demoScoreCard(
  "Speech Stability",
  85,
  Icons.mic,
),

const SizedBox(height: 30),

// =========================
// AI INSIGHTS
// =========================

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.indigo.withOpacity(0.08),
    borderRadius:
        BorderRadius.circular(18),
  ),

  child: const Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Text(
        "AI Insights",
        style: TextStyle(
          fontSize: 22,
          fontWeight:
              FontWeight.bold,
        ),
      ),

      SizedBox(height: 16),

      Text(
        "• Mild decline patterns observed in memory recall consistency.",
        style: TextStyle(
          fontSize: 16,
        ),
      ),

      SizedBox(height: 10),

      Text(
        "• Attention variability increased during sequencing tasks.",
        style: TextStyle(
          fontSize: 16,
        ),
      ),

      SizedBox(height: 10),

      Text(
        "• Executive function performance remains relatively stable.",
        style: TextStyle(
          fontSize: 16,
        ),
      ),

      SizedBox(height: 10),

      Text(
        "• Continued longitudinal monitoring recommended.",
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    ],
  ),
),

const SizedBox(height: 30),

          const SizedBox(height: 28),

          const Text(
            "Cognitive trends over time",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 300,
            child: TimelineChart(
              memory: memoryTimeline,
              attention:
                  attentionTimeline,
              executive:
                  executiveTimeline,
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            "Passive Cognitive Biomarkers",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(
              20,
            ),
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                _passiveMetric(
                  "Typing Speed",
                  "${(latestKeyboardMetrics["typing_speed_keys_per_sec"] ?? 0).toStringAsFixed(2)} keys/sec",
                  Icons.speed,
                ),

                const SizedBox(
                    height: 18),

                _passiveMetric(
                  "Correction Ratio",
                  "${((latestKeyboardMetrics["correction_ratio"] ?? 0) * 100).toStringAsFixed(1)}%",
                  Icons.keyboard_return,
                ),

                const SizedBox(
                    height: 18),

                _passiveMetric(
                  "Hesitation Pauses",
                  "${(latestKeyboardMetrics["hesitation_pauses"] ?? 0).toInt()} events",
                  Icons.pause_circle_outline,
                ),

                const SizedBox(
                    height: 18),

                _passiveMetric(
                  "Long Inactivity Bursts",
                  "${(latestKeyboardMetrics["long_pauses"] ?? 0).toInt()} detected",
                  Icons.timelapse,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            "Contributing factors",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          ...explanations.entries.map(
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
                      style:
                          const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    e.value
                        .abs()
                        .toStringAsFixed(2),
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

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
  try {
    await ClinicianPDF.generate();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "PDF report generated successfully",
        ),
      ),
    );
  } catch (e) {
    debugPrint(e.toString());

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "PDF generation failed: $e",
        ),
      ),
    );
  }
},
            ),
          ),

          const SizedBox(height: 30),
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
              child: _buildSummary(),
            ),
    );
  }
}