import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/ambience.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/mini_player_bar.dart';
import '../../../shared/widgets/tag_chip.dart';
import '../../player/providers/player_provider.dart';

class AmbienceDetailScreen extends ConsumerWidget {
  final Ambience ambience;

  const AmbienceDetailScreen({super.key, required this.ambience});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color accentColor;
    try {
      accentColor = Color(int.parse('FF${ambience.accentColor}', radix: 16));
    } catch (_) {
      accentColor = AppColors.accent;
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, accentColor),
                SliverToBoxAdapter(
                  child: _buildContent(context, ref, accentColor),
                ),
              ],
            ),
          ),
          _buildBottomBar(context, ref),
          const MiniPlayerBar(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Color accentColor) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Base gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accentColor.withValues(alpha: 0.8),
                    accentColor.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
            Image.network(
              ambience.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              loadingBuilder: (_, child, event) =>
                  event == null ? child : const SizedBox.shrink(),
            ),
            // Bottom fade
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.background,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TagChip(tag: ambience.tag),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: AppColors.textTertiary, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      ambience.durationLabel,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ambience.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ambience.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'SENSORY RECIPE',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ambience.sensoryRecipes
                .map((recipe) => _SensoryChip(label: recipe))
                .toList(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: () => _startSession(context, ref),
          child: const Text('Start Session'),
        ),
      ),
    );
  }

  void _startSession(BuildContext context, WidgetRef ref) {
    ref.read(playerProvider.notifier).startSession(ambience);
    // Use pushReplacement so the detail screen (and its MiniPlayerBar subscription)
    // is fully disposed before async state updates from startSession complete.
    Navigator.of(context).pushReplacementNamed('/session');
  }
}

class _SensoryChip extends StatelessWidget {
  final String label;
  const _SensoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
