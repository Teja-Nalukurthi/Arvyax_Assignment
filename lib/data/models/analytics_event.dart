class AnalyticsEvent {
  final String type;
  final DateTime timestamp;
  final Map<String, String> metadata;

  const AnalyticsEvent({
    required this.type,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) => AnalyticsEvent(
        type: json['type'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        metadata: Map<String, String>.from(json['metadata'] as Map? ?? {}),
      );
}
