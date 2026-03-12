import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../data/models/ambience.dart';
import '../../../data/models/player_session.dart';
import '../../../data/models/analytics_event.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../../../data/repositories/session_repository.dart';

final sessionRepositoryProvider =
    Provider<SessionRepository>((_) => SessionRepository());

class PlayerState {
  final Ambience? ambience;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final bool isSessionActive;
  final bool isPlayerScreenOpen;
  final bool isCompleted;

  const PlayerState({
    this.ambience,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.isSessionActive = false,
    this.isPlayerScreenOpen = false,
    this.isCompleted = false,
  });

  PlayerState copyWith({
    Ambience? ambience,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    bool? isSessionActive,
    bool? isPlayerScreenOpen,
    bool? isCompleted,
  }) {
    return PlayerState(
      ambience: ambience ?? this.ambience,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isPlayerScreenOpen: isPlayerScreenOpen ?? this.isPlayerScreenOpen,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Duration get totalDuration => ambience?.duration ?? Duration.zero;

  double get progress {
    if (totalDuration.inSeconds == 0) return 0.0;
    return (position.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
  }

  bool get showMiniPlayer => isSessionActive && !isPlayerScreenOpen;
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final SessionRepository _sessionRepo;
  final AnalyticsRepository _analyticsRepo;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  int _sessionToken = 0; // used to cancel stale startSession continuations
  bool _wasPlayingBeforeBackground = false;

  PlayerNotifier(this._sessionRepo, this._analyticsRepo)
      : super(const PlayerState()) {
    // Clear any leftover session from a previous app run on startup
    _sessionRepo.clearSession();
  }

  Future<void> startSession(Ambience ambience) async {
    final token = ++_sessionToken;
    // Update state immediately so the session screen has content to display
    state = state.copyWith(
      ambience: ambience,
      isPlaying: false,
      isLoading: true,
      position: Duration.zero,
      isSessionActive: true,
      isCompleted: false,
    );
    _logEvent('session_start', {
      'ambience_id': ambience.id,
      'ambience_title': ambience.title,
    });
    await _stopCurrent();
    if (_sessionToken != token) return; // a newer session was started, bail out
    await _initAudio();
    if (_sessionToken != token) return;
    // Do NOT await play() — with LoopMode.one it never completes (loops forever)
    _audioPlayer.play().catchError((e) {
      debugPrint('[PlayerNotifier] play error: $e');
    });
    if (_sessionToken != token) return;
    state = state.copyWith(isPlaying: true, isLoading: false);
    _startTimer();
    await _persistSession();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAsset('assets/audio/ambient_loop.wav');
      await _audioPlayer.setLoopMode(LoopMode.one);
    } catch (e) {
      debugPrint('[PlayerNotifier] audio init error: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isPlaying || !mounted) return;

      final newPos = state.position + const Duration(seconds: 1);
      if (newPos >= state.totalDuration) {
        _timer?.cancel();
        _logEvent('session_end', {
          'ambience_id': state.ambience?.id ?? '',
          'elapsed_seconds': newPos.inSeconds.toString(),
          'completed': 'true',
        });
        state = state.copyWith(
          position: state.totalDuration,
          isPlaying: false,
          isCompleted: true,
          isSessionActive: false,
        );
        _audioPlayer.pause();
        _sessionRepo.clearSession();
        return;
      }
      state = state.copyWith(position: newPos);

      // Persist every 10 seconds to avoid heavy writes
      if (newPos.inSeconds % 10 == 0) {
        _persistSession();
      }
    });
  }

  Future<void> togglePlayPause() async {
    if (state.isLoading) return; // ignore taps while audio is initializing
    if (state.isPlaying) {
      _timer?.cancel();
      state = state.copyWith(isPlaying: false);
      await _audioPlayer.pause();
    } else {
      state = state.copyWith(isPlaying: true);
      await _audioPlayer.play();
      _startTimer();
    }
    await _persistSession();
  }

  Future<void> seek(Duration position) async {
    final totalSec = state.totalDuration.inSeconds;
    final sec = position.inSeconds.clamp(0, totalSec);
    state = state.copyWith(position: Duration(seconds: sec));
    await _audioPlayer.seek(Duration(seconds: sec));
    await _persistSession();
  }

  Future<void> endSession() async {
    final ambience = state.ambience;
    final elapsed = state.position.inSeconds;
    _timer?.cancel();
    await _audioPlayer.pause();
    await _sessionRepo.clearSession();
    state = state.copyWith(
      isPlaying: false,
      isSessionActive: false,
      isCompleted: true,
      isPlayerScreenOpen: false,
    );
    if (ambience != null) {
      _logEvent('session_end', {
        'ambience_id': ambience.id,
        'elapsed_seconds': elapsed.toString(),
        'completed': 'false',
      });
    }
  }

  void setPlayerScreenOpen(bool open) {
    state = state.copyWith(isPlayerScreenOpen: open);
  }

  void resetCompletedState() {
    state = state.copyWith(isCompleted: false);
  }

  // ── App Lifecycle ──────────────────────────────────────────────────────────

  void handleLifecycleChange(AppLifecycleState lifecycleState) {
    switch (lifecycleState) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _pauseForBackground();
        break;
      case AppLifecycleState.resumed:
        _resumeFromBackground();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _pauseForBackground() {
    if (!state.isPlaying) return;
    _wasPlayingBeforeBackground = true;
    _timer?.cancel();
    _audioPlayer.pause();
    state = state.copyWith(isPlaying: false);
  }

  void _resumeFromBackground() {
    if (!_wasPlayingBeforeBackground || !state.isSessionActive) return;
    _wasPlayingBeforeBackground = false;
    state = state.copyWith(isPlaying: true);
    _audioPlayer.play().catchError((e) {
      debugPrint('[PlayerNotifier] resume play error: $e');
    });
    _startTimer();
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  void _logEvent(String type, Map<String, String> metadata) {
    _analyticsRepo
        .log(AnalyticsEvent(
          type: type,
          timestamp: DateTime.now(),
          metadata: metadata,
        ))
        .catchError((e) => debugPrint('[Analytics] $e'));
  }

  Future<void> _stopCurrent() async {
    _timer?.cancel();
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  Future<void> _persistSession() async {
    if (!state.isSessionActive || state.ambience == null) return;
    await _sessionRepo.saveSession(PlayerSession(
      ambienceId: state.ambience!.id,
      elapsedSeconds: state.position.inSeconds,
      isPlaying: state.isPlaying,
      savedAt: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier(
    ref.watch(sessionRepositoryProvider),
    ref.watch(analyticsRepositoryProvider),
  );
});
