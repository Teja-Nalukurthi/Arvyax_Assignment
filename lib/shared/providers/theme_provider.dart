import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the app's active [ThemeMode].
/// Defaults to [ThemeMode.dark] — the app's primary design intent.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
