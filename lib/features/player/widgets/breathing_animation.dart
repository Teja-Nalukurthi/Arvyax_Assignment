import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

/// A subtle breathing gradient animation that pulses slowly
class BreathingAnimation extends StatefulWidget {
  final Color accentColor;
  const BreathingAnimation({super.key, required this.accentColor});

  @override
  State<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final t = _animation.value;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8 + (t * 0.4),
              colors: [
                widget.accentColor.withValues(alpha: 0.18 + t * 0.08),
                AppColors.background.withValues(alpha: 0.95),
                AppColors.background,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        );
      },
    );
  }
}
