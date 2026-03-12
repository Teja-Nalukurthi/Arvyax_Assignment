class Ambience {
  final String id;
  final String title;
  final String tag;
  final int durationMinutes;
  final String imageUrl;
  final String description;
  final List<String> sensoryRecipes;
  final String accentColor;

  const Ambience({
    required this.id,
    required this.title,
    required this.tag,
    required this.durationMinutes,
    required this.imageUrl,
    required this.description,
    required this.sensoryRecipes,
    required this.accentColor,
  });

  factory Ambience.fromJson(Map<String, dynamic> json) {
    return Ambience(
      id: json['id'] as String,
      title: json['title'] as String,
      tag: json['tag'] as String,
      durationMinutes: json['durationMinutes'] as int,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      sensoryRecipes: List<String>.from(json['sensoryRecipes'] as List),
      accentColor: json['accentColor'] as String,
    );
  }

  Duration get duration => Duration(minutes: durationMinutes);

  String get durationLabel => '$durationMinutes min';
}
