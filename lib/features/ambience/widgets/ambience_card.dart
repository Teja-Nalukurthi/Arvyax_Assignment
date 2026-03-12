import 'package:flutter/material.dart';
import '../../../data/models/ambience.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/tag_chip.dart';

class AmbienceCard extends StatelessWidget {
  final Ambience ambience;
  final VoidCallback onTap;

  const AmbienceCard({
    super.key,
    required this.ambience,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(15),
              ),
              child: SizedBox(
                width: 100,
                height: 90,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ColorPlaceholder(accentColor: ambience.accentColor),
                    Image.network(
                      ambience.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _ColorPlaceholder(accentColor: ambience.accentColor),
                      loadingBuilder: (_, child, event) {
                        if (event == null) return child;
                        return _ColorPlaceholder(
                            accentColor: ambience.accentColor);
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TagChip(tag: ambience.tag, small: true),
                        const Spacer(),
                        Text(
                          ambience.durationLabel,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ambience.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ambience.sensoryRecipes.take(3).join(' · '),
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textTertiary,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPlaceholder extends StatelessWidget {
  final String accentColor;
  const _ColorPlaceholder({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    Color color;
    try {
      color = Color(int.parse('FF$accentColor', radix: 16));
    } catch (_) {
      color = AppColors.surfaceElevated;
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.3)],
        ),
      ),
      child: Icon(
        Icons.spa_rounded,
        color: color.withValues(alpha: 0.6),
        size: 28,
      ),
    );
  }
}
