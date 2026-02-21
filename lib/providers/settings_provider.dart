import 'package:flutter/foundation.dart';
import 'package:loop_timer/models/app_settings.dart';
import 'package:loop_timer/services/storage_service.dart';

/// Manages and persists [AppSettings] for the whole application.
///
/// Screens and widgets read settings via `context.watch<SettingsProvider>()`.
/// Mutations go through the typed update methods which each persist
/// immediately after applying the change.
class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  AppSettings _settings = const AppSettings();

  SettingsProvider(this._storage);

  // ---------------------------------------------------------------------------
  // Public getters
  // ---------------------------------------------------------------------------

  /// The current application settings.
  AppSettings get settings => _settings;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Loads settings from persistent storage.
  ///
  /// Should be called once during app startup (before [runApp] or in a
  /// `FutureBuilder`). Falls back to [AppSettings] defaults on any error.
  Future<void> load() async {
    try {
      _settings = await _storage.loadSettings();
    } catch (_) {
      _settings = const AppSettings();
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mutations — each applies the change and persists immediately
  // ---------------------------------------------------------------------------

  /// Changes the active UI theme.
  Future<void> updateTheme(String themeId) async {
    _settings = _settings.copyWith(themeId: themeId);
    notifyListeners();
    await _storage.saveSettings(_settings);
  }

  /// Updates the default volume used when creating new timers.
  Future<void> updateDefaultVolume(double v) async {
    final clamped = v.clamp(0.0, 1.0);
    _settings = _settings.copyWith(defaultVolume: clamped);
    notifyListeners();
    await _storage.saveSettings(_settings);
  }

  /// Updates the default tone used when creating new timers.
  Future<void> updateDefaultTone(String toneId) async {
    _settings = _settings.copyWith(defaultToneId: toneId);
    notifyListeners();
    await _storage.saveSettings(_settings);
  }

  /// Updates the cap on how many timers may be saved.
  ///
  /// [n] is clamped to the range 1–100 to avoid nonsensical values.
  Future<void> updateMaxSavedTimers(int n) async {
    final clamped = n.clamp(1, 100);
    _settings = _settings.copyWith(maxSavedTimers: clamped);
    notifyListeners();
    await _storage.saveSettings(_settings);
  }
}
