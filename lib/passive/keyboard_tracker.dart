import 'dart:async';

class KeyboardTracker {
  static DateTime? _lastKeyTime;
  static final List<int> _keyIntervals = [];
  static int _backspaceCount = 0;
  static int _errorBursts = 0;

  static Timer? _burstTimer;
  static int _burstBackspaces = 0;

  /// Call this on every key press
  static void onKeyPress({required bool isBackspace}) {
    final now = DateTime.now();

    if (_lastKeyTime != null) {
      final diff = now.difference(_lastKeyTime!).inMilliseconds;
      _keyIntervals.add(diff);
    }
    _lastKeyTime = now;

    if (isBackspace) {
      _backspaceCount++;
      _burstBackspaces++;

      _burstTimer?.cancel();
      _burstTimer = Timer(const Duration(seconds: 2), () {
        if (_burstBackspaces >= 3) {
          _errorBursts++;
        }
        _burstBackspaces = 0;
      });
    }
  }

  /// Export aggregated metrics (DOUBLE ONLY)
  static Map<String, double> exportDailyMetrics() {
    final double avgInterval = _keyIntervals.isEmpty
        ? 0.0
        : _keyIntervals.reduce((a, b) => a + b) /
            _keyIntervals.length;

    final Map<String, double> metrics = {
      "avg_inter_key_interval_ms": avgInterval,
      "backspace_count": _backspaceCount.toDouble(),
      "error_bursts": _errorBursts.toDouble(),
    };

    reset();
    return metrics;
  }

  static void reset() {
    _keyIntervals.clear();
    _backspaceCount = 0;
    _errorBursts = 0;
    _lastKeyTime = null;
  }
}
