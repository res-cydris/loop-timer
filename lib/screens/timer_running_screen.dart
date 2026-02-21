import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:loop_timer/models/timer_config.dart';
import 'package:loop_timer/providers/timer_provider.dart';
import 'package:loop_timer/widgets/circular_timer.dart';

/// The active timer screen — the centrepiece of Loop Timer.
///
/// Receives a [TimerConfig] via `ModalRoute.of(context)!.settings.arguments`
/// and starts the timer on first mount if the provider is idle.
class TimerRunningScreen extends StatefulWidget {
  const TimerRunningScreen({super.key});

  @override
  State<TimerRunningScreen> createState() => _TimerRunningScreenState();
}

class _TimerRunningScreenState extends State<TimerRunningScreen>
    with TickerProviderStateMixin {
  // Whether the timer has been started by this screen instance.
  bool _started = false;

  // Whether the completion overlay is currently showing.
  bool _showCompletion = false;

  // Completion overlay auto-dismiss timer.
  int _completionCountdown = 3;

  // Animation controller for the pulsing gradient background behind the ring.
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // Animation controller for the completion overlay entrance.
  late final AnimationController _completionController;

  // Tracks the most recent [TimerState] so we can detect the completed
  // transition without repeatedly firing on every rebuild.
  TimerState? _lastPhase;

  @override
  void initState() {
    super.initState();

    // Subtle breathing pulse for the background glow (2-second period).
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.04, end: 0.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Completion overlay animation.
    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Start the timer once, right after the widget is inserted into the tree.
    if (!_started) {
      _started = true;
      final config =
          ModalRoute.of(context)!.settings.arguments as TimerConfig;
      final timerProvider = context.read<TimerProvider>();
      if (timerProvider.phase == TimerState.idle) {
        // Schedule after the current frame so the provider is fully wired up.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) timerProvider.startTimer(config);
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Completion handling
  // ---------------------------------------------------------------------------

  void _onCompleted() {
    if (_showCompletion) return;
    setState(() {
      _showCompletion = true;
      _completionCountdown = 3;
    });
    _completionController.forward(from: 0);
    _startCompletionDismissTimer();
  }

  void _startCompletionDismissTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !_showCompletion) return;
      setState(() => _completionCountdown--);
      if (_completionCountdown > 0) {
        _startCompletionDismissTimer();
      } else {
        _dismissCompletion();
      }
    });
  }

  void _dismissCompletion() {
    if (!mounted) return;
    setState(() => _showCompletion = false);
    Navigator.of(context).pop();
  }

  // ---------------------------------------------------------------------------
  // Back navigation guard
  // ---------------------------------------------------------------------------

  Future<bool> _onWillPop(TimerProvider timerProvider) async {
    final phase = timerProvider.phase;
    if (phase == TimerState.running || phase == TimerState.delay) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Stop timer?'),
          content: const Text(
            'The timer is still running. Going back will stop it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Keep running'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Stop'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        timerProvider.stop();
        return true;
      }
      return false;
    }
    // Paused or idle — allow immediate back navigation.
    if (phase == TimerState.paused) {
      timerProvider.stop();
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, _) {
        final state = timerProvider.activeState;
        final phase = timerProvider.phase;
        final config = timerProvider.activeConfig ??
            (ModalRoute.of(context)!.settings.arguments as TimerConfig);

        // Detect completion transition.
        if (phase == TimerState.completed && _lastPhase != TimerState.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _onCompleted();
          });
        }
        _lastPhase = phase;

        final colorScheme = Theme.of(context).colorScheme;
        final primaryColor = colorScheme.primary;
        final bgColor = colorScheme.surface;

        final screenSize = MediaQuery.of(context).size;
        final isLandscape = screenSize.width > screenSize.height;

        // Ring diameter: 80% of the narrow dimension.
        final ringDiameter = isLandscape
            ? screenSize.height * 0.7
            : screenSize.width * 0.8;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (!didPop) {
              final allow = await _onWillPop(timerProvider);
              if (allow && mounted) Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            backgroundColor: bgColor,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () async {
                  final allow = await _onWillPop(timerProvider);
                  if (allow && mounted) Navigator.of(context).pop();
                },
              ),
              title: Text(
                'LOOP TIMER',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            body: Stack(
              children: [
                // --- Pulsing gradient background ---
                _PulsingBackground(
                  animation: _pulseAnimation,
                  color: primaryColor,
                ),

                // --- Main content ---
                SafeArea(
                  child: isLandscape
                      ? _LandscapeLayout(
                          ringDiameter: ringDiameter,
                          state: state,
                          phase: phase,
                          config: config,
                          primaryColor: primaryColor,
                          colorScheme: colorScheme,
                          timerProvider: timerProvider,
                        )
                      : _PortraitLayout(
                          ringDiameter: ringDiameter,
                          state: state,
                          phase: phase,
                          config: config,
                          primaryColor: primaryColor,
                          colorScheme: colorScheme,
                          timerProvider: timerProvider,
                        ),
                ),

                // --- Completion overlay ---
                if (_showCompletion)
                  _CompletionOverlay(
                    controller: _completionController,
                    state: state,
                    config: config,
                    countdown: _completionCountdown,
                    onDismiss: _dismissCompletion,
                    primaryColor: primaryColor,
                    colorScheme: colorScheme,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Pulsing background glow
// ---------------------------------------------------------------------------

class _PulsingBackground extends StatelessWidget {
  const _PulsingBackground({
    required this.animation,
    required this.color,
  });

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.0, -0.3),
              radius: 1.2,
              colors: [
                color.withOpacity(animation.value),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Portrait layout
// ---------------------------------------------------------------------------

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({
    required this.ringDiameter,
    required this.state,
    required this.phase,
    required this.config,
    required this.primaryColor,
    required this.colorScheme,
    required this.timerProvider,
  });

  final double ringDiameter;
  final ActiveTimerState? state;
  final TimerState phase;
  final TimerConfig config;
  final Color primaryColor;
  final ColorScheme colorScheme;
  final TimerProvider timerProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Circular timer ring.
        Center(
          child: SizedBox(
            width: ringDiameter,
            height: ringDiameter,
            child: _buildRing(),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),

        const SizedBox(height: 20),

        // Info row.
        _InfoRow(state: state, phase: phase, colorScheme: colorScheme)
            .animate()
            .fadeIn(duration: 400.ms, delay: 150.ms)
            .slideY(begin: 0.2, curve: Curves.easeOut),

        const SizedBox(height: 28),

        // Control buttons.
        _ControlButtons(
          phase: phase,
          timerProvider: timerProvider,
          primaryColor: primaryColor,
          colorScheme: colorScheme,
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 250.ms)
            .slideY(begin: 0.2, curve: Curves.easeOut),

        const SizedBox(height: 24),

        // Config summary card.
        _ConfigSummaryCard(config: config, colorScheme: colorScheme)
            .animate()
            .fadeIn(duration: 400.ms, delay: 350.ms)
            .slideY(begin: 0.2, curve: Curves.easeOut),

        const Spacer(),
      ],
    );
  }

  Widget _buildRing() {
    return CircularTimer(
      progress: state?.progress ?? 0.0,
      secondsRemaining: state?.secondsRemaining ?? config.durationSeconds,
      currentRep: state?.currentRep ?? 1,
      totalReps: state?.totalReps ??
          (config.infiniteRepeat ? 0 : config.repeatCount),
      phase: phase,
      delaySecondsRemaining:
          phase == TimerState.delay ? state?.secondsRemaining : null,
      color: primaryColor,
      backgroundColor: colorScheme.surfaceContainerHighest,
    );
  }
}

// ---------------------------------------------------------------------------
// Landscape layout
// ---------------------------------------------------------------------------

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({
    required this.ringDiameter,
    required this.state,
    required this.phase,
    required this.config,
    required this.primaryColor,
    required this.colorScheme,
    required this.timerProvider,
  });

  final double ringDiameter;
  final ActiveTimerState? state;
  final TimerState phase;
  final TimerConfig config;
  final Color primaryColor;
  final ColorScheme colorScheme;
  final TimerProvider timerProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left: ring.
        Expanded(
          child: Center(
            child: SizedBox(
              width: ringDiameter,
              height: ringDiameter,
              child: CircularTimer(
                progress: state?.progress ?? 0.0,
                secondsRemaining:
                    state?.secondsRemaining ?? config.durationSeconds,
                currentRep: state?.currentRep ?? 1,
                totalReps: state?.totalReps ??
                    (config.infiniteRepeat ? 0 : config.repeatCount),
                phase: phase,
                delaySecondsRemaining: phase == TimerState.delay
                    ? state?.secondsRemaining
                    : null,
                color: primaryColor,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(
                    begin: const Offset(0.85, 0.85),
                    curve: Curves.easeOutBack),
          ),
        ),

        // Right: info + controls + summary.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _InfoRow(
                    state: state, phase: phase, colorScheme: colorScheme),
                const SizedBox(height: 20),
                _ControlButtons(
                  phase: phase,
                  timerProvider: timerProvider,
                  primaryColor: primaryColor,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 16),
                _ConfigSummaryCard(config: config, colorScheme: colorScheme),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Info row (rep counter + delay indicator)
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.state,
    required this.phase,
    required this.colorScheme,
  });

  final ActiveTimerState? state;
  final TimerState phase;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final currentRep = state?.currentRep ?? 1;
    final totalReps = state?.totalReps ?? 0;
    final repLabel = totalReps == 0
        ? 'Rep $currentRep / ∞'
        : 'Rep $currentRep / $totalReps';

    final isDelay = phase == TimerState.delay;
    final delayRemaining = isDelay ? (state?.secondsRemaining ?? 0) : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.repeat_rounded,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            repLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (isDelay) ...[
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 14,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.hourglass_top_rounded,
              size: 16,
              color: colorScheme.tertiary,
            ),
            const SizedBox(width: 6),
            Text(
              'Next in ${delayRemaining}s',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Control buttons
// ---------------------------------------------------------------------------

class _ControlButtons extends StatelessWidget {
  const _ControlButtons({
    required this.phase,
    required this.timerProvider,
    required this.primaryColor,
    required this.colorScheme,
  });

  final TimerState phase;
  final TimerProvider timerProvider;
  final Color primaryColor;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isPaused = phase == TimerState.paused;
    final isActive = phase == TimerState.running || phase == TimerState.delay;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pause / Resume button.
          Expanded(
            child: FilledButton.icon(
              onPressed: (isActive || isPaused)
                  ? () {
                      if (isPaused) {
                        timerProvider.resume();
                      } else {
                        timerProvider.pause();
                      }
                    }
                  : null,
              icon: Icon(
                isPaused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                size: 22,
              ),
              label: Text(
                isPaused ? 'RESUME' : 'PAUSE',
                style: const TextStyle(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Stop button.
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                // Confirm before stopping while active.
                if (isActive || isPaused) {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('Stop timer?'),
                      content: const Text('This will end the current session.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Stop'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                }
                timerProvider.stop();
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.stop_rounded, size: 22),
              label: const Text(
                'STOP',
                style: TextStyle(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error.withOpacity(0.6)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Config summary card
// ---------------------------------------------------------------------------

class _ConfigSummaryCard extends StatelessWidget {
  const _ConfigSummaryCard({
    required this.config,
    required this.colorScheme,
  });

  final TimerConfig config;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final repText = config.infiniteRepeat
        ? '∞ reps'
        : '${config.repeatCount} rep${config.repeatCount == 1 ? '' : 's'}';
    final delayText =
        config.delaySeconds > 0 ? ', ${config.delaySeconds}s delay' : '';
    final durationMin = config.durationSeconds ~/ 60;
    final durationSec = config.durationSeconds % 60;
    final durationText = durationMin > 0
        ? '${durationMin}m ${durationSec}s'
        : '${durationSec}s';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  config.name,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$durationText × $repText$delayText',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.65),
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Completion overlay
// ---------------------------------------------------------------------------

class _CompletionOverlay extends StatelessWidget {
  const _CompletionOverlay({
    required this.controller,
    required this.state,
    required this.config,
    required this.countdown,
    required this.onDismiss,
    required this.primaryColor,
    required this.colorScheme,
  });

  final AnimationController controller;
  final ActiveTimerState? state;
  final TimerConfig config;
  final int countdown;
  final VoidCallback onDismiss;
  final Color primaryColor;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final repText = config.infiniteRepeat
        ? '∞'
        : '${config.repeatCount}';

    return GestureDetector(
      onTap: onDismiss,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final t = Curves.easeOutCubic.transform(controller.value);
          return Opacity(
            opacity: t,
            child: Container(
              color: colorScheme.surface.withOpacity(0.92),
              child: child,
            ),
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated checkmark.
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final t = Curves.elasticOut
                      .transform(controller.value.clamp(0.0, 1.0));
                  return Transform.scale(
                    scale: 0.6 + 0.4 * t,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.15),
                        border: Border.all(
                          color: primaryColor,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 64,
                        color: primaryColor,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // "Complete!" heading.
              Text(
                'Complete!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: 1.0,
                    ),
              )
                  .animate(controller: controller)
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOut),

              const SizedBox(height: 12),

              // Summary text.
              Text(
                '${config.name}  •  $repText rep${config.repeatCount == 1 && !config.infiniteRepeat ? '' : 's'} done',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              )
                  .animate(controller: controller)
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOut),

              const SizedBox(height: 36),

              // Auto-dismiss countdown chip.
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) => Opacity(
                  opacity:
                      Curves.easeIn.transform(controller.value.clamp(0.0, 1.0)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Closing in $countdown…',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: onDismiss,
                child: Text(
                  'Tap anywhere to close',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

