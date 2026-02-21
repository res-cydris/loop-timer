import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:loop_timer/models/timer_config.dart';
import 'package:loop_timer/providers/saved_timers_provider.dart';
import 'package:loop_timer/providers/settings_provider.dart';
import 'package:loop_timer/providers/timer_provider.dart';
import 'package:loop_timer/services/audio_service.dart';
import 'package:loop_timer/widgets/timer_config_form.dart';

class SavedTimersScreen extends StatelessWidget {
  const SavedTimersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, _, __) {
        return Consumer<SavedTimersProvider>(
          builder: (context, savedProvider, _) {
            final timers = savedProvider.savedTimers;
            final max = context
                .read<SettingsProvider>()
                .settings
                .maxSavedTimers;
            final count = timers.length;

            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  // --- App bar ---
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    backgroundColor:
                        Theme.of(context).scaffoldBackgroundColor,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Saved Timers',
                          style: Theme.of(context).appBarTheme.titleTextStyle,
                        ),
                        Text(
                          '$count / $max',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(153),
                              ),
                        ),
                      ],
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  // --- Body ---
                  if (timers.isEmpty)
                    const SliverFillRemaining(
                      child: _EmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      sliver: _TimerList(
                        timers: timers,
                        savedProvider: savedProvider,
                      ),
                    ),
                ],
              ),

              // --- FAB: add new (navigates back to home) ---
              floatingActionButton: Tooltip(
                message: savedProvider.canSaveMore
                    ? 'Create a new timer'
                    : 'Limit of $max timers reached',
                child: FloatingActionButton.extended(
                  onPressed: savedProvider.canSaveMore
                      ? () => Navigator.of(context).pop()
                      : null,
                  backgroundColor: savedProvider.canSaveMore
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withAlpha(51),
                  foregroundColor: savedProvider.canSaveMore
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface.withAlpha(102),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New Timer'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Reorderable list
// ---------------------------------------------------------------------------

class _TimerList extends StatelessWidget {
  const _TimerList({
    required this.timers,
    required this.savedProvider,
  });

  final List<TimerConfig> timers;
  final SavedTimersProvider savedProvider;

  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
      itemCount: timers.length,
      onReorder: (oldIndex, newIndex) =>
          savedProvider.reorder(oldIndex, newIndex),
      itemBuilder: (context, index) {
        final timer = timers[index];
        return _DismissibleTimerTile(
          key: ValueKey(timer.id),
          timer: timer,
          index: index,
          savedProvider: savedProvider,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Dismissible + tile
// ---------------------------------------------------------------------------

class _DismissibleTimerTile extends StatelessWidget {
  const _DismissibleTimerTile({
    super.key,
    required this.timer,
    required this.index,
    required this.savedProvider,
  });

  final TimerConfig timer;
  final int index;
  final SavedTimersProvider savedProvider;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey('dismiss_${timer.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cs.error.withAlpha(204),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_rounded, color: cs.onError, size: 28),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: cs.onError,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Timer?'),
            content: Text(
              'Remove "${timer.name}" from your saved timers?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(backgroundColor: cs.error),
                child: Text(
                  'Delete',
                  style: TextStyle(color: cs.onError),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        savedProvider.deleteTimer(timer.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${timer.name}" deleted'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: ReorderableDelayedDragStartListener(
        index: index,
        child: _TimerTile(timer: timer, savedProvider: savedProvider),
      )
          .animate()
          .fadeIn(duration: 300.ms, delay: (index * 50).ms)
          .slideY(begin: 0.04, end: 0, duration: 300.ms),
    );
  }
}

// ---------------------------------------------------------------------------
// Timer list tile
// ---------------------------------------------------------------------------

class _TimerTile extends StatelessWidget {
  const _TimerTile({required this.timer, required this.savedProvider});

  final TimerConfig timer;
  final SavedTimersProvider savedProvider;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openEditSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Accent dot
              Container(
                width: 6,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timer.name,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _durationLabel(timer),
                      style: tt.bodyMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _repeatLabel(timer),
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ),

              // Drag handle
              Icon(
                Icons.drag_handle_rounded,
                color: cs.onSurface.withAlpha(102),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _durationLabel(TimerConfig t) {
    final s = t.durationSeconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    final parts = <String>[];
    if (h > 0) parts.add('${h}h');
    if (m > 0) parts.add('${m}m');
    if (sec > 0 || parts.isEmpty) parts.add('${sec}s');
    return parts.join(' ');
  }

  String _repeatLabel(TimerConfig t) {
    if (t.infiniteRepeat) return 'Loops forever';
    if (t.repeatCount == 1) return 'Runs once';
    final delayPart =
        t.delaySeconds > 0 ? ' · ${t.delaySeconds}s delay' : '';
    return '${t.repeatCount} reps$delayPart';
  }

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _EditTimerSheet(
        timer: timer,
        savedProvider: savedProvider,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit bottom sheet
// ---------------------------------------------------------------------------

class _EditTimerSheet extends StatefulWidget {
  const _EditTimerSheet({required this.timer, required this.savedProvider});

  final TimerConfig timer;
  final SavedTimersProvider savedProvider;

  @override
  State<_EditTimerSheet> createState() => _EditTimerSheetState();
}

class _EditTimerSheetState extends State<_EditTimerSheet> {
  final _formKey = GlobalKey<TimerConfigFormState>();

  Future<void> _update() async {
    final formState = _formKey.currentState;
    if (formState == null) return;

    // Preserve the original id so the update replaces rather than appends.
    final updated = formState.value.copyWith(id: widget.timer.id);
    await widget.savedProvider.updateTimer(updated);

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${updated.name}" updated'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _start() {
    final formState = _formKey.currentState;
    if (formState == null) return;

    final config = formState.value.copyWith(id: widget.timer.id);
    final timerProvider = context.read<TimerProvider>();
    timerProvider.startTimer(config);
    Navigator.of(context).pop(); // close sheet
    Navigator.of(context).pushNamed('/timer', arguments: config);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withAlpha(76),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Title row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Edit Timer',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable form
            Expanded(
              child: ListView(
                controller: scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  TimerConfigForm(
                    key: _formKey,
                    initialValue: widget.timer,
                    onPreviewTone: (id) => context
                        .read<AudioService>()
                        .previewTone(id),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      // Start
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _start,
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: const Text('Start'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                                color: cs.primary.withAlpha(178), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Update
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _update,
                          icon:
                              const Icon(Icons.save_rounded, size: 20),
                          label: const Text('Update Timer'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 72,
              color: cs.onSurface.withAlpha(76),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1,
                  end: 1.08,
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 20),
            Text(
              'No saved timers yet',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurface.withAlpha(153),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a timer on the home screen\nand tap "Save Timer" to add it here.',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface.withAlpha(102),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.06, end: 0, duration: 500.ms);
  }
}
