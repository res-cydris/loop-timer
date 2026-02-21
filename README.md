# Loop Timer

A beautiful, fully offline repeatable countdown timer app for iOS and Android, built with Flutter.

## Features

- **Repeatable timers** — single-shot or N reps or infinite loop
- **Rep delay** — optional silence between repetitions (0–300 s)
- **10 saved presets** — name, configure and save up to 10 timers (limit adjustable in settings)
- **7 themes** — Dark, Light, Modern, Retro, RGB, Futuristic, Colorblind-friendly
- **7 tones** — Beep, Chime, Bell, Alarm, Gentle, Buzz, Digital (all synthesised on-device — no audio files)
- **Per-timer volume** — 0–100 % volume control
- **100 % offline** — all data stays on your device; no network permission required
- **Portrait + landscape** — adaptive layout on the timer screen

## Getting started

### Prerequisites

- Flutter SDK ≥ 3.2
- Dart SDK ≥ 3.2

### Install & run

```bash
cd loop_timer
flutter pub get
flutter run
```

### Build release

```bash
# Android APK
flutter build apk --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

## Project structure

```
lib/
├── main.dart                     # App entry point
├── app.dart                      # MaterialApp + routing
├── models/
│   ├── timer_config.dart         # TimerConfig data class, ToneIds, TimerState
│   └── app_settings.dart         # AppSettings, ThemeIds
├── services/
│   ├── timer_service.dart        # Pure-Dart countdown + repeat + delay logic
│   ├── storage_service.dart      # SharedPreferences persistence
│   └── audio_service.dart        # Programmatic WAV tone generator + playback
├── providers/
│   ├── timer_provider.dart       # ChangeNotifier wrapping TimerService
│   ├── saved_timers_provider.dart# Saved timer CRUD
│   └── settings_provider.dart    # App-wide settings
├── theme/
│   └── app_themes.dart           # ThemeData for all 7 themes
├── widgets/
│   ├── circular_timer.dart       # Custom-painted countdown ring
│   ├── timer_config_form.dart    # Duration / repeat / tone / volume form
│   ├── tone_picker.dart          # Horizontal tone selector
│   ├── volume_slider.dart        # Styled volume slider
│   └── theme_card.dart           # Theme selection card with color swatch
└── screens/
    ├── home_screen.dart          # Quick-start + save timer
    ├── timer_running_screen.dart # Active timer with animated ring
    ├── saved_timers_screen.dart  # Saved presets list
    └── settings_screen.dart      # Theme, audio, storage settings
```

## Dependencies

| Package | Purpose |
|---|---|
| `provider` | State management |
| `shared_preferences` | Local data persistence |
| `audioplayers` | WAV byte playback |
| `uuid` | Unique timer IDs |
| `flutter_animate` | Entrance animations |
| `google_fonts` | Theme typography |
