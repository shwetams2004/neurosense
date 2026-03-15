import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../risk/risk_engine.dart';

class ClinicianPDF {
  static Future<File> generate() async {
    final pdf = pw.Document();
    final result = await RiskEngine.computeRisk();

    final riskLevel = result["risk_level"];
    final explanations =
        Map<String, double>.from(result["explanation"] ?? {});

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "NeuroSense — Cognitive Risk Summary",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 16),

                pw.Text(
                  "Risk Level: ${riskLevel.toString().toUpperCase()}",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 12),

                pw.Text(
                  "This report summarizes longitudinal cognitive signals "
                  "collected via smartphone-based assessments. "
                  "It is intended to support clinical conversations and "
                  "does not provide a diagnosis.",
                  style: const pw.TextStyle(fontSize: 12),
                ),

                pw.SizedBox(height: 24),

                pw.Text(
                  "Contributing Factors",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 8),

                ...explanations.entries.map(
                  (e) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(e.key),
                        pw.Text(
                          e.value.abs().toStringAsFixed(2),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                pw.Spacer(),

                pw.Text(
                  "Recommendation:\n"
                  "If concerns persist, further clinical evaluation may "
                  "be considered at the discretion of the healthcare professional.",
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/neurosense_clinician_report.pdf");
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
