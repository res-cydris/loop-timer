import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:loop_timer/models/app_settings.dart';
import 'package:loop_timer/theme/app_themes.dart';

/// A tappable card representing a single theme choice in the theme selector.
///
/// Displays:
/// - Theme name and description
/// - A three-swatch color strip representative of the theme's palette
/// - A checkmark overlay when [isSelected] is `true`
class ThemeCard extends StatelessWidget {
  const ThemeCard({
    super.key,
    required this.themeId,
    required this.isSelected,
    required this.onTap,
  });

  final String themeId;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final swatches = _swatchesForTheme(themeId);
    final borderColor = isSelected ? cs.primary : cs.onSurface.withAlpha(31);
    final borderWidth = isSelected ? 2.5 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withAlpha(76),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Card content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color swatch strip
                  _ColorSwatchStrip(swatches: swatches),
                  const SizedBox(height: 10),

                  // Theme name
                  Text(
                    ThemeIds.label(themeId),
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Short description
                  Text(
                    ThemeIds.description(themeId),
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withAlpha(153),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Selected checkmark overlay
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ).animate().scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 200.ms,
                      curve: Curves.elasticOut,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  /// Returns three representative colors for the given theme, derived directly
  /// from the theme's [ColorScheme] to stay always in sync.
  List<Color> _swatchesForTheme(String id) {
    final theme = AppThemes.themeData(id);
    final cs = theme.colorScheme;
    return [
      theme.scaffoldBackgroundColor,
      cs.primary,
      cs.secondary,
    ];
  }
}

// ---------------------------------------------------------------------------
// Color swatch strip
// ---------------------------------------------------------------------------

class _ColorSwatchStrip extends StatelessWidget {
  const _ColorSwatchStrip({required this.swatches});

  final List<Color> swatches;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            for (final color in swatches)
              Expanded(
                child: ColoredBox(color: color),
              ),
          ],
        ),
      ),
    );
  }
}
