import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/models/ambience.dart';
import 'data/models/journal_entry.dart';
import 'features/ambience/screens/ambience_detail_screen.dart';
import 'features/ambience/screens/home_screen.dart';
import 'features/journal/screens/journal_detail_screen.dart';
import 'features/journal/screens/journal_history_screen.dart';
import 'features/journal/screens/reflection_screen.dart';
import 'features/player/providers/player_provider.dart';
import 'features/player/screens/session_player_screen.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/theme/app_theme.dart';

class ArvyaXApp extends ConsumerStatefulWidget {
  const ArvyaXApp({super.key});

  @override
  ConsumerState<ArvyaXApp> createState() => _ArvyaXAppState();
}

class _ArvyaXAppState extends ConsumerState<ArvyaXApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(playerProvider.notifier).handleLifecycleChange(state);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'ArvyaX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
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
