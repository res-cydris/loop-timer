import 'timer_config.dart';

/// Theme identifiers.
class ThemeIds {
  static const String dark = 'dark';
  static const String light = 'light';
  static const String retro = 'retro';
  static const String rgb = 'rgb';
  static const String colorblind = 'colorblind';
  static const String futuristic = 'futuristic';
  static const String modern = 'modern';

  static const List<String> all = [
    dark,
    light,
    modern,
    retro,
    rgb,
    futuristic,
    colorblind,
  ];

  static String label(String id) {
    const labels = {
      dark: 'Dark',
      light: 'Light',
      modern: 'Modern',
      retro: 'Retro',
      rgb: 'RGB',
      futuristic: 'Futuristic',
      colorblind: 'Colorblind',
    };
    return labels[id] ?? id;
  }

  static String description(String id) {
    const desc = {
      dark: 'Easy on the eyes',
      light: 'Clean & bright',
      modern: 'Minimal & elegant',
      retro: 'Vintage CRT glow',
      rgb: 'Gaming rainbow',
      futuristic: 'Sci-fi holographic',
      colorblind: 'High-contrast accessible',
    };
    return desc[id] ?? '';
  }
}

/// App-wide settings persisted to local storage.
class AppSettings {
  /// Active theme from [ThemeIds].
  final String themeId;

  /// Default audio volume 0.0–1.0 for new timers.
  final double defaultVolume;

  /// Default tone for new timers.
  final String defaultToneId;

  /// Maximum number of saved timers (default 10).
  final int maxSavedTimers;

  const AppSettings({
    this.themeId = ThemeIds.dark,
    this.defaultVolume = 0.7,
    this.defaultToneId = ToneIds.beep,
    this.maxSavedTimers = 10,
  });

  AppSettings copyWith({
    String? themeId,
    double? defaultVolume,
    String? defaultToneId,
    int? maxSavedTimers,
  }) {
    return AppSettings(
      themeId: themeId ?? this.themeId,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      defaultToneId: defaultToneId ?? this.defaultToneId,
      maxSavedTimers: maxSavedTimers ?? this.maxSavedTimers,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeId': themeId,
        'defaultVolume': defaultVolume,
        'defaultToneId': defaultToneId,
        'maxSavedTimers': maxSavedTimers,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        themeId: json['themeId'] as String? ?? ThemeIds.dark,
        defaultVolume: (json['defaultVolume'] as num?)?.toDouble() ?? 0.7,
        defaultToneId: json['defaultToneId'] as String? ?? ToneIds.beep,
        maxSavedTimers: json['maxSavedTimers'] as int? ?? 10,
      );
}
