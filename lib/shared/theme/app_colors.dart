import 'package:flutter/material.dart';

abstract class AppColors {
  // Background layers
  static const background = Color(0xFF09090F);
  static const surface = Color(0xFF111118);
  static const surfaceElevated = Color(0xFF18181F);
  static const surfaceCard = Color(0xFF1D1D26);

  // Accent
  static const accent = Color(0xFF9B8BF4);
  static const accentDim = Color(0x559B8BF4);
  static const accentGlow = Color(0x259B8BF4);

  // Text
  static const textPrimary = Color(0xFFF0EEF8);
  static const textSecondary = Color(0xFF9896B0);
  static const textTertiary = Color(0xFF5C5A74);

  // Tags
  static const tagFocus = Color(0xFF7EC8E3);
  static const tagFocusBg = Color(0x227EC8E3);
  static const tagCalm = Color(0xFF7DD4BA);
  static const tagCalmBg = Color(0x227DD4BA);
  static const tagSleep = Color(0xFFB09CF4);
  static const tagSleepBg = Color(0x22B09CF4);
  static const tagReset = Color(0xFFF4BD6E);
  static const tagResetBg = Color(0x22F4BD6E);

  // Moods
  static const moodCalm = Color(0xFF7DD4BA);
  static const moodGrounded = Color(0xFF8DB87A);
  static const moodEnergized = Color(0xFFF4BD6E);
  static const moodSleepy = Color(0xFFB09CF4);

  // Divider
  static const divider = Color(0xFF252530);

  static Color tagColor(String tag) {
    switch (tag) {
      case 'Focus':
        return tagFocus;
      case 'Calm':
        return tagCalm;
      case 'Sleep':
        return tagSleep;
      case 'Reset':
        return tagReset;
      default:
        return tagFocus;
    }
  }

  static Color tagBgColor(String tag) {
    switch (tag) {
      case 'Focus':
        return tagFocusBg;
      case 'Calm':
        return tagCalmBg;
      case 'Sleep':
        return tagSleepBg;
      case 'Reset':
        return tagResetBg;
      default:
        return tagFocusBg;
    }
  }

  static Color moodColor(String mood) {
    switch (mood) {
      case 'Calm':
        return moodCalm;
      case 'Grounded':
        return moodGrounded;
      case 'Energized':
        return moodEnergized;
      case 'Sleepy':
        return moodSleepy;
      default:
        return moodCalm;
    }
  }
}
