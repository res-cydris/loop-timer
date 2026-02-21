import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:loop_timer/models/app_settings.dart';
import 'package:loop_timer/providers/saved_timers_provider.dart';
import 'package:loop_timer/providers/settings_provider.dart';
import 'package:loop_timer/services/audio_service.dart';
import 'package:loop_timer/widgets/theme_card.dart';
import 'package:loop_timer/widgets/tone_picker.dart';
import 'package:loop_timer/widgets/volume_slider.dart';

/// Settings screen with sections for Theme, Audio Defaults, Storage, and About.
///
/// Uses a [CustomScrollView] with a [SliverAppBar] for an expandable header,
/// and [Consumer] widgets for reactive rebuilds on settings changes.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final settings = settingsProvider.settings;
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ---- Expandable app bar ----
              SliverAppBar(
                expandedHeight: 130,
                pinned: true,
                stretch: true,
                backgroundColor: colorScheme.surface,
                surfaceTintColor: colorScheme.surfaceTint,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                  ),
                  titlePadding:
                      const EdgeInsets.only(left: 20, bottom: 14),
                  collapseMode: CollapseMode.parallax,
                ),
              ),

              // ---- Theme section ----
              _SectionHeader(
                title: 'Theme',
                icon: Icons.palette_outlined,
              ),

              SliverToBoxAdapter(
                child: _ThemeSection(
                  settings: settings,
                  settingsProvider: settingsProvider,
                  colorScheme: colorScheme,
                ),
              ),

              // ---- Audio Defaults section ----
              _SectionHeader(
                title: 'Audio Defaults',
                icon: Icons.volume_up_outlined,
              ),

              SliverToBoxAdapter(
                child: _AudioSection(
                  settings: settings,
                  settingsProvider: settingsProvider,
                  colorScheme: colorScheme,
                ),
              ),

              // ---- Storage section ----
              _SectionHeader(
                title: 'Storage',
                icon: Icons.save_outlined,
              ),

              SliverToBoxAdapter(
                child: _StorageSection(
                  settings: settings,
                  settingsProvider: settingsProvider,
                  colorScheme: colorScheme,
                ),
              ),

              // ---- About section ----
              _SectionHeader(
                title: 'About',
                icon: Icons.info_outline_rounded,
              ),

              SliverToBoxAdapter(
                child: _AboutSection(colorScheme: colorScheme),
              ),

              // Bottom padding.
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms).slideX(begin: -0.08),
    );
  }
}

// ---------------------------------------------------------------------------
// Theme section
// ---------------------------------------------------------------------------

class _ThemeSection extends StatelessWidget {
  const _ThemeSection({
    required this.settings,
    required this.settingsProvider,
    required this.colorScheme,
  });

  final AppSettings settings;
  final SettingsProvider settingsProvider;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        color: colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: ThemeIds.all.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.6,
            ),
            itemBuilder: (context, index) {
              final themeId = ThemeIds.all[index];
              return ThemeCard(
                themeId: themeId,
                isSelected: settings.themeId == themeId,
                onTap: () => settingsProvider.updateTheme(themeId),
              );
            },
          ),
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 50.ms).slideY(begin: 0.1),
    );
  }
}

// ---------------------------------------------------------------------------
// Audio Defaults section
// ---------------------------------------------------------------------------

class _AudioSection extends StatelessWidget {
  const _AudioSection({
    required this.settings,
    required this.settingsProvider,
    required this.colorScheme,
  });

  final AppSettings settings;
  final SettingsProvider settingsProvider;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioService>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        color: colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Tone picker ---
              _SettingLabel(
                label: 'Default Tone',
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 10),
              TonePicker(
                selectedToneId: settings.defaultToneId,
                onChanged: (toneId) async {
                  await settingsProvider.updateDefaultTone(toneId);
                },
                onPreview: (toneId) => audioService.previewTone(toneId),
              ),

              const SizedBox(height: 20),
              Divider(
                color: colorScheme.outlineVariant.withOpacity(0.4),
                height: 1,
              ),
              const SizedBox(height: 20),

              // --- Volume slider ---
              _SettingLabel(
                label: 'Default Volume',
                colorScheme: colorScheme,
                trailing: Text(
                  '${(settings.defaultVolume * 100).round()}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              VolumeSlider(
                value: settings.defaultVolume,
                onChanged: (v) => settingsProvider.updateDefaultVolume(v),
              ),

              const SizedBox(height: 12),

              // Preview button.
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => audioService.previewTone(
                    settings.defaultToneId,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Preview'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1),
    );
  }
}

// ---------------------------------------------------------------------------
// Storage section
// ---------------------------------------------------------------------------

class _StorageSection extends StatelessWidget {
  const _StorageSection({
    required this.settings,
    required this.settingsProvider,
    required this.colorScheme,
  });

  final AppSettings settings;
  final SettingsProvider settingsProvider;
  final ColorScheme colorScheme;

  static const List<int> _steps = [5, 10, 15, 20];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        color: colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Max saved timers stepper ---
              _SettingLabel(
                label: 'Max Saved Timers',
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decrement.
                  _StepperButton(
                    icon: Icons.remove_rounded,
                    onPressed: _canDecrement(settings.maxSavedTimers)
                        ? () {
                            final current = settings.maxSavedTimers;
                            final idx = _steps.indexOf(current);
                            if (idx > 0) {
                              settingsProvider
                                  .updateMaxSavedTimers(_steps[idx - 1]);
                            } else if (idx == -1) {
                              // Value not in steps — snap down.
                              settingsProvider.updateMaxSavedTimers(
                                  _steps.lastWhere((s) => s < current,
                                      orElse: () => _steps.first));
                            }
                          }
                        : null,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(width: 24),

                  // Value display.
                  SizedBox(
                    width: 60,
                    child: Text(
                      settings.maxSavedTimers.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Increment.
                  _StepperButton(
                    icon: Icons.add_rounded,
                    onPressed: _canIncrement(settings.maxSavedTimers)
                        ? () {
                            final current = settings.maxSavedTimers;
                            final idx = _steps.indexOf(current);
                            if (idx != -1 && idx < _steps.length - 1) {
                              settingsProvider
                                  .updateMaxSavedTimers(_steps[idx + 1]);
                            } else if (idx == -1) {
                              settingsProvider.updateMaxSavedTimers(
                                  _steps.firstWhere((s) => s > current,
                                      orElse: () => _steps.last));
                            }
                          }
                        : null,
                    colorScheme: colorScheme,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Steps row.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _steps.map((step) {
                  final isSelected = step == settings.maxSavedTimers;
                  return GestureDetector(
                    onTap: () =>
                        settingsProvider.updateMaxSavedTimers(step),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        step.toString(),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface
                                          .withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              Divider(
                color: colorScheme.outlineVariant.withOpacity(0.4),
                height: 1,
              ),
              const SizedBox(height: 12),

              // Saved timer count.
              Consumer<SavedTimersProvider>(
                builder: (context, savedTimersProvider, _) {
                  final count = savedTimersProvider.savedTimers.length;
                  final max = settings.maxSavedTimers;
                  return Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Currently saved: $count / $max timer${count == 1 ? '' : 's'}',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color:
                                      colorScheme.onSurface.withOpacity(0.55),
                                ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.1),
    );
  }

  bool _canDecrement(int current) {
    final minStep = _steps.first;
    return current > minStep ||
        (_steps.indexOf(current) == -1 &&
            _steps.any((s) => s < current));
  }

  bool _canIncrement(int current) {
    final maxStep = _steps.last;
    return current < maxStep ||
        (_steps.indexOf(current) == -1 &&
            _steps.any((s) => s > current));
  }
}

// ---------------------------------------------------------------------------
// About section
// ---------------------------------------------------------------------------

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        color: colorScheme.surfaceContainerLow,
        child: Column(
          children: [
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.loop_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              title: Text(
                'Loop Timer',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              subtitle: Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
              ),
            ),

            Divider(
              indent: 20,
              endIndent: 20,
              color: colorScheme.outlineVariant.withOpacity(0.4),
              height: 1,
            ),

            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Icon(
                Icons.lock_outline_rounded,
                color: colorScheme.secondary,
                size: 22,
              ),
              title: Text(
                'Fully offline',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              subtitle: Text(
                'No data leaves your device',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
              ),
            ),

            Divider(
              indent: 20,
              endIndent: 20,
              color: colorScheme.outlineVariant.withOpacity(0.4),
              height: 1,
            ),

            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Icon(
                Icons.music_off_outlined,
                color: colorScheme.secondary,
                size: 22,
              ),
              title: Text(
                'No audio files required',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              subtitle: Text(
                'All tones generated on-device',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _SettingLabel extends StatelessWidget {
  const _SettingLabel({
    required this.label,
    required this.colorScheme,
    this.trailing,
  });

  final String label;
  final ColorScheme colorScheme;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.75),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onPressed,
    required this.colorScheme,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed != null
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: onPressed != null
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface.withOpacity(0.3),
            size: 22,
          ),
        ),
      ),
    );
  }
}
