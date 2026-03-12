import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/ambience.dart';
import '../../../data/repositories/ambience_repository.dart';

final ambienceRepositoryProvider =
    Provider<AmbienceRepository>((_) => AmbienceRepository());

class AmbienceState {
  final List<Ambience> allAmbiences;
  final String searchQuery;
  final String? selectedTag;
  final bool isLoading;
  final String? error;

  const AmbienceState({
    this.allAmbiences = const [],
    this.searchQuery = '',
    this.selectedTag,
    this.isLoading = false,
    this.error,
  });

  AmbienceState copyWith({
    List<Ambience>? allAmbiences,
    String? searchQuery,
    String? selectedTag,
    bool clearTag = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AmbienceState(
      allAmbiences: allAmbiences ?? this.allAmbiences,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTag: clearTag ? null : (selectedTag ?? this.selectedTag),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<Ambience> get filtered {
    return allAmbiences.where((a) {
      final q = searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty || a.title.toLowerCase().contains(q);
      final matchesTag = selectedTag == null || a.tag == selectedTag;
      return matchesSearch && matchesTag;
    }).toList();
  }

  bool get hasActiveFilter => searchQuery.isNotEmpty || selectedTag != null;
}

class AmbienceNotifier extends StateNotifier<AmbienceState> {
  final AmbienceRepository _repository;

  AmbienceNotifier(this._repository) : super(const AmbienceState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ambiences = await _repository.loadAmbiences();
      state = state.copyWith(allAmbiences: ambiences, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearch(String query) => state = state.copyWith(searchQuery: query);

  void setTag(String? tag) {
    if (state.selectedTag == tag) {
      state = state.copyWith(clearTag: true);
    } else {
      state = state.copyWith(selectedTag: tag);
    }
  }

  void clearFilters() =>
      state = state.copyWith(searchQuery: '', clearTag: true);
}

final ambienceProvider =
    StateNotifierProvider<AmbienceNotifier, AmbienceState>((ref) {
  return AmbienceNotifier(ref.watch(ambienceRepositoryProvider));
});
