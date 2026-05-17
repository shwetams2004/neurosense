import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
extension ListUtils<T> on List<T> {
  Iterable<T> takeLast(int n) => skip(length - n);
}

class LocalStore {
  /* ================= CURRENT USER ================= */

  static const currentUserKey = "current_user";

  static Future<void> setCurrentUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(currentUserKey, userId);
  }

  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(currentUserKey);
  }

  /* ================= MEMORY ================= */

  static String memoryScoresKey(String userId) =>
      "memory_scores_$userId";

  static Future<void> saveMemoryScore(
    String userId,
    int score,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final list =
        prefs.getStringList(memoryScoresKey(userId)) ?? [];

    list.add(score.toString());

    await prefs.setStringList(
      memoryScoresKey(userId),
      list,
    );
  }

  static Future<List<int>> getMemoryScores(
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    return (prefs.getStringList(
              memoryScoresKey(userId),
            ) ??
            [])
        .map(int.parse)
        .toList();
  }

  static Future<int> getWeekCount(
    String userId,
  ) async {
    return (await getMemoryScores(userId)).length;
  }

  static Future<String> analyzeMemoryTrend(
    String userId,
  ) async {
    final scores = await getMemoryScores(userId);

    if (scores.length < 3) {
      return "insufficient_data";
    }

    final recent = scores.takeLast(3).toList();

    if (recent[2] < recent[1] &&
        recent[1] < recent[0]) {
      return "possible_change";
    }

    return "stable";
  }

  /* ================= DIGIT SPAN ================= */

static String digitSpanKey(String userId) =>
    "digit_span_scores_$userId";

static Future<void> saveDigitSpanScore(
  String userId,
  int span,
) async {
  final prefs = await SharedPreferences.getInstance();

  final list =
      prefs.getStringList(
            digitSpanKey(userId),
          ) ??
          [];

  list.add(span.toString());

  await prefs.setStringList(
    digitSpanKey(userId),
    list,
  );
}

static Future<List<int>> getDigitSpanScores(
  String userId,
) async {
  final prefs = await SharedPreferences.getInstance();

  return (prefs.getStringList(
            digitSpanKey(userId),
          ) ??
          [])
      .map(int.parse)
      .toList();
}

  /* ================= TRAIL MAKING ================= */

static String trailTimeKey(String userId) =>
    "trail_time_scores_$userId";

static String trailErrorKey(String userId) =>
    "trail_error_scores_$userId";

static Future<void> saveTrailMakingResult(
  String userId,
  int seconds,
  int errors,
) async {
  final prefs = await SharedPreferences.getInstance();

  final times =
      prefs.getStringList(
            trailTimeKey(userId),
          ) ??
          [];

  final errs =
      prefs.getStringList(
            trailErrorKey(userId),
          ) ??
          [];

  times.add(seconds.toString());
  errs.add(errors.toString());

  await prefs.setStringList(
    trailTimeKey(userId),
    times,
  );

  await prefs.setStringList(
    trailErrorKey(userId),
    errs,
  );
}

static Future<List<int>> getTrailTimes(
  String userId,
) async {
  final prefs = await SharedPreferences.getInstance();

  return (prefs.getStringList(
            trailTimeKey(userId),
          ) ??
          [])
      .map(int.parse)
      .toList();
}

static Future<List<int>> getTrailErrors(
  String userId,
) async {
  final prefs = await SharedPreferences.getInstance();

  return (prefs.getStringList(
            trailErrorKey(userId),
          ) ??
          [])
      .map(int.parse)
      .toList();
}

  /* ================= VISUOSPATIAL ================= */

static String visuospatialTimeKey(
  String userId,
) =>
    "visuospatial_time_$userId";

static String visuospatialErrorKey(
  String userId,
) =>
    "visuospatial_errors_$userId";

static String visuospatialTapKey(
  String userId,
) =>
    "visuospatial_taps_$userId";

static Future<void>
    saveVisuospatialResult({
  required String userId,
  required int seconds,
  required int errors,
  required int taps,
}) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  final times =
      prefs.getStringList(
            visuospatialTimeKey(
                userId),
          ) ??
          [];

  final errs =
      prefs.getStringList(
            visuospatialErrorKey(
                userId),
          ) ??
          [];

  final tapList =
      prefs.getStringList(
            visuospatialTapKey(
                userId),
          ) ??
          [];

  times.add(seconds.toString());

  errs.add(errors.toString());

  tapList.add(taps.toString());

  await prefs.setStringList(
    visuospatialTimeKey(userId),
    times,
  );

  await prefs.setStringList(
    visuospatialErrorKey(userId),
    errs,
  );

  await prefs.setStringList(
    visuospatialTapKey(userId),
    tapList,
  );
}

static Future<List<int>>
    getVisuospatialTimes(
  String userId,
) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  return (prefs.getStringList(
            visuospatialTimeKey(
                userId),
          ) ??
          [])
      .map(int.parse)
      .toList();
}

static Future<List<int>>
    getVisuospatialErrors(
  String userId,
) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  return (prefs.getStringList(
            visuospatialErrorKey(
                userId),
          ) ??
          [])
      .map(int.parse)
      .toList();
}

/* ================= KEYBOARD ================= */

static const keyboardMetricsKey =
    "keyboard_metrics";

static Future<void>
    saveKeyboardMetrics(
  Map<String, double> metrics,
) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  final list =
      prefs.getStringList(
            keyboardMetricsKey,
          ) ??
          [];

  // =========================
  // STORE FULL METRIC SET
  // =========================

  final encoded =
      [
        metrics[
                "avg_inter_key_interval_ms"] ??
            0,

        metrics[
                "backspace_count"] ??
            0,

        metrics[
                "error_bursts"] ??
            0,

        metrics[
                "total_keys"] ??
            0,

        metrics[
                "hesitation_pauses"] ??
            0,

        metrics[
                "long_pauses"] ??
            0,

        metrics[
                "session_duration_sec"] ??
            0,

        metrics[
                "typing_speed_keys_per_sec"] ??
            0,

        metrics[
                "correction_ratio"] ??
            0,
      ].join(",");

  list.add(encoded);

  await prefs.setStringList(
    keyboardMetricsKey,
    list,
  );
}

static Future<
        List<Map<String, double>>>
    getKeyboardMetrics() async {
  final prefs =
      await SharedPreferences
          .getInstance();

  final raw =
      prefs.getStringList(
            keyboardMetricsKey,
          ) ??
          [];

  return raw.map((entry) {
    final parts =
        entry.split(",");

    return {
      "avg_inter_key_interval_ms":
          double.tryParse(
                parts.elementAtOrNull(
                        0) ??
                    "0",
              ) ??
              0,

      "backspace_count":
          double.tryParse(
                parts.elementAtOrNull(
                        1) ??
                    "0",
              ) ??
              0,

      "error_bursts":
          double.tryParse(
                parts.elementAtOrNull(
                        2) ??
                    "0",
              ) ??
              0,

      "total_keys":
          double.tryParse(
                parts.elementAtOrNull(
                        3) ??
                    "0",
              ) ??
              0,

      "hesitation_pauses":
          double.tryParse(
                parts.elementAtOrNull(
                        4) ??
                    "0",
              ) ??
              0,

      "long_pauses":
          double.tryParse(
                parts.elementAtOrNull(
                        5) ??
                    "0",
              ) ??
              0,

      "session_duration_sec":
          double.tryParse(
                parts.elementAtOrNull(
                        6) ??
                    "0",
              ) ??
              0,

      "typing_speed_keys_per_sec":
          double.tryParse(
                parts.elementAtOrNull(
                        7) ??
                    "0",
              ) ??
              0,

      "correction_ratio":
          double.tryParse(
                parts.elementAtOrNull(
                        8) ??
                    "0",
              ) ??
              0,
    };
  }).toList();
}

static Future<
        Map<String, double>>
    getLatestKeyboardMetrics() async {
  final all =
      await getKeyboardMetrics();

  if (all.isEmpty) {
    return {};
  }

  return all.last;
}

  /* ================= VIGILANCE ================= */

static String vigilanceHitsKey(
  String userId,
) =>
    "vigilance_hits_$userId";

static String vigilanceMissesKey(
  String userId,
) =>
    "vigilance_misses_$userId";

static String vigilanceFalseKey(
  String userId,
) =>
    "vigilance_false_$userId";

static String vigilanceRtKey(
  String userId,
) =>
    "vigilance_rt_$userId";

static Future<void>
    saveVigilanceResult({
  required String userId,
  required int hits,
  required int misses,
  required int falseAlarms,
  required int avgRtMs,
}) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  final hitsList =
      prefs.getStringList(
            vigilanceHitsKey(
                userId),
          ) ??
          [];

  final missList =
      prefs.getStringList(
            vigilanceMissesKey(
                userId),
          ) ??
          [];

  final falseList =
      prefs.getStringList(
            vigilanceFalseKey(
                userId),
          ) ??
          [];

  final rtList =
      prefs.getStringList(
            vigilanceRtKey(
                userId),
          ) ??
          [];

  hitsList.add(hits.toString());

  missList.add(
      misses.toString());

  falseList.add(
      falseAlarms.toString());

  rtList.add(avgRtMs.toString());

  await prefs.setStringList(
    vigilanceHitsKey(userId),
    hitsList,
  );

  await prefs.setStringList(
    vigilanceMissesKey(userId),
    missList,
  );

  await prefs.setStringList(
    vigilanceFalseKey(userId),
    falseList,
  );

  await prefs.setStringList(
    vigilanceRtKey(userId),
    rtList,
  );
}

static Future<List<int>>
    getVigilanceHits(
  String userId,
) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  return (prefs.getStringList(
            vigilanceHitsKey(
                userId),
          ) ??
          [])
      .map(int.parse)
      .toList();
}

static Future<List<int>>
    getVigilanceMisses(
  String userId,
) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  return (prefs.getStringList(
            vigilanceMissesKey(
                userId),
          ) ??
          [])
      .map(int.parse)
      .toList();
}

static Future<List<int>>
    getVigilanceReactionTimes(
  String userId,
) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  return (prefs.getStringList(
            vigilanceRtKey(
                userId),
          ) ??
          [])
      .map(int.parse)
      .toList();
}

  /* ================= SERIAL SUBTRACTION ================= */

static String subtractionCorrectKey(
  String userId,
) =>
    "subtraction_correct_$userId";

static String subtractionErrorKey(
  String userId,
) =>
    "subtraction_errors_$userId";

static Future<void>
    saveSerialSubtractionResult({
  required String userId,
  required int correct,
  required int errors,
}) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  final correctList =
      prefs.getStringList(
            subtractionCorrectKey(
                userId),
          ) ??
          [];

  final errorList =
      prefs.getStringList(
            subtractionErrorKey(
                userId),
          ) ??
          [];

  correctList.add(
      correct.toString());

  errorList.add(
      errors.toString());

  await prefs.setStringList(
    subtractionCorrectKey(
        userId),
    correctList,
  );

  await prefs.setStringList(
    subtractionErrorKey(
        userId),
    errorList,
  );
}

static Future<List<int>>
    getSerialSubtractionCorrect(
  String userId,
) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  return (prefs.getStringList(
            subtractionCorrectKey(
                userId),
          ) ??
          [])
      .map(int.parse)
      .toList();
}

static Future<List<int>>
    getSerialSubtractionErrors(
  String userId,
) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  return (prefs.getStringList(
            subtractionErrorKey(
                userId),
          ) ??
          [])
      .map(int.parse)
      .toList();
}

/* ================= SPEECH ================= */

static String speechPauseKey(
  String userId,
) =>
    "speech_pause_$userId";

static String speechRateKey(
  String userId,
) =>
    "speech_rate_$userId";

static String speechHesitationKey(
  String userId,
) =>
    "speech_hesitation_$userId";

static Future<void>
    saveSpeechMetrics({
  required String userId,
  required Map<String, dynamic>
      metrics,
}) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  final pauseList =
      prefs.getStringList(
            speechPauseKey(
                userId),
          ) ??
          [];

  final rateList =
      prefs.getStringList(
            speechRateKey(
                userId),
          ) ??
          [];

  final hesitationList =
      prefs.getStringList(
            speechHesitationKey(
                userId),
          ) ??
          [];

  pauseList.add(
    metrics["pause_ratio"]
        .toString(),
  );

  rateList.add(
    metrics["speech_rate"]
        .toString(),
  );

  hesitationList.add(
    metrics["hesitation_events"]
        .toString(),
  );

  await prefs.setStringList(
    speechPauseKey(userId),
    pauseList,
  );

  await prefs.setStringList(
    speechRateKey(userId),
    rateList,
  );

  await prefs.setStringList(
    speechHesitationKey(
        userId),
    hesitationList,
  );
}

static Future<List<double>>
    getSpeechPauseRatios(
  String userId,
) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  return (prefs.getStringList(
            speechPauseKey(
                userId),
          ) ??
          [])
      .map(double.parse)
      .toList();
}

static Future<List<int>>
    getSpeechRates(
  String userId,
) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  return (prefs.getStringList(
            speechRateKey(
                userId),
          ) ??
          [])
      .map(int.parse)
      .toList();
}

  /* ================= DEMO MODE ================= */

  static Future<void> injectDemoData() async {
  final prefs = await SharedPreferences.getInstance();

  final currentUser =
      prefs.getString(currentUserKey) ??
          "demo_user";

  await prefs.setStringList(
    memoryScoresKey(currentUser),
    ["4", "4", "3"],
  );

  await prefs.setStringList(
    digitSpanKey(currentUser),
    ["6", "6", "5"],
  );

  await prefs.setStringList(
    trailTimeKey(currentUser),
    ["45", "50", "60"],
  );

  await prefs.setStringList(
    trailErrorKey(currentUser),
    ["0", "1", "2"],
  );
}
}