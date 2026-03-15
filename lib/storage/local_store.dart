import 'package:shared_preferences/shared_preferences.dart';

extension ListUtils<T> on List<T> {
  Iterable<T> takeLast(int n) => skip(length - n);
}

class LocalStore {
  /* ================= MEMORY ================= */

  static const memoryScoresKey = "memory_scores";

  static Future<void> saveMemoryScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(memoryScoresKey) ?? [];
    list.add(score.toString());
    await prefs.setStringList(memoryScoresKey, list);
  }

  static Future<List<int>> getMemoryScores() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(memoryScoresKey) ?? [])
        .map(int.parse)
        .toList();
  }

  static Future<int> getWeekCount() async {
    return (await getMemoryScores()).length;
  }

  static Future<String> analyzeMemoryTrend() async {
    final scores = await getMemoryScores();
    if (scores.length < 3) return "insufficient_data";

    final recent = scores.takeLast(3).toList();
    if (recent[2] < recent[1] && recent[1] < recent[0]) {
      return "possible_change";
    }
    return "stable";
  }

  /* ================= DIGIT SPAN ================= */

  static const digitSpanKey = "digit_span_scores";

  static Future<void> saveDigitSpanScore(int span) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(digitSpanKey) ?? [];
    list.add(span.toString());
    await prefs.setStringList(digitSpanKey, list);
  }

  static Future<List<int>> getDigitSpanScores() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(digitSpanKey) ?? [])
        .map(int.parse)
        .toList();
  }

  /* ================= TRAIL MAKING ================= */

  static const trailTimeKey = "trail_time_scores";
  static const trailErrorKey = "trail_error_scores";

  static Future<void> saveTrailMakingResult(
      int seconds, int errors) async {
    final prefs = await SharedPreferences.getInstance();
    final times = prefs.getStringList(trailTimeKey) ?? [];
    final errs = prefs.getStringList(trailErrorKey) ?? [];

    times.add(seconds.toString());
    errs.add(errors.toString());

    await prefs.setStringList(trailTimeKey, times);
    await prefs.setStringList(trailErrorKey, errs);
  }

  static Future<List<int>> getTrailTimes() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(trailTimeKey) ?? [])
        .map(int.parse)
        .toList();
  }

  static Future<List<int>> getTrailErrors() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(trailErrorKey) ?? [])
        .map(int.parse)
        .toList();
  }

  /* ================= VISUOSPATIAL ================= */

  static const visuospatialKey = "visuospatial_scores";

  static Future<void> saveVisuospatialResult({
    required int seconds,
    required int errors,
    required int taps,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(visuospatialKey) ?? [];
    list.add("$seconds,$errors,$taps");
    await prefs.setStringList(visuospatialKey, list);
  }

  static Future<List<List<int>>> getVisuospatialResults() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(visuospatialKey) ?? [])
        .map((e) => e.split(",").map(int.parse).toList())
        .toList();
  }

  /* ================= KEYBOARD ================= */

  static const keyboardMetricsKey = "keyboard_metrics";

  static Future<void> saveKeyboardMetrics(
      Map<String, double> metrics) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(keyboardMetricsKey) ?? [];

    list.add(
      "${metrics["avg_inter_key_interval_ms"] ?? 0},"
      "${metrics["backspace_count"] ?? 0},"
      "${metrics["error_bursts"] ?? 0}",
    );

    await prefs.setStringList(keyboardMetricsKey, list);
  }

  /* ================= VIGILANCE ================= */

  static const vigilanceKey = "vigilance_scores";

  static Future<void> saveVigilanceResult({
    required int hits,
    required int misses,
    required int falseAlarms,
    required int avgRtMs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(vigilanceKey) ?? [];
    list.add("$hits,$misses,$falseAlarms,$avgRtMs");
    await prefs.setStringList(vigilanceKey, list);
  }

  /* ================= SERIAL SUBTRACTION ================= */

  static const subtractionKey = "subtraction_scores";

  static Future<void> saveSerialSubtractionResult({
    required int correct,
    required int errors,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(subtractionKey) ?? [];

    list.add("$correct,$errors");
    await prefs.setStringList(subtractionKey, list);
  }

  /* ================= DEMO MODE ================= */

  static Future<void> injectDemoData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(memoryScoresKey, ["4", "4", "3"]);
    await prefs.setStringList(digitSpanKey, ["6", "6", "5"]);
    await prefs.setStringList(trailTimeKey, ["45", "50", "60"]);
    await prefs.setStringList(trailErrorKey, ["0", "1", "2"]);
  }
}
