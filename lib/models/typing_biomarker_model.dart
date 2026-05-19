class TypingBiomarkerModel {

  final double typingSpeed;

  final int pauseCount;

  final int backspaceCount;

  final double averagePauseMs;

  final int totalCharacters;

  final int sessionDurationMs;

  final DateTime timestamp;

  TypingBiomarkerModel({

    required this.typingSpeed,

    required this.pauseCount,

    required this.backspaceCount,

    required this.averagePauseMs,

    required this.totalCharacters,

    required this.sessionDurationMs,

    required this.timestamp,
  });

  // =========================
  // TO MAP
  // =========================

  Map<String, dynamic> toMap() {

    return {

      "typingSpeed":
          typingSpeed,

      "pauseCount":
          pauseCount,

      "backspaceCount":
          backspaceCount,

      "averagePauseMs":
          averagePauseMs,

      "totalCharacters":
          totalCharacters,

      "sessionDurationMs":
          sessionDurationMs,

      "timestamp":
          timestamp
              .toIso8601String(),
    };
  }

  // =========================
  // FROM MAP
  // =========================

  factory TypingBiomarkerModel.fromMap(
    Map<String, dynamic> map,
  ) {

    return TypingBiomarkerModel(

      typingSpeed:
          (map["typingSpeed"] ?? 0)
              .toDouble(),

      pauseCount:
          map["pauseCount"] ?? 0,

      backspaceCount:
          map["backspaceCount"] ?? 0,

      averagePauseMs:
          (map["averagePauseMs"] ?? 0)
              .toDouble(),

      totalCharacters:
          map["totalCharacters"] ?? 0,

      sessionDurationMs:
          map["sessionDurationMs"] ?? 0,

      timestamp:
          DateTime.parse(
        map["timestamp"],
      ),
    );
  }
}