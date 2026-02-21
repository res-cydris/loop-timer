import 'package:flutter/foundation.dart';
import 'package:loop_timer/models/timer_config.dart';
import 'package:loop_timer/providers/settings_provider.dart';
import 'package:loop_timer/services/storage_service.dart';

/// Manages the user's saved [TimerConfig] list and persists it via
/// [StorageService].
///
/// The list order is user-controlled and preserved across app restarts.
/// Every mutation immediately persists the updated list to storage.
class SavedTimersProvider extends ChangeNotifier {
  final StorageService _storage;
  final SettingsProvider _settingsProvider;

  List<TimerConfig> _timers = [];

  SavedTimersProvider(this._storage, this._settingsProvider);

  // ---------------------------------------------------------------------------
  // Public getters
  // ---------------------------------------------------------------------------

  /// The current list of saved timers in user-defined order.
  List<TimerConfig> get savedTimers => List.unmodifiable(_timers);

  /// Whether additional timers can be saved without exceeding the cap defined
  /// in [AppSettings.maxSavedTimers].
  bool get canSaveMore =>
      _timers.length < _settingsProvider.settings.maxSavedTimers;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Loads saved timers from persistent storage.
  ///
  /// Should be called once at app startup.  Falls back to an empty list on any
  /// error so the app remains usable without stored data.
  Future<void> load() async {
    try {
      _timers = await _storage.loadSavedTimers();
    } catch (_) {
      _timers = [];
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Adds [config] to the saved list if the cap has not been reached.
  ///
  /// Silently ignores the call when [canSaveMore] is false.
  Future<void> addTimer(TimerConfig config) async {
    if (!canSaveMore) return;
    _timers = [..._timers, config];
    notifyListeners();
    await _persist();
  }

  /// Replaces the timer whose [TimerConfig.id] matches [config.id].
  ///
  /// Silently ignores the call when no matching timer is found.
  Future<void> updateTimer(TimerConfig config) async {
    final index = _timers.indexWhere((t) => t.id == config.id);
    if (index == -1) return;

    final updated = List<TimerConfig>.from(_timers);
    updated[index] = config;
    _timers = updated;
    notifyListeners();
    await _persist();
  }

  /// Removes the timer with the given [id].
  ///
  /// Silently ignores the call when no matching timer is found.
  Future<void> deleteTimer(String id) async {
    final updated = _timers.where((t) => t.id != id).toList();
    if (updated.length == _timers.length) return; // nothing removed
    _timers = updated;
    notifyListeners();
    await _persist();
  }

  /// Moves a timer from [oldIndex] to [newIndex] (same semantics as
  /// `ReorderableListView` — [newIndex] is the target position *before* the
  /// item is removed from [oldIndex]).
  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < 0 ||
        oldIndex >= _timers.length ||
        newIndex < 0 ||
        newIndex > _timers.length ||
        oldIndex == newIndex) {
      return;
    }

    final updated = List<TimerConfig>.from(_timers);
    final item = updated.removeAt(oldIndex);

    // After removal the target index may shift by one.
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    updated.insert(insertAt, item);

    _timers = updated;
    notifyListeners();
    await _persist();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _persist() async {
    await _storage.saveSavedTimers(_timers);
  }
}
