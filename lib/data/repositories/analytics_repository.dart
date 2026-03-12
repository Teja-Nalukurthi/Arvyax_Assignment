import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/analytics_event.dart';

class AnalyticsRepository {
  static const _boxName = 'analytics_events';

  static Future<void> init() => Hive.openBox<String>(_boxName);

  Box<String> get _box => Hive.box<String>(_boxName);

  Future<void> log(AnalyticsEvent event) async {
    await _box.add(jsonEncode(event.toJson()));
  }

  List<AnalyticsEvent> getAll() {
    return _box.values
        .map((json) =>
            AnalyticsEvent.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }
}

final analyticsRepositoryProvider =
    Provider<AnalyticsRepository>((_) => AnalyticsRepository());
