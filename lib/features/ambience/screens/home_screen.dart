import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/ambience.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/widgets/mini_player_bar.dart';
import '../providers/ambience_provider.dart';
import '../widgets/ambience_card.dart';

const _tags = ['Focus', 'Calm', 'Sleep', 'Reset'];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ambienceProvider);
    final notifier = ref.read(ambienceProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSearchBar(notifier),
            _buildTagFilters(state, notifier),
            const SizedBox(height: 4),
            Expanded(
              child: _buildAmbienceList(state, notifier),
            ),
            const MiniPlayerBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ArvyaX',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Choose your ambience',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              size: 22,
            ),
            onPressed: () {
              final current = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state =
                  current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, size: 24),
            onPressed: () => Navigator.of(context).pushNamed('/history'),
            tooltip: 'Reflections',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AmbienceNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: notifier.setSearch,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search ambiences…',
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textTertiary, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textTertiary, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    notifier.setSearch('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTagFilters(AmbienceState state, AmbienceNotifier notifier) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: _tags.map((tag) {
          final isSelected = state.selectedTag == tag;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => notifier.setTag(tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.tagBgColor(tag)
                      : AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.tagColor(tag).withValues(alpha: 0.5)
                        : AppColors.divider,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.tagColor(tag)
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmbienceList(AmbienceState state, AmbienceNotifier notifier) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (state.error != null) {
      return Center(
        child: Text(
          'Failed to load ambiences',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final items = state.filtered;

    if (items.isEmpty) {
      return _buildEmptyState(state, notifier);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final ambience = items[index];
        return AmbienceCard(
          ambience: ambience,
          onTap: () => _openDetail(context, ambience),
        );
      },
    );
  }

  Widget _buildEmptyState(AmbienceState state, AmbienceNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: AppColors.textTertiary,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'No ambiences found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search or clear your filters.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (state.hasActiveFilter)
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  notifier.clearFilters();
                },
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Clear Filters'),
              ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Ambience ambience) {
    Navigator.of(context).pushNamed('/ambience-detail', arguments: ambience);
  }
}
