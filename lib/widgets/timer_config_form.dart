import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loop_timer/models/timer_config.dart';
import 'package:loop_timer/widgets/tone_picker.dart';
import 'package:loop_timer/widgets/volume_slider.dart';

// ---------------------------------------------------------------------------
// Repeat mode enum (internal to the form)
// ---------------------------------------------------------------------------

enum _RepeatMode { none, finite, infinite }

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

/// A form for creating or editing a [TimerConfig].
///
/// Usage with a key:
/// ```dart
/// final _formKey = GlobalKey<TimerConfigFormState>();
///
/// TimerConfigForm(key: _formKey, initialValue: existing)
///
/// // Later:
/// final config = _formKey.currentState?.value;
/// ```
class TimerConfigForm extends StatefulWidget {
  const TimerConfigForm({
    super.key,
    this.initialValue,
    this.onPreviewTone,
  });

  /// Pre-fills the form when editing an existing timer.
  final TimerConfig? initialValue;

  /// Optional override for tone preview; if `null` preview is a no-op.
  final void Function(String toneId)? onPreviewTone;

  @override
  State<TimerConfigForm> createState() => TimerConfigFormState();
}

class TimerConfigFormState extends State<TimerConfigForm> {
  // Duration fields
  int _hours = 0;
  int _minutes = 1;
  int _seconds = 0;

  // Name
  late TextEditingController _nameCtrl;

  // Repeat
  _RepeatMode _repeatMode = _RepeatMode.none;
  int _repeatCount = 2;

  // Delay
  int _delaySeconds = 0;

  // Tone & volume
  String _toneId = ToneIds.beep;
  double _volume = 0.7;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    final init = widget.initialValue;
    if (init != null) {
      _nameCtrl = TextEditingController(text: init.name);
      final d = init.durationSeconds;
      _hours = d ~/ 3600;
      _minutes = (d % 3600) ~/ 60;
      _seconds = d % 60;
      if (init.infiniteRepeat) {
        _repeatMode = _RepeatMode.infinite;
      } else if (init.repeatCount > 1) {
        _repeatMode = _RepeatMode.finite;
        _repeatCount = init.repeatCount;
      } else {
        _repeatMode = _RepeatMode.none;
      }
      _delaySeconds = init.delaySeconds;
      _toneId = init.toneId;
      _volume = init.volume;
    } else {
      _nameCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Public value accessor
  // ---------------------------------------------------------------------------

  /// Returns the current form state as a [TimerConfig].
  ///
  /// If [existingId] is provided, the returned config preserves that id (for
  /// updates). Otherwise a new UUID is generated via [TimerConfig.create].
  TimerConfig get value {
    final totalSeconds = _hours * 3600 + _minutes * 60 + _seconds;
    final name = _nameCtrl.text.trim().isEmpty ? 'Timer' : _nameCtrl.text.trim();

    return TimerConfig.create(
      name: name,
      durationSeconds: totalSeconds < 1 ? 1 : totalSeconds,
      infiniteRepeat: _repeatMode == _RepeatMode.infinite,
      repeatCount: _repeatMode == _RepeatMode.finite
          ? _repeatCount
          : _repeatMode == _RepeatMode.none
              ? 1
              : 1,
      delaySeconds: _repeatMode != _RepeatMode.none ? _delaySeconds : 0,
      toneId: _toneId,
      volume: _volume,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final showDelay =
        _repeatMode == _RepeatMode.finite || _repeatMode == _RepeatMode.infinite;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Name ---
        _SectionLabel(label: 'Timer Name'),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            hintText: 'e.g. Morning Workout',
            prefixIcon: Icon(Icons.label_outline_rounded),
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLength: 40,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
              null,
        ),

        const SizedBox(height: 24),

        // --- Duration ---
        _SectionLabel(label: 'Duration'),
        const SizedBox(height: 12),
        _DurationPicker(
          hours: _hours,
          minutes: _minutes,
          seconds: _seconds,
          onHoursChanged: (v) => setState(() => _hours = v),
          onMinutesChanged: (v) => setState(() => _minutes = v),
          onSecondsChanged: (v) => setState(() => _seconds = v),
        ),

        const SizedBox(height: 24),

        // --- Repetitions ---
        _SectionLabel(label: 'Repetitions'),
        const SizedBox(height: 10),
        _RepeatModeSelector(
          mode: _repeatMode,
          onChanged: (m) => setState(() => _repeatMode = m),
        ),
        if (_repeatMode == _RepeatMode.finite) ...[
          const SizedBox(height: 12),
          _StepperRow(
            label: 'Repeat count',
            value: _repeatCount,
            min: 2,
            max: 99,
            onChanged: (v) => setState(() => _repeatCount = v),
          ),
        ],

        // --- Delay ---
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: SizeTransition(sizeFactor: anim, child: child)),
          child: showDelay
              ? Column(
                  key: const ValueKey('delay'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _SectionLabel(label: 'Delay between reps'),
                    const SizedBox(height: 10),
                    _StepperRow(
                      label: 'Seconds',
                      value: _delaySeconds,
                      min: 0,
                      max: 300,
                      step: 5,
                      onChanged: (v) => setState(() => _delaySeconds = v),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _delaySeconds == 0
                          ? 'Reps start immediately'
                          : 'Pause for $_delaySeconds s between reps',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withAlpha(127),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(key: ValueKey('no_delay')),
        ),

        const SizedBox(height: 24),

        // --- Tone picker ---
        TonePicker(
          selectedToneId: _toneId,
          onChanged: (id) => setState(() => _toneId = id),
          onPreview: (id) => widget.onPreviewTone?.call(id),
        ),

        const SizedBox(height: 24),

        // --- Volume slider ---
        VolumeSlider(
          value: _volume,
          onChanged: (v) => setState(() => _volume = v),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: cs.onSurface.withAlpha(178),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Duration picker — three columns with +/- controls and direct entry
// ---------------------------------------------------------------------------

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.onHoursChanged,
    required this.onMinutesChanged,
    required this.onSecondsChanged,
  });

  final int hours;
  final int minutes;
  final int seconds;
  final void Function(int) onHoursChanged;
  final void Function(int) onMinutesChanged;
  final void Function(int) onSecondsChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeColumn(
            label: 'HRS',
            value: hours,
            min: 0,
            max: 23,
            onChanged: onHoursChanged,
          ),
        ),
        _Colon(),
        Expanded(
          child: _TimeColumn(
            label: 'MIN',
            value: minutes,
            min: 0,
            max: 59,
            onChanged: onMinutesChanged,
          ),
        ),
        _Colon(),
        Expanded(
          child: _TimeColumn(
            label: 'SEC',
            value: seconds,
            min: 0,
            max: 59,
            onChanged: onSecondsChanged,
          ),
        ),
      ],
    );
  }
}

class _Colon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Text(
        ':',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ctrl = TextEditingController(
      text: value.toString().padLeft(2, '0'),
    );

    return Column(
      children: [
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: cs.onSurface.withAlpha(127),
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),

        // + button
        _TimeStepButton(
          icon: Icons.keyboard_arrow_up_rounded,
          onTap: () {
            final next = value + 1;
            onChanged(next > max ? min : next);
          },
        ),
        const SizedBox(height: 4),

        // Direct-entry field
        SizedBox(
          width: 72,
          child: TextField(
            controller: ctrl,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            style: tt.headlineSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: cs.primary.withAlpha(102)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: cs.primary.withAlpha(76)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: cs.primary, width: 2),
              ),
              filled: true,
              fillColor: cs.surface,
            ),
            onChanged: (s) {
              final parsed = int.tryParse(s);
              if (parsed != null) {
                onChanged(parsed.clamp(min, max));
              }
            },
            onSubmitted: (s) {
              final parsed = int.tryParse(s);
              if (parsed != null) {
                onChanged(parsed.clamp(min, max));
              }
            },
          ),
        ),
        const SizedBox(height: 4),

        // - button
        _TimeStepButton(
          icon: Icons.keyboard_arrow_down_rounded,
          onTap: () {
            final next = value - 1;
            onChanged(next < min ? max : next);
          },
        ),
      ],
    );
  }
}

class _TimeStepButton extends StatelessWidget {
  const _TimeStepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 28,
        decoration: BoxDecoration(
          color: cs.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Repeat mode selector — segmented-style buttons
// ---------------------------------------------------------------------------

class _RepeatModeSelector extends StatelessWidget {
  const _RepeatModeSelector({required this.mode, required this.onChanged});

  final _RepeatMode mode;
  final void Function(_RepeatMode) onChanged;

  @override
  Widget build(BuildContext context) {
    const modes = [
      (_RepeatMode.none, 'No Repeat'),
      (_RepeatMode.finite, 'Finite'),
      (_RepeatMode.infinite, 'Infinite'),
    ];

    return Row(
      children: [
        for (final (m, label) in modes) ...[
          Expanded(
            child: _SegmentButton(
              label: label,
              isSelected: mode == m,
              onTap: () => onChanged(m),
            ),
          ),
          if (m != _RepeatMode.infinite) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? cs.primary : cs.onSurface.withAlpha(51),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: tt.bodySmall?.copyWith(
            color: isSelected ? cs.onPrimary : cs.onSurface.withAlpha(178),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic stepper row
// ---------------------------------------------------------------------------

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        // - button
        _StepperBtn(
          icon: Icons.remove_rounded,
          enabled: value > min,
          onTap: () => onChanged((value - step).clamp(min, max)),
          color: cs.primary,
        ),

        // Value display
        Expanded(
          child: Center(
            child: Text(
              value.toString(),
              style: tt.titleLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        // + button
        _StepperBtn(
          icon: Icons.add_rounded,
          enabled: value < max,
          onTap: () => onChanged((value + step).clamp(min, max)),
          color: cs.primary,
        ),
      ],
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? color.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? color.withAlpha(102) : color.withAlpha(38),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? color : color.withAlpha(76),
          size: 22,
        ),
      ),
    );
  }
}
