import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';

class JournalRepository {
  static const _boxName = 'journal_entries';

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  List<JournalEntry> getAllEntries() {
    return _box.values.map((v) => JournalEntry.fromMap(v as Map)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveEntry(JournalEntry entry) async {
    await _box.put(entry.id, entry.toMap());
  }

  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
  }
}
