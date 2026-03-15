import 'dart:math';
import '../storage/local_store.dart';
import '../risk/risk_engine.dart';

class RiskEngine {
  static Future<Map<String, dynamic>> computeRisk() async {
    try {
      final memory = await LocalStore.getMemoryScores();
      final digit = await LocalStore.getDigitSpanScores();
      final trail = await LocalStore.getTrailTimes();

      if (memory.length < 3 ||
          digit.length < 3 ||
          trail.length < 3) {
        return {
          "risk_level": "insufficient_data",
          "score": 0.0,
          "explanation": {},
        };
      }

      double zScore(List<int> values, {bool inverse = false}) {
        final mean =
            values.reduce((a, b) => a + b) / values.length;

        final variance = values
                .map((v) => pow(v - mean, 2))
                .reduce((a, b) => a + b) /
            values.length;

        final sd = sqrt(variance);
        if (sd == 0) return 0;

        final z = (values.last - mean) / sd;
        return inverse ? -z : z;
      }

      final memoryZ = zScore(memory, inverse: true);
      final attentionZ = zScore(digit);
      final executiveZ = zScore(trail);

      final riskScore =
          (0.4 * memoryZ) +
          (0.3 * attentionZ) +
          (0.3 * executiveZ);

      String level = "low";
      if (riskScore > 1.5) level = "high";
      else if (riskScore > 0.8) level = "medium";

      return {
        "risk_level": level,
        "score": riskScore,
        "explanation": {
          "memory": memoryZ,
          "attention": attentionZ,
          "executive": executiveZ,
        },
      };
    } catch (_) {
      return {
        "risk_level": "error",
        "score": 0.0,
        "explanation": {},
      };
    }
  }

  static List<double> toZTimeline(
    List<int> values, {
    bool inverse = false,
  }) {
    if (values.isEmpty) return [];

    final mean =
        values.reduce((a, b) => a + b) / values.length;

    final variance = values
            .map((v) => pow(v - mean, 2))
            .reduce((a, b) => a + b) /
        values.length;

    final sd = sqrt(variance);
    if (sd == 0) return List.filled(values.length, 0);

    return values.map((v) {
      final z = (v - mean) / sd;
      return inverse ? -z : z;
    }).toList();
  }
}
