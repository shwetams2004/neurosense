import 'dart:async';

class KeyboardTracker {
  static DateTime? _lastKeyTime;
  static DateTime? _sessionStart;

  static final List<int>
      _keyIntervals = [];

  static int _backspaceCount = 0;
  static int _errorBursts = 0;

  static int _totalKeys = 0;

  static int _hesitationPauses = 0;

  static int _longPauses = 0;

  static Timer? _burstTimer;
  static int _burstBackspaces = 0;

  /// =========================
  /// TRACK EVERY KEYSTROKE
  /// =========================

  static void onKeyPress({
    required bool isBackspace,
  }) {
    final now = DateTime.now();

    _sessionStart ??= now;

    _totalKeys++;

    if (_lastKeyTime != null) {
      final diff = now
          .difference(_lastKeyTime!)
          .inMilliseconds;

      _keyIntervals.add(diff);

      // =========================
      // HESITATION DETECTION
      // =========================

      if (diff > 1500) {
        _hesitationPauses++;
      }

      // =========================
      // LONG INACTIVITY
      // =========================

      if (diff > 5000) {
        _longPauses++;
      }
    }

    _lastKeyTime = now;

    // =========================
    // BACKSPACE / ERROR BURSTS
    // =========================

    if (isBackspace) {
      _backspaceCount++;

      _burstBackspaces++;

      _burstTimer?.cancel();

      _burstTimer = Timer(
        const Duration(seconds: 2),
        () {
          if (_burstBackspaces >= 3) {
            _errorBursts++;
          }

          _burstBackspaces = 0;
        },
      );
    }
  }

  /// =========================
  /// EXPORT METRICS
  /// =========================

  static Map<String, double>
      exportDailyMetrics() {
    final avgInterval =
        _keyIntervals.isEmpty
            ? 0.0
            : _keyIntervals.reduce(
                      (a, b) => a + b,
                    ) /
                _keyIntervals.length;

    // =========================
    // SESSION DURATION
    // =========================

    double sessionDuration = 0;

    if (_sessionStart != null &&
        _lastKeyTime != null) {
      sessionDuration = _lastKeyTime!
              .difference(_sessionStart!)
              .inSeconds
              .toDouble();
    }

    // =========================
    // TYPING SPEED
    // =========================

    double typingSpeed = 0;

    if (sessionDuration > 0) {
      typingSpeed =
          _totalKeys /
          sessionDuration;
    }

    // =========================
    // CORRECTION RATIO
    // =========================

    double correctionRatio = 0;

    if (_totalKeys > 0) {
      correctionRatio =
          _backspaceCount /
          _totalKeys;
    }

    final metrics = {
      "avg_inter_key_interval_ms":
          avgInterval,

      "backspace_count":
          _backspaceCount.toDouble(),

      "error_bursts":
          _errorBursts.toDouble(),

      "total_keys":
          _totalKeys.toDouble(),

      "hesitation_pauses":
          _hesitationPauses.toDouble(),

      "long_pauses":
          _longPauses.toDouble(),

      "session_duration_sec":
          sessionDuration,

      "typing_speed_keys_per_sec":
          typingSpeed,

      "correction_ratio":
          correctionRatio,
    };

    reset();

    return metrics;
  }

  /// =========================
  /// RESET SESSION
  /// =========================

  static void reset() {
    _keyIntervals.clear();

    _backspaceCount = 0;

    _errorBursts = 0;

    _totalKeys = 0;

    _hesitationPauses = 0;

    _longPauses = 0;

    _lastKeyTime = null;

    _sessionStart = null;
  }
}