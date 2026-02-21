import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:loop_timer/models/timer_config.dart';
import 'package:loop_timer/providers/saved_timers_provider.dart';
import 'package:loop_timer/providers/settings_provider.dart';
import 'package:loop_timer/providers/timer_provider.dart';
import 'package:loop_timer/services/audio_service.dart';
import 'package:loop_timer/widgets/timer_config_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<TimerConfigFormState>();

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _startTimer() {
    final config = _formKey.currentState?.value;
    if (config == null) return;

    final timerProvider = context.read<TimerProvider>();
    timerProvider.startTimer(config);
    Navigator.of(context).pushNamed('/timer', arguments: config);
  }

  Future<void> _saveTimer() async {
    final config = _formKey.currentState?.value;
    if (config == null) return;

    final savedProvider = context.read<SavedTimersProvider>();
    if (!savedProvider.canSaveMore) return;

    await savedProvider.addTimer(config);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${config.name}" saved!',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW',
          onPressed: () => Navigator.of(context).pushNamed('/saved'),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final cs = Theme.of(context).colorScheme;

        return Consumer<SavedTimersProvider>(
          builder: (context, savedProvider, _) {
            final canSave = savedProvider.canSaveMore;

            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  // --- App bar ---
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    expandedHeight: 120,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Loop Timer',
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                      titlePadding: const EdgeInsetsDirectional.only(
                        start: 20,
                        bottom: 14,
                      ),
                    ),
                    actions: [
                      // Saved timers shortcut
                      IconButton(
                        tooltip: 'Saved Timers',
                        icon: const Icon(Icons.bookmarks_rounded),
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/saved'),
                      ),
                      // Settings
                      IconButton(
                        tooltip: 'Settings',
                        icon: const Icon(Icons.settings_rounded),
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/settings'),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),

                  // --- Hero tagline ---
                  SliverToBoxAdapter(
                    child: _HeroTagline(accentColor: cs.primary),
                  ),

                  // --- Form ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: TimerConfigForm(
                            key: _formKey,
                            onPreviewTone: (id) => context
                                .read<AudioService>()
                                .previewTone(id),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.05, end: 0, duration: 400.ms),
                  ),

                  // --- Action buttons ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      child: _ActionButtons(
                        canSave: canSave,
                        onStart: _startTimer,
                        onSave: _saveTimer,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 350.ms)
                        .slideY(begin: 0.05, end: 0, duration: 400.ms),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Hero tagline section
// ---------------------------------------------------------------------------

class _HeroTagline extends StatelessWidget {
  const _HeroTagline({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated loop icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(26),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withAlpha(76), width: 2),
            ),
            child: Icon(
              Icons.loop_rounded,
              color: accentColor,
              size: 30,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .rotate(
                begin: 0,
                end: 1,
                duration: 6000.ms,
                curve: Curves.linear,
              ),

          const SizedBox(width: 16),

          // Tagline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Repeat. Focus. Improve.',
                  style: tt.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure your timer below and hit Start.',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideX(begin: -0.04, end: 0, duration: 500.ms);
  }
}

// ---------------------------------------------------------------------------
// Action buttons row
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.canSave,
    required this.onStart,
    required this.onSave,
  });

  final bool canSave;
  final VoidCallback onStart;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Start Timer — primary CTA
        ElevatedButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow_rounded, size: 22),
          label: const Text('Start Timer'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: Theme.of(context)
                .elevatedButtonTheme
                .style
                ?.textStyle
                ?.resolve({}) ??
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),

        const SizedBox(height: 12),

        // Save Timer — secondary action
        Tooltip(
          message: canSave
              ? 'Save this timer for later'
              : 'Saved timers limit reached',
          child: OutlinedButton.icon(
            onPressed: canSave ? onSave : null,
            icon: Icon(
              Icons.bookmark_add_rounded,
              size: 20,
              color: canSave ? cs.primary : cs.onSurface.withAlpha(76),
            ),
            label: Text(
              'Save Timer',
              style: TextStyle(
                color: canSave ? cs.primary : cs.onSurface.withAlpha(76),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: canSave
                    ? cs.primary.withAlpha(178)
                    : cs.onSurface.withAlpha(51),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
