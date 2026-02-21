import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:loop_timer/providers/settings_provider.dart';
import 'package:loop_timer/theme/app_themes.dart';

// Screen imports — the UI layer is owned by a separate agent.
import 'package:loop_timer/screens/home_screen.dart';
import 'package:loop_timer/screens/timer_running_screen.dart';
import 'package:loop_timer/screens/saved_timers_screen.dart';
import 'package:loop_timer/screens/settings_screen.dart';

/// Root widget of the Loop Timer application.
///
/// Watches [SettingsProvider] so the theme updates reactively whenever the
/// user changes it in the settings screen without requiring an app restart.
class LoopTimerApp extends StatelessWidget {
  const LoopTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final themeId = settingsProvider.settings.themeId;

        return MaterialApp(
          title: 'Loop Timer',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.themeData(themeId),
          initialRoute: '/',
          routes: {
            '/': (_) => const HomeScreen(),
            '/timer': (_) => const TimerRunningScreen(),
            '/saved': (_) => const SavedTimersScreen(),
            '/settings': (_) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
