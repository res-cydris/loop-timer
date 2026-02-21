import 'dart:async';

import 'package:loop_timer/models/timer_config.dart';

/// Snapshot of the timer's state at any given tick.
class ActiveTimerState {
  /// Current lifecycle phase of the timer.
  final TimerState phase;

  /// Seconds remaining in the current countdown or delay window.
  final int secondsRemaining;

  /// Which repetition we are currently executing (1-based).
  final int currentRep;

  /// Total number of repetitions (0 when [TimerConfig.infiniteRepeat] is true).
  final int totalReps;

  /// The [TimerConfig] that is driving this session.
  final TimerConfig config;

  const ActiveTimerState({
    required this.phase,
    required this.secondsRemaining,
    required this.currentRep,
    required this.totalReps,
    required this.config,
  });

  /// Progress of the current phase as a value between 0.0 (start) and 1.0 (end).
  ///
  /// During a countdown phase the denominator is [TimerConfig.durationSeconds].
  /// During a delay phase the denominator is [TimerConfig.delaySeconds].
  /// Returns 1.0 when completed or the denominator would be zero.
  double get progress {
    switch (phase) {
      case TimerState.running:
      case TimerState.paused:
        final total = config.durationSeconds;
        if (total <= 0) return 1.0;
        final elapsed = total - secondsRemaining;
        return (elapsed / total).clamp(0.0, 1.0);

      case TimerState.delay:
        final total = config.delaySeconds;
        if (total <= 0) return 1.0;
        final elapsed = total - secondsRemaining;
        return (elapsed / total).clamp(0.0, 1.0);

      case TimerState.completed:
        return 1.0;

      case TimerState.idle:
        return 0.0;
    }
  }

  ActiveTimerState copyWith({
    TimerState? phase,
    int? secondsRemaining,
    int? currentRep,
    int? totalReps,
    TimerConfig? config,
  }) {
    return ActiveTimerState(
      phase: phase ?? this.phase,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      currentRep: currentRep ?? this.currentRep,
      totalReps: totalReps ?? this.totalReps,
      config: config ?? this.config,
    );
  }
}

/// Pure-Dart countdown timer with repeat and delay support.
///
/// No Flutter dependencies — safe to unit-test without a widget environment.
///
/// Usage:
/// ```dart
/// final service = TimerService(onPlayTone: (id, vol) => audio.play(id, vol));
/// service.stateStream.listen((state) { /* update UI */ });
/// service.start(myConfig);
/// ```
class TimerService {
  /// Optional callback invoked when the end-of-rep tone should be played.
  final void Function(String toneId, double volume)? onPlayTone;

  TimerService({this.onPlayTone});

  // Internal state
  TimerConfig? _config;
  TimerState _phase = TimerState.idle;
  int _secondsRemaining = 0;
  int _currentRep = 1;
  bool _paused = false;

  Timer? _ticker;

  final StreamController<ActiveTimerState> _controller =
      StreamController<ActiveTimerState>.broadcast();

  /// Stream of [ActiveTimerState] snapshots emitted once per second (and on
  /// significant state transitions such as pause / stop / completion).
  Stream<ActiveTimerState> get stateStream => _controller.stream;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Starts a new session with [config], cancelling any current session first.
  void start(TimerConfig config) {
    _cancelTicker();
    _config = config;
    _currentRep = 1;
    _paused = false;
    _beginCountdown();
  }

  /// Pauses the current countdown or delay.  No-op if already paused / idle.
  void pause() {
    if (_phase == TimerState.running || _phase == TimerState.delay) {
      _paused = true;
      _cancelTicker();
      _phase = TimerState.paused;
      _emit();
    }
  }

  /// Resumes after a [pause] call.  No-op if not paused.
  void resume() {
    if (_phase != TimerState.paused) return;
    _paused = false;

    // Work out which phase we were in before the pause.  We use `_secondsRemaining`
    // to figure out context: if it relates to the delay we restart a delay tick,
    // otherwise a countdown tick.  We track which sub-phase via [_resumePhase].
    _phase = _resumePhase;
    _startTicker();
    _emit();
  }

  /// Stops the timer and resets to idle.
  void stop() {
    _cancelTicker();
    _phase = TimerState.idle;
    if (_config != null) _emit();
    _config = null;
  }

  /// Releases resources.  The service must not be used after this call.
  void dispose() {
    _cancelTicker();
    _controller.close();
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// The phase to restore when resuming (countdown vs delay).
  TimerState _resumePhase = TimerState.running;

  void _beginCountdown() {
    final config = _config!;
    _phase = TimerState.running;
    _resumePhase = TimerState.running;
    _secondsRemaining = config.durationSeconds;
    _emit();
    _startTicker();
  }

  void _beginDelay() {
    final config = _config!;
    _phase = TimerState.delay;
    _resumePhase = TimerState.delay;
    _secondsRemaining = config.delaySeconds;
    _emit();
    _startTicker();
  }

  void _startTicker() {
    _cancelTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _onTick(Timer _) {
    if (_paused || _config == null) return;

    _secondsRemaining--;

    if (_secondsRemaining > 0) {
      _emit();
      return;
    }

    // Reached zero — handle based on current phase.
    if (_phase == TimerState.running) {
      _onRepCompleted();
    } else if (_phase == TimerState.delay) {
      _onDelayCompleted();
    }
  }

  void _onRepCompleted() {
    final config = _config!;

    // Fire the tone for the completed rep.
    onPlayTone?.call(config.toneId, config.volume);

    final hasMoreReps =
        config.infiniteRepeat || _currentRep < config.repeatCount;

    if (!hasMoreReps) {
      _cancelTicker();
      _phase = TimerState.completed;
      _secondsRemaining = 0;
      _emit();
      return;
    }

    // Advance rep counter before starting the delay / next countdown.
    _currentRep++;

    if (config.delaySeconds > 0) {
      _cancelTicker();
      _beginDelay();
    } else {
      // Immediate next rep — reset countdown without cancelling the ticker.
      _phase = TimerState.running;
      _resumePhase = TimerState.running;
      _secondsRemaining = config.durationSeconds;
      _emit();
    }
  }

  void _onDelayCompleted() {
    _cancelTicker();
    _beginCountdown();
  }

  void _emit() {
    if (_controller.isClosed) return;
    final config = _config;
    if (config == null) return;

    _controller.add(ActiveTimerState(
      phase: _phase,
      secondsRemaining: _secondsRemaining,
      currentRep: _currentRep,
      totalReps: config.infiniteRepeat ? 0 : config.repeatCount,
      config: config,
    ));
  }
}
