# Immersive Session & Reflection Mini App

The experience is designed to feel **calm, minimal, and premium** — guided audio sessions with journaling and history.

---

## How to Run

### Prerequisites
- Flutter SDK ≥ 3.0
- Android SDK / Android Studio (for APK)
- An internet connection for ambience thumbnail images
### Steps

```bash
# 1. Clone / unzip the project
cd assignment

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run

# 4. Build a release APK
flutter build apk --release

```



## Architecture

### Folder Structure

```
lib/
├── main.dart                   # Entry point: Hive init, ProviderScope
├── app.dart                    # MaterialApp, theme, named routes
│
├── data/                       # Pure Dart – no Flutter UI imports
│   ├── models/
│   │   ├── ambience.dart       # Ambience model (fromJson)
│   │   ├── journal_entry.dart  # JournalEntry (toMap / fromMap, Hive storage)
│   │   └── player_session.dart # Persisted session snapshot
│   └── repositories/
│       ├── ambience_repository.dart   # Reads ambiences.json asset
│       ├── journal_repository.dart    # Hive CRUD for journal entries
│       └── session_repository.dart    # Hive save/restore of active session
│
├── features/
│   ├── ambience/
│   │   ├── providers/ambience_provider.dart   # Search + tag filter state
│   │   ├── screens/
│   │   │   ├── home_screen.dart               # Ambience list, search, chips
│   │   │   └── ambience_detail_screen.dart    # Hero image, sensory chips, CTA
│   │   └── widgets/ambience_card.dart
│   │
│   ├── player/
│   │   ├── providers/player_provider.dart     # Audio + session timer state
│   │   ├── screens/session_player_screen.dart # Full-screen player UI
│   │   └── widgets/breathing_animation.dart  # Radial gradient pulse
│   │
│   └── journal/
│       ├── providers/journal_provider.dart    # Journal entry list state
│       ├── screens/
│       │   ├── reflection_screen.dart         # Post-session journal input
│       │   ├── journal_history_screen.dart    # Entry list
│       │   └── journal_detail_screen.dart     # Full entry view
│       └── widgets/mood_selector.dart
│
└── shared/
    ├── theme/
    │   ├── app_colors.dart     # All colour constants + tag/mood helpers
    │   └── app_theme.dart      # ThemeData (dark, Material 3)
    └── widgets/
        ├── mini_player_bar.dart  # Persistent mini player (Home + Detail)
        └── tag_chip.dart         # Coloured tag badge
```

### State Management – Riverpod

**Riverpod** (`flutter_riverpod ^2.6`) was chosen for its:
- compile-safe provider graph (no `BuildContext` required for reads)
- clean separation of business logic from UI
- testable `StateNotifier` pattern

Three `StateNotifierProvider`s cover all dynamic state:

| Provider | State class | Responsibility |
|---|---|---|
| `ambienceProvider` | `AmbienceState` | Loads JSON, owns search query + tag filter |
| `playerProvider` | `PlayerState` | Audio playback, session timer, mini player visibility |
| `journalProvider` | `JournalState` | Journal entry list, add operations |

### Data Flow

```
JSON asset
   └──> AmbienceRepository.loadAmbiences()
              └──> AmbienceNotifier._load()
                        └──> AmbienceState.filtered  (derived, no extra provider)
                                  └──> HomeScreen (Consumer)
                                  └──> AmbienceDetailScreen

Hive box "journal_entries"
   └──> JournalRepository.getAllEntries()
              └──> JournalNotifier._load()
                        └──> JournalState.entries
                                  └──> JournalHistoryScreen

Hive box "session_state"   ←──  PlayerNotifier._persistSession()
   └──> SessionRepository.loadSession()
              └──> PlayerNotifier._restoreFromPersistence()  (on init)
                        └──> PlayerState.isSessionActive → MiniPlayerBar shown
```

---

## Packages Used

| Package | Version | Why |
|---|---|---|
| `flutter_riverpod` | ^2.6.1 | Compile-safe, scalable state management |
| `hive_flutter` | ^1.1.0 | Fast, schema-free local storage with no code generation |
| `just_audio` | ^0.9.39 | Robust audio with built-in `LoopMode.one`, stream-based position |
| `google_fonts` | ^6.2.1 | Outfit typeface for a premium, clean look |
| `intl` | ^0.19.0 | Date formatting in journal entries |
| `path_provider` | ^2.1.3 | Required by Hive for discovering the documents path |

---

## Bonus Feature Implemented

**Option 4 – Haptic Feedback**

Haptic feedback is triggered on:
- **Play / Pause** in the session player (`HapticFeedback.mediumImpact`)
- **Play / Pause** in the mini player (`HapticFeedback.lightImpact`)
- **Save Reflection** (`HapticFeedback.mediumImpact`)

---

## Audio

The bundled file `assets/audio/ambient_loop.wav` is a programmatically generated 30-second layered tone (432 Hz fundamental + harmonics) that loops seamlessly.  
To replace with a real ambient field recording, simply swap in any WAV/MP3 file at that path and update `pubspec.yaml` if the filename changes.

---
