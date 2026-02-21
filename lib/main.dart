import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:loop_timer/app.dart';
import 'package:loop_timer/services/audio_service.dart';
import 'package:loop_timer/services/storage_service.dart';
import 'package:loop_timer/providers/settings_provider.dart';
import 'package:loop_timer/providers/saved_timers_provider.dart';
import 'package:loop_timer/providers/timer_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise shared infrastructure before the widget tree is built.
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  final audioService = AudioService();

  // Pre-load settings and saved timers so providers are hydrated before the
  // first frame is painted.
  final settingsProvider = SettingsProvider(storageService);
  await settingsProvider.load();

  final savedTimersProvider =
      SavedTimersProvider(storageService, settingsProvider);
  await savedTimersProvider.load();

  runApp(
    MultiProvider(
      providers: [
        // Expose AudioService so screens (e.g. SettingsScreen) can obtain it
        // via Provider.of<AudioService>(context, listen: false).
        Provider<AudioService>.value(value: audioService),

        // Settings must be above SavedTimersProvider because the latter reads
        // AppSettings.maxSavedTimers from it.
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
        ),
        ChangeNotifierProvider<SavedTimersProvider>.value(
          value: savedTimersProvider,
        ),
        ChangeNotifierProvider<TimerProvider>(
          create: (_) => TimerProvider(audioService),
        ),
      ],
      child: const LoopTimerApp(),
    ),
  );
}
