import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/models/ambience.dart';
import 'data/models/journal_entry.dart';
import 'features/ambience/screens/ambience_detail_screen.dart';
import 'features/ambience/screens/home_screen.dart';
import 'features/journal/screens/journal_detail_screen.dart';
import 'features/journal/screens/journal_history_screen.dart';
import 'features/journal/screens/reflection_screen.dart';
import 'features/player/screens/session_player_screen.dart';
import 'shared/theme/app_theme.dart';

class ArvyaXApp extends ConsumerWidget {
  const ArvyaXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ArvyaX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (ctx) => const HomeScreen(),
        '/history': (ctx) => const JournalHistoryScreen(),
        '/session': (ctx) => const SessionPlayerScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/ambience-detail':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => AmbienceDetailScreen(
                ambience: settings.arguments as Ambience,
              ),
            );
          case '/reflection':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => ReflectionScreen(
                ambience: settings.arguments as Ambience,
              ),
            );
          case '/journal-detail':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => JournalDetailScreen(
                entry: settings.arguments as JournalEntry,
              ),
            );
        }
        return null;
      },
    );
  }
}
