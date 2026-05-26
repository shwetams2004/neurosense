import 'package:pdf/widgets.dart'
    as pw;

import 'package:printing/printing.dart';

import '../localization/app_strings.dart';
import '../risk/risk_engine.dart';
import '../storage/local_store.dart';

class ClinicianPDF {

  static Future<void> generate()
      async {

    final pdf = pw.Document();

    final currentLanguage =
        await LocalStore
            .getLanguage();

    final result =
        await RiskEngine
            .computeRisk();

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

            // =========================
            // TITLE
            // =========================

            pw.Text(

              AppStrings.text(
                "clinical_report",
                currentLanguage,
              ),

              style: pw.TextStyle(

                fontSize: 24,

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 24,
            ),

            // =========================
            // RISK LEVEL
            // =========================

            pw.Text(

              "${AppStrings.text(
                "risk_level",
                currentLanguage,
              )}: ${riskLevel.toString().toUpperCase()}",

              style: pw.TextStyle(

                fontSize: 18,

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 20,
            ),

            // =========================
            // COGNITIVE SCORES
            // =========================

            pw.Text(

              AppStrings.text(
                "cognitive_domain_scores",
                currentLanguage,
              ),

              style: pw.TextStyle(

                fontSize: 16,

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 12,
            ),

            _metric(

              AppStrings.text(
                "memory_function",
                currentLanguage,
              ),

              memoryScore
                  .toStringAsFixed(1),
            ),

            _metric(

              AppStrings.text(
                "attention_span",
                currentLanguage,
              ),

              attentionScore
                  .toStringAsFixed(1),
            ),

            _metric(

              AppStrings.text(
                "executive_function",
                currentLanguage,
              ),

              executiveScore
                  .toStringAsFixed(1),
            ),

            pw.SizedBox(
              height: 24,
            ),

            // =========================
            // PASSIVE BIOMARKERS
            // =========================

            pw.Text(

              AppStrings.text(
                "passive_biomarkers",
                currentLanguage,
              ),

              style: pw.TextStyle(

                fontSize: 16,

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 12,
            ),

            _metric(

              AppStrings.text(
                "typing_speed",
                currentLanguage,
              ),

              "${(keyboard["typing_speed_keys_per_sec"] ?? 0).toStringAsFixed(2)} keys/sec",
            ),

            _metric(

              AppStrings.text(
                "correction_ratio",
                currentLanguage,
              ),

              "${((keyboard["correction_ratio"] ?? 0) * 100).toStringAsFixed(1)}%",
            ),

            _metric(

              AppStrings.text(
                "hesitation_pauses",
                currentLanguage,
              ),

              "${(keyboard["hesitation_pauses"] ?? 0).toInt()}",
            ),

            _metric(

              AppStrings.text(
                "long_pauses",
                currentLanguage,
              ),

              "${(keyboard["long_pauses"] ?? 0).toInt()}",
            ),

            pw.SizedBox(
              height: 24,
            ),

            // =========================
            // AI INSIGHTS
            // =========================

            pw.Text(

              AppStrings.text(
                "ai_insights",
                currentLanguage,
              ),

              style: pw.TextStyle(

                fontSize: 16,

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 12,
            ),

            pw.Bullet(

              text: AppStrings.text(
                "insight_memory_decline",
                currentLanguage,
              ),
            ),

            pw.Bullet(

              text: AppStrings.text(
                "insight_attention",
                currentLanguage,
              ),
            ),

            pw.Bullet(

              text: AppStrings.text(
                "insight_executive",
                currentLanguage,
              ),
            ),

            pw.Bullet(

              text: AppStrings.text(
                "insight_monitoring",
                currentLanguage,
              ),
            ),

            pw.SizedBox(
              height: 24,
            ),

            // =========================
            // CONTRIBUTING FACTORS
            // =========================

            pw.Text(

              AppStrings.text(
                "contributing_factors",
                currentLanguage,
              ),

              style: pw.TextStyle(

                fontSize: 16,

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 12,
            ),

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

                    pw.Text(
                      e.key,
                    ),

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

  // =========================
  // METRIC ROW
  // =========================

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