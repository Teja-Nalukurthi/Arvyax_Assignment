import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../data/models/ambience.dart';
import '../../../data/models/player_session.dart';
import '../../../data/repositories/ambience_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../ambience/providers/ambience_provider.dart';

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
  final AmbienceRepository _ambienceRepo;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  int _sessionToken = 0; // used to cancel stale startSession continuations

  PlayerNotifier(this._sessionRepo, this._ambienceRepo)
      : super(const PlayerState()) {
    // Clear any leftover session from a previous app run on startup
    _sessionRepo.clearSession();
  }

  Future<void> _restoreFromPersistence() async {
    try {
      final saved = _sessionRepo.loadSession();
      if (saved == null) return;

      // Discard stale sessions (> 24 hours)
      if (DateTime.now().difference(saved.savedAt).inHours > 24) {
        await _sessionRepo.clearSession();
        return;
      }

      final ambiences = await _ambienceRepo.loadAmbiences();
      final matches = ambiences.where((a) => a.id == saved.ambienceId);
      if (matches.isEmpty) return;

      final ambience = matches.first;
      final elapsed = saved.elapsedSeconds;

      // Session already completed
      if (elapsed >= ambience.durationMinutes * 60) {
        await _sessionRepo.clearSession();
        return;
      }

      await _initAudio();
      state = state.copyWith(
        ambience: ambience,
        position: Duration(seconds: elapsed),
        isPlaying: false,
        isSessionActive: true,
        isCompleted: false,
      );
    } catch (e) {
      debugPrint('[PlayerNotifier] restore error: $e');
    }
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
    _timer?.cancel();
    await _audioPlayer.pause();
    await _sessionRepo.clearSession();
    state = state.copyWith(
      isPlaying: false,
      isSessionActive: false,
      isCompleted: true,
      isPlayerScreenOpen: false,
    );
  }

  void setPlayerScreenOpen(bool open) {
    state = state.copyWith(isPlayerScreenOpen: open);
  }

  void resetCompletedState() {
    state = state.copyWith(isCompleted: false);
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
    ref.watch(ambienceRepositoryProvider),
  );
});
