import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ambience.dart';

class AmbienceRepository {
  static const _assetPath = 'assets/data/ambiences.json';

  Future<List<Ambience>> loadAmbiences() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => Ambience.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
