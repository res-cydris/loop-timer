import 'package:flutter/material.dart';
import 'package:loop_timer/models/timer_config.dart';

/// A horizontally-scrollable row of selectable tone buttons.
///
/// Each button shows the tone label and a preview icon. Tapping the label
/// area selects the tone; tapping the play icon calls [onPreview].
class TonePicker extends StatelessWidget {
  const TonePicker({
    super.key,
    required this.selectedToneId,
    required this.onChanged,
    required this.onPreview,
  });

  /// The currently selected tone identifier (from [ToneIds]).
  final String selectedToneId;

  /// Called when the user taps a tone button to select it.
  final void Function(String toneId) onChanged;

  /// Called when the user taps the play icon to preview a tone.
  final void Function(String toneId) onPreview;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tone',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: cs.onSurface.withAlpha(178),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ToneIds.all.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final toneId = ToneIds.all[index];
              final isSelected = toneId == selectedToneId;
              return _ToneButton(
                toneId: toneId,
                isSelected: isSelected,
                onSelect: () => onChanged(toneId),
                onPreview: () => onPreview(toneId),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual tone button
// ---------------------------------------------------------------------------

class _ToneButton extends StatelessWidget {
  const _ToneButton({
    required this.toneId,
    required this.isSelected,
    required this.onSelect,
    required this.onPreview,
  });

  final String toneId;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final bgColor = isSelected ? cs.primary : cs.surface;
    final fgColor = isSelected ? cs.onPrimary : cs.onSurface;
    final borderColor = isSelected ? cs.primary : cs.onSurface.withAlpha(51);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: cs.primary.withAlpha(76),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label — tap to select
          GestureDetector(
            onTap: onSelect,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(left: 14, top: 0, bottom: 0, right: 4),
              child: Center(
                child: Text(
                  ToneIds.label(toneId),
                  style: tt.bodyMedium?.copyWith(
                    color: fgColor,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Preview icon
          GestureDetector(
            onTap: onPreview,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.play_circle_outline_rounded,
                size: 20,
                color: fgColor.withAlpha(isSelected ? 255 : 178),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
