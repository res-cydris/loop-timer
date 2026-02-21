import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:loop_timer/models/timer_config.dart';
import 'package:loop_timer/services/audio_service.dart';
import 'package:loop_timer/services/timer_service.dart';

/// Flutter [ChangeNotifier] wrapper around the pure-Dart [TimerService].
///
/// Screens and widgets consume this provider to read the current timer state
/// and to issue control commands (start / pause / resume / stop).
///
/// The provider owns the [TimerService] lifecycle and closes it when disposed.
class TimerProvider extends ChangeNotifier {
  final TimerService _service;
  StreamSubscription<ActiveTimerState>? _subscription;

  ActiveTimerState? _activeState;

  TimerProvider(AudioService audioService)
      : _service = TimerService(
          onPlayTone: (toneId, volume) => audioService.playTone(toneId, volume),
        ) {
    _subscription = _service.stateStream.listen(_onStateUpdate);
  }

  // ---------------------------------------------------------------------------
  // Public getters
  // ---------------------------------------------------------------------------

  /// Current lifecycle phase of the active timer session.
  ///
  /// Returns [TimerState.idle] when no session is running.
  TimerState get phase => _activeState?.phase ?? TimerState.idle;

  /// The latest snapshot of the active timer, or `null` when idle.
  ActiveTimerState? get activeState => _activeState;

  /// The [TimerConfig] driving the current session, or `null` when idle.
  TimerConfig? get activeConfig => _activeState?.config;

  // ---------------------------------------------------------------------------
  // Control methods
  // ---------------------------------------------------------------------------

  /// Starts a new timer session with [config], replacing any existing session.
  void startTimer(TimerConfig config) {
    _service.start(config);
  }

  /// Pauses the currently running session.  No-op when not running.
  void pause() {
    _service.pause();
  }

  /// Resumes a paused session.  No-op when not paused.
  void resume() {
    _service.resume();
  }

  /// Stops the current session and resets state to idle.
  void stop() {
    _service.stop();
    // The service emits one final event; the stream listener will clear state.
    // Proactively clear here so the UI responds immediately.
    _activeState = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _subscription?.cancel();
    _service.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _onStateUpdate(ActiveTimerState state) {
    _activeState = state;
    notifyListeners();
  }
}
