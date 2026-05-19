import '../models/typing_biomarker_model.dart';

class TypingBiomarkerService {

  DateTime? _sessionStart;

  DateTime? _lastKeyTime;

  int pauseCount = 0;

  int backspaceCount = 0;

  int totalCharacters = 0;

  final List<int> pauseDurations =
      [];

  // =========================
  // START SESSION
  // =========================

  void startSession() {

    _sessionStart =
        DateTime.now();

    _lastKeyTime = null;

    pauseCount = 0;

    backspaceCount = 0;

    totalCharacters = 0;

    pauseDurations.clear();
  }

  // =========================
  // TRACK INPUT
  // =========================

  void onTextChanged(
    String oldText,
    String newText,
  ) {

    final now =
        DateTime.now();

    // =========================
    // PAUSE DETECTION
    // =========================

    if (_lastKeyTime != null) {

      final diff =
          now
              .difference(
                _lastKeyTime!,
              )
              .inMilliseconds;

      // Hesitation threshold
      if (diff > 1500) {

        pauseCount++;

        pauseDurations.add(
          diff,
        );
      }
    }

    _lastKeyTime = now;

    // =========================
    // BACKSPACE DETECTION
    // =========================

    if (newText.length <
        oldText.length) {

      backspaceCount++;
    }

    totalCharacters =
        newText.length;
  }

  // =========================
  // END SESSION
  // =========================

  TypingBiomarkerModel
      endSession() {

    final sessionEnd =
        DateTime.now();

    final durationMs =
        _sessionStart == null
            ? 0
            : sessionEnd
                .difference(
                  _sessionStart!,
                )
                .inMilliseconds;

    final avgPause = pauseDurations
            .isEmpty
        ? 0.0
        : pauseDurations.reduce(
                  (a, b) => a + b,
                ) /
            pauseDurations.length;

    final double typingSpeed =
    durationMs == 0
        ? 0.0
        : totalCharacters /
            (durationMs / 1000);

    return TypingBiomarkerModel(

      typingSpeed:
          typingSpeed,

      pauseCount:
          pauseCount,

      backspaceCount:
          backspaceCount,

      averagePauseMs:
          avgPause,

      totalCharacters:
          totalCharacters,

      sessionDurationMs:
          durationMs,

      timestamp:
          DateTime.now(),
    );
  }
}