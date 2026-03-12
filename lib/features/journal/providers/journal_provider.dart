import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/journal_entry.dart';
import '../../../data/repositories/journal_repository.dart';

final journalRepositoryProvider =
    Provider<JournalRepository>((_) => JournalRepository());

class JournalState {
  final List<JournalEntry> entries;
  final bool isLoading;
  final String? error;

  const JournalState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });

  JournalState copyWith({
    List<JournalEntry>? entries,
    bool? isLoading,
    String? error,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class JournalNotifier extends StateNotifier<JournalState> {
  final JournalRepository _repository;

  JournalNotifier(this._repository) : super(const JournalState()) {
    _load();
  }

  void _load() {
    try {
      final entries = _repository.getAllEntries();
      state = state.copyWith(entries: entries);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addEntry(JournalEntry entry) async {
    await _repository.saveEntry(entry);
    _load();
  }
}

final journalProvider =
    StateNotifierProvider<JournalNotifier, JournalState>((ref) {
  return JournalNotifier(ref.watch(journalRepositoryProvider));
});
