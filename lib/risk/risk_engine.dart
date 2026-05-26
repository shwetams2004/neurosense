import 'dart:math';

import '../storage/local_store.dart';

class RiskEngine {
  static Future<Map<String, dynamic>>
      computeRisk() async {
    try {
      // =========================
      // CURRENT USER
      // =========================

      final currentUser =
          await LocalStore.getCurrentUser();

      if (currentUser == null) {
        return {
          "risk_level":
              "insufficient_data",
          "score": 0.0,
          "explanation": {},
        };
      }

      // =========================
      // USER-SPECIFIC SCORES
      // =========================

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

      // =========================
      // NEED MINIMUM DATA
      // =========================

      if (memory.isEmpty &&
    digit.isEmpty &&
    trail.isEmpty) {
        return {
          "risk_level":
              "insufficient_data",
          "score": 0.0,
          "explanation": {},
        };
      }

      // =========================
      // Z-SCORE FUNCTION
      // =========================

      double zScore(
        List<int> values, {
        bool inverse = false,
      }) {
        final mean =
            values.reduce(
                  (a, b) => a + b,
                ) /
                values.length;

        final variance = values
                .map(
                  (v) => pow(
                    v - mean,
                    2,
                  ),
                )
                .reduce(
                  (a, b) => a + b,
                ) /
            values.length;

        final sd = sqrt(variance);

        if (sd == 0) {
          return 0;
        }

        final z =
            (values.last - mean) /
                sd;

        return inverse ? -z : z;
      }

      // =========================
      // DOMAIN SCORES
      // =========================

      final memoryZ = zScore(
        memory,
        inverse: true,
      );

      final attentionZ =
          zScore(digit);

      final executiveZ =
          zScore(trail);

      // =========================
      // COMPOSITE RISK SCORE
      // =========================

      final riskScore =
          (0.4 * memoryZ) +
              (0.3 * attentionZ) +
              (0.3 * executiveZ);

      // =========================
      // RISK LEVEL
      // =========================

      String level = "low";

      if (riskScore > 1.5) {
        level = "high";
      } else if (riskScore > 0.8) {
        level = "medium";
      }

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

  // =========================
  // TIMELINE NORMALIZATION
  // =========================

  static List<double> toZTimeline(
  List<num> values, {
  bool inverse = false,
}) {

  if (values.isEmpty) {
    return [];
  }

  // =========================
  // SINGLE SESSION SUPPORT
  // =========================

  if (values.length == 1) {

    double value =
        values.first.toDouble();

    // normalize roughly to z-like range

    double normalized =
        (value / 10.0)
            .clamp(0.0, 1.0);

    double z =
        (normalized * 6) - 3;

    if (inverse) {
      z = -z;
    }

    return [z];
  }

  // =========================
  // NORMAL MULTI-SESSION
  // =========================

  double mean =
      values.reduce(
            (a, b) => a + b,
          ) /
          values.length;

  double variance = values
          .map(
            (e) =>
                (e - mean) *
                (e - mean),
          )
          .reduce((a, b) => a + b) /
      values.length;

  double std =
      sqrt(variance);

  if (std == 0) {
    return List.generate(
      values.length,
      (_) => 0,
    );
  }

  return values.map((e) {

    double z =
        (e - mean) / std;

    if (inverse) {
      z = -z;
    }

    return z.clamp(-3.0, 3.0).toDouble();

  }).toList();
}
}