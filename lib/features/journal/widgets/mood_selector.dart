import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

const _moods = ['Calm', 'Grounded', 'Energized', 'Sleepy'];

const _moodIcons = {
  'Calm': Icons.water_rounded,
  'Grounded': Icons.park_rounded,
  'Energized': Icons.bolt_rounded,
  'Sleepy': Icons.bedtime_rounded,
};

class MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _moods.map((mood) {
        final isSelected = selectedMood == mood;
        final color = AppColors.moodColor(mood);
        return GestureDetector(
          onTap: () => onMoodSelected(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.6)
                    : AppColors.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _moodIcons[mood] ?? Icons.mood_rounded,
                  color: isSelected ? color : AppColors.textTertiary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  mood,
                  style: TextStyle(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
