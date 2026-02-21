import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:loop_timer/models/timer_config.dart';

/// A `CustomPainter`-driven circular countdown timer widget.
///
/// The caller is responsible for driving the animation externally by passing
/// the current [progress], [secondsRemaining], [currentRep], [totalReps] and
/// [phase].  No internal [AnimationController] is needed — this widget simply
/// paints whatever state is supplied.
class CircularTimer extends StatelessWidget {
  const CircularTimer({
    super.key,
    required this.progress,
    required this.secondsRemaining,
    required this.currentRep,
    required this.totalReps,
    required this.phase,
    this.delaySecondsRemaining,
    required this.color,
    required this.backgroundColor,
    this.size = 260.0,
  });

  /// Fraction of the arc that is filled, from 0.0 (empty) to 1.0 (full).
  final double progress;

  /// Seconds left in the current phase — shown as `MM:SS` or `HH:MM:SS`.
  final int secondsRemaining;

  /// 1-based current repetition number.
  final int currentRep;

  /// Total repetitions (0 = infinite).
  final int totalReps;

  /// Current lifecycle phase.
  final TimerState phase;

  /// When [phase] is [TimerState.delay], the delay seconds left (optional).
  final int? delaySecondsRemaining;

  /// Arc / accent color.
  final Color color;

  /// Background track color for the arc.
  final Color backgroundColor;

  /// Overall widget diameter in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularTimerPainter(
          progress: progress,
          arcColor: color,
          trackColor: backgroundColor,
        ),
        child: Center(
          child: _TimerContent(
            secondsRemaining: secondsRemaining,
            currentRep: currentRep,
            totalReps: totalReps,
            phase: phase,
            delaySecondsRemaining: delaySecondsRemaining,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom painter
// ---------------------------------------------------------------------------

class _CircularTimerPainter extends CustomPainter {
  _CircularTimerPainter({
    required this.progress,
    required this.arcColor,
    required this.trackColor,
  });

  final double progress;
  final Color arcColor;
  final Color trackColor;

  static const double _strokeWidth = 12.0;
  static const double _startAngle = -math.pi / 2; // 12 o'clock

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - _strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

    // Progress arc
    if (progress > 0) {
      final arcPaint = Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        _startAngle,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularTimerPainter old) =>
      old.progress != progress ||
      old.arcColor != arcColor ||
      old.trackColor != trackColor;
}

// ---------------------------------------------------------------------------
// Inner content column
// ---------------------------------------------------------------------------

class _TimerContent extends StatelessWidget {
  const _TimerContent({
    required this.secondsRemaining,
    required this.currentRep,
    required this.totalReps,
    required this.phase,
    this.delaySecondsRemaining,
    required this.color,
  });

  final int secondsRemaining;
  final int currentRep;
  final int totalReps;
  final TimerState phase;
  final int? delaySecondsRemaining;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Phase badge
        _PhaseBadge(phase: phase, color: color),
        const SizedBox(height: 6),

        // Main time display
        Text(
          _formatTime(secondsRemaining),
          style: tt.displaySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ) ??
              TextStyle(
                color: color,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
        ),

        const SizedBox(height: 4),

        // Rep indicator
        _RepIndicator(
          currentRep: currentRep,
          totalReps: totalReps,
          color: color,
        ),

        // Delay sub-label
        if (phase == TimerState.delay && delaySecondsRemaining != null) ...[
          const SizedBox(height: 4),
          Text(
            'Next in ${delaySecondsRemaining}s',
            style: tt.bodySmall?.copyWith(color: color.withAlpha(178)) ??
                TextStyle(color: color.withAlpha(178), fontSize: 12),
          ),
        ],
      ],
    );
  }

  String _formatTime(int totalSeconds) {
    final s = totalSeconds.abs();
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${sec.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:'
        '${sec.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Phase badge
// ---------------------------------------------------------------------------

class _PhaseBadge extends StatelessWidget {
  const _PhaseBadge({required this.phase, required this.color});

  final TimerState phase;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = switch (phase) {
      TimerState.running => 'RUNNING',
      TimerState.paused => 'PAUSED',
      TimerState.delay => 'DELAY',
      TimerState.completed => 'DONE',
      TimerState.idle => 'READY',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(102), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rep indicator
// ---------------------------------------------------------------------------

class _RepIndicator extends StatelessWidget {
  const _RepIndicator({
    required this.currentRep,
    required this.totalReps,
    required this.color,
  });

  final int currentRep;
  final int totalReps;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final repText = totalReps == 0
        ? 'Rep $currentRep / \u221E'
        : 'Rep $currentRep / $totalReps';

    return Text(
      repText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color.withAlpha(204),
            fontWeight: FontWeight.w500,
          ) ??
          TextStyle(
            color: color.withAlpha(204),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
    );
  }
}
