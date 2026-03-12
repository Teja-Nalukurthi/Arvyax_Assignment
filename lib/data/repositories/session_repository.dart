import 'package:hive_flutter/hive_flutter.dart';
import '../models/player_session.dart';

class SessionRepository {
  static const _boxName = 'session_state';
  static const _sessionKey = 'active_session';

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  Future<void> saveSession(PlayerSession session) async {
    await _box.put(_sessionKey, session.toMap());
  }

  PlayerSession? loadSession() {
    final data = _box.get(_sessionKey);
    if (data == null) return null;
    return PlayerSession.fromMap(data as Map);
  }

  Future<void> clearSession() async {
    await _box.delete(_sessionKey);
  }
}
