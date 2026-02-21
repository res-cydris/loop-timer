import 'package:flutter/material.dart';

/// A custom-styled volume control combining a speaker icon, a [Slider], and a
/// percentage label.
class VolumeSlider extends StatelessWidget {
  const VolumeSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// Current volume, 0.0–1.0.
  final double value;

  /// Called whenever the user drags the slider.
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Volume',
          style: tt.labelLarge?.copyWith(
            color: cs.onSurface.withAlpha(178),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Mute / low / high icon
            Icon(
              _iconForVolume(value),
              color: cs.primary,
              size: 26,
            ),
            const SizedBox(width: 8),

            // Slider
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                ),
                child: Slider(
                  value: value.clamp(0.0, 1.0),
                  onChanged: onChanged,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Percentage label
            SizedBox(
              width: 42,
              child: Text(
                '${(value * 100).round()}%',
                style: tt.bodyMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _iconForVolume(double v) {
    if (v <= 0.0) return Icons.volume_off_rounded;
    if (v < 0.5) return Icons.volume_down_rounded;
    return Icons.volume_up_rounded;
  }
}
