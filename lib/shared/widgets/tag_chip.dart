import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TagChip extends StatelessWidget {
  final String tag;
  final bool small;

  const TagChip({super.key, required this.tag, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.tagBgColor(tag),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.tagColor(tag).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: AppColors.tagColor(tag),
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
