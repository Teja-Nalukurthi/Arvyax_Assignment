class PlayerSession {
  final String ambienceId;
  final int elapsedSeconds;
  final bool isPlaying;
  final DateTime savedAt;

  const PlayerSession({
    required this.ambienceId,
    required this.elapsedSeconds,
    required this.isPlaying,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() => {
        'ambienceId': ambienceId,
        'elapsedSeconds': elapsedSeconds,
        'isPlaying': isPlaying,
        'savedAt': savedAt.toIso8601String(),
      };

  factory PlayerSession.fromMap(Map<dynamic, dynamic> map) {
    return PlayerSession(
      ambienceId: map['ambienceId'] as String,
      elapsedSeconds: map['elapsedSeconds'] as int,
      isPlaying: map['isPlaying'] as bool? ?? false,
      savedAt: DateTime.parse(map['savedAt'] as String),
    );
  }
}
