import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/player_provider.dart';
import '../widgets/breathing_animation.dart';

class SessionPlayerScreen extends ConsumerStatefulWidget {
  const SessionPlayerScreen({super.key});

  @override
  ConsumerState<SessionPlayerScreen> createState() =>
      _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen> {
  bool _isSeeking = false;
  double _seekValue = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(playerProvider.notifier).setPlayerScreenOpen(true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final ambience = playerState.ambience;

    // Navigate to reflection when session completes
    ref.listen(playerProvider, (prev, next) {
      if (!(prev?.isCompleted ?? false) &&
          next.isCompleted &&
          next.ambience != null) {
        if (mounted) {
          ref.read(playerProvider.notifier).setPlayerScreenOpen(false);
          Navigator.of(context).pushReplacementNamed(
            '/reflection',
            arguments: next.ambience,
          );
        }
      }
    });

    if (ambience == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    Color accentColor;
    try {
      accentColor = Color(int.parse('FF${ambience.accentColor}', radix: 16));
    } catch (_) {
      accentColor = AppColors.accent;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ref.read(playerProvider.notifier).setPlayerScreenOpen(false);
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            BreathingAnimation(accentColor: accentColor),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context, ref, playerState),
                  Expanded(
                    child: _buildCenterContent(context, ambience, accentColor),
                  ),
                  _buildControls(context, ref, playerState),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref, PlayerState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 28, color: AppColors.textSecondary),
            onPressed: () {
              ref.read(playerProvider.notifier).setPlayerScreenOpen(false);
              Navigator.of(context).pop();
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _confirmEndSession(context, ref),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterContent(
      BuildContext context, ambience, Color accentColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Orb
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                accentColor.withValues(alpha: 0.5),
                accentColor.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.self_improvement_rounded,
            color: accentColor.withValues(alpha: 0.8),
            size: 56,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          ambience.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          ambience.tag,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildControls(
      BuildContext context, WidgetRef ref, PlayerState state) {
    final position =
        _isSeeking ? Duration(seconds: _seekValue.toInt()) : state.position;
    final total = state.totalDuration;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDuration(total),
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Seek bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value:
                  _isSeeking ? _seekValue : state.position.inSeconds.toDouble(),
              min: 0,
              max: total.inSeconds > 0 ? total.inSeconds.toDouble() : 1,
              onChangeStart: (v) {
                setState(() {
                  _isSeeking = true;
                  _seekValue = v;
                });
              },
              onChanged: (v) {
                setState(() => _seekValue = v);
              },
              onChangeEnd: (v) {
                setState(() => _isSeeking = false);
                ref
                    .read(playerProvider.notifier)
                    .seek(Duration(seconds: v.toInt()));
              },
            ),
          ),
          const SizedBox(height: 20),
          // Play / Pause
          GestureDetector(
            onTap: state.isLoading
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    ref.read(playerProvider.notifier).togglePlayPause();
                  },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: state.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Icon(
                      state.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmEndSession(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text(
            'Your session will end and you\'ll be taken to your reflection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
            child: const Text('End'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final ambience = ref.read(playerProvider).ambience;
      await ref.read(playerProvider.notifier).endSession();
      if (context.mounted && ambience != null) {
        ref.read(playerProvider.notifier).setPlayerScreenOpen(false);
        Navigator.of(context).pushReplacementNamed(
          '/reflection',
          arguments: ambience,
        );
      }
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
