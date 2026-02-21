import 'dart:convert';

import 'package:loop_timer/models/app_settings.dart';
import 'package:loop_timer/models/timer_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys used for SharedPreferences storage.
const String _kSavedTimers = 'saved_timers';
const String _kAppSettings = 'app_settings';

/// Handles all persistent storage using [SharedPreferences].
///
/// Timers and settings are each serialised as a single JSON string so that
/// reading / writing is a single atomic prefs operation per entity type.
class StorageService {
  final SharedPreferences _prefs;

  const StorageService(this._prefs);

  // ---------------------------------------------------------------------------
  // Saved timers
  // ---------------------------------------------------------------------------

  /// Loads the persisted list of [TimerConfig] objects.
  ///
  /// Returns an empty list if nothing has been saved yet or if decoding fails.
  Future<List<TimerConfig>> loadSavedTimers() async {
    try {
      final raw = _prefs.getString(_kSavedTimers);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(TimerConfig.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists [timers] to storage, replacing any previously saved list.
  Future<void> saveSavedTimers(List<TimerConfig> timers) async {
    try {
      final encoded = jsonEncode(timers.map((t) => t.toJson()).toList());
      await _prefs.setString(_kSavedTimers, encoded);
    } catch (_) {
      // Silently ignore write failures; the in-memory state remains correct.
    }
  }

  // ---------------------------------------------------------------------------
  // App settings
  // ---------------------------------------------------------------------------

  /// Loads persisted [AppSettings].
  ///
  /// Returns a default [AppSettings] instance if nothing has been saved yet or
  /// if decoding fails.
  Future<AppSettings> loadSettings() async {
    try {
      final raw = _prefs.getString(_kAppSettings);
      if (raw == null || raw.isEmpty) return const AppSettings();

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const AppSettings();

      return AppSettings.fromJson(decoded);
    } catch (_) {
      return const AppSettings();
    }
  }

  /// Persists [settings] to storage.
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final encoded = jsonEncode(settings.toJson());
      await _prefs.setString(_kAppSettings, encoded);
    } catch (_) {
      // Silently ignore write failures.
    }
  }
}
