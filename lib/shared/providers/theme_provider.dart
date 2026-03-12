import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the app's active [ThemeMode].
/// Defaults to [ThemeMode.system] so it follows the device dark/light setting.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
