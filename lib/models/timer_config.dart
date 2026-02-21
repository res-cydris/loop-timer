import 'package:uuid/uuid.dart';

/// Tone identifiers bundled with the app (generated programmatically).
/// Values must match keys in AudioService.toneOptions.
class ToneIds {
  static const String beep = 'beep';
  static const String chime = 'chime';
  static const String bell = 'bell';
  static const String alarm = 'alarm';
  static const String gentle = 'gentle';
  static const String buzz = 'buzz';
  static const String digital = 'digital';

  static const List<String> all = [beep, chime, bell, alarm, gentle, buzz, digital];

  static String label(String id) {
    const labels = {
      beep: 'Beep',
      chime: 'Chime',
      bell: 'Bell',
      alarm: 'Alarm',
      gentle: 'Gentle',
      buzz: 'Buzz',
      digital: 'Digital',
    };
    return labels[id] ?? id;
  }
}

/// Timer states during an active session.
enum TimerState { idle, running, paused, delay, completed }

/// A single saved timer configuration.
class TimerConfig {
  final String id;
  final String name;

  /// Total countdown duration in seconds.
  final int durationSeconds;

  /// If true, repeats indefinitely (repeatCount ignored).
  final bool infiniteRepeat;

  /// How many times to repeat (1 = no repeat, just one run).
  final int repeatCount;

  /// Seconds of silence between repetitions (0 = immediate).
  final int delaySeconds;

  /// Tone identifier from [ToneIds].
  final String toneId;

  /// Audio volume 0.0–1.0.
  final double volume;

  /// When this config was created/saved.
  final DateTime createdAt;

  const TimerConfig({
    required this.id,
    required this.name,
    required this.durationSeconds,
    this.infiniteRepeat = false,
    this.repeatCount = 1,
    this.delaySeconds = 0,
    this.toneId = ToneIds.beep,
    this.volume = 0.7,
    required this.createdAt,
  });

  factory TimerConfig.create({
    String? name,
    int durationSeconds = 60,
    bool infiniteRepeat = false,
    int repeatCount = 1,
    int delaySeconds = 0,
    String toneId = ToneIds.beep,
    double volume = 0.7,
  }) {
    return TimerConfig(
      id: const Uuid().v4(),
      name: name ?? 'Timer',
      durationSeconds: durationSeconds,
      infiniteRepeat: infiniteRepeat,
      repeatCount: repeatCount,
      delaySeconds: delaySeconds,
      toneId: toneId,
      volume: volume,
      createdAt: DateTime.now(),
    );
  }

  TimerConfig copyWith({
    String? id,
    String? name,
    int? durationSeconds,
    bool? infiniteRepeat,
    int? repeatCount,
    int? delaySeconds,
    String? toneId,
    double? volume,
    DateTime? createdAt,
  }) {
    return TimerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      infiniteRepeat: infiniteRepeat ?? this.infiniteRepeat,
      repeatCount: repeatCount ?? this.repeatCount,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      toneId: toneId ?? this.toneId,
      volume: volume ?? this.volume,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'durationSeconds': durationSeconds,
        'infiniteRepeat': infiniteRepeat,
        'repeatCount': repeatCount,
        'delaySeconds': delaySeconds,
        'toneId': toneId,
        'volume': volume,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TimerConfig.fromJson(Map<String, dynamic> json) => TimerConfig(
        id: json['id'] as String,
        name: json['name'] as String,
        durationSeconds: json['durationSeconds'] as int,
        infiniteRepeat: json['infiniteRepeat'] as bool? ?? false,
        repeatCount: json['repeatCount'] as int? ?? 1,
        delaySeconds: json['delaySeconds'] as int? ?? 0,
        toneId: json['toneId'] as String? ?? ToneIds.beep,
        volume: (json['volume'] as num?)?.toDouble() ?? 0.7,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TimerConfig && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TimerConfig($name, ${durationSeconds}s, repeat=$repeatCount)';
}
