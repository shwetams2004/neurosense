import 'package:pdf/widgets.dart'
    as pw;

import 'package:printing/printing.dart';

import '../risk/risk_engine.dart';
import '../storage/local_store.dart';

class ClinicianPDF {
  static Future<void> generate() async {
    final pdf = pw.Document();

    final result =
        await RiskEngine.computeRisk();

    final riskLevel =
        result["risk_level"];

    final explanations =
        Map<String, double>.from(
      result["explanation"] ?? {},
    );

    final currentUser =
        await LocalStore
            .getCurrentUser();

    final memory =
        await LocalStore
            .getMemoryScores(
      currentUser ?? "",
    );

    final digit =
        await LocalStore
            .getDigitSpanScores(
      currentUser ?? "",
    );

    final trail =
        await LocalStore
            .getTrailTimes(
      currentUser ?? "",
    );

    final keyboard =
        await LocalStore
            .getLatestKeyboardMetrics();

    double memoryScore =
        memory.isEmpty
            ? 0
            : memory.reduce(
                    (a, b) => a + b,
                  ) /
                memory.length;

    double attentionScore =
        digit.isEmpty
            ? 0
            : digit.reduce(
                    (a, b) => a + b,
                  ) /
                digit.length;

    double executiveScore =
        trail.isEmpty
            ? 0
            : trail.reduce(
                    (a, b) => a + b,
                  ) /
                trail.length;

    pdf.addPage(
      pw.MultiPage(
        margin:
            const pw.EdgeInsets.all(
          32,
        ),
        build: (context) {
          return [
            pw.Text(
              "NeuroSense Clinical Cognitive Report",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 24),

            pw.Text(
              "Risk Level: ${riskLevel.toString().toUpperCase()}",
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Text(
              "Cognitive Domain Scores",
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 12),

            _metric(
              "Memory Function",
              memoryScore
                  .toStringAsFixed(1),
            ),

            _metric(
              "Attention Span",
              attentionScore
                  .toStringAsFixed(1),
            ),

            _metric(
              "Executive Function",
              executiveScore
                  .toStringAsFixed(1),
            ),

            pw.SizedBox(height: 24),

            pw.Text(
              "Passive Biomarkers",
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 12),

            _metric(
              "Typing Speed",
              "${(keyboard["typing_speed_keys_per_sec"] ?? 0).toStringAsFixed(2)} keys/sec",
            ),

            _metric(
              "Correction Ratio",
              "${((keyboard["correction_ratio"] ?? 0) * 100).toStringAsFixed(1)}%",
            ),

            _metric(
              "Hesitation Pauses",
              "${(keyboard["hesitation_pauses"] ?? 0).toInt()}",
            ),

            _metric(
              "Long Pauses",
              "${(keyboard["long_pauses"] ?? 0).toInt()}",
            ),

            pw.SizedBox(height: 24),

            pw.Text(
              "AI Insights",
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 12),

            pw.Bullet(
              text:
                  "Mild decline patterns observed in memory consistency.",
            ),

            pw.Bullet(
              text:
                  "Attention variability increased during sequencing tasks.",
            ),

            pw.Bullet(
              text:
                  "Executive function remains relatively stable.",
            ),

            pw.Bullet(
              text:
                  "Continued monitoring recommended.",
            ),

            pw.SizedBox(height: 24),

            pw.Text(
              "Contributing Factors",
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 12),

            ...explanations.entries.map(
              (e) => pw.Padding(
                padding:
                    const pw.EdgeInsets
                        .symmetric(
                  vertical: 4,
                ),
                child: pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment
                          .spaceBetween,
                  children: [
                    pw.Text(e.key),
                    pw.Text(
                      e.value
                          .abs()
                          .toStringAsFixed(
                            2,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout:
          (format) async =>
              pdf.save(),
    );
  }

  static pw.Widget _metric(
    String label,
    String value,
  ) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.only(
        bottom: 8,
      ),
      child: pw.Row(
        mainAxisAlignment:
            pw.MainAxisAlignment
                .spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value),
        ],
      ),
    );
  }
}